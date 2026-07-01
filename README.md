# Cognitive Systems Research

> 一个公开的、持续更新的认知系统研究仓。覆盖 agent、大语言模型、意识等方向。

## 这是什么

一个用来沉淀「怎么构建可恢复、可适应、严密的认知系统」研究的公开知识库。
不是论文集、不是教程，是**还在演进中的思考与设计**——框架、协议、实验、踩过的坑、对未来的猜测，都在这里。

## 当前状态：v0.5

- **首个落地方向**：agent harness 体系
- **首个具体系统**：[`20-systems/agent-harness/`](./20-systems/agent-harness/) —— 关于"运行 agent 的系统"该怎么设计的研究
- **v0.2 新增**：行为一致性治理（consistency-governance + audit-protocols），含实证案例（creation-loop v0.3）
- **v0.2.1 新增**：cron-as-system-mirror（cron 作为 5 层依赖的全栈镜子，治理框架的"集成测试"）
- **v0.3 新增**：语境保存 + 趋势预判（context-preservation + context-snapshot-template + trend-prediction + evolution.md 升级为 8 维度）
- **v0.4 新增**：决策流程设计（decision-flow-design 主文档 + evolution.md 每个版本加"决策流程回顾"段 = 把所有研究整合进统一框架）
- **v0.5 起点**：LLM 顿悟能力评测骨架（`80-meta/llm-insight-benchmark.md` = 5 任务 + 4 维度 + 5 类开放问题；评测方式研究**不急着展开**，等协议研究透）
- **总文件数**：约 33 个
- **总 commit 数**：12
- **公开性**：public，欢迎讨论与共建

## 仓库结构

```
00-essence/         本体论 / 底层假设 / 我们在研究什么
10-frameworks/      通用框架（角色-维度矩阵、能力图谱等）
20-systems/         具体系统设计
  ├── agent-harness/   v0.1：agent 运行系统的体系研究
  ├── llm-frontier/    v0.2（计划）：大模型前沿
  └── consciousness/   v0.3（计划）：意识/认知架构
30-protocols/       协议 / 接口规范 / RFC 风格文档
40-experiments/     实验 / 案例 / 验证记录
50-metrics/         指标 / 测度 / 评估方法
60-tools/           工具（脚本、CLI、配置）
70-artifacts/       制品（生成的文档、图、数据集）
80-meta/            元思考：我们怎么研究、为什么这么分
90-conventions/     约定 / 协作规范 / 命名法
```

## 路线图

| 版本 | 时间 | 内容 |
|---|---|---|
| **v0.1** | 2026-07 | agent harness 体系（建筑师/居民/10 维护维度） |
| **v0.2** | 2026-07（同日）| 行为一致性治理（4 层一致性 + 硬约束/软机制/反向防御 + 审计协议） |
| **v0.2.1** | 2026-07（同日）| cron 作为系统镜子（5 层依赖 + 反模式 + 模式 + 开放问题） |
| **v0.3** | 2026-07（同日）| 语境保存 + 趋势预判（context-preservation + trend-prediction + 8 维度 evolution 模板） |
| **v0.4** | 2026-07（同日）| 决策流程设计（4 阶段 + 4 不变量 + 3 杠杆 = 整合视图） |
| **v0.5** | 2026-07 | LLM 顿悟能力评测（benchmark 骨架 + 评测方式研究，5 任务 + 4 维度） |
| **v0.6** | 计划 | mavis harness 加 decision_log + 第一份月度 review |
| **v0.7+** | 待定 | LLM/意识/跨方向交叉 |

## 核心立场

1. **公开演进**：思考过程和结论同样重要，错的判断也保留并标注。
2. **协议优先于实现**：先把"是什么"定义清楚，再写"怎么做"。
3. **诚实是基础设施**：承认不知道、承认失败，比假装正确更有价值。
4. **可恢复性是一等公民**：把"将来怎么救"当成"现在怎么设计"的核心约束。
5. **极简偏好**：能用 5 个概念解决的事，绝不引入第 6 个。
6. **决策流程 > 事后修复**（v0.4 新增）：在对的阶段、用对的标准、产生可观测信号、并可被复盘。

## 怎么读这个仓

- 5 分钟版：读 `00-essence/research-map.md` + `20-systems/agent-harness/overview.md`
- 30 分钟版：顺着 `00 → 20 → 80 → 90` 读一遍，agent-harness 目录全读
- 深度参与：从 `90-conventions/contributing.md` 开始

## 怎么贡献

欢迎 issue、PR、讨论。但请先读 [`90-conventions/contributing.md`](./90-conventions/contributing.md)。

## 许可

MIT
