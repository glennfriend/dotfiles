---
name: project-create-my-plan--for-gl
description: 跟開發者來回討論, 並建立執行計劃, 討論結果寫入 {Plan File}. 只討論計劃, 不產生任何程式碼
allowed-tools: Read, Write, Edit, Bash
---

# 開發者一起討論並且規劃要做的事

## 必須要遵守的規則
- follow Clean Architecture & Domain & DDD (Domain-Driven Design)
- 如果是產生 PHP 程式碼
  - 請遵守 template: onr-document/wisdom/code-template/**/*
- 如果是產生 react 程式碼
  - 請請使用 react + ant-design
- 如果有討論到規格
  - 盡量先參考國際上的大型科技公司都有在使用的規格, 即使不用, 我們也能知道有什麼差異
- NO over-design ! NO over-engineer !
- step by step 依順序完成

## 建立計劃檔案
- laravel project
  - 暫存目錄 `storage/temp/` 你可以自行使用, 不需要再詢問我
  - touch storage/temp/my-plan.md
- other
  - plans/yyyy-mm-dd-{plan-name}.md

## 討論之前要先記住的事
- 建立 `my-plan.md` 並且儲存, 用來討論計劃, 我們一起持續修改這份計劃
- 因為 `my-plan.md` 會一直持續修改, 所以每次討論都要一定要重新讀取 `my-plan.md`
- 非常重要! 任何開發者應該只要看這份計劃, 就應該要知道要怎麼做! important!

## 計劃文件 example
- 計劃至少有兩個主要大標
  - Perform
    - 所有真正要做的事請, 要依照先後順序排列在 Perform
    - 只有 Perform 會列出 check list
    - 每個 check list 都是各別執行的子計劃
    - 每次都完成一項 Phase 就要勾選 check list, 然後執行 git commit
  - Confirm the existing functions
    - 搜尋跟這次需求相關的功能與資源, 請重複復用
    - 不要產生重覆的 程式碼, 資源
    - 應該要重用 已存在的程式碼, 資源
  - Description
    - 所有需要的知識都要放在 Description
    - 要描述 Milestones
    - 要描述 限制的範圍
    - 要產生 mermaid 圖表
- 計劃的先後順序建議
  - schema, route, business domain, controller, use case
- 計劃文件 `my-plan.md` 格式 example

<plan-example>
## Issue 核心需求
- 核心問題為客戶提供各種 hello world 訊息
- 核心需要為提供打招呼的 API 功能給 frontend 界接

## Perform

### Phase 1: 建立 Modules
- [ ] 1.1 docker compose exec php php artisan module:make {ModuleName}

### Phase 2: 建立 hello_worlds table
- [ ] 2.1 create schema, hello_worlds table

### Phase 3: 建立 hello world API
- [ ] 3.1 list   API
- [ ] 3.2 create API
- [ ] 3.3 update API
- [ ] 3.4 delete API

### Phase 4: 更新相關的 use case
- [ ] update use case, CreateHelloWorldUseCase

### Phase 5: phpstan fix
- [ ] composer phpstan:docker ; tools/scripts/phpcs-pr.sh

### Phase 6: upgrade document
- [ ] tree onr-document/knowledge

## Confirm the existing functions
- accounts table 已存在, 可以關聯 hello_worlds.account_id = accounts.id

## Description
- target
  - 產生 hello world 的 API, 在前端串接好之後, 讓 end-user 可以 建立/編輯/刪除/列表 所有的 hello world rows
- 預計 used files
  - Modules/Core/ValueObjects/E164PhoneNumber.php
- 預計 update files
  - Modules/HelloWorld/Routes/api.php
- 預計 new files
  - Modules/HelloWorld/Http/Controllers/CreateHelloWorldController.php
  - Modules/HelloWorld/Tests/Feature/APIs/CreateHelloWorldTest.php
- 預計 deprecated files
  - none
- database schema
  - hello_worlds table fields
    - id, PK
    - account_id, index
    - status, varchart(20), [enabled, disabled]
    - name, string, uniqued-index
    - description, text, nullable
    - config, json
      - config.age
      - config.interest
- hello world API required, limit
  - 新的 API 需要建立 route, request, controller, command, use case, resource, test case
  - 要建立 tools/httpclient

## API

### [GET] /api/hello-worlds?page=1
- 有分頁功能, 每頁固定 20 筆
- name unique key
- name a-z 排序

### [POST] /api/hello-worlds
- 權限 system-admin
- respnose 201
{
  "name": "hi"
}

### [PUT] /api/hello-worlds/{id}

### [DELETE] /api/hello-worlds/{id}
- 檢查是否有關聯資料, 有的話不能刪除
- 無 soft delete

## 時序圖 (有需要才建立)

```mermaid
sequenceDiagram
    Hello World 時序圖
```
</plan-example>

## Step 1

### 跟開發者討論計劃
- 開始討論, 持續進行討論, 編輯 `my-plan.md`
- 確認我們必須要完成什麼事
- 來回持續討論
- 如果你需要, 就思考, 如果你需要更多訊息, 就問我問題
- 只討論計劃, 不要產生任何程式碼

### 子計劃
- 每次 commit 應該都是能完成一個小部份的功能
- 每次都要一定要參照 `my-plan.md`
- 如果有建立/修改 unit service, API 請建立/修改 相關的測試

## Step 2

### 依照順序執行計劃
- 每次執行前都要重新讀取 `my-plan.md`
- 每次完成一個子計劃
  - 請解釋這次建立的程式碼
  - 如果有相對應的 test case 要確認是否正常運作
  - 打勾 `my-plan.md` 的 check list
  - 詢問開發者是否要 commit 這次的變動
- 完成子計劃之後
  - 等開發者確認, 才會繼續進行下一個子計劃

## Step 3
- 如果 `my-plan.md` 未完成所有的工作, 請回到 Step 3

## Step 4
- 執行指令檢查 test case 是否正常
- 執行指令檢查 phpstan 是否正常
- 執行指令檢查 這次整個改動, 如果有多餘的中文註解, 應該要移除
  - git --no-pager diff master...HEAD
