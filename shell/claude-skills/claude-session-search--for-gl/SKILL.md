---
name: claude-session-search--for-gl
description: 在 ~/.claude/projects 裡用純文字搜尋過往的 Claude Code 討論串. 預設只搜尋當前 project ( 6 筆 ), 找不到時自動 fallback 到所有 projects. 使用者要求搜尋全部時可直接加 --all 旗標. 每筆結果會附上可複製的 `claude --resume` 指令
allowed-tools: Bash
---

# Claude Session Search

協助使用者搜尋過往的 Claude Code 討論串, 找到相似內容的 session, 並給出可直接復原該 session 的指令

## 使用情境

使用者想回到先前某次 Claude Code 討論, 但不記得是哪一個 session, 只記得對話中提到的某個關鍵字

## 輸入

使用者會提供一個純文字關鍵字. 如果沒提供, 請先向使用者詢問

## 執行步驟

1. 取得關鍵字 ( 來自使用者輸入, 為純文字, 不是 regex )
2. 判斷搜尋範圍:
   - 預設: 只搜尋當前 project. 如果 0 筆, 腳本會自動 fallback 到所有 projects
   - 若使用者明確提到「所有 project」, 「全部專案」, 「所有討論串」, 「global」, 「全域」等字眼, 直接加上 `--all` 旗標
3. 執行 skill 目錄下的搜尋腳本:
   ```bash
   # 預設 ( 當前 project, 0 筆時自動 fallback 到所有 projects )
   bash ~/.claude/skills/claude-session-search--for-gl/scripts/search.sh "<keyword>"

   # 明確要求搜尋所有 projects
   bash ~/.claude/skills/claude-session-search--for-gl/scripts/search.sh --all "<keyword>"
   ```
4. 將腳本輸出「原樣」呈現給使用者, 不要改寫, 不要摘要, 不要重新排版. 因為結果中的 `claude --resume ...` 指令需要讓使用者直接複製貼上

## 腳本行為說明

- 兩種模式都最多顯示 6 筆, 依檔案修改時間 ( mtime ) 由新到舊排序
- 當前 project 模式 Resume 指令: `claude --resume <id>`
- 所有 projects 模式 Resume 指令: `cd <project-path> && claude --resume <id>`
- 每筆結果包含: 序號 + 相對時間 + Resume 指令 (同一行), Title (第一則 user message), Match (最多 3 個命中位置, 每處關鍵字前後 60 字)

## 注意事項

- 如果腳本回報「No matches in any project」, 直接告知使用者, 不要自行再去 grep
- 不要代替使用者執行 `claude --resume`. 只要印出指令即可
- 若關鍵字含有特殊字元 ( 空白, 引號, `$` 等 ), 呼叫腳本時請用雙引號包住整個關鍵字
