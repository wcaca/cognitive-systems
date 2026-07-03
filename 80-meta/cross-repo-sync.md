# 跨仓元数据同步 · 顿悟 Q 的升级

> 2026-07-03 · v0.8.14 框架升级
> 起源: 顿悟 Q (本仓 evolution.md 严重落后暴露)
> 关联: `ci-enforcement.md` (v0.8.13) + `auto-generated-docs.md` (v0.8.12)
> 核心命题: **单仓 CI 检查 ≠ 多仓 source of truth; 跨仓 sync 需要显式协议**

## 顿悟 Q 现象

2026-07-02 06:46 commit v0.8.13 (CI enforcement) 后, 仓库实际状态:

| 仓 | 最新 commit | README 状态 | evolution 状态 |
|---|---|---|---|
| cognitive-systems | v0.8.13 (10977fb) | v0.6 (落后 7 个版本) | v0.4 (落后 9 个版本) |
| sas-graph | v0.6.17 (a41e0d4) | v0.6.8 (落后 9 个版本) | n/a |
| creation-loop | v1.0 (5dc92b8) | 无明确版本段 | v0.3 (落后整个 v1.0) |
| agent-memory | 2026-07-01 (253dfd1) | MEMORY.md 自动生成 | 自动生成 |

**4 个仓的元数据全不一致**, 但都遵循各自仓的"committed code" 是 source of truth.

**CI check** (v0.8.13) 解决的是 **单仓内**: auto-generated docs 跟 source 不同步.
**Q 暴露的是跨仓**: README/evolution 跟 commit 不同步, agent-memory 摘要跟实际 commit 不同步.

**根因**: 4 种状态 4 个格式 4 个节奏, **没有跨仓同步协议**.

## 升级: 跨仓元数据同步协议 (v0.8.14)

### 协议 1: 各仓 commit message 是 local SSOT

每个仓:
- `git log --oneline | head -N` → 最近 N 个 commit
- 每个 commit message 包含 v0.X.Y (版本号)
- README/evolution/changelog 是 **commit 的视图**, 不是 source of truth
- 这是 P 顿悟 + Q 顿悟的统一基础: **commit message 永远最新**

### 协议 2: 跨仓视图是 derived, 不是 source

```bash
# scripts/cross-repo-status.sh
# 输入: 4 个仓的 path
# 输出: 统一 JSON (latest commit + version + date + summary)

repos=(
  "wcaca/cognitive-systems"
  "wcaca/sas-graph"
  "wcaca/creation-loop"
  "wcaca/agent-memory"
)

for repo in "${repos[@]}"; do
  cd "/path/to/$repo"
  latest=$(git log --oneline -1)
  # 解析版本号 + 日期
  ...
done

# 输出统一 table
| repo | latest commit | version | date | next pending |
```

**关键**: 跨仓视图永远从 **git log** 生成, 不会手写.

### 协议 3: agent-memory 是 LLM 记忆, 不是 sync 协议

agent-memory 的 MEMORY.md 是 **LLM 工作记忆的压缩**, 它的同步节奏跟 commits 不同:
- 跨 session 累积
- LLM 决定何时写
- 是给 LLM 用的, 不是给 CI 用的

**不要把 agent-memory 当 cross-repo-sync 用**, 它不是 sync 协议, 是 memory.

### 协议 4: 跨仓视图落地位置

各仓的 cross-repo 视图放哪?
- **cognitive-systems/insights/cross-repo-status.md** (auto-gen)
- **agent-memory/dashboard/cross-repo.json** (auto-gen by cron)
- 不在每个仓都加, **只在 cognitive-systems (元方法论仓) + agent-memory (cron 仓) 各 1 份**

### 协议 5: CI 检查跨仓视图是否过期

```yaml
# cognitive-systems/.github/workflows/cross-repo-status-check.yml
on:
  schedule:
    - cron: '0 */6 * * *'  # 每 6 小时
  workflow_dispatch:

jobs:
  check-cross-repo:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: generate cross-repo status
        run: bash scripts/cross-repo-status.sh > insights/cross-repo-status.md
      - name: check freshness
        run: |
          age=$(stat -c %Y insights/cross-repo-status.md)
          now=$(date +%s)
          hours_old=$(( (now - age) / 3600 ))
          if [ $hours_old -gt 24 ]; then
            echo "cross-repo-status.md is $hours_old hours old"
            exit 1
          fi
```

## 反哺 3 处

### 反哺 1: 加 `cross-repo-sync.md` 到 v0.8.x 14 层爬升链

```
v0.8.1 递进认知链 (单仓内)
v0.8.2 全景感知清单 (单仓 LLM 自检)
v0.8.3 全局性顿悟 (LLM + user)
v0.8.4 立体完整度 (单仓推断/判断/验证)
v0.8.5 可能性域感知 (单仓 schema 枚举)
v0.8.6 显式依赖 (单仓模块)
v0.8.7 schema 元信息框架
v0.8.8 schema 元信息格式
v0.8.9 类型即元信息
v0.8.10 类型系统局限 + escape hatch
v0.8.11 escape 文档化
v0.8.12 auto-generated 文档
v0.8.13 CI enforcement
v0.8.14 跨仓元数据同步 (本文) ← Q 顿悟
```

### 反哺 2: evolution.md 必须按节奏补

v0.8.13 之前 13 个 v0.8.x commit 都没写 evolution 段 — 是 P 顿悟的直接证据.
v0.8.14 必须 **同步补 v0.5 - v0.8.13 的 evolution 段** (本文 commit 配套).

### 反哺 3: README 状态表必须同步更新

README "当前状态" 段必须包含 v0.7 - v0.8.14 所有 commit, 否则就是 P 顿悟违反.

## 实施 (本 commit 配套)

1. `80-meta/cross-repo-sync.md` (本文)
2. `20-systems/agent-harness/evolution.md` 加 v0.5 - v0.8.14 段 (10 段)
3. `README.md` 状态表 + 路线图加 v0.7 - v0.8.14
4. `scripts/cross-repo-status.sh` 实现协议 2 + 4
5. `.github/workflows/cross-repo-status-check.yml` 实施协议 5

## 跟已有体系连接

- **v0.8.12 auto-generated**: 单仓内 doc 跟 source 同步; 跨仓还需要新协议
- **v0.8.13 CI enforcement**: 单仓内强制跑; 跨仓 cron 强制跑
- **v0.6.5 prototype**: 本文 protocol 5 段对标 v0.6.5 prototype (4 面)
- **v0.8.4 立体完整度**: 跨仓 sync 是 "判断层" — 决定 "什么算 source of truth"

## 5 个开放问题

1. **agent-memory 怎么进 cross-repo 视图?** 它不是普通 repo, 是 LLM 工作记忆.
2. **多 sandbox (本地 + github + server) 的 source of truth 怎么定?** github 是 SSOT, 还是本地?
3. **跨仓视图放 cognitive-systems 还是 agent-memory?** 两个仓各放一份还是单点?
4. **LLM session 写仓 + cron 写仓 = 多个 writer, 怎么避免冲突?**
5. **跨仓 protocol 跟"rebase" / "merge" 怎么交互?** 4 个仓都有 main 分支, 跨仓视图版本化怎么做?

## 链接

- 起源: 本仓 v0.8.13 之后 + sas-graph v0.6.17 + creation-loop v1.0
- 上承: `ci-enforcement.md` (v0.8.13) + `auto-generated-docs.md` (v0.8.12)
- 上承: `decision-flow-design.md` (跨仓决策流程)
- 上承: `insight-completion-rubric.md` (27 点 rubric 加 cross-repo 子分)
- 预测 v0.8.15: 顿悟 R = 多 writer 协调协议

---

> 沉淀人: Mavis · 2026-07-03
> 月亮引力模式: 小波 (1 个框架升级 + 配套补 10 个 evolution 段) + 永续 (跨仓 sync 协议持续运转) + 单核心 (Q 顿悟 = SSOT 必须从 commit 派生)