# cross-repo-status.sh · 跨仓元数据同步工具

> **60-tools 第一篇 (v0.8.19 / 顿悟 V)** — 工具契约 (contract) + 使用指南
>
> **顿悟 V 起源**：T 协议 (填实顺序协调) 实施时, 最常跑的工具就是 cross-repo-status.sh, 但它没有 README, 想给别人用都得读源码。把"反复使用的工具"从 scripts/ 抽到 60-tools/ 并写契约 = 工具发现的最后一公里。
>
> **路径不动, 契约抽出来** — 脚本本身仍在 `scripts/cross-repo-status.sh` (避免破坏现有调用), 60-tools/ 只放契约 + 例子 + 故障排查。

## 工具身份

| 字段 | 值 |
|------|-----|
| **name** | cross-repo-status.sh |
| **version** | v0.8.17 (带 --archive) / v0.8.15 (带 --push) |
| **path** | `scripts/cross-repo-status.sh` (361 行 bash) |
| **language** | bash (set -euo pipefail) |
| **dependencies** | git, jq (optional), python3 (for JSON parse in --push) |
| **runtime** | < 5s (4 仓无 push) / 30-90s (with push, 含 fetch) |

## 功能

从 N 个仓的 git log 自动抽取 latest commit / version / date / next-pending。

输出:
1. `insights/cross-repo-status.md` — 人类可读
2. `insights/cross-repo-status.json` — 机器可读 (含 repos[] 数组)
3. `70-artifacts/cross-repo-status-archive/<date>-daily.md` — 归档 (--archive daily)
4. `70-artifacts/cross-repo-status-archive/<date>-<version>.md` — 版本快照 (--archive=version)

## 调用契约

### 输入

| flag | 类型 | 默认 | 说明 |
|------|------|------|------|
| `--repos=PATH1,PATH2,...` | string | `cognitive-systems/sas-graph/creation-loop/agent-memory` (4 仓硬编码) | 指定仓路径 |
| `--push` | bool | false | 生成后自动 pull-push 到各仓 (v0.8.15 协议 2) |
| `--no-lock` | bool | false | 跳过 lock 检查 (debug 用, 不推荐) |
| `--archive` | bool | false | daily 归档模式 (v0.8.17 起) |
| `--archive=version` | bool | false | 版本快照模式 |
| `--archive-version=X.Y.Z` | string | (auto) | 强制指定版本号 |

### 输出

- exit 0: 成功, 生成上述文件
- exit 1: 某仓 unreachable (git fetch 失败) 或 lock conflict
- exit 2: 参数解析失败

### 副作用

- 写 `insights/cross-repo-status.md` + `.json`
- (--push) 自动 commit + push 各仓
- (--archive) 写 `70-artifacts/cross-repo-status-archive/<date>-<mode>.md`

## 设计原则 (协议摘要)

跨仓 sync 协议 (v0.8.15 起, 完整版见 30-protocols/cross-repo-sync.md):

1. **各仓 commit message 是 local SSOT** — version 不存 README, 只存 commit msg
2. **跨仓视图是 derived** — `insights/cross-repo-status.md` 自动生成, 不手写
3. **auto-generated 跟 source 同步** — 协议 2 + 协议 4 (cron/手动触发)
4. **多 writer 协调**: lock + pull-push + own view per 仓 (v0.8.15 协议 1+2+4)

## 使用场景

### 场景 1: 看 4 仓最新状态 (manual, 5s)

```bash
bash scripts/cross-repo-status.sh
cat insights/cross-repo-status.md
```

### 场景 2: 加新仓到跨仓视图 (v0.8.18 起)

1. 编辑 `scripts/cross-repo-status.sh` 的 `REPO_TYPES_BY_BASENAME` 数组加新仓 type
2. 编辑 `DEFAULT_REPOS` 数组加新仓路径
3. 跑一次生成 → `insights/cross-repo-status.json` 自动包含新仓
4. README.md 加新仓到"跨仓状态"段
5. commit + push cognitive-systems

### 场景 3: 归档当天状态 (cron 友好)

```bash
bash scripts/cross-repo-status.sh --archive
# 写入 70-artifacts/cross-repo-status-archive/2026-07-07-daily.md
```

### 场景 4: 版本发布时锁定快照

```bash
bash scripts/cross-repo-status.sh --archive=version
# 写入 70-artifacts/cross-repo-status-archive/2026-07-07-v0.8.19.md
```

### 场景 5: 同步 4 仓 (--push)

⚠️ **慎重使用**, 这会 commit + push 所有仓!

```bash
bash scripts/cross-repo-status.sh --push
# 各仓分别:
# 1. 拉最新
# 2. 重新生成 insights/cross-repo-status.{md,json}
# 3. commit (auto(cross-repo): refresh status <sha>)
# 4. push
```

## 故障排查

| 症状 | 原因 | 解决 |
|------|------|------|
| `fatal: could not read Username` | git credential 失效 | 设置 `GIT_TERMINAL_PROMPT=0` 或用 SSH key |
| `lock file exists` | 上次 --push 中途崩了 | 删 `.git/cross-repo-status.lock` 后重跑 |
| JSON 含 `version: "unknown"` | commit msg 没匹配 `vX.Y.Z` pattern | 改 commit msg 格式或用 `--archive-version=X.Y.Z` 强制 |
| 某仓 `sha: null` | 仓没拉到本地 | `git clone` 那个仓到 REPO_PARENT 路径 |
| `parse_version 报错 "from <仓名> vX.Y"` | commit msg 引用其他仓版本被误识别 | v0.6.19 已修, 升级 sas-graph |

## 已知坑

1. **REPO_PARENT 假设** — 脚本默认 4 仓在同一父目录下 (REPO_PARENT 推导). 单仓独立目录需要 `--repos=` 显式传
2. **protocol_version 字段** — JSON 里 hardcoded "v0.8.15", 协议升级时要同步改
3. **parse_version regex** — 旧版误识别 commit msg 里 "after/before/from <仓名> vX.Y" 为版本引用, v0.6.19 (sas-graph) + 协议升级已修
4. **lock file 不跨机器** — 本地 lock 文件不参与跨机器协调, 跨机器同时跑 --push 仍可能 race (接受风险, cron 错峰 5min)

## 版本

- v0.8.15 (2026-07-03): 初版, lock + pull-push + own view per 仓
- v0.8.17 (2026-07-05): 加 --archive (daily + version)
- v0.8.19 (2026-07-07): 抽工具契约到 60-tools/cross-repo-status.md (本文, 顿悟 V)

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-07-07)