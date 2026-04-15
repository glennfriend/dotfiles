---
description: Contact Loop (Samurai, Ava) remote server 的 mysql query
allowed-tools: Read, Bash
---

## Contact Loop 環境
除了 localhost 開發環境
我們也有 staging 供 QA 測試使用
我們有 CL1            重要環境, 客戶比較少, 資料量大, 有些 table 筆數很多, 要注意效能
我們有 CLO production 重要環境, 客戶比較多, 資料量大, 有些 table 筆數很多, 要注意效能


## 可以使用的 SQL query 指令

- Samurai
```bash
sql="
SELECT id,name,email FROM users
WHERE id < 100
LIMIT 1
"
onr-samurai-local-db "${sql}"         # for localhost
onr-samurai-cl1-sshdb "${sql}"        # for CL1
onr-samurai-production-sshdb "${sql}" # for CLO production
```

- AVA
```bash
onr-ava-staging-sshdb "${sql}"        # for staging
onr-ava-cl1-sshdb "${sql}"            # for CL1
onr-ava-production-db "${sql}"        # for CLO production
```
