# 体系演进记录

> **格式说明**：从 v0.3 开始，本文件按 [`90-conventions/context-snapshot-template.md`](../../90-conventions/context-snapshot-template.md) 的 8 维度格式记录每个版本。早期版本（v0.1 / v0.2 / v0.2.1）按新格式回填，作为"使用示范"。

---

## v0.1 · 2026-07-01

### 触发 (Trigger)
与 Mavis（一个实际运行的 agent harness）的对话。原对话主题：
> "要达到完整严密的适应性强可恢复性强的 agent harness，对建立这套系统的 agent 的基础能力有什么要求？对运行的 agent 有什么要求，具体到维护这套系统的每个能力维度呢？"

### 目的 (Purpose)
把"agent harness 体系"作为第一个研究对象落地，验证"认知系统研究"这个项目能不能跑起来。

### 当时的状态 (State)
- 已有：无（仓从零建）
- 缺：一切

### 方法 (Methodology)
采用"角色-维度"二维矩阵：3 个角色（建筑师/居民/维护）× 10 个维护维度。先把矩阵搭起来，再填具体内容。
- 没用过：纯文献综述（容易脱离实际）

### 前提 (Assumptions)
- 假设 agent harness 设计可以抽象为有限维度
- 假设 mavis harness 的实战经验足以作为研究起点

### 已知未知 (Known-Unknowns)
- 不知道这 10 个维度是否覆盖所有重要场景
- 不知道抽象的"体系"对实际工程有多大指导价值

### 历史 (Lineage)
起源项目。从 wcaca/creation-loop v0.2（5 identity 系统）的"管理方式本身可被改"理念演化而来。

### 基调 (Tone)
探索性 + 验证性混合。预设方向（agent harness 是值得研究的）但开放具体框架。

### 做了什么 (What was done)
- 创建仓 wcaca/cognitive-systems（public）
- 6 个文档：overview / architect / resident / maintenance-dimensions / cross-cutting-judgments / evolution
- LICENSE (MIT) + .gitignore
- 22 文件, 2 commit (792b7fd HEAD)

### 未来伏笔 (Future Threads)
- 治理机制（"行为一致性"将引出 v0.2）
- cron 的特殊性（"cron 是全栈镜子"将引出 v0.2.1）
- 跨方向连接（agent / LLM / 意识）

### 反方观点 (Counter-View)
可能反对：v0.1 太抽象，对实际 harness 工程没指导价值。需要 v0.2/v0.3 给出实证和具体协议来回应。

---

## v0.2 · 2026-07-01（同日）

### 触发 (Trigger)
对话主题：
> "如何在 agent 行为一致性的层面上维护整个项目，防止不同时期、不同工作、不同能力下的 agent 扰乱、引导错误这个系统？"

### 目的 (Purpose)
解决 v0.1 留下的隐患：v0.1 假设了"系统能被一致地维护"，但没给机制。

### 当时的状态 (State)
- 已有：v0.1 的 6 个基础文档
- 缺：治理机制（一致性、决策反查、审计）

### 方法 (Methodology)
"硬约束 + 软机制 + 反向防御"三层框架。这个分层是因为：
- 硬约束 = 不依赖 agent 配合也能生效
- 软机制 = 依赖 agent 配合，但有流程兜底
- 反向防御 = 前两层失效时怎么救
- 没用过：纯软机制（agent 群会腐蚀软机制）

### 前提 (Assumptions)
- 假设 agent 群 > 3 个时治理才必要
- 假设"协议只读 + 签名链"在工程上可实现
- 假设人机边界（哪些事必须人类点头）是可定义的

### 已知未知 (Known-Unknowns)
- 不知道 4 层一致性（身份/协议/决策/记忆）是否覆盖所有场景
- 不知道审计机制实际能发现多少问题
- 不知道多 agent 一致性协议（n-of-n）具体怎么实现

### 历史 (Lineage)
从 v0.1 的"维护维度"中抽出"一致性"作为独立主题。
实证引用：wcaca/creation-loop v0.3 的 autonomy 4 级 / scheduler 4 节拍 / state mode 开关 / 已知部署限制。

### 基调 (Tone)
验证性。在测"v0.1 假设的'系统能被一致维护'是否可行"。

### 做了什么 (What was done)
- consistency-governance.md（4 层一致性 + 硬约束/软机制/反向防御）
- audit-protocols.md（4 层审计 + 模板 + 反模式）
- evolution.md 状态更新
- 25 文件, 3 commit (78e6507 HEAD)

### 未来伏笔 (Future Threads)
- cron 场景的具体化（"治理框架在 cron 怎么用"）
- 已知未知的工程化（"harness 怎么探测自己不知道什么"）
- 人机边界的细化（"L0-L3 权限分层在 mavis 怎么落地"）

### 反方观点 (Counter-View)
可能反对：v0.2 太学院派，没解决 mavis 自己的 cron session 写不进 sandbox 的具体问题。需要 v0.2.1 给出具体场景化。

---

## v0.2.1 · 2026-07-01（同日稍后）

### 触发 (Trigger)
对话主题（接续 v0.2）：
> "cron 的使用特别依赖已有体系和 llm 能力，还有提示词设计，还有 harness 对这项工作的已知未知（也就是人的认知体系和行为的耦合度）这整个工作模式"

### 目的 (Purpose)
把 v0.2 的抽象治理框架**映射到 cron 这个具体场景**——验证治理框架在工程层面的可操作性。

### 当时的状态 (State)
- 已有：v0.2 的治理框架
- 缺：具体场景的应用实例

### 方法 (Methodology)
"5 层依赖"分解法。把 cron 任务的成败拆成 5 个层次（基础设施 / LLM 能力 / prompt 设计 / harness 元认知 / 人机耦合），每层对应具体的失败模式和设计模式。
- 没用过：单层深挖（容易只见树木不见森林）

### 前提 (Assumptions)
- 假设 cron 是 agent harness 的"集成测试"——治理框架设计行不行，跑 cron 任务就知道
- 假设"自完备 prompt"是可实现的（虽然比对话 prompt 难 10 倍）

### 已知未知 (Known-Unknowns)
- 不知道自动生成自完备 cron prompt 是否可行
- 不知道 mavis harness 自身的 cron 健康度
- 不知道沉默失败的检测方案

### 历史 (Lineage)
从 v0.2 的"软机制"扩展到 cron 场景的具体模式。
实证案例：wcaca/creation-loop v0.3 的"已知部署限制"（cron session 写不进 sandbox）正好是 v0.2.1 第 1 层依赖的实例。

### 基调 (Tone)
应用性。把抽象落到具体。

### 做了什么 (What was done)
- cron-as-system-mirror.md（5 层依赖 + 6 反模式 + 6 模式 + 7 开放问题）
- evolution.md 状态更新
- 26 文件, 4 commit (eb3b47f HEAD)

### 未来伏笔 (Future Threads)
- 自完备 cron prompt 模板（具体协议）
- mavis 自身 cron 任务加"已知未知"清单（自我应用）
- 沉默失败检测机制（开放问题 2）

### 反方观点 (Counter-View)
可能反对：v0.2.1 太具体，可能让研究失去通用性。需要 v0.3 把"语境保存"这种更通用的元机制拉回来。

---

## v0.3 · 2026-07-01（同日更晚）

### 触发 (Trigger)
对话主题：
> "这种语境保存能力和语境下的本次对话所延伸的对话趋势的预判能力如何增强研究信息的文件管理，进而如何系统利用这项增强能力"

### 目的 (Purpose)
解决一个被忽视的问题：**研究的"语境"不是装饰，是研究本身的一部分**。没有语境保存的研究，未来回看时只能看到结论，看不到当时怎么想、为什么这么想。

把"语境 + 趋势预判"沉淀成机制 = 把研究仓从"档案柜"升级为"活的认知系统"。

### 当时的状态 (State)
- 已有：v0.1 / v0.2 / v0.2.1 的 9 个核心文档
- 缺：
  - evolution.md 只有"做了什么"，没有"为什么 / 当时怎么想"
  - 没有"语境保存"的元机制
  - 没有"趋势预判"的工具化

### 方法 (Methodology)
"3 层语境 + 8 维度"双轨设计：
- 3 层 = ephemeral（一次性）/ linked（链接对话）/ versioned（commit 时快照）
- 8 维度 = 触发 / 目的 / 状态 / 方法 / 前提 / 已知未知 / 历史 / 基调
- 不用：纯文档记录（无结构 → 难用）

### 前提 (Assumptions)
- 假设未来回看时，需要的不仅是"结论"，更是"推理链"
- 假设"语境保存"是研究的内禀属性，不应外部强加
- 假设 LLM 预判对话趋势是可行的（基于历史对话模式）

### 已知未知 (Known-Unknowns)
- 不知道 8 个维度是否覆盖所有必要信息（可能漏了"协作方" / "成本" 等）
- 不知道"心境笔记"会不会变成形式主义
- 不知道跨 session 怎么共享语境（mavis cron session 写不进工作区是已知限制）
- 不知道"趋势预判"会不会过度引导研究方向

### 历史 (Lineage)
- 从 v0.2.1 的"已知未知清单"扩展到"语境保存模型"
- 从 creation-loop 的"管理方式本身可被改"理念深化
- 跟 mavis harness 自身的 "memory" 机制形成对照（仓的语境 = harness 的 memory）

### 基调 (Tone)
元研究。问的不是"agent harness 怎么设计"，而是"研究本身怎么设计"。

### 做了什么 (What was done)
- 80-meta/context-preservation.md（主文档：3 层模型 + 8 维度 + 4 张力）
- 90-conventions/context-snapshot-template.md（操作模板：完整版 + 简化版）
- evolution.md 重写为 8 维度格式（示范）
- 80-meta/trend-prediction.md（v0.3 后续：预判机制）

### 心境笔记 (Mind-State)
今天用户连续追问 4 轮研究性问题，每一轮都比上一轮更深。我感觉我自己在这种对话里学到的可能比仓里写下来的还多。但写下"心境笔记"是因为：未来回看时，连这种"对话密度"本身也是语境的组成部分。

### 未来伏笔 (Future Threads)
- 自动生成 Layer 1 心境笔记的机制（开放问题 1）
- 跨 session 语境共享协议（开放问题 4）
- 语境保存的"完整性"验证机制（开放问题 2）
- 趋势预判工具化（v0.3 后续 commit）

### 反方观点 (Counter-View)
可能反对：语境保存可能让仓变日记，违背"研究产品"的目标。
- 回应：8 维度必填 + 简化版可用，控制负担
- 回应：80-meta 是过程记录，主目录仍是成果展示
- 但这个反方观点本身值得持续观察，作为 v0.4 的评估维度

---

## 演进方向（v0.4+ 计划）

| 版本 | 主题 | 状态 |
|---|---|---|
| v0.4 | 趋势预判工具化 + 跨 session 语境共享 | 待启动 |
| v0.5 | 30-protocols 第一个具体协议（cron-prompt-template） | 待启动 |
| v0.6 | harness 评测指标清单 + 第一个真实审计 | 待启动 |
| v0.7 | LLM 能力边界研究（v0.3 的延伸：cron 第 2 层依赖展开）| 待启动 |
| v0.8 | 意识研究（v0.1 research-map 里排期 v0.4 的项）| 待启动 |
| v0.9 | 跨方向交叉（agent + LLM + 意识的综合视角）| 待启动 |

---

## 演进元规则

> **每个 v0.X 段必须包含 8 个维度的最小集**：触发、目的、状态、方法、前提、已知未知、历史、基调。
> 
> 心境笔记 / 未来伏笔 / 反方观点是可选，但**强烈建议**至少填心境（个人项目）。
> 
> 没有按 8 维度写的版本 = 缺失语境 = 未来回看时无法复现推理链。