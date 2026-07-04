# Q + R 顿悟的实证实验记录

> [active] 2026-07-04 · v0.8.16 · S 顿悟的实施产物
>
> 配套：[`80-meta/skeleton-as-completeness-signal.md`](../80-meta/skeleton-as-completeness-signal.md) §五
>
> **目的**：把 v0.8.14 (Q 跨仓同步) + v0.8.15 (R 多 writer 协调) 这两个顿悟的**实施过程**记录成实验数据，让后人能复现 + 找到新的顿悟。

---

## 实验 1：跨仓同步脚本首次跑通

### 1.1 背景

v0.8.14 之前，每个仓的状态都散在各自 README，cognitive-systems 仓的 README 状态表已经停在 v0.6 状态。

### 1.2 设计

- 输入：4 个仓的本地 git log
- 输出：`insights/cross-repo-status.md` + `.json`
- 触发：手动跑 / CI check freshness (< 24h)

### 1.3 实施步骤

1. 写 `scripts/cross-repo-status.sh` (v0.8.14 起)
2. 写 `.github/workflows/cross-repo-status-check.yml`
3. 跑通 + 看输出对不对
4. commit + push

### 1.4 结果

✅ 4 个仓状态自动同步，README 不再手动维护版本表。
❌ evolution.md 没在每次 commit 同步补（暴露在 v0.8.14 的自我观察段）。

### 1.5 暴露的新问题 → 顿悟 R

跨仓 sync 在单 writer 下没问题，但是：
- 凌晨长程推进时，一个 LLM session 同时跑 `--push` 和手动 commit
- 触发 rebase 冲突 + force-with-lease push 失败
- race condition **真实发生**

→ 顿悟 R = 多 writer 协调协议 (v0.8.15)

---

## 实验 2：多 writer 协调协议

### 2.1 背景

v0.8.15 实施暴露的 race condition。

### 2.2 设计

5 个协议组合：
- **协议 1**：lock 文件（`<repo>/.cross-repo-status.lock`）
- **协议 2**：pull-push 顺序（先 pull → 改 → push，不直接 push）
- **协议 3**：hash skip（如果远端 commit hash == 生成的 hash，跳过）
- **协议 4**：own view per仓（每个仓有自己的视图，不共享）
- **协议 5**：owner 模式（只有 owner session 才能 `--push`，其他 session 跑 generate only）

### 2.3 实施步骤

1. 在 `cross-repo-status.sh` 加 lock 检查
2. 在 CI 加 pull-push 顺序
3. 跑通 + 模拟 race

### 2.4 结果

✅ 凌晨长程推进时，多 session 协作不再冲突。
✅ race condition 不再发生。
⚠️ 但出现"新的不诚实"——脚本失败时静默跳过，owner 看不到失败原因。

### 2.5 暴露的新问题 → 顿悟 S

脚本失败被静默吞掉 = 空目录的"完成度信号"被静默吞掉 = **诚实信号**缺失。
→ 顿悟 S = 诚实信号协议 (v0.8.16) = skeleton-as-completeness-signal

---

## 实验 3：诚实信号协议 (S 顿悟的实施)

### 3.1 背景

v0.8.16 — 看到 6 个空目录 + 没有 README 占位。

### 3.2 设计

3 条协议：
- 空目录有 README 占位 + `.gitkeep`
- 仓根 README 标 `[empty: 原因]`
- 填实后 README 占位升级为 README 索引

### 3.3 实施步骤

1. 写 `80-meta/skeleton-as-completeness-signal.md` (本文)
2. 填实 `30-protocols/` (1 个文档)
3. 填实 `40-experiments/` (本文)
4. 填实 `50-metrics/` (完整性指标体系)
5. 填实 `70-artifacts/` (cross-repo-status 快照归档)
6. CI 检查空目录健康度

### 3.4 预期结果

✅ README 不再假装有内容
✅ 6 个空目录中有 4 个填实 (60%)
⚠️ 剩下 2 个 (10-frameworks / 60-tools) 暂时保留为空

---

## 数据汇总

| 顿悟 | 暴露的 bug | 实施后 | 暴露的新问题 |
|---|---|---|---|
| Q (v0.8.14) | 跨仓状态散落 | cross-repo-status.sh auto | evolution.md 不同步 |
| R (v0.8.15) | race condition | lock + pull-push + owner | 失败被静默吞掉 |
| S (v0.8.16) | 空目录假装有内容 | README 占位 + CI 检查 | (预测 T) 填实顺序 + 谁来做 |

---

## 演进

- v0.8.16 (2026-07-04)：初稿。Q+R 实施记录 + S 触发原因