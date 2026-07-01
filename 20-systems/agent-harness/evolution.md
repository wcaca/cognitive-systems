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
- [active] — 当前重点研究方向
- 8 个文件，约 8000 字
- 0 个实验、0 个工具、0 个协议（待补）

### 已知缺口
- 没有 30-protocols 下的具体协议
- 没有 40-experiments 下的实际验证
- 没有 50-metrics 下的具体 metric 定义
- 没有和其他 harness 实现的对比（LangChain、AutoGen、CrewAI 等）
- "意识"维度完全没碰

## 未来版本

### v0.2 计划
- 加入 1-2 个具体协议（如"工具契约格式"、"session 状态机"）
- 加入 1 个实验（验证"恢复粒度"判断的可行性）
- 加入"harness 评测指标"清单

### v0.3 计划
- 和 1-2 个真实 harness 实现对比（找差异、学经验）
- 加入"代理可观测性"专项研究
