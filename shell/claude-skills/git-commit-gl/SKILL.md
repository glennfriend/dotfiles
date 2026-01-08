---
name: git commit flow
description: 將現在已進到 git stage 的檔案 commit 到 git repository
---

## Step 1

### 分析變動內容
- 取得當下最新的 staged changes
  - `git --no-pager diff --cached`


## Step 2

### 為這次的變動產生 git commit message
- commit message 必須是英文
- 真正要 commit 之前, 必須經過我的同意
- 禁止幫我執行任何危險的指令, 包含以下的 git 操作
  - force push
  - delete un-merged branches
  - delete tags
  - delete main/master branches
  - delete release-* branches
  - rebase
- 默認 commit 的範圍僅是 staged changes 
- 幫我產生 1-3 個建議使用的 commit messages 讓我選擇, commit message 必須是簡單易懂, 並且每行不要超過 80 characters
- commit 內容請不要包含開發者的名稱
- 如果 commit 的內容比較簡單, 一行 commit messages 即可
- 如果 commit 的內容比較複雜, 請幫我產生至少三行以上的 commit messages, 第二行是空白, 第三行開始以後的 message 重點整理這次變更的摘要內容
- commit message 使用 Conventional Commits 標準
  - commit types (格式小寫)
    - chore
    - feat
    - fix
    - doc
    - refactor
  - unit types (格式小寫)
    - entity
    - value-object
    - repository
    - service
    - contract
    - model
    - controller
    - use-case
    - api
  - 第一行的 commit message 格式請嚴格遵守以下 valid formats
    - commitType(moduleName/unitType): [unitName] description of this change
    - commitType(moduleName): [unitName] description of this change
    - commitType(moduleName): description of this change
    - commitType(moduleName/unitType): description of this change
  - unitName 應該是 class name 或 API route
  - commit message examples
    - chore(assistant/entity): check if greeting is empty
    - feat(assistant/api): [POST /assistants] added name validation, should be a-zA-Z
    - doc(assistant/api): added response status code.
    - fix(assistant/api): [PUT /ai-tools/:id] respond http 500 error if name is duplicated.


## Step 3

### fix phpstan
- fix phpstan command line: `composer phpstan:docker` or `docker compose exec 'php' composer phpstan:docker`
- 如果有 phpstan 的錯誤, 並且是這次 commit 的檔案, 請修正

