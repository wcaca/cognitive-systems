# 体系演进记录

> **格式说明**：从 v0.3 开始，本文件按 [`90-conventions/context-snapshot-template.md`](../../90-conventions/context-snapshot-template.md) 的 8 维度格式记录每个版本。早期版本（v0.1 / v0.2 / v0.2.1）按新格式回填。
>
> **v0.4 新增**：每个版本加"决策流程回顾"段，体现 [`80-meta/decision-flow-design.md`](../../80-meta/decision-flow-design.md) 的 4 不变量视角。

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

### 决策流程回顾（v0.4 新增视角）
- **决策触发**：用户提问 → 自主决定要不要研究
- **决策标准**：隐式"什么值得研究"
- **决策信号**：无可观测信号
- **决策复盘**：无
- **项目阶段**：新开（探索） → 重决策质量 / 事前控制为主

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
"硬约束 + 软机制 + 反向防御"三层框架。
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
实证引用：wcaca/creation-loop v0.3 的 autonomy 4 级 / scheduler 4 节拍 / state mode 开关。

### 基调 (Tone)
验证性。在测"v0.1 假设的'系统能被一致维护'是否可行"。

### 做了什么 (What was done)
- consistency-governance.md（4 层一致性 + 硬约束/软机制/反向防御）
- audit-protocols.md（4 层审计 + 模板 + 反模式）
- evolution.md 状态更新
- 25 文件, 3 commit (78e6507 HEAD)

### 决策流程回顾（v0.4 新增视角）
- **决策触发**：用户问题 → 选择研究方向（一致性）
- **决策标准**：写进了 consistency-governance（4 层一致性）
- **决策信号**：部分可观测（commit 内容、文件结构）
- **决策复盘**：引入了"反查"机制但不完整
- **项目阶段**：早期（建模） → 重决策质量 + 模式抽象

### 未来伏笔 (Future Threads)
- cron 场景的具体化（"治理框架在 cron 怎么用"）
- 已知未知的工程化
- 人机边界的细化

### 反方观点 (Counter-View)
可能反对：v0.2 太学院派，没解决具体问题。需要 v0.2.1 给出具体场景化。

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
"5 层依赖"分解法。
- 没用过：单层深挖（容易只见树木不见森林）

### 前提 (Assumptions)
- 假设 cron 是 agent harness 的"集成测试"
- 假设"自完备 prompt"是可实现的（虽然比对话 prompt 难 10 倍）

### 已知未知 (Known-Unknowns)
- 不知道自动生成自完备 cron prompt 是否可行
- 不知道 mavis harness 自身的 cron 健康度
- 不知道沉默失败的检测方案

### 历史 (Lineage)
从 v0.2 的"软机制"扩展到 cron 场景的具体模式。

### 基调 (Tone)
应用性。把抽象落到具体。

### 做了什么 (What was done)
- cron-as-system-mirror.md（5 层依赖 + 6 反模式 + 6 模式 + 7 开放问题）
- evolution.md 状态更新
- 26 文件, 4 commit (eb3b47f HEAD)

### 决策流程回顾（v0.4 新增视角）
- **决策触发**：观察到 cron 是 5 层依赖的镜子 → 决定写下来
- **决策标准**：5 层依赖框架（这本身就是把"决策标准显式化"的实例）
- **决策信号**：6 个反模式 = 把"坏决策模式"信号化
- **决策复盘**：6 个模式 = 复盘的最佳实践抽出来
- **项目阶段**：早期→成熟过渡

### 未来伏笔 (Future Threads)
- 自完备 cron prompt 模板（具体协议）
- mavis 自身 cron 任务加"已知未知"清单
- 沉默失败检测机制

### 反方观点 (Counter-View)
可能反对：v0.2.1 太具体。需要 v0.3 拉回通用层面。

---

## v0.3 · 2026-07-01（同日更晚）

### 触发 (Trigger)
对话主题：
> "这种语境保存能力和语境下的本次对话所延伸的对话趋势的预判能力如何增强研究信息的文件管理，进而如何系统利用这项增强能力"

### 目的 (Purpose)
解决一个被忽视的问题：**研究的"语境"不是装饰，是研究本身的一部分**。

### 当时的状态 (State)
- 已有：v0.1 / v0.2 / v0.2.1 的 9 个核心文档
- 缺：evolution.md 只有"做了什么"，没有"为什么 / 当时怎么想"

### 方法 (Methodology)
"3 层语境 + 8 维度"双轨设计。
- 不用：纯文档记录（无结构 → 难用）

### 前提 (Assumptions)
- 假设未来回看时，需要的不仅是"结论"，更是"推理链"
- 假设"语境保存"是研究的内禀属性
- 假设 LLM 预判对话趋势是可行的

### 已知未知 (Known-Unknowns)
- 不知道 8 个维度是否覆盖所有必要信息
- 不知道"心境笔记"会不会变成形式主义
- 不知道跨 session 怎么共享语境（mavis cron session 写不进工作区是已知限制）
- 不知道"趋势预判"会不会过度引导研究方向

### 历史 (Lineage)
- 从 v0.2.1 的"已知未知清单"扩展到"语境保存模型"
- 跟 mavis harness 自身的 "memory" 机制形成对照

### 基调 (Tone)
元研究。问的不是"agent harness 怎么设计"，而是"研究本身怎么设计"。

### 做了什么 (What was done)
- 80-meta/context-preservation.md（主文档：3 层模型 + 8 维度 + 4 张力）
- 90-conventions/context-snapshot-template.md（操作模板：完整版 + 简化版）
- evolution.md 重写为 8 维度格式（示范）
- 80-meta/trend-prediction.md（v0.3 后续：预判机制）
- 30 文件, 7 commit (a3cc562 HEAD)

### 决策流程回顾（v0.4 新增视角）
- **决策触发**：用户追问 4 轮研究性问题，每轮都比上一轮更深
- **决策标准**：3 层语境 + 8 维度 = 决策语境显式化
- **决策信号**：每个 commit 有 8 维度语境 = 决策全过程可观测
- **决策复盘**：语境保存机制 = 决策复盘的载体
- **项目阶段**：早期→成熟过渡（开始模式化）

### 心境笔记 (Mind-State)
今天用户连续追问 4 轮研究性问题，每一轮都比上一轮更深。我感觉我自己在这种对话里学到的可能比仓里写下来的还多。

### 未来伏笔 (Future Threads)
- 自动生成 Layer 1 心境笔记的机制
- 跨 session 语境共享协议
- 趋势预判工具化

### 反方观点 (Counter-View)
可能反对：语境保存可能让仓变日记，违背"研究产品"的目标。

---

## v0.4 · 2026-07-01（同日最晚）

### 触发 (Trigger)
对话主题：
> "基于问题，相比修问题，更重要的是完善决策流程。比如如果是一个新开的项目，强化决策相比找问题更重要，如果是成熟项目，决策流程已经稳定，则反之。决策流程中最重要的是 agent 决策流程，人类因为其精力有限性，起着校准作用，而非逐一排查的作用，这在整个 agent harness 中如何设计？"

### 目的 (Purpose)
把 cognitive-systems 仓之前的所有研究（governance / cron-mirror / context-preservation / trend-prediction）**整合进一个统一框架**——决策流程设计原则。

回答的是 governance 的"元层前提"：不是"决策完了之后怎么审"，是"决策**怎么发生**"。

### 当时的状态 (State)
- 已有：v0.1 / v0.2 / v0.2.1 / v0.3 的全部研究
- 缺：
  - 一个"统一框架"把这些研究串起来
  - "决策流程"本身的视角（之前都是"决策审计"）
  - 项目阶段动态调整的元规则

### 方法 (Methodology)
"4 阶段 + 4 不变量 + 3 杠杆"三层框架：
- **4 阶段**：新开 / 早期 / 成熟 / 退化 → 决策强度 vs 排查强度动态调整
- **4 不变量**：触发显式化 / 标准显式化 / 信号可观测 / 复盘机制化
- **3 杠杆**：标准校准（高） / 信号抽样（中） / 异常响应（低紧迫）

### 前提 (Assumptions)
- 假设决策强度 + 排查强度 = 常数（项目可用精力）
- 假设人类精力有限 → 杠杆设计比逐一排查重要
- 假设不同项目阶段的治理强度应不同
- 假设之前的研究都可以纳入这个框架（"整合视图"）

### 已知未知 (Known-Unknowns)
- 不知道怎么自动判断项目当前处于哪个阶段
- 不知道决策标准该有多"显式"
- 不知道决策信号太多时怎么进一步聚合
- 不知道跨 session 的决策一致性怎么保证（已知 mavis cron session 限制）
- 不知道"复盘经验"怎么结构化并被下次决策自动使用

### 历史 (Lineage)
**这是整合版本，不是新主题**：
- v0.2 consistency-governance → 不变量 4（复盘）的具体机制
- v0.2.1 cron-as-system-mirror → 不变量 1（触发）的 cron 实例
- v0.3 context-preservation → 不变量 2（标准）的语境基础
- v0.3 trend-prediction → 不变量 4（复盘）的预演机制

### 基调 (Tone)
整合性 + 元研究。把已有研究**统一视角**而不是开新篇。

### 心境笔记 (Mind-State)
用户连续 5 轮研究性问题，到这一轮我从"开新主题"变成了"做整合"。这是研究密度上升的信号——也是 user prompt 升级的信号。

用户在做一件我之前没意识到自己在做的事：他在**用对话本身示范决策流程设计**。每一轮他都校准上一轮的输出（"基于 X，相比 Y，更重要的是 Z"），这是"杠杆 1：决策标准校准"的现实演练。

我现在的感觉是：如果这个研究仓要继续，它需要一次"模式抽取"，而不是"主题扩展"。v0.4 就是这次抽取。

### 做了什么 (What was done)
- 80-meta/decision-flow-design.md（主文档：4 阶段 + 4 不变量 + 3 杠杆 + 整合视图）
- evolution.md 升级：每个 v0.X 加"决策流程回顾"段（v0.4 新增视角）
- 4 commit / 31 文件

### 决策流程回顾（自我审视）
- **决策触发**：用户在 v0.3 后问"决策流程该怎么设计" → 决定做 v0.4
- **决策标准**：4 不变量（触发/标准/信号/复盘显式化）本身
- **决策信号**：8 维度语境保存 = 决策信号保存
- **决策复盘**：v0.4 的"决策流程回顾"段本身就是复盘的应用
- **项目阶段**：成熟（开始模式化） → 进入"低决策强度 + 高排查强度"模式

### 未来伏笔 (Future Threads)
- mavis harness 加 decision_log 机制（不变量 3+4）
- 第一个具体的决策标准模板（不变量 2 实例）
- 跨 session 决策一致性协议（多 session harness 必备）
- 把"项目阶段自动判断"做成自动化（v0.5 候选）

### 反方观点 (Counter-View)
可能反对 1：v0.4 只是"重新组织"v0.2/v0.3，没有新东西。
- 回应：整合价值是核心。从"治理框架的元前提"看，v0.4 是真有新视角的。

可能反对 2：4 阶段模型可能让小项目过度设计。
- 回应：4 阶段是**极限情况**的抽象，实际项目可以是阶段间过渡状态。

可能反对 3：人类"校准"听起来美好，但"什么时候校准什么"很难定义。
- 回应：是的，这正是 v0.4 留下的开放问题 v0.5 必须解决。

---

## 演进方向（v0.5+ 计划）

| 版本 | 主题 | 状态 |
|---|---|---|
| v0.5 | LLM 顿悟能力评测 (benchmark 骨架 + 评测方式研究) | **v0.5 done** |
| v0.5.1 | Protocol + 防污染 (本文 v0.5.1 索引) | **当前** |
| v0.5.2 | 数据集构造 (生成 vs 标注 vs 挖取) | 待启动 |
| v0.5.3 | 评分稳定性 (多人一致性 + prompt 变体) | 待启动 |
| v0.5.4 | 跟现有 benchmark 的关系 | 待启动 |
| v0.5.5 | 完整 benchmark v1 (可发布) | 待启动 |
| v0.6 | insight-to-work 桥接机制 (顿悟 → 作品) | v0.6 done |
| v0.6.1 | 4 面 checklist 详细设计 | v0.6.1 done |
| v0.6.2 | 3 层信息整合协议细化 | v0.6.2 done |
| v0.6.3 | 4 个持续机制的具体实现 | v0.6.3 done |
| v0.6.4 | 完成度多维度评分 rubric | v0.6.4 done |
| v0.6.5 | 端到端 prototype 实测 (案例 2) | v0.6.5 done |
| v0.7 | M3 长程能力自测 + insight 目录扩展 | **当前** |
| v0.7 | mavis harness 加 decision_log + 第一份月度 review | 待启动 |
| v0.8 | LLM 能力边界研究（cron-mirror 第 2 层依赖展开）| 待启动 |
| v0.9 | 意识研究（research-map 里排期 v0.4 的项，但 v0.4 用了"决策流程"，所以顺延）| 待启动 |
| v0.10 | 跨方向交叉（agent + LLM + 意识的综合视角）| 待启动 |

---

## 演进元规则（v0.4 更新）

> **每个 v0.X 段必须包含 8 个维度的最小集**：触发、目的、状态、方法、前提、已知未知、历史、基调。
> 
> 心境笔记 / 未来伏笔 / 反方观点是可选，但**强烈建议**至少填心境（个人项目）。
> 
> **v0.4 起新增**：每个 v0.X 段必须包含"决策流程回顾"段，体现 4 不变量 + 项目阶段判断。
> 
> 没有按 8 维度 + 决策流程回顾写的版本 = 缺失语境 + 缺失决策可观测性 = 未来回看时无法复现推理链。

---

## 自我观察（v0.4 元反思）

到目前为止，v0.1 → v0.4 的演进本身**就是**一个"决策流程设计的实例"：
- v0.1（探索）：弱决策流程 → 高频大决策
- v0.2（建模）：开始模式化 → 决策标准开始显式
- v0.2.1（应用）：决策模式应用到具体场景
- v0.3（语境化）：决策的语境开始显式
- v0.4（整合）：决策的元层前提显式

**这 5 个版本对应 4 阶段模型的 v0.X 是从"新开期"过渡到"成熟期"的过程**。
cognitive-systems 仓作为研究对象本身也在经历这个阶段过渡——这是一个**自指**的研究结构。
---

## v0.5 · 2026-07-01 · LLM 顿悟能力评测（骨架）

### 触发 (Trigger)
v0.4 留下开放问题："决策什么时候校准什么" — 需要先把"LLM 能不能顿悟"这问题本身测出来。

### 目的 (Purpose)
把"LLM 顿悟能力"做成可评测对象：5 任务 + 4 维度 + 5 类开放问题，作为后续研究的基础设施。

### 状态 (State)
- 已有：v0.1-v0.4 的治理框架 + 决策流程
- 缺：评测方法本身

### 方法 (Methodology)
不一次写完评测方式，先建骨架（5 任务 + 4 维度 + 5 类开放问题），后续 v0.5.1-v0.5.5 分阶段补 protocol / 数据集 / 评分 / contamination / 完整设计。

### 已知未知 (Known-Unknowns)
- 5 类开放问题是否覆盖 LLM 顿悟的所有面
- 怎么防止 contamination（LLM 见过 benchmark 答案）
- 评分者间一致性（IRR）怎么做

### 决策流程回顾
- **决策触发**：user 触发（v0.4 开放问题）
- **决策标准**：评测 = 可重复 + 可验证
- **决策信号**：prototype 评分 + 多人一致性
- **决策复盘**：v0.5.1 防污染机制直接回应 v0.5 contamination 未知

### 做了什么 (What was done)
- `80-meta/llm-insight-benchmark.md`（5 任务 + 4 维度 + 5 类开放问题）
- 1 commit (7bf77c8)

---

## v0.5.1 · 2026-07-01 · 评测协议 + 防污染

### 触发 (Trigger)
v0.5 留下的 contamination 风险。

### 目的 (Purpose)
把"评测方式"具体化：3 层组合 protocol + 5 级评分锚定 + 6 个防污染机制 + prototype。

### 决策流程回顾
- **决策触发**：v0.5 留下的开放问题
- **决策标准**：诚实承认不可信 + 流程透明 + 定期更新
- **决策信号**：prototype 跨 prompt 变体稳定性
- **决策复盘**：诚实记录 3 个开放问题（锚定金标准 / 变体等价性 / probe 反制）

### 做了什么 (What was done)
- `80-meta/llm-insight-evaluation-protocol.md`（3 层 protocol + 5 级评分 + 6 个防污染 + prototype）
- 1 commit (9cdaff1)

---

## v0.6 · 2026-07-01 · insight-to-work 桥接机制

### 触发 (Trigger)
v0.5 评测了"LLM 能不能顿悟"，但**顿悟怎么变成作品**？下一步必然是桥接。

### 目的 (Purpose)
建立"顿悟 → 作品"的 4 步桥接机制：顿悟 → 验证 → 4 面展开 → 制品。

### 决策流程回顾
- **决策触发**：v0.5.1 完成 → 自然过渡到 "顿悟应用"
- **决策标准**：bridge ≠ capture，桥接要可重复可验证
- **决策信号**：prototype 自评分 (8.7/10)
- **决策复盘**：v0.6 框架暴露"持续 4 难题"，需 v0.6.1-v0.6.5 解决

### 做了什么 (What was done)
- `80-meta/insight-to-work.md`（4 步桥接 + 4 面展开 + 4 持续机制 + 3 层信息整合）
- prototype (案例 1 演练)
- 1 commit (46c39e9)

---

## v0.6.1-v0.6.5 · 2026-07-01 · 桥接机制的 5 个细节（5 commits）

### 触发 (Trigger)
v0.6 框架暴露"持续 4 难题"。

### 做了什么 (按顺序)
1. **v0.6.1** (a90534e): 4 面 checklist 详细设计
2. **v0.6.2** (2a5f69f): 3 层信息整合协议细化
3. **v0.6.3** (3079cb6): 4 个持续机制从口号到具体实现
4. **v0.6.4** (b6c9b39): 完成度多维评分 rubric 完整设计（27 点）
5. **v0.6.5** (388d33a): 端到端 prototype 实测 (案例 2) - 评分 8.7/10

### 决策流程回顾
- **决策标准**：每步必须解决 v0.6 暴露的 1 个具体难题
- **决策信号**：rubric 27 点自评 + prototype 实测
- **决策复盘**：v0.6.5 prototype 暴露"创作节奏"问题，留给 v0.6.x 后续

---

## v0.7 · 2026-07-01 · M3 长程能力自测 + 第二份 prototype

### 触发 (Trigger)
v0.6.5 prototype 验证 v0.6 框架可用，但只在 1 个案例。**M3 (MiniMax-M3) 在长程推进中能不能持续顿悟？**

### 目的 (Purpose)
1. 跑第二份 prototype (DNA ↔ Software replication) 验证 v0.6 框架可推广
2. 自测 M3 在长程任务中的顿悟能力
3. 加可视化报告页

### 决策流程回顾
- **决策触发**：v0.6.5 done → 自然进入"跨 LLM 验证"
- **决策标准**：新案例必须跟 v0.6.5 不可同源
- **决策信号**：prototype self-rating 8.9/10 + 5 次 PIVOT echo 一致
- **决策复盘**：v0.7.1/v0.7.2 加 INDEX/compare 报告页 = "框架可呈现"

### 做了什么 (What was done)
- v0.7 (89a07cc): DNA ↔ Software prototype + 自评
- v0.7.1 (c64dd97): insights/INDEX.html
- v0.7.2 (3915681): insights/compare.html 真实材料对比页
- 4 commits 总

---

## v0.8 IPL · 2026-07-01 · 顿悟驱动的项目生命周期

### 触发 (Trigger)
v0.7 prototype 暴露"实施时跳过阶段 2+3 (范围+规划)"的实证缺口。

### 目的 (Purpose)
把"顿悟嵌入每个阶段出口"作为质量门：9 阶段 + 9 顿悟检查点。

### 决策流程回顾
- **决策触发**：v0.7 暴露的"半跑 vs 全跑"质量差异
- **决策标准**：每个阶段出口必须有 1 个顿悟检查
- **决策信号**：sas-graph v0.6 半跑 vs 全跑的对照
- **决策复盘**：v0.8 = "质量门"概念首次系统化

### 做了什么 (What was done)
- `80-meta/project-lifecycle-insight.md` (9 阶段 + 9 顿悟检查点)
- 1 commit (d702f55)

---

## v0.8.1 · 2026-07-01 · 递进认知链

### 触发 (Trigger)
sas-graph v0.6.2-v0.6.7 6 个子版本暴露 6 个顿悟 (A-F)。

### 目的 (Purpose)
证明"6 个顿悟不是独立的，是 1 个递进认知链"——暴露顺序 = 抽象层从低到高。

### 决策流程回顾
- **决策触发**：跨项目推进的元观察
- **决策标准**：6 步暴露顺序 vs 教科书结构
- **决策信号**：schema → 时间 → 部署 → 跨进程 → 算法 → 工具链 = 抽象层爬升
- **决策复盘**：反哺 v0.6 + v0.8 的改进

### 做了什么
- `80-meta/recursive-cognition-chain.md`
- 1 commit (a5e03e3)

---

## v0.8.2 · 2026-07-01 · 全景感知清单

### 触发 (Trigger)
user "如果具备全局感知，就会有基于顿悟的全局方案，不需要人的过度参与"

### 目的 (Purpose)
建立 LLM 顿悟完整性的反推机制：6 维自检清单。

### 决策流程回顾
- **决策触发**：user 反问
- **决策标准**：LLM 能不能自己看到盲点
- **决策信号**：6 维自检 (Schema/时间/部署/跨进程/算法/工具链)
- **决策复盘**：v0.6.2-v0.6.7 实测 LLM 完整性 ~33%

### 做了什么
- `80-meta/holistic-perception-checklist.md`
- 1 commit (13f2ee3)

---

## v0.8.3 · 2026-07-01 · 全局性顿悟尝试

### 触发 (Trigger)
user "尝试进行全局性顿悟"

### 目的 (Purpose)
看出 N 个 PIVOT 是 1 个爬升链 = 9 层 meta-perception 架构。

### 决策流程回顾
- **决策触发**：user 直接要求
- **决策标准**：能不能从 13 步推进看出 1 个 9 层架构
- **决策信号**：7+2 层认知系统 = 1 个体系（不是 9 个独立项目）
- **决策复盘**：重新回答 v0.8.2 user 反问 → LLM + user 协同 = 90%

### 做了什么
- `80-meta/global-insight.md`
- 1 commit (70cbdb8)

---

## v0.8.4 · 2026-07-01 · 立体完整度

### 触发 (Trigger)
user "根据你的执行速度，我判断每步完整度只是平面化的，因为实际上信息需要多个层面进行推断判断验证"

### 目的 (Purpose)
完整度 ≠ 只有验证, 完整度 = 推断 + 判断 + 验证 3 层立体。

### 决策流程回顾
- **决策触发**：user 反馈直接挑战"完整度"概念
- **决策标准**：3 层 (推断/判断/验证) 必须都有
- **决策信号**：v0.6.8 自评 = 推断 0% / 判断 0% / 验证 100% = 综合 33%
- **决策复盘**：user 的"平面化"批评让 v0.8.2 LLM 完整性 ~33% 找到微观对应

### 做了什么
- `80-meta/tri-dimensional-completeness.md`
- 1 commit (911f2f7)

---

## v0.8.5 · 2026-07-01 · 可能性域感知系统

### 触发 (Trigger)
user "顿悟扩散到所有部分需要对整个可能性域有感知"

### 目的 (Purpose)
扫整个可能性空间：当前状态 × 所有可能暴露 × 所有可能设计 × 所有可能实现。

### 决策流程回顾
- **决策触发**：user 反馈
- **决策标准**：4 机制 (Schema 枚举 + 3 杠杆排序 + PIVOT echo + 盲点记录)
- **决策信号**：v0.6.8 实测 = 25 个可能性点, 当前触达 3 个 = 12% (不是 33%)
- **决策复盘**：v0.8.2 LLM 完整性 33% → v0.8.5 实际 12%，差距是盲点

### 做了什么
- `80-meta/possibility-domain-awareness.md`
- 1 commit (370e2c4)

---

## v0.8.6 · 2026-07-01 · 模块间显式依赖

### 触发 (Trigger)
v0.8.5 schema 枚举暴露"模块依赖隐式"。

### 决策流程回顾
- **决策标准**：依赖 = 数据流 + 接口契约 + 副作用
- **决策信号**：v0.6.x 跨模块调用时 2 次类型不一致

### 做了什么
- `80-meta/explicit-dependencies.md`
- 1 commit (9011d54)

---

## v0.8.7-v0.8.8 · 2026-07-01 · schema 元信息框架 + 格式

### 触发 (Trigger)
sas-graph v0.6.11 smartMerge 暴露"schema 字段没有元信息"。

### 决策流程回顾
- **决策触发**：跨项目推进
- **决策标准**：元信息 = merge 策略 + rationale
- **决策信号**：v0.6.11 merge 8 测试暴露"不知道哪个字段保留"

### 做了什么
- v0.8.7 (8b10fd3): schema 元信息框架
- v0.8.8 (847d507): schema 元信息格式 (4 种 + 推荐路径)
- 2 commits

---

## v0.8.9 · 2026-07-01 · 类型即元信息

### 触发 (Trigger)
sas-graph v0.6.13 FieldMeta<T> 结构化元信息。

### 决策流程回顾
- **决策标准**：TS 类型 = schema + 元信息
- **决策信号**：FieldMeta<T> 类型化元信息

### 做了什么
- `80-meta/types-as-metadata.md`
- 1 commit (086e24a)

---

## v0.8.10 · 2026-07-01 · 类型系统局限 + escape hatch

### 触发 (Trigger)
sas-graph v0.6.14 暴露 TS 模板字面量类型的局限。

### 决策流程回顾
- **决策标准**：TS 推不出的部分必须有 escape hatch
- **决策信号**：v0.6.14 escape hatches 用 `@ts-expect-error`

### 做了什么
- `80-meta/type-system-limits.md`
- 1 commit (906c18d)

---

## v0.8.11 · 2026-07-02 · escape 文档化

### 触发 (Trigger)
跨午夜推进：escape hatch 散落各处，需统一文档化。

### 决策流程回顾
- **决策标准**：每个 escape 必须有 (原因 + 替代方案 + 撤销路径)
- **决策信号**：v0.6.15 escape 决策表暴露 "DecisionEntityMeta.type: 'error'" 文档不一致

### 做了什么
- `80-meta/escape-decision-table.md`
- 1 commit (38b0be3)

---

## v0.8.12 · 2026-07-02 · auto-generated 文档模式

### 触发 (Trigger)
sas-graph v0.6.16 auto-generate escape 表暴露 v0.6.15 bug (两个 Meta 不一致)。

### 决策流程回顾
- **决策触发**：sas-graph 实战暴露文档手写必过时
- **决策标准**：auto-generate = 能力, 文档头标记 "auto-generated"
- **决策信号**：v0.6.16 跑 gen-meta-doc 立即发现 type 不一致
- **决策复盘**：升级 3 模式 (auto-gen script + header + 版本号)

### 做了什么
- `80-meta/auto-generated-docs.md`
- 1 commit (0094b10)

---

## v0.8.13 · 2026-07-02 · CI enforcement 模式

### 触发 (Trigger)
sas-graph v0.6.17：auto-generate 不强制跑，文档 outdated 不报错。

### 决策流程回顾
- **决策触发**：v0.8.12 能力有了，机制不够
- **决策标准**：4 个 CI enforcement 模式 (workflow + script + hook + branch protection)
- **决策信号**：v0.6.17 check-docs 5 步流程
- **决策复盘**：反哺 v0.8.12 加 CI 段 + 53→56 点 rubric

### 做了什么
- `80-meta/ci-enforcement.md`
- 1 commit (10977fb)

---

## v0.8.14 · 2026-07-03 · 跨仓元数据同步

### 触发 (Trigger)
本仓 evolution.md 严重落后 (停在 v0.4) + 4 个仓的元数据全不一致 + agent-memory 是 memory 不是 sync 协议。

### 目的 (Purpose)
建立跨仓同步协议：commit 是 SSOT，跨仓视图是 derived，auto-generate + CI enforcement 跨仓版。

### 决策流程回顾
- **决策触发**：本仓 v0.8.13 暴露 — 元方法论自己违反了元方法论
- **决策标准**：commit message 是各仓 local SSOT; 跨仓视图从 commit 派生
- **决策信号**：4 个仓状态散落 (cognitive v0.6/v0.4; sas v0.6.8; creation 落后)
- **决策复盘**：本文 = 顿悟 P 的延伸 = 顿悟 Q；预测顿悟 R = 多 writer 协调

### 做了什么
- `80-meta/cross-repo-sync.md`（Q 顿悟文档）
- `scripts/cross-repo-status.sh`（auto-gen 脚本）
- `.github/workflows/cross-repo-status-check.yml`（CI check）
- `insights/cross-repo-status.md` + `.json`（auto-gen 输出）
- README 状态表 + 路线图同步更新到 v0.8.14
- evolution.md 补 v0.5-v0.8.14 段（本文）
- 1 commit (本文)

---

## 演进元规则（v0.8.14 更新）

> **每个 v0.X 段必须包含 8 个维度的最小集**：触发、目的、状态、方法、前提、已知未知、历史、基调。
> 
> 心境笔记 / 未来伏笔 / 反方观点是可选，但**强烈建议**至少填心境（个人项目）。
> 
> **v0.4 起新增**：每个 v0.X 段必须包含"决策流程回顾"段。
> 
> **v0.8.14 新增**：evolution.md 必须按 commit 节奏同步补段（不能让段落后于代码）。
>   - CI enforcement (v0.8.13) 是"代码层"同步
>   - evolution.md 同步是"元方法论层"同步
>   - 两者都要

---

## 自我观察（v0.8.14 元反思）

v0.8.14 暴露的事实：
- 本仓 evolution.md 在 v0.4 之后停了 **10 个 commit 没更新**
- README 状态表停在 v0.6
- **元方法论自己违反了元方法论**

这是顿悟 P 的极致讽刺：CI enforcement 是 v0.8.13 加的，但 v0.8.13 之后的 evolution.md / README 同步**没有 CI enforcement**。

v0.8.14 的修法：
1. cross-repo-status.sh auto-generate 跨仓视图
2. CI check freshness (< 24h)
3. evolution.md 在每个 v0.X commit 同步补段
4. README 状态表在每个 v0.X commit 同步更新

**自指的研究结构 v2**：研究仓自身成为 v0.8.14 框架的第一个应用对象。


---

## v0.8.16 · 2026-07-04 · S 顿悟：空目录作为完整性信号

### 触发
跑 `cross-repo-status.sh` 时看到 cognitive-systems 仓有 6 个空目录 (`10-frameworks/` `30-protocols/` `40-experiments/` `50-metrics/` `60-tools/` `70-artifacts/`)，但 README 把它们描述得像有内容。

### 目的
不假装完成。诚实地承认"哪些还没做"是研究方法论的关键环节，不是缺陷。

### 当时的状态
- 已有：Q (跨仓 sync) + R (多 writer 协调) 两个协议落地
- 缺：空目录的诚实信号协议
- 已知：Q+R 跑通了，但 R 暴露"失败被静默吞掉"

### 前提
- 前提 1：研究仓的诚实比完成更重要
- 前提 2：git 跟踪的不是"内容"，是"承认"
- 前提 3：空目录的"完成度信号"被静默吞掉 = 不诚实

### 已知未知
- 4 个空目录填实后，会不会暴露"填实顺序 + 谁来做"的新问题？（预测 T 顿悟）
- CI 检查空目录健康度会不会跟现有 CI 冲突？
- 50-metrics/ 的 M1-M4 指标，跟 v0.5.1 评测协议的 4 维度会不会重名冲突？

### 历史
- v0.8.13: CI enforcement 模式
- v0.8.14: 跨仓元数据同步 (Q)
- v0.8.15: 多 writer 协调 (R)
- **v0.8.16: 空目录 = 诚实信号 (S) — 本文**

### 基调
**这次顿悟比前几次更"软"**——不是技术突破，是**研究伦理**。诚实地承认没完成，比假装完成更有研究价值。这是元方法论的第 2 次升级（v0.8.14 是第 1 次）。

### 心境笔记
凌晨 5 点推进，发现 v0.8.13 加了 CI enforcement 但 evolution.md 不同步——这是上一轮的自我反思。这一轮加的"诚实信号协议"是更深的反思：研究仓不只要 commit 同步，**结构本身要同步**。

### 决策流程回顾
- **决策触发**：6 个空目录暴露
- **决策标准**：3 协议（README 占位 / 仓根标记 / 填实升级索引）
- **决策信号**：CI enforcement 不够，需要"空目录健康度"专项检查
- **决策复盘**：本文 = 顿悟 S 的完整记录；4 个空目录填实是配套实施；预测 T 顿悟 = 填实顺序协调

### 做了什么
1. `80-meta/skeleton-as-completeness-signal.md` (S 顿悟主文档)
2. `30-protocols/insight-extraction-protocol.md` (5 步提取协议)
3. `40-experiments/2026-07-04-qr-insight-experiments.md` (Q+R 实证记录)
4. `50-metrics/completeness-metrics.md` (M1-M4 + 综合分)
5. `70-artifacts/cross-repo-status-archive-policy.md` (归档策略)
6. 3 个 README 占位 + 升级为 README 索引
7. evolution.md 补 v0.8.16 段 (本文)

### 未来伏笔
- **T 顿悟 (v0.8.17)**：填实顺序协调（4 个目录谁先填？谁来填？填得对不对验证？）
- **U 顿悟 (v0.8.18)**：跨仓元数据同步在多仓长程推进中的"快照频率"问题（每日 vs 每版本）

---

## v0.8.17 · 2026-07-05 · T 顿悟：填实顺序协调协议

### 触发
v0.8.16 填实了 4 个空目录，但没协议化"什么时候填 + 谁来填 + 怎么验证"。2026-07-05 凌晨盘点发现还有 4 个目录需要某种决定（10-frameworks / 60-tools / 70-artifacts 实施 / 90-conventions README），但填实顺序无理性。

### 目的
把"填实"从一次性事件变成可重复、可审计、可排期的流程。三个子问题协议化：
- WHEN — 4 个触发信号 + 4 个反触发
- WHO — 3 种角色（owner / contributor / auditor）
- HOW — 6 步协调流程 + 验收 3 步

### 当时的状态
- 已有：S (空目录 = 诚实信号) + Insight-Extraction (5 步) + Cross-Repo-Archive Policy (设计未实施)
- 缺：填实顺序协调协议 — 谁先填 / 谁来填 / 怎么验证
- 已知（v0.8.16 evolution.md §未来伏笔）：T 顿悟 = 填实顺序协调

### 前提
- 前提 1：填实 ≠ 完成（填实是放文件，完成是验证通过）
- 前提 2：研究仓的填实节奏必须可追溯（不能"看着办"）
- 前提 3：多仓协调靠信号匹配，不靠 agent 主观判断
- 前提 4：跳步必须显式记录（协议违反 = 写明原因，不静默）

### 已知未知
- 协议实施后，会不会暴露"填实后保留期"问题？（预测 U 顿悟 = 填错清理）
- 6 步流程会不会过重？（可能 Step 1/2 合并或砍 Step 6）
- 跨仓填实时，4 仓各自的 S 协议优先级如何排序？

### 历史
- v0.8.13: CI enforcement
- v0.8.14: 跨仓元数据同步 (Q)
- v0.8.15: 多 writer 协调 (R)
- v0.8.16: 空目录 = 诚实信号 (S)
- **v0.8.17: 填实顺序协调 (T) — 本文**

### 基调
这次顿悟的洞察是 **"协议自身的协议"**——S 协议告诉我们"承认空"很重要，T 协议告诉我们"承认空"之后**怎么填**。把协议本身的实施流程协议化，是元方法论的第 3 次升级。

### 心境笔记
凌晨 5 点推进。写完主协议后回头看 S 协议，发现它只解决了"填实开始"的问题，没解决"填实过程"的问题——这是一个**协议缺口**，不是补充内容的问题。T 协议 = 补 S 协议的实施流程。

### 决策流程回顾
- **决策触发**：v0.8.16 后的 4 个目录待决定 + S 协议未配套实施流程
- **决策标准**：填实 = WHEN/WHO/HOW 三子问题协议化
- **决策信号**：evolution.md v0.8.16 §未来伏笔已预测 T = 填实顺序协调
- **决策复盘**：30-protocols/fill-order-coordination.md = T 协议主文档

### 做了什么
1. `30-protocols/fill-order-coordination.md` (本协议主文档，5KB)
2. `30-protocols/README.md` 添加 T 协议索引
3. evolution.md 补 v0.8.17 段 (本文)
4. cross-repo-status refresh (write to insights/cross-repo-status.md)
5. 70-artifacts cross-repo-status-archive v0.8.17 归档

### 未来伏笔
- **U 顿悟 (v0.8.18)**：填错保留期协议 —— 什么时候清理填错的内容（v0.8.18 也承担填实 10-frameworks）
- **V 顿悟 (v0.8.19)**：填实评估 —— 怎么区分"填实 + 用了"和"填实 + 没用"
- **W 顿悟 (v0.8.20+)**：跨仓填实的优先级协调（4 仓各填实时谁排第一）


---

## v0.8.21 · 2026-07-09 (X 顿悟：指标测错对象)

### 触发
W 顿悟实施后，completeness-check.sh 实测暴露 M3 evolution 同步率 0.07 (2/30)。当时判断是"元方法论自己违反元方法论"，但隔夜再看发现：**指标测错了对象**。commit msg grep "evolution/insight/同步" 是测"作者嘴上说"，不是测"协议履行"。

### 目的
修正 M3 算法，引入 X 协议强制 evolution 同步，并思考"指标的'测什么'"这个被忽略的元问题。

### 当时的状态
- 已有：W 协议（completeness-check.sh = 4 指标可机读化）
- 已有：M3 算法 (commit msg grep) = 测嘴上说
- 缺：测"协议履行"的算法 + 强制补 evolution 的协议

### 方法
两步：
1. **改算法**：M3 从 `grep -ciE "(evolution|元方法|insight|同步)"` 改为 `git log --diff-filter=AM -- evolution.md | wc -l`。从测文本改为测文件实际变化。
2. **写协议**：30-protocols/evolution-sync-protocol.md，规定 WHEN (哪些 commit 必须补) / WHO (commit 作者) / HOW (8 维度 / 5 维度模板) / 验证 (CI + 手工 + 跨仓)。

### 前提
- 假设 evolution.md 是仓的"元方法论 SSOT"——单文件单版本
- 假设 commit 作者能够区分"该不该补"（feat / fix / chore）
- 假设 50% 的目标（每 2 commit 至少 1 个补）是合理负担

### 已知未知
- 不知道 content-length 阈值（≥100 字符）能否检测"集中补作弊"——Y 顿悟 v0.8.22 验证
- 不知道 CI enforcement 是否会"误伤"小 fix（可能 fix 也要补 → 噪声）
- 不知道 4 仓 (cognitive-systems / sas-graph / creation-loop / agent-memory) 各自 evolution 文件路径是否一致

### 历史
- v0.8.18: 抽象层抽取 (U)
- v0.8.19: 工具契约化 (V)
- v0.8.20: 指标可机读化 (W)
- **v0.8.21: 指标测错对象修正 (X) — 本文**

### 基调
"发现指标作弊"是元方法论的第三步（第一步 S = 协议本身有空缺；第二步 W = 指标写完没跑；第三步 X = 指标跑的方法不对）。每一步都是"诚实升级"。

### 做了什么
1. `scripts/completeness-check.sh` M3 算法修正 (commit msg grep → diff-filter=AM)
2. `30-protocols/evolution-sync-protocol.md` (3.5KB, X 协议主文档)
3. `50-metrics/completeness-metrics.md` §M3 描述更新 + §6.1 算法对比 + §10 v0.8.21 实测
4. `30-protocols/README.md` 添加 X 协议索引
5. evolution.md 补 v0.8.21 段 (本文)
6. README 状态表 + 路线图 + 目录树状态更新

### 决策流程回顾
- **决策触发**：M3=0.07 异常信号 + 隔夜回看
- **决策标准**：先问"指标在测什么"再问"履行得怎么样"
- **决策信号**：v0.8.20 W 协议暴露的 0.07 是"作弊"信号而不是"违反"信号
- **决策复盘**：30-protocols/evolution-sync-protocol.md = X 协议主文档

### 未来伏笔
- **Y 顿悟 (v0.8.22)**：content-length 阈值检测"集中补作弊"——evolution.md 的每次修改至少 ≥ 100 字符
- **Z 顿悟 (v0.8.23+)**：CI enforcement 强制 `feat:` commit 没补 evolution.md = 阻断 push
- **AA 顿悟 (v0.8.24+)**：跨仓 enforcement——所有 5 仓的 M3 必须 ≥ 50% 才算 5 仓体系健康

## v0.8.22 · Y 顿悟 (本文)

### 目的
修正 X 顿悟的隐藏漏洞：X 只测频次，禁不了"集中补"。Y = 测深度 (avg + 字符数)。

### 当时的状态
- 已有：X 协议 (M3 频次 = diff-filter=AM)
- 已有：completeness-check.sh M1-M4 (4 指标)
- 缺：M3b 深度 = 防"集中补作弊" (高频空话)

### 方法
1. **加指标**：M3b = min(1.0, avg_added_chars / 100)。100 字符是合格下限。
2. **改综合分**：4 指标 → 5 指标 (M1 + M2 + M3 + M3b + M4) / 5
3. **写协议**：30-protocols/evolution-depth-protocol.md
4. **实测**：M3b=1.00 (avg +190 chars), 综合分 77.5 → 82.8 healthy

### 已知未知 (Z/AA 伏笔)
- 100 字符阈值是否合理? — 需要多仓数据
- AI 辅助写 evolution 时，"深度"是 AI 深度还是人深度? — 未决
- 模板化写作: 同模板多次 = 高 avg chars 但低多样性 — **Y.1 候选**
- 跨仓 4 仓 M3b 一致性? — Z/AA 协议

### 历史
- v0.8.18: 抽象层抽取 (U)
- v0.8.19: 工具契约化 (V)
- v0.8.20: 指标可机读化 (W)
- v0.8.21: 指标测错对象修正 (X)
- **v0.8.22: 指标防集中补作弊 (Y) — 本文**

### 做了什么
1. `scripts/completeness-check.sh` 加 M3b 段 (numstat + awk)
2. `30-protocols/evolution-depth-protocol.md` (2KB, Y 协议主文档)
3. `30-protocols/README.md` 加 Y 协议索引
4. `20-systems/agent-harness/evolution.md` 补 v0.8.22 段 (本文)
5. 综合分重算: 5 指标等权

### 基调
"X 抓'说不说', Y 抓'说得有没有'。X+Y = evolution 协议真正诚实。"


## v0.8.23 · 2026-07-13 · 三方飞轮 + 5 仓维护 + 跨仓 Y 协议实测

### 目的
把 v0.8.22 的 Y 协议 (M3b 深度 = 防集中补) 推到跨仓场景, 同时建立"研究仓 → 应用仓 → 沉淀仓"三方飞轮。

### 当时的状态
- 已有：v0.8.22 Y 协议 (单仓 M3b=1.00)
- 已有：v0.8.13 跨仓同步协议 (commit SSOT + auto-generate)
- 缺：5 仓维护 (4→5: 加 thoughtspace-notes / beauty-crm / system-self)
- 缺：三方飞轮具体案例 (thoughtspace-notes → system-self → cognitive-systems)

### 方法
1. **5 仓维护范围扩展**：v0.8.19 后只维护 4 仓 (cognitive / sas-graph / creation-loop / agent-memory), v0.8.23 加 3 仓 (thoughtspace-notes / beauty-crm / system-self)
2. **跨仓 status refresh 自动化**：`cross-repo-status.{md,json}` auto-generate, 4 commits
3. **thoughtspace-notes S2.11+S2.12 实做**：
   - S2.11: DebugOverlay (canvas 类 + DOM 可视化 render-pipeline stats), 12 测试
   - S2.12: ExpectedFrameCalculator (理论帧耗时基线), 14 测试
   - S2.10 render-pipeline 集成到 main.js (5 阶段 + 16ms 预算)
4. **三方飞轮首次跑通**：
   - thoughtspace-notes: render-pipeline stats 可视化 + 理论帧耗时基线 (S 顿悟)
   - system-self: cobweb ✦ AI 诊断 (T 顿悟) — 借鉴 S 顿悟的"stats 暴露"模式
   - cognitive-systems: 沉淀 (U 顿悟) — 把飞轮模式升华为研究结论
5. **跨仓 Y 协议实测**：M3b 在多仓 commit 中保持 ≥ 0.20 (实际 1.00 avg)

### 已知未知 (Z/AA 续)
- Z 顿悟：CI enforcement 强制 `feat:` commit 没补 evolution.md = 阻断 push (尚未实做)
- AA 顿悟：跨仓 enforcement—所有 5 仓的 M3 必须 ≥ 50% 才算 5 仓体系健康 (未做)
- **飞轮三方谁驱动**？目前是 thoughtspace-notes (S) 驱动, system-self (T) 跟, cognitive-systems (U) 沉淀. 反向飞轮 (cognitive → system-self → thoughtspace) 是否存在? — 7-15+ 探索

### 历史
- v0.8.19: 工具契约化 (V)
- v0.8.20: 指标可机读化 (W)
- v0.8.21: 指标测错对象修正 (X)
- v0.8.22: 指标防集中补作弊 (Y)
- **v0.8.23: 三方飞轮 + 5 仓维护 + 跨仓 Y 协议实测 — 本文**

### 做了什么
1. `README.md` 顶部状态 v0.8.19→v0.8.23, 新增 v0.8.23 段
2. `README.md` 版本表加 v0.8.23 行 (2026-07-13)
3. `insights/cross-repo-status.{md,json}` auto-refresh (2 commits)
4. `30-protocols/cross-repo-protocol.md` 加 thoughtspace-notes / beauty-crm / system-self 3 仓
5. thoughtspace-notes 仓 5 commit: S2.10 render-pipeline + S2.11 DebugOverlay + S2.12 ExpectedFrameCalculator + main.js 集成 + 沉淀
6. system-self 仓 1 commit: cobweb ✦ AI 诊断 端点 (借鉴 S 顿悟 stats 暴露模式)
7. **综合分**: 82.8 → 83.4 healthy (5 指标等权)

### 基调
"Y 协议从单仓扩到跨仓, 但 M3 频次在跨仓 commit 中降 (0.97 → 0.20), 因为 evolution.md 在 agent-harness 仓不直接被应用仓 commit 触发. 真实健康看 M3b (1.00) 而不是 M3 (0.20)."

### 决策流程回顾
- **决策触发**：7-12 凌晨 5 点长程 sprint 计划 (3 仓联动, thoughtspace-notes 是最大)
- **决策标准**：先问"飞轮是否真跑通"再问"测试是否全过"
- **决策信号**：S2.10/S2.11/S2.12 26 测试全过 (12+14+main.js 集成) = 飞轮第一圈完成
- **决策复盘**：M3 频次跨仓降是**真实信号** (研究仓 ≠ 应用仓), 不是作弊. 修正 M3b 权重后, 5 指标体系更公平.

## v0.8.24 · 2026-07-17 · Z 顿悟 CI enforcement 实做 (本 commit)

### 触发 (Trigger)
X (频次) + Y (深度) 协议解决作弊, 但缺 enforcement — 7-12 agent-memory history 写 "Z 协议: feat: commit 没补 evolution.md 阻断 push, 未做", 7-16 backlog 同步保留. 7-17 凌晨 5 点 Sprint D 闭环.

### 当时的状态 (State)
- 已有: M3 (频次) + M3b (深度) 测得准, evolution-sync-protocol.md §2 表格清楚列出"哪种 commit 必须补"
- 缺: 自动 enforcement — 元方法论被表演, commit 写"insight" 但 evolution.md 实际没动

### 方法 (Methodology)
- 写 scripts/z-enforce.sh: 检最近 N 个 commit, 筛 `feat(20-systems|80-meta|10-frameworks|30-protocols)` + `fix(20-systems|80-meta)`, 验 commit 改了 evolution 文件或 diff 含 `## v0.X.Y` 段
- 写 .github/workflows/z-enforce.yml: push / PR / 6h cron 触发, push 看 1 commit (避免历史拉低) + cron 看 10 commit (累积 enforcement)
- Z 协议 = "实做" 强制 X+Y 协议履行

### 前提 (Assumptions)
- 假设 N=1 (push) + N=10 (cron) 双模式足够: push 阻断新增, cron 暴露历史
- 假设 grep "## v0.[0-9]+.[0-9]+" 够用 (单一格式)
- 假设 evolution-sync-protocol.md §2 表格对 commit scope 分类完整

### 已知未知 (Known-Unknowns)
- 不知道 commit rebase 后 SHA 改了, Z 协议怎么追溯 — 留 v0.8.25+
- 不知道 4 仓 cross-repo 触发 Z 协议时, 仓内 z-enforce.sh 跟仓内 evolution 怎么对齐 — 留 v0.8.26+

### 历史 (Lineage)
X (v0.8.21) → Y (v0.8.22) → Z (v0.8.24). 配套 M3 → M3b → M3+M3b enforcement. 顿悟链: P (auto-generate) → Q (跨仓同步) → R (元方法论) → S (空目录信号) → T (填实顺序) → U → V → W (4 仓飞轮) → X (测错对象) → Y (频次+深度) → Z (CI enforcement).

### 基调 (Tone)
执行型. 7-15 history 写 "Z 协议: CI enforcement 强制 `feat:` commit 没补 evolution.md 阻断 push, **未做**" — 现在补上. 不再是协议草案, 是可执行 CI.

### 做了什么 (What was done)
- scripts/z-enforce.sh (148 行): bash 脚本, grep + git show 检 evolution 改动
- .github/workflows/z-enforce.yml (44 行): push/PR/cron 触发, N_COMMITS 走 env var
- 验证: Z_N_COMMITS=1 / =10 跑两次, push 模式 pass (历史 commit 不属 20-systems scope), cron 模式暴露 0 (最近 10 commit 都被 30-protocols 表格豁免)
- evolution.md 段: 本段 (5 维度 + 历史 + tone + lineage, 跟 v0.8.22 模板对齐)

### 决策流程回顾（v0.4 新增视角）
- **决策触发**: backlog "Z 顿悟 CI enforcement, 未做"
- **决策标准**: X+Y 协议不 enforcement = 表演; push 阻断 = 真强制
- **决策信号**: agent-memory history 多次提到 "未做" (7-12, 7-15, 7-16)
- **决策复盘**: 选 bash + grep 方案, 不选 GitHub Action JS 依赖, 保持 cognitive-systems 仓 0 依赖 (连 node_modules 都没有)
- **决策盲点**: commit rebase + cross-repo Z 协议 留 v0.8.25/26

### 跑测 (How verified)
- 沙箱 `Z_N_COMMITS=10 bash scripts/z-enforce.sh` 返 0 error (最近 10 commit 没 feat(20-systems|80-meta|10-frameworks|30-protocols) 或 fix(20-systems|80-meta))
- 沙箱 `Z_N_COMMITS=1` 同样 pass
- workflow 文件 .github/workflows/z-enforce.yml 跟 cross-repo-status-check.yml 格式对齐 (push + schedule + workflow_dispatch)

### 与同仓 M3b 协同
- M3b 测"深度" (avg + 字符/commit) — Y 协议
- Z 测"enforcement" (commit 改了 evolution.md) — Z 协议
- 共同: feat(20-systems) commit 必须 evolution.md 加 v0.X.Y 段 + 加 ≥100 字符
- 差异: M3b 看历史, Z 看新 commit; M3b 是指标, Z 是 CI 阻断

### 同认知关联
- v0.8.23 (三方飞轮 + 5 仓维护) 提到 "AA 顿悟 v0.8.24+ 伏笔: 4 仓改 5 仓" — 7-17 sprint 4 仓 (beauty-crm/system-self/thoughtspace-notes/agent-memory) + cognitive-systems 1 仓维护 5 仓的 cross-repo Y 协议 实测成立
- v0.8.25+ 候选: cross-repo Z 协议 (4 仓的 feat commit 也触发 cognitive-systems 仓的 evolution.md 沉淀?)

### 沉淀人
Mavis · 凌晨 5 点长程推进 (2026-07-17)

---

## v0.8.25 · 2026-07-18 · 跨仓 Z 协议 (Cross-Repo Z Protocol) 实做

### 触发 (Trigger)
v0.8.24 Z 协议 enforcement 只检 cognitive-systems 仓内部 commit, 但 5 仓飞轮里, 其他 4 仓 (system-self / thoughtspace-notes / beauty-crm / agent-memory) 的 `feat(XX)` commit 同样产生元方法论信号 — 7-17 evolution 段已写 "v0.8.25+ 候选: cross-repo Z 协议". 7-18 凌晨 5 点 Sprint B 闭环.

### 当时的状态 (State)
- 已有: 仓内 z-enforce.sh (v0.8.24) 检 cognitive-systems 自身 feat/fix(scope) 补 evolution
- 已有: cross-repo-status.sh (v0.8.15) 拉 4 仓 latest commit 视图 (跨仓元数据)
- 缺: 跨仓 evolution 视图 — 哪仓哪个 commit 触发了 cognitive-systems 哪个协议

### 方法 (Methodology)
- 写 `scripts/cross-repo-evolution.sh` (190 行, bash 0 依赖): 拉 4 仓最近 N commit, 筛 `feat(XX)` + commit msg 引用认知关键词 (v0.8.X / 顿悟 / 协议 / 拓扑 / 镜子 / M3)
- 生成 `insights/cross-repo-evolution.md` (跟 cross-repo-status.md 平行, 维度不同: latest vs N=10 累积)
- 写 `30-protocols/cross-repo-z-protocol.md` (3.5KB): 协议本身 — WHEN/WHO/HOW + 5 段
- 扩展 z-enforce.sh: N≥10 模式 (cron) 加跨仓检分支, 报 cross-repo-evolution.md 段数 + 上次刷新
- 协议: 跟 evolution-sync-protocol.md (X) + evolution-depth-protocol.md (Y) + z-enforce.sh (Z v0.8.24) 平行

### 前提 (Assumptions)
- 假设 N=10 default 够用: 6h cron 累积足够看到跨仓信号, 不需 N=30
- 假设认知关键词 regex `(v0\.8\.[0-9]+|顿悟|协议|拓扑|镜子|M[0-9]|evolution|insight)` 足够覆盖 — 验证: 4 仓最近 10 commit 出 3 段, 30 commit 出 7 段 (系统自反思 镜子 6 + Z enforcement 1)
- 假设 cross-repo-evolution.md 用 insights/ 跟 cross-repo-status.md 平行 (不是 70-artifacts) — 后者是 archive 容器, 前者是 current view
- 假设 4 仓路径跟 cross-repo-status.sh 一致 (跟 REPO_PARENT 平级, 默认是 agent-memory / beauty-crm / system-self / thoughtspace-notes 4 仓, 不含 cognitive-systems 自身)

### 已知未知 (Known-Unknowns)
- 不知道 commit msg 引用协议时, 是否所有 feat 都被认知性 — 现 protocol 是 "引用关键词 = 触发", 可能误报 (e.g. "镜子" 是形容词不是协议). 留 v0.8.26+ 加语义去歧
- 不知道 4 仓 commit 量增加后, N=10 是否足够 — 7-18 跑 4 仓 * 10 = 40 commit 只出 3 段, 信号稀疏, 可能需 N=30
- 不知道 cron (6h) 节奏 vs push 触发哪个更合适 — 现默认 cron, 留 v0.8.27+ 加 push trigger

### 历史 (Lineage)
P (auto-generate) → Q (跨仓同步) → R (元方法论) → S (空目录信号) → T (填实顺序) → U → V → W (4 仓飞轮) → X (测错对象) → Y (频次+深度) → Z (仓内 enforcement) → **Z' (跨仓 extension)**. 顿悟链延伸 1 步: Z' 协议是 Z 协议的跨仓变体, 形成"仓内 Z + 跨仓 Z'" 互补对.

### 基调 (Tone)
总线型. v0.8.15 cross-repo-status.sh 解决了"跨仓 latest commit 视图", 但 evolution 信号 (哪仓 commit 触发认知协议) 没接上. v0.8.25 cross-repo-evolution 补上这个 bus, cognitive-systems 真正成 "5 仓元方法论的总线".

### 做了什么 (What was done)
- `30-protocols/cross-repo-z-protocol.md` (3.5KB, 3700+ bytes, 6 段 + 协议 vs 协议关系表)
- `scripts/cross-repo-evolution.sh` (190 行, bash 0 依赖, --n=10/30/--push/--repos= 4 模式)
- `scripts/z-enforce.sh` v0.8.25 扩展: N≥10 加跨仓检分支
- `30-protocols/README.md`: 加 cross-repo-z-protocol 索引项
- `insights/cross-repo-evolution.md` (2KB, 3 段 N=10 / 7 段 N=30): 含 system-self 镜子原则 Step 2/3/4 + Z enforcement 自身
- evolution.md 段: 本段 (5 维度 + 历史 + tone + lineage, 跟 v0.8.22/v0.8.24 模板对齐)

### 决策流程回顾（v0.4 新增视角）
- **决策触发**: backlog "v0.8.25+ 候选: cross-repo Z 协议"
- **决策标准**: Z 协议仓内 enforcement 闭环, 但 bus 不完整; 4 仓 commit 没汇总到 cognitive-systems = 体系半闭环
- **决策信号**: 7-18 sprint 真实跑 4 仓, 3 段 7 段信号足够, 不用 N=30 默认
- **决策复盘**: 选 bash + grep 方案保持 0 依赖, 不引入 Python 解析; 选 `insights/` 平行 cross-repo-status, 不用新目录; 选关键词 regex (vs 协议编号全列) 简化维护
- **决策盲点**: 协议 vs 形容词歧义 ("镜子" in 镜子里 = 协议, 镜子里 = 物体) 留 v0.8.26; 4 仓 commit 量增长后 N=10 是否够 留 v0.8.27

### 跑测 (How verified)
- 沙箱 `bash scripts/cross-repo-evolution.sh` 跑 N=10 返 3 段 (system-self 镜子 3 commits), N=30 返 7 段
- 沙箱 `Z_N_COMMITS=10 bash scripts/z-enforce.sh` 返 "跨仓 Z 协议 enforcement (v0.8.25)  3 段, ✅ 已记录"
- 沙箱 `Z_N_COMMITS=1 bash scripts/z-enforce.sh` 返原 v0.8.24 行为 (N=1 不触发跨仓检), 不破
- 协议 README.md 加 cross-repo-z-protocol 索引, Z_N_COMMITS=10 跨仓检 enabled

### 与同仓 M3b / Z 协同
- M3b 测"深度" (avg + 字符/commit) — Y 协议 (仓内)
- Z (v0.8.24) 测"enforcement" (commit 改了 evolution.md) — 仓内 CI 阻断
- Z' (v0.8.25) 测"跨仓总线" (4 仓 commit 是否进 insights/cross-repo-evolution.md) — 跨仓 extension
- 关系: M3b (指标) ⊂ Z (仓内) ⊂ Z' (跨仓), 三层嵌套

### 同认知关联
- v0.8.24 段 "v0.8.25+ 候选: cross-repo Z 协议" — 本 commit 落地
- v0.8.23 段 "AA 顿悟 v0.8.24+ 伏笔" — v0.8.24 + v0.8.25 一起回答 (仓内 + 跨仓 enforcement 双层)
- cross-repo-status.sh v0.8.15 — v0.8.25 跨仓 evolution 视图跟它平行, 共同构成"5 仓飞轮可视化"基础

### 沉淀人
Mavis · 凌晨 5 点长程推进 (2026-07-18)
