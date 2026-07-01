# 体系演进记录

## v0.1 · 2026-07-01

**起点**：把"agent harness 体系"作为第一个研究对象落地。

### 包含内容
- overview.md：体系总览
- architect.md：建筑师 agent 的 6 项能力
- resident.md：居民 agent 的 6 项内在能力
- maintenance-dimensions.md：10 个维护维度
- cross-cutting-judgments.md：7 条跨维度判断
- README.md：入口

### 起源
来自与 Mavis（一个实际运行的 agent harness）的对话。原对话主题：
> "要达到完整严密的适应性强可恢复性强的 agent harness，对建立这套系统的 agent 的基础能力有什么要求？对运行的 agent 有什么要求，具体到维护这套系统的每个能力维度呢？"

### 状态
- [stable] — 基础框架稳定
- 6 个文件，约 6000 字

### 已知缺口
- 没有 30-protocols 下的具体协议
- 没有 40-experiments 下的实际验证
- 没有 50-metrics 下的具体 metric 定义
- 没有和其他 harness 实现的对比（LangChain、AutoGen、CrewAI 等）
- "意识"维度完全没碰
- **没有治理框架**（← v0.2 解决）

---

## v0.2 · 2026-07-01（同日）

**主题**：行为一致性治理 — 防止 agent 群腐蚀系统

### 新增内容
- consistency-governance.md：治理框架（4 层一致性 + 硬约束/软机制/反向防御）
- audit-protocols.md：行为审计协议（4 层审计 + 模板 + 反模式）
- evolution.md（本文件）：状态更新

### 起源
对话主题：
> "如何在 agent 行为一致性的层面上维护整个项目，防止不同时期、不同工作、不同能力下的 agent 扰乱、引导错误这个系统？"

### 实证
引用 wcaca/creation-loop v0.3 的实践作为治理机制的实证案例：
- autonomy 4 级权限 → 权限分层（白名单）
- scheduler 4 节拍 → 变更窗口
- state mode 开关 → 全局闸
- cron + state 联动 → 跨 session 一致性
- 已知部署限制（cron session 写不进 sandbox）→ 多 agent 一致性协议的实战考验

### 状态
- [active] — 当前重点研究方向
- 8 个文件，约 12000 字
- 0 个实验、0 个工具、0 个具体协议（待补）
- 0 个真实审计跑过（待补）

### 仍欠缺的
- 没有 30-protocols 下的具体协议（计划 v0.3）
- 没有 40-experiments 下的实际验证（计划 v0.3）
- 没有 50-metrics 下的具体 metric 定义（计划 v0.3）
- 没有"决策反查"的真实实例（计划 v0.3）
- 没有"行为审计"的真实跑过记录（计划 v0.3）
- 没有 protocol 指纹机制（计划 v0.4）
- 没有多 agent n-of-n 一致性协议（计划 v0.4）

---

## v0.2.1 · 2026-07-01（同日稍后）

**主题**：cron 作为系统镜子 — 加深"治理框架的集成测试"视角

### 新增内容
- cron-as-system-mirror.md：cron 是 5 层依赖的"全栈镜子"
  - 5 层依赖：基础设施 / LLM 能力 / prompt 设计 / harness 元认知 / 人机耦合
  - 6 个反模式 + 6 个设计模式
  - 7 个开放研究问题
  - mavis harness 自身的 3 个欠债

### 起源
对话主题（接续 v0.2）：
> "cron 的使用特别依赖已有体系和 llm 能力，还有提示词设计，还有 harness 对这项工作的已知未知（也就是人的认知体系和行为的耦合度）这整个工作模式"

### 状态
- [active] — 当前重点
- 9 个文件，约 18000 字

### 跟 v0.2 的关系
v0.2 提出治理框架（抽象），v0.2.1 把治理框架**映射到 cron 场景**（具体）。从抽象到具体的一次跨越。

---

## 未来版本

### v0.3 计划
- **优先**：把 cron-as-system-mirror 里提的"自完备 prompt 模板"实现为 `30-protocols/cron-prompt-template.md`
- 1-2 个其他具体协议（工具契约 / session 状态机）
- 1 个实验（验证"恢复粒度"判断的可行性）
- harness 评测指标清单
- 1 个真实的"决策反查"实例
- 在 mavis harness 上跑第一次 Level 1 周审计
- 给 mavis 自己的 cron 任务加"已知未知"清单

### v0.4 计划
- 协议指纹机制
- 多 agent 一致性协议（n-of-n）
- 第一次 Level 2 月审计 + 第一次 Level 3 季审计

### v0.5 计划
- 和 1-2 个真实 harness 实现对比（LangChain、AutoGen、CrewAI 找差异、学经验）
- 代理可观测性专项研究
