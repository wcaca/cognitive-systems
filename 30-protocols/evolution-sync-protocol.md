# Evolution-Sync Protocol · 元方法论同步协议

> [active] 2026-07-09 · v0.8.21 · X 顿悟的协议产物
>
> **X 顿悟**：指标测错对象 = 指标在作弊。M3 (evolution 同步率) 原来测的是"commit msg 文本里是否出现 evolution 关键词"——这是"嘴上说"而不是"协议履行"。X 协议强制：每次 commit 必须判断"是否应该补 evolution.md"，并在 evolution.md 里加一个"v0.X.Y 段"或显式说明"不补理由"。
>
> 配套：[`50-metrics/completeness-metrics.md` §M3](../50-metrics/completeness-metrics.md) · [`scripts/completeness-check.sh`](../scripts/completeness-check.sh)
>
> **问题**：怎么保证"元方法论被履行"而不是"元方法论被表演"？

---

## 1. 协议的核心理念

**M3 的本意**是测"协议履行度"，**不是测"作者态度"**。v0.8.20 算法（commit msg grep）测的是后者，所以一直在作弊——commit msg 写 "insight" 或 "同步" 即可得高分，但 evolution.md 真的被更新了没有？没人在乎。

**X 协议强制 M3 测前者**：
- 触发器：每次 `git commit`
- 检查项：本次 commit 是否影响了 20-systems/agent-harness/evolution.md（或自定义 evolution 文件）
- 算法：用 `git log --diff-filter=AM -- evolution.md` 数实际变化

---

## 2. WHEN — 什么时候必须补 evolution.md

| commit 类型 | 必须补？ | 理由 |
|---|---|---|
| `feat(XX-systems)` | ✅ 是 | 体系演进（agent-harness 等 20-systems 子项） |
| `feat(80-meta)` | ✅ 是 | 元思考自身就是 evolution 的对象 |
| `feat(10-frameworks)` | ✅ 是 | 抽象层抽取影响体系 |
| `feat(30-protocols)` | ✅ 是 | 新协议本身就是 evolution 事件 |
| `fix(XX-systems)` | ⚠ 视情况 | 修 bug 影响小可不补，但需要简短说明 |
| `chore:` (版本同步、CI 等) | ❌ 否 | 机械动作，不涉及认知演进 |
| `auto(cross-repo)` | ❌ 否 | 自动同步，不涉及认知 |
| `docs:` (纯文字排版) | ❌ 否 | 排版变化 |

**默认行为**：不确定时，补。

---

## 3. WHO — 谁负责补

- **commit 作者**：必须在 commit 后立刻补 evolution.md 的 "v0.X.Y 段"
- **reviewer (如有)**：检查 v0.X.Y 段是否按 8 维度格式（见 [`90-conventions/context-snapshot-template.md`](../90-conventions/context-snapshot-template.md)）
- **CI (v0.8.22 计划)**：在 `feat:` / `fix(20-systems)` / `fix(80-meta)` 这类 commit 后检查 evolution.md 是否有对应 v0.X.Y 段

---

## 4. HOW — 怎么补

### 4.1 最小段（5 维度）— fix / 小改动

```markdown
## v0.X.Y · 2026-07-XX

### 触发 (Trigger)
（一句话：什么触发了这个 commit）

### 做了什么 (What was done)
- 1-3 个 bullet

### 决策流程回顾
- **决策触发**：...
- **决策标准**：...
- **决策复盘**：...

### 未来伏笔 (Future Threads)
- **Y 顿悟 (v0.X.Z)**：...
```

### 4.2 完整段（8 维度）— feat / 顿悟 / 大改动

加 4 维度：目的 / 当时状态 / 方法 / 已知未知 / 历史 / 基调 / 反方观点。详见 context-snapshot-template.md。

### 4.3 不补的显式声明

如果按 §2 判定不补，必须在 commit msg 里写：

```
chore: sync cross-repo status (no evolution update)
```

并在 evolution.md §X 段里加一句 "本 commit 不补 evolution（理由：chore）"。

---

## 5. 验证 (Verification)

### 5.1 自动验证（CI / completeness-check）

```bash
# M3 计算: evolution.md 在最近 30 个 commit 中被增/改的次数 / 30
git log --oneline -30 --diff-filter=AM -- 20-systems/agent-harness/evolution.md | wc -l
```

目标：≥ 50%（每 2 个 commit 至少 1 个补 evolution）

### 5.2 手工验证（review 时）

- 打开 commit 的 diff
- 查 20-systems/agent-harness/evolution.md 是否有对应 v0.X.Y 段
- 如果没段：判定违反 X 协议，要求作者补

### 5.3 跨仓验证

`scripts/cross-repo-status.sh --completeness` 应输出 4 仓各自的 M3 分数，让"哪个仓在作弊"可见。

---

## 6. 反模式 (Anti-Patterns)

| 反模式 | 表现 | 修正 |
|---|---|---|
| 嘴上说 | commit msg 写 "insight" 但 evolution.md 没动 | M3 改用 diff-filter-AM（已实施）|
| 偷换文件 | 在 evolution.md 末尾加一句 "本版本无变化" = 触发 AM = 作弊 | M3 算法需要 --diff-filter=AM + 内容长度阈值（v0.8.22+ 计划）|
| 集中补 | 30 个 commit 累积后一次性补 = 集中作弊 | 协议 §2 强制"立刻补"，review 时检查时序 |
| 不分类型 | 所有 commit 都补 = 噪声 | §2 表格给出明确范围 |

---

## 7. 演进 (Evolution)

- v0.8.16 (2026-07-04)：S 协议提"空目录 = 诚实信号"，本协议是其延伸
- v0.8.20 (2026-07-08)：W 顿悟实施 completeness-check.sh，发现 M3=0.07 异常
- v0.8.21 (2026-07-09)：X 顿悟——指标测错对象，**本文是修正协议**
  - M3 算法从 commit msg grep 改为 diff-filter=AM on evolution.md
  - M3 目标从 70% 修正为 50%
  - 引入本协议强制"协议履行"而不是"嘴上说"

## 8. 未来伏笔 (Future Threads)

- **Y 顿悟 (v0.8.22+)**：content-length 阈值检测"集中补作弊"——evolution.md 的每次修改至少要 ≥ 100 字符
- **Z 顿悟 (v0.8.23+)**：CI 强制 enforcement——`feat:` commit 没补 evolution.md = 阻断 push
- **AA 顿悟 (v0.8.24+)**：跨仓 enforcement——所有 4 仓的 M3 必须 ≥ 50% 才算 4 仓体系健康
