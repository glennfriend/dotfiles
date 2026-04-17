---
description: 擷取並分析 Reddit 內容. 方法一使用 Gemini CLI 透過 tmux 進行瀏覽, 摘要與複雜查詢. 方法二在 Gemini 無法使用時, 退回使用 curl 搭配 Reddit 公開 JSON API
allowed-tools: Bash, Read, Write
---

# Reddit Fetch

## 方法一: Gemini CLI (優先嘗試)

透過 tmux 使用 Gemini CLI. 它可以瀏覽, 摘要並回答關於 Reddit 內容的複雜問題

選一個唯一的 session 名稱 (例如 `gemini_abc123`), 並在整個流程中一致使用

### 設定

```bash
tmux new-session -d -s <session_name> -x 200 -y 50
tmux send-keys -t <session_name> 'gemini -m gemini-3-pro-preview' Enter
sleep 3  # 等待 Gemini CLI 載入
```

### 送出查詢並擷取輸出

```bash
tmux send-keys -t <session_name> 'Your Reddit query here' Enter
sleep 30  # 等待回應 (依需求調整, 複雜搜尋最多可到 90 秒)
tmux capture-pane -t <session_name> -p -S -500  # 擷取輸出
```

如果擷取到的輸出顯示 API 錯誤 (例如 quota 超量, 模型無法使用), 請關閉 session, 並去除 `-m` 參數重試 (直接執行 `gemini` 不帶任何 model 參數).
這會退回使用預設模型

### 如何判斷 Enter 是否已送出

請特別尋找你的查詢文字. 它是在框線框內還是框外?

**Enter 未送出** - 查詢文字在框內:
```
╭─────────────────────────────────────╮
│ > Your actual query text here       │
╰─────────────────────────────────────╯
```

**Enter 已送出** - 查詢文字在框外, 後面會接著活動訊息:
```
> Your actual query text here

⠋ Our hamsters are working... (processing)

╭────────────────────────────────────────────╮
│ >   Type your message or @path/to/file     │
╰────────────────────────────────────────────╯
```

注意: 空白提示 `Type your message or @path/to/file` 一定會出現在框內, 這是正常的. 重點是你的查詢文字是在框內還是框外

如果查詢文字還在框內, 請執行 `tmux send-keys -t <session_name> Enter` 送出

### 結束後清理

```bash
tmux kill-session -t <session_name>
```

### 如果 Gemini 完全無法使用

如果移除 `-m` 重試後仍然失敗, 請退回使用下方的方法二

---

## 方法二: 使用 curl 搭配 Reddit JSON API (Fallback)

Reddit 的公開 JSON API 使用方式是在任何 Reddit URL 後面加上 `.json`. 當 Gemini 無法使用時請使用此方法 (例如 quota 已用盡, API 錯誤等)

### 列出 hot / new / top 貼文

```bash
curl -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "https://old.reddit.com/r/SUBREDDIT/hot.json?limit=15"
```

依需求將 `hot` 替換為 `new`, `top` 或 `rising`. 使用 `top` 時可加上 `&t=day` (或 `week`, `month`, `year`, `all`)

### 擷取特定貼文與留言

```bash
curl -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "https://old.reddit.com/r/SUBREDDIT/comments/POST_ID.json?limit=20"
```

回應是一個 JSON 陣列: `[0]` 是貼文本體, `[1]` 是留言樹

### 在 subreddit 內搜尋

```bash
curl -s -L -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  "https://old.reddit.com/r/SUBREDDIT/search.json?q=QUERY&restrict_sr=on&sort=new&limit=15"
```

### 解析 JSON

使用 jq 擷取需要的欄位:

```bash
# 列出貼文
curl -s -L -o /tmp/reddit_result.txt -w "%{http_code}" \
  -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
  'https://old.reddit.com/r/SUBREDDIT/hot.json?limit=15'

jq -r '.data.children[] | .data | "\(.title)\n   \(.score) pts | \(.num_comments) comments | u/\(.author) | id: \(.id)\n"' /tmp/reddit_result.txt

# 列出特定貼文的留言 (陣列中的 [1] 元素是留言)
jq -r '.[1].data.children[] | select(.kind == "t1") | .data | "u/\(.author) (\(.score) pts):\n  \(.body[:300])\n"' /tmp/reddit_thread.txt
```

重點細節:
- 先把結果抓到暫存檔, 再解析, 可避免 pipe 造成的編碼問題
- `-o /tmp/file` 與 `-w "%{http_code}"` 會儲存回應並印出 HTTP 狀態碼 (在除錯空回應時很有用)
- `-L` 會跟隨 redirect (old.reddit.com 有時會 redirect)
- 使用單引號包住 URL 可避免 shell 解釋 query string 中的 `&`
- `.body[:300]` 截斷過長的留言內容 (需要 jq 1.7 以上)

### Rate limiting

Reddit 的 JSON API 會嚴格進行 rate limit:

- **不要發送平行請求**. 請依序發送, 每個請求之間加上 `sleep 2` 或 `sleep 3`
- 如果某次請求回傳空白 (0 bytes), 請等待 3-5 秒再重試
- 如果收到 HTTP 429, 請 back off 10-15 秒
- 推薦模式: 先抓一份搜尋結果列表, 解析完後, 再逐一抓取個別討論串, 每次都加上延遲

---

## 來源

改寫自: https://github.com/ykdojo/claude-code-tips/blob/main/skills/reddit-fetch/SKILL.md
