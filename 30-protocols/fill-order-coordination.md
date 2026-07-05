# Fill-Order Coordination Protocol · 填实顺序协调协议

> [draft] 2026-07-05 · v0.8.17 · T 顿悟的实施产物
>
> 配套：
> - [`80-meta/skeleton-as-completeness-signal.md`](../80-meta/skeleton-as-completeness-signal.md) (S 顿悟)
> - [`70-artifacts/cross-repo-status-archive-policy.md`](../70-artifacts/cross-repo-status-archive-policy.md) (跨仓归档)
>
> **问题**：v0.8.16 填实了 4 个空目录（30-protocols / 40-experiments / 50-metrics / 70-artifacts），但**填实顺序 + 谁填 + 填得对不对**没有协议。下一个空目录（比如 60-tools / 10-frameworks）填还是不填、谁来填，按什么标准填，是开放的。
>
> 本协议 = 把"什么时候填、谁来填、怎么验证"三个问题协议化。

---

## 1. 为什么需要协调协议

v0.8.16 后的真实状态（2026-07-05 凌晨盘点）：

| 目录 | 状态 | 是否已填实 | 谁该填 |
|---|---|---|---|
| 00-essence | 旧实 | ✅ research-map.md | — |
| 10-frameworks | [empty] | ❌ | 计划 v0.8.18 |
| 20-systems | 旧实 | ✅ agent-harness/ | — |
| 30-protocols | active | ✅ insight-extraction.md | 已 v0.8.16 |
| 40-experiments | active | ✅ qr-insight-experiments.md | 已 v0.8.16 |
| 50-metrics | active | ✅ completeness-metrics.md | 已 v0.8.16 |
| 60-tools | .gitkeep only | ❌ | 待定 |
| 70-artifacts | active | ✅ cross-repo-status-archive-policy.md | 已 v0.8.16（实施待 v0.8.17） |
| 80-meta | 旧实 | ✅ 10+ 文件 | — |
| 90-conventions | 部分实 | ⚠️ 缺 README | — |

**4 个目录需要某种形式的"下一步"决定**（10-frameworks / 60-tools / 70-artifacts 实施 / 90-conventions README）。

不协议化的现象：
- "想填哪个填哪个" → 顺序无理性，缺追溯链
- "等会儿填" → 反复延期，没有 deadline signal
- 多人协调 → 谁覆盖谁不清楚

本协议的目标：**让"填实"从一次性事件，变成可重复、可审计、可排期的流程。**

---

## 2. 三个子问题，三个协议

### 2.1 WHEN — 什么时候填（信号协议）

**触发信号**（满足任一即考虑填）：
1. **上游协议缺位信号**：X 协议被多个新顿悟引用，但仓里还没有 → 必须填
2. **跨仓倒挂信号**：其他仓有相关文档，本仓缺 → 应填（参考 `70-artifacts/cross-repo-status-archive-policy.md`）
3. **历史承诺信号**：evolution.md 写了"vX.Y.Z 实施"但实际未实施（v0.8.17 第 1 个候选就是 70-artifacts 实施）
4. **CI 暴露信号**：S 协议的 CI enforcement 暴露 [empty: 计划] 但已无对应计划 → 升级或清理

**反触发**（抑制填实，避免填充式填）：
- 内容已经被其他仓覆盖（比如 v0.8.18 plan 还在 60 天后）
- 用户/agent 共识是"先不填"（比如 10-frameworks 在 evolution.md 计划 v0.8.18）

### 2.2 WHO — 谁来填（角色协议）

**3 种填实角色**（按复杂度）：

| 角色 | 适用场景 | 责任 |
|---|---|---|
| **owner** | 大型协议（比如 insight-extraction 5 步） | 写主文档 + README 索引 + evolution 段 |
| **contributor** | 小型补完（README / 归档脚本） | 写单个文件 + PR |
| **auditor** | 验证已填内容（CI / 完整性） | 写检查 + 报告，不写主内容 |

**自我填实原则**：研究仓的填实由一个 agent 完成，多 agent 写就回到 R 协议（多 writer 协调）。

### 2.3 HOW — 怎么验证（验收协议）

填实不是 commit 完成 = 验收。3 步验收：

```
Step A: 一致性检查
  - 仓根 README 状态表是否已更新（含新文件）
  - 30-protocols/README.md 是否已添加索引
  - evolution.md 是否已补 v0.X.Y 段
  - insights/cross-repo-status.md 是否已 refresh
```

```
Step B: 完整性检查
  - M1 (状态标记) → 文件存在 + README 占位
  - M2 (骨架结构) → section 完整
  - M3 (跨仓链接) → 其他仓可被引用
  - M4 (CI enforcement) → 协议被脚本验证
```

```
Step C: 归档
  - 70-artifacts/cross-repo-status-archive/YYYY-MM-DD-vX.Y.Z.md
  - 存本次填实前后的 M1-M4 快照
  - 写 3 行 diff: 填实了什么 / 验证了什么 / 下次回看
```

---

## 3. 完整协调流程（6 步）

```
[Step 1] 信号扫描：跑 cross-repo-status.sh → 列 4 仓的 [empty] / [active] / [empty: 计划]
   ↓
[Step 2] 触发判断：上面 2.1 的 4 信号匹配？ → 是 → 候选填实；否 → 跳过本次
   ↓
[Step 3] 角色分配：按 2.2 三种角色之一，写明在 commit message
   ↓
[Step 4] 实施填实：写文件 + README + evolution + cross-repo-status refresh
   ↓
[Step 5] 验收：跑 Step A / B / C
   ↓
[Step 6] 归档：cross-repo-status-archive 写版本快照
```

**强制约束**：
- 跳步 = 协议违反（必须在 commit message 里写明为什么跳）
- Step 4 没完成前不能 commit（避免"半成品"入库）
- Step 5 全过才能算"committed as ready"（否则是 "committed as draft"）

---

## 4. 协议的实施案例（v0.8.17 本轮填实）

**本轮填实计划**：

| 目录 | 触发信号 | 角色 | 计划版本 |
|---|---|---|---|
| 30-protocols | S 协议 2.1 #3 (历史承诺) | owner | **v0.8.17** |
| 50-metrics | S 协议 2.1 #3 (历史承诺，验证 M1-M4) | auditor | **v0.8.17** |
| 70-artifacts | S 协议 2.1 #3 (实施 cross-repo-status --archive) | contributor | **v0.8.17** |
| 10-frameworks | 2.1 #1 缺位信号（5 维度框架协议未实现） | owner | **v0.8.18** |
| 60-tools | 2.1 #2 跨仓倒挂（其他仓有工具仓） | owner | **v0.8.19** |
| 90-conventions | 2.1 #4 CI 暴露（缺 README） | contributor | **v0.8.17**（顺手补） |

**反模式避免**：
- 不在本轮填 10-frameworks（按 plan 留 v0.8.18）
- 不在本轮填 60-tools（按 plan 留 v0.8.19）
- 不重复填已 active 目录

---

## 5. 与已有协议的衔接

| 已有协议 | 衔接方式 |
|---|---|
| S 协议 (skeleton-as-completeness-signal) | 本协议 = S 协议的"实施阶段" |
| Insight-Extraction (5 步) | 写新顿悟时也走 5 步（核心命题 + 证据 + 命名） |
| Cross-Repo-Sync | 填实后立即 refresh cross-repo-status.md |
| Cross-Repo-Archive Policy | 填实后写版本快照到 70-artifacts/cross-repo-status-archive/ |
| CI Enforcement | 跑 `bash scripts/skeleton-check.sh` 验证 |

---

## 6. 协议的反模式

| 反模式 | 表现 | 修正 |
|---|---|---|
| 没信号就填 | "看着该填就填" | 必须 2.1 信号匹配 |
| 多人写同一目录 | race / 覆盖 | 必须走 R 协议 |
| commit 后不验收 | 半成品入主分支 | Step 5 全过才算 ready |
| 填实没归档 | 不知道填了什么 | Step 6 强制归档 |
| 把"填实"和"完成"混 | 填完像做了很多 | 协议区分: 填实 ≠ 验证 ≠ 完成 |

---

## 7. 协议的限制

- 本协议是"协调协议"，**不是"内容协议"** —— 填什么内容靠每个目录自己的 protocol
- 当填实候选 > 3 个时，**强制先跑 cross-repo-status 信号扫描**而不是凭印象
- 协议不阻止"超计划填实"（比如用户突然要填 60-tools），但要求超计划时 commit message 写明触发原因

---

## 8. 演进

- v0.8.16 (2026-07-04)：S 协议 + 4 目录填实，但缺协调协议
- v0.8.17 (2026-07-05)：T 顿悟 = 填实顺序协调协议（本协议）
- v0.8.18 (计划)：填实 10-frameworks（5 维度框架协议）
- v0.8.19 (计划)：填实 60-tools（工具清单协议）
- 未来：U 顿悟 (v0.8.20) 预测 — 填实后**保留期**（什么时候清理填错的内容）

---

## 9. 给后续 agent 的 1 句话

> **填实前看 §2.1 信号，填实时标 §2.2 角色，填实后跑 §3 的 Step 5/6**。跳过任何一步都是协议违反，记入 commit message。
