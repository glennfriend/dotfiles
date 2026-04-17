#!/usr/bin/env bash
# 以純文字關鍵字搜尋過往的 Claude Code 討論串
#
# 預設:  只搜尋當前 project, 最多 6 筆
#        如果當前 project 0 筆, 自動 fallback 到所有 projects
# --all: 強制搜尋所有 projects, 最多 6 筆
#
# 兩種模式的 Resume 指令格式不同:
#   當前 project : claude --resume <id>
#   所有 projects: cd <project-path> && claude --resume <id>
#
# 搜尋會先用 jq 把 JSONL 的每筆事件展開成純文字再比對,
# 這樣 UUID, 內部結構, API usage token 之類的 JSON 雜訊不會干擾命中.
# 同時過濾 slash-command 的 meta frame ( <command-name>, <command-args>... )
# 避免「搜尋指令自己」互相命中.

set -uo pipefail

LIMIT=6
SCOPE="local"      # local | global

# 解析旗標
if [ "${1:-}" = "--all" ] || [ "${1:-}" = "-a" ]; then
  SCOPE="global"
  shift
fi

KEYWORD="${1:-}"
if [ -z "$KEYWORD" ]; then
  echo "Usage: $0 [--all|-a] <keyword>" >&2
  exit 1
fi

PROJECTS_DIR="$HOME/.claude/projects"
CURRENT_PWD="$(pwd)"
# Claude Code 把 cwd 的 `/` 編碼為 `-` 當作資料夾名稱
CURRENT_ENCODED="$(echo "$CURRENT_PWD" | sed 's|/|-|g')"
CURRENT_DIR="$PROJECTS_DIR/$CURRENT_ENCODED"

if [ ! -d "$PROJECTS_DIR" ]; then
  echo "No Claude projects directory found at $PROJECTS_DIR" >&2
  exit 1
fi

# --- Helpers --------------------------------------------------------------

# 跨平台取得檔案 mtime ( Linux GNU stat, macOS fallback 到 BSD stat )
mtime_of() {
  stat -c %Y "$1" 2>/dev/null || stat -f %m "$1" 2>/dev/null
}

# 相對時間 ( 秒 / 分 / 時 / 天 ), 簡短格式如 13s, 2h, 4d
rel_time() {
  local ts="$1" now diff
  now=$(date +%s)
  diff=$(( now - ts ))
  if   [ "$diff" -lt 60    ]; then echo "${diff}s"
  elif [ "$diff" -lt 3600  ]; then echo "$((diff/60))m"
  elif [ "$diff" -lt 86400 ]; then echo "$((diff/3600))h"
  else                             echo "$((diff/86400))d"
  fi
}

# 從 JSONL 的 `.cwd` 取 project 路徑, 比反解資料夾名安全
get_cwd() {
  jq -r 'select(.cwd != null) | .cwd' "$1" 2>/dev/null | awk 'NF' | /usr/bin/head -n 1
}

# 從 JSONL 把每筆事件展開成一行可讀純文字. 從 stdin 讀, 輸出到 stdout
# - 只保留 user / assistant 事件, 排除 isMeta 事件
# - 過濾 slash-command 的 meta frame ( <command-name> / <command-args> 等 )
# - content 可能是 string 或 array; array 展開 text / tool_use / tool_result
# - 連續 whitespace 壓成單一空白, 讓 snippet 顯示不會跳行
extract_text() {
  jq -r '
    select(.isMeta != true and (.type == "user" or .type == "assistant")) |
    .message.content as $c |
    (if   ($c | type) == "string" then $c
     elif ($c | type) == "array"  then
       ($c | map(
         if   .type == "text"        then (.text // "")
         elif .type == "tool_use"    then ((.name // "") + " " + (.input | tostring))
         elif .type == "tool_result" then
           (if   (.content | type) == "string" then .content
            elif (.content | type) == "array"  then
              (.content | map(.text // "") | join(" "))
            else "" end)
         else "" end
       ) | join(" "))
     else "" end) as $text |
    select(($text | length) > 0) |
    select($text | test("<command-(name|message|args|stdout|stderr)>") | not) |
    # 排除呼叫這個 skill 本身的 Bash tool_use / tool_result,
    # 否則每次執行搜尋, 當前 session 的記錄都會命中自己
    select($text | test("claude-session-search--for-gl/scripts/search\\.sh") | not) |
    ($text | gsub("[[:space:]]+"; " "))
  ' 2>/dev/null
}

# 取第一則人類 user message 當標題 ( 過濾 meta frame 後 )
first_user_msg() {
  jq -r '
    select(.isMeta != true and .type=="user" and (.message.role // "") == "user") |
    .message.content as $c |
    (if   ($c | type) == "string" then $c
     elif ($c | type) == "array"  then
       ($c | map(select(.type=="text") | .text // "") | join(" "))
     else ""
     end) as $text |
    select(($text | length) > 0) |
    select($text | test("<command-(name|message|args|stdout|stderr)>") | not) |
    $text
  ' "$1" 2>/dev/null | awk 'NF' | /usr/bin/head -n 1 | cut -c1-100
}

# 最多 3 個命中位置, 每處關鍵字前後各 60 字. 輸入為 extract_text 輸出
match_snippets() {
  local file="$1" kw="$2"
  extract_text < "$file" | \
    grep -F -i -m 3 -- "$kw" | \
    awk -v kw="$kw" '
    {
      line = $0
      lc_line = tolower(line); lc_kw = tolower(kw)
      idx = index(lc_line, lc_kw)
      if (idx > 0) {
        # 關鍵字前後各 40 字, 總長 ~80 字 + 關鍵字, 讓每筆 Match 寬度一致
        start = idx - 40; if (start < 1) start = 1
        show_len = length(kw) + 80
        s = substr(line, start, show_len)
        prefix = (start > 1) ? "..." : ""
        suffix = (start + show_len - 1 < length(line)) ? "..." : ""
        print prefix s suffix
      }
    }'
}

# 蒐集候選檔案: raw grep 快速找出可能命中檔, 依 mtime 由新到舊
# 注意: 這裡 raw grep 可能命中 UUID / API 結構等假陽性,
#       實際列印時會透過 extract_text 再驗證一次 ( 無命中則略過 )
list_candidates() {
  local files
  files="$(grep -l -F -i -r --include='*.jsonl' -- "$KEYWORD" "$@" 2>/dev/null || true)"
  [ -z "$files" ] && return 0
  printf '%s\n' "$files" | while IFS= read -r f; do
    [ -f "$f" ] && printf '%s\t%s\n' "$(mtime_of "$f")" "$f"
  done | sort -rn | cut -f2-
}

# 將單筆結果格式化後 append 到 RESULT_BUFFER (全域變數)
# 回傳 0 表示有真實命中 (已 append), 1 表示過濾後無命中 (跳過)
#
# 格式:
#   [N] <rel-time>: <resume-cmd>
#       Title: <第一則 user message>
#       Match: <snippet 1>
#              <snippet 2>
#              <snippet 3>
format_result_if_real() {
  local rank="$1" file="$2" kw="$3" scope="$4"
  local snippets
  snippets="$(match_snippets "$file" "$kw")"
  [ -z "$snippets" ] && return 1

  local session_id title cwd ts rt resume_cmd
  session_id="$(basename "$file" .jsonl)"
  ts="$(mtime_of "$file")"
  rt="$(rel_time "$ts")"
  title="$(first_user_msg "$file")"

  if [ "$scope" = "global" ]; then
    cwd="$(get_cwd "$file")"; [ -z "$cwd" ] && cwd="(unknown)"
    resume_cmd="$(printf 'cd %q && claude --resume %s' "$cwd" "$session_id")"
  else
    resume_cmd="claude --resume $session_id"
  fi

  RESULT_BUFFER+="[${rank}] (${rt}) ${resume_cmd}"$'\n'
  [ -n "$title" ] && RESULT_BUFFER+="    Title: ${title}"$'\n'

  local i=0 line
  while IFS= read -r line; do
    [ -z "$line" ] && continue
    i=$((i+1))
    if [ "$i" -eq 1 ]; then
      RESULT_BUFFER+="    Match: ${line}"$'\n'
    else
      RESULT_BUFFER+="           ${line}"$'\n'
    fi
  done <<< "$snippets"

  RESULT_BUFFER+=$'\n'
  return 0
}

# 迭代候選檔, 累積最多 LIMIT 筆真實命中到 RESULT_BUFFER
# 回傳 PRINTED 個數 ( 透過全域變數 PRINTED_COUNT )
build_results() {
  local scope="$1"; shift
  local f next_rank
  PRINTED_COUNT=0
  RESULT_BUFFER=""
  for f in "$@"; do
    [ "$PRINTED_COUNT" -ge "$LIMIT" ] && break
    next_rank=$((PRINTED_COUNT+1))
    if format_result_if_real "$next_rank" "$f" "$KEYWORD" "$scope"; then
      PRINTED_COUNT=$next_rank
    fi
  done
}

# --- Main -----------------------------------------------------------------

printf "Keyword: %s\n\n" "$KEYWORD"

if [ "$SCOPE" = "local" ]; then
  if [ -d "$CURRENT_DIR" ]; then
    mapfile -t local_candidates < <(list_candidates "$CURRENT_DIR")
  else
    local_candidates=()
  fi

  if [ "${#local_candidates[@]}" -gt 0 ]; then
    build_results "local" "${local_candidates[@]}"
    if [ "$PRINTED_COUNT" -gt 0 ]; then
      printf "(scope: current project — %s)\n\n" "$CURRENT_PWD"
      printf '%s' "$RESULT_BUFFER"
      exit 0
    fi
  fi

  # Fallback: 當前 project 0 筆, 改搜所有 projects
  printf "No matches in current project. Falling back to all projects...\n\n"
  SCOPE="global"
fi

# Global search
mapfile -t global_candidates < <(list_candidates "$PROJECTS_DIR")
if [ "${#global_candidates[@]}" -gt 0 ]; then
  build_results "global" "${global_candidates[@]}"
  if [ "$PRINTED_COUNT" -gt 0 ]; then
    printf "(scope: all projects)\n\n"
    printf '%s' "$RESULT_BUFFER"
    exit 0
  fi
fi

printf "No matches in any project.\n"
