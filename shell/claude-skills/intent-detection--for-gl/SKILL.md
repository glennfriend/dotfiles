---
name: intent-detection--for-gl
description: 依照使用者的意圖, 調用 bash/skill/plugin/MCP 來完成工作
allowed-tools: Read, Write, Edit, Bash
disable-model-invocation: true
---

## `wisdom update` 更新文件
cat /var/www/cl/onr-document/wisdom/knowledge/README.md
必讀 /var/www/cl/onr-document/wisdom/knowledge/CONVENTIONS.md
更新前須經過 user 同意

## `create plan` 建立計畫
必讀 /var/www/cl/onr-document/wisdom/prompts/project-create-my-plan.md
建計畫 /var/www/aquarium/plans/*.md

## `exe plan` 執行計畫
必讀 /var/www/cl/onr-document/wisdom/prompts/project-execute-my-plan.md

## `github release` 整理 github release 的文字訊息
必讀 /000/Dropbox/rice/rice/prompt/1-work.prompt/monday-release--deployment-message-converter-轉換-to-user.prompt.md

## `private doc deploy` 發佈文件到私密網頁
> mkdir -p /var/www/doc-report/private/new/ ; cp 指定的檔案.md /var/www/doc-report/private/new/
> cd /var/www/doc-report ; bash deploy-html-to-temporary-folder/private-deploy.sh
先 dry run
> cd /var/www/doc-report ; bash deploy-html-to-temporary-folder/private-deploy.sh --real-run
無異狀請執行, 有任何異狀請請示使用者決定是否繼續

## `mysql query` `ElasticSearch query` `datadog query` `aws query` 資料查詢
cat /var/www/tool/onr-support/PROMPT.md


---
以上是所有可能的意圖
不是以上的意圖, 請停止, 並輸出 "not supported intent"
如果目錄檔案路徑不存在, 請停止, 回報使用者

