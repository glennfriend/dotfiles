---
name: project-execute-my-plan--for-gl
description: 讀取 {Plan File} 並依先後順序執行已規劃好的子計劃. 每完成一項就打勾 check list, 完成後執行 test case 與 phpstan 檢查. 適用於計劃已討論完成, 要開始落實程式碼產出的情境
allowed-tools: Read, Write, Edit, Bash
---

# 落實已完成的執行計劃

## 讀取計劃檔案
- laravel project
  - 暫存目錄 `storage/temp/` 你可以自行使用, 不需要再詢問我
  - cat storage/temp/my-plan.md
- other
  - plans/yyyy-mm-dd-{plan-name}.md
  - 可能會有多個 plan file, 先跟開發者確認是哪一個計劃檔

## 一開始要跟開發者確認
- 每完成一個大項目, 是要直接 commit, 還是要每次都等開發者確認之後再 commit

## 必須要遵守的規則
- follow Clean Architecture & Domain & DDD (Domain-Driven Design)
- 如果是產生 PHP 程式碼
  - 請遵守 template: onr-document/wisdom/code-template/**/*
- 如果是產生 react 程式碼
  - 請使用 react + ant-design
- local 開發環境會用到的指令
  - docker compose exec 'php' php artisan tinker
- NO over-design ! NO over-engineer !

### 產生程式的過程如果不順利
- 如果修改後讓程式產生意外的嚴重錯誤      -> 請跟我討論, 恢復程式碼, 重新修改
- 如果進入持續修復錯誤的輪迴, 一直修改不好 -> 請跟我討論, 恢復程式碼, 重新修改
- 如果你修改到太多不相關這次的範圍        -> 請跟我討論, 恢復程式碼, 重新修改

## 讀取計畫並且執行
- 讀取 storage/temp/my-plan.md
- 請依照計畫執行, 除非有改變計畫, 否則 my-plan.md 應該只會回寫 check list, 其它內容不應該被更改
- 如果在執行計畫的時候, 改變的檔案有超出計畫表, 請等我允許才能做出變更
- step by step 依順序完成

## 依照先後順序執行 子計劃
- 每次都要讀取並且參照 `my-plan.md`
- 如果有 建立/修改 unit service, API -> 請建立/修改 相關的測試
- 每次完成一小部份的功能就要準備 commit
- 每次 commit 前要執行指令檢查 test case 是否正常
- 詢問開發者是否要 commit 這次的變動
- commit 之後再執行下一個子計劃
- 完成子計劃之後
  - 打勾 `my-plan.md` 的 check list, 不要額外加上無關的資訊
  - 等開發者確認, 才會繼續進行下一個子計劃

## 全部完成後
- 執行指令檢查 test case 是否正常
- 執行指令檢查 phpstan 是否正常
- 執行指令檢查 這次整個改動, 如果有多餘的中文註解, 應該要移除
  - git --no-pager diff master...HEAD
