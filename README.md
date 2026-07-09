# Cognitive Systems Research

> 一个公开的、持续更新的认知系统研究仓。覆盖 agent、大语言模型、意识等方向。

## 这是什么

一个用来沉淀「怎么构建可恢复、可适应、严密的认知系统」研究的公开知识库。
不是论文集、不是教程，是**还在演进中的思考与设计**——框架、协议、实验、踩过的坑、对未来的猜测，都在这里。

## 当前状态：v0.8.19

- **首个落地方向**：agent harness 体系
- **首个具体系统**：[`20-systems/agent-harness/`](./20-systems/agent-harness/) —— 关于"运行 agent 的系统"该怎么设计的研究
- **v0.2 新增**：行为一致性治理（consistency-governance + audit-protocols），含实证案例（creation-loop v0.3）
- **v0.2.1 新增**：cron-as-system-mirror（cron 作为 5 层依赖的全栈镜子，治理框架的"集成测试"）
- **v0.3 新增**：语境保存 + 趋势预判（context-preservation + context-snapshot-template + trend-prediction + evolution.md 升级为 8 维度）
- **v0.4 新增**：决策流程设计（decision-flow-design 主文档 + evolution.md 每个版本加"决策流程回顾"段 = 把所有研究整合进统一框架）
- **v0.5 起点**：LLM 顿悟能力评测骨架（`80-meta/llm-insight-benchmark.md` = 5 任务 + 4 维度 + 5 类开放问题）
- **v0.5.1**：评测协议 + 防污染（`80-meta/llm-insight-evaluation-protocol.md` = 3 层 protocol + 5 级评分锚定 + 6 个防污染机制 + prototype）
- **v0.6 起点**：insight-to-work 桥接机制（`80-meta/insight-to-work.md` = 4 步桥接 + 4 面展开 + 4 持续机制 + 3 层信息整合）
- **v0.6.1-0.6.5**：4 面 checklist / 3 层信息整合 / 4 持续机制 / 完成度 rubric / 端到端 prototype
- **v0.7**：M3 长程能力自测 + 第二份 prototype (DNA ↔ Software replication) + 报告页 + 真实材料对比页
- **v0.8 IPL 框架**：顿悟驱动的项目生命周期（9 阶段 + 9 顿悟检查点）
- **v0.8.1 递进认知链**：边跑边暴露的研究方法（6 抽象层爬升规律）
- **v0.8.2 全景感知清单**：LLM 顿悟完整性的反推
- **v0.8.3 全局性顿悟**：LLM + user 协同 = 90% 完整性（13 步推进的 9 层架构）
- **v0.8.4 立体完整度**：推断 + 判断 + 验证 3 层（user 反馈触发）
- **v0.8.5 可能性域感知系统**：让 LLM 看见所有可走的路（schema 枚举 + 3 杠杆 + PIVOT echo + 盲点记录）
- **v0.8.6 模块间显式依赖**：顿悟 I 框架升级
- **v0.8.7-0.8.8 schema 元信息框架 + 格式**：顿悟 J/K
- **v0.8.9 类型即元信息**：顿悟 L
- **v0.8.10-0.8.11 类型系统局限 + escape hatch**：顿悟 M/N
- **v0.8.12 auto-generated 文档模式**：顿悟 O 升级
- **v0.8.13 CI enforcement 模式**：顿悟 P 升级
- **v0.8.14 跨仓元数据同步**（Q 顿悟）：4 个仓的版本号 / commit 自动同步
- **v0.8.15 多 writer 协调**（R 顿悟）：lock + pull-push + owner 模式解决 race condition
- **v0.8.16 空目录 = 诚实信号**（S 顿悟）：填实 4 个空目录 (30-protocols / 40-experiments / 50-metrics / 70-artifacts) + 3 协议（README 占位 / 仓根标记 / 填实升级索引）
- **v0.8.17 填实顺序协调**（T 顿悟）：3 子问题 (WHEN/WHO/HOW) + 6 步协调流程 + 验收 3 步 (一致性/完整性/归档)。补充 T 协议 (30-protocols/fill-order-coordination.md) + 实施 cross-repo-status --archive (70-artifacts/cross-repo-status-archive/) + 90-conventions 填实 README
- **v0.8.18 抽象层抽取**（U 顿悟）：T 协议实施第一步 — 抽 20-systems/agent-harness 重复模式到 10-frameworks/role-dimension-matrix.md (3 角色 × 10 维度 = 30 单元矩阵)。填实 10-frameworks 目录第一步 ([empty] → [active v0.8.18])
- **v0.8.19 工具契约化**（V 顿悟）：填实 60-tools/ 目录 ([empty] → [active v0.8.19]) — 收录 cross-repo-status.md 契约 (路径不动, scripts/ 仍在, 60-tools/ 只放契约)
- **v0.8.20 指标可机读化**（W 顿悟）：50-metrics/completeness-metrics.md 从 [draft] 升级为 [active]，补可机读实现 `scripts/completeness-check.sh`（M1-M4 4 指标 + 综合分 0-100 + JSON 输出）。填实 60-tools/ 第二篇契约 `completeness-check.md`。**核心：指标不被自动化 = 指标不存在**
- **总文件数**：约 80 个（v0.8.20 +4）
- **总 commit 数**：约 46+（v0.8.20 +2）
- **公开性**：public，欢迎讨论与共建

### 跨仓状态

[`insights/cross-repo-status.md`](./insights/cross-repo-status.md) (auto-generated) — 4 个仓 (cognitive-systems / sas-graph / creation-loop / agent-memory) 的最新版本 + commit。

## 仓库结构

```
00-essence/         本体论 / 底层假设 / 我们在研究什么
10-frameworks/      通用框架 [active v0.8.18] — role-dimension-matrix.md
20-systems/         具体系统 [active v0.8.20] — agent-harness/consciousness/llm-frontier
  ├── agent-harness/   v0.1：agent 运行系统的体系研究
  ├── llm-frontier/    v0.2（计划）：大模型前沿
  └── consciousness/   v0.3（计划）：意识/认知架构
30-protocols/       协议 [active v0.8.16] — insight-extraction-protocol
40-experiments/     实验 [active v0.8.16] — Q+R 实证记录
50-metrics/         指标 [active v0.8.20] — completeness-metrics (M1-M4) + 可机读
60-tools/           工具 [active v0.8.21] — cross-repo-status.md + completeness-check.md 契约 (M3 算法修正)
70-artifacts/       制品 [active v0.8.17] — cross-repo-status-archive 已实施
80-meta/            元思考：我们怎么研究、为什么这么分
90-conventions/     约定 [active v0.8.17] — context-snapshot-template + contributing
```

## 路线图

| 版本 | 时间 | 内容 |
|---|---|---|
| **v0.1** | 2026-07-01 | agent harness 体系（建筑师/居民/10 维护维度） |
| **v0.2** | 2026-07-01（同日）| 行为一致性治理（4 层一致性 + 硬约束/软机制/反向防御 + 审计协议） |
| **v0.2.1** | 2026-07-01（同日）| cron 作为系统镜子（5 层依赖 + 反模式 + 模式 + 开放问题） |
| **v0.3** | 2026-07-01（同日）| 语境保存 + 趋势预判（context-preservation + trend-prediction + 8 维度 evolution 模板） |
| **v0.4** | 2026-07-01（同日）| 决策流程设计（4 阶段 + 4 不变量 + 3 杠杆 = 整合视图） |
| **v0.5** | 2026-07-01 | LLM 顿悟能力评测（benchmark 骨架 + 评测方式研究，5 任务 + 4 维度） |
| **v0.5.1** | 2026-07-01 | Protocol + 防污染（3 层组合 + 5 级行为锚定 + 6 个防污染机制） |
| **v0.6** | 2026-07-01 | insight-to-work 桥接机制（4 步桥接 + 4 面展开 + 4 持续机制） |
| **v0.6.1-0.6.5** | 2026-07-01（同日）| 4 面 checklist / 3 层信息整合 / 4 持续机制 / 完成度 rubric / 端到端 prototype |
| **v0.7** | 2026-07-01 | M3 长程能力自测 + 第二份 prototype (DNA ↔ Software replication) + 报告页 + 真实材料对比页 |
| **v0.8** | 2026-07-01 | IPL 顿悟驱动的项目生命周期（9 阶段 + 9 顿悟检查点） |
| **v0.8.1** | 2026-07-01 | 递进认知链（边跑边暴露的研究方法） |
| **v0.8.2** | 2026-07-01 | 全景感知清单（LLM 顿悟完整性的反推） |
| **v0.8.3** | 2026-07-01 | 全局性顿悟（LLM + user 协同 = 90% 完整性） |
| **v0.8.4** | 2026-07-01 | 立体完整度（推断 + 判断 + 验证 3 层） |
| **v0.8.5** | 2026-07-01 | 可能性域感知系统（schema 枚举 + 3 杠杆 + PIVOT echo + 盲点记录） |
| **v0.8.6** | 2026-07-01 | 模块间显式依赖 |
| **v0.8.7-0.8.8** | 2026-07-01 | schema 元信息框架 + 格式 |
| **v0.8.9** | 2026-07-01 | 类型即元信息 |
| **v0.8.10-0.8.11** | 2026-07-01-02 | 类型系统局限 + escape hatch + escape 文档化 |
| **v0.8.12** | 2026-07-02 | auto-generated 文档模式（顿悟 O 升级） |
| **v0.8.13** | 2026-07-02 | CI enforcement 模式（顿悟 P 升级） |
| **v0.8.14** | 2026-07-03 | 跨仓元数据同步（顿悟 Q） |
| **v0.8.15** | 2026-07-03 | 多 writer 协调（顿悟 R — lock + pull-push + owner） |
| **v0.8.16** | 2026-07-04 | 空目录 = 诚实信号（顿悟 S — 本文） |
| **v0.8.17** | 2026-07-05 | 填实顺序协调（顿悟 T）：3 子问题 (WHEN/WHO/HOW) + 6 步流程 + cross-repo-status --archive 实施 + 90-conventions README |
| **v0.8.18** | 2026-07-07 | 抽象层抽取（顿悟 U）：T 协议实施第一步 — role-dimension-matrix.md (3 角色 × 10 维度 = 30 单元) |
| **v0.8.19** | 2026-07-07 | 工具契约化（顿悟 V）：60-tools/ 填实 — cross-repo-status.md 契约 + 收录标准 + 与其他目录关系 |
| **v0.8.20** | 2026-07-08 | 指标可机读化（顿悟 W）：completeness-check.sh + completeness-metrics.md [active] |
| **v0.8.21** | 2026-07-09 | 指标测错对象修正（顿悟 X）：M3 算法从 commit msg grep 改为 diff-filter=AM on evolution.md；目标 70%→50%；新增 evolution-sync-protocol.md |
| **v0.9** | 计划 | 多 writer 协调协议（顿悟 R 预测） |
| **v0.10+** | 待定 | LLM/意识/跨方向交叉 |

## 核心立场

1. **公开演进**：思考过程和结论同样重要，错的判断也保留并标注。
2. **协议优先于实现**：先把"是什么"定义清楚，再写"怎么做"。
3. **诚实是基础设施**：承认不知道、承认失败，比假装正确更有价值。
4. **可恢复性是一等公民**：把"将来怎么救"当成"现在怎么设计"的核心约束。
5. **极简偏好**：能用 5 个概念解决的事，绝不引入第 6 个。
6. **决策流程 > 事后修复**（v0.4 新增）：在对的阶段、用对的标准、产生可观测信号、并可被复盘。
7. **commit message 是 SSOT**（v0.8.14 新增）：文档是 commit 的视图，不是 source of truth。auto-generate 是能力，CI enforcement 是机制，跨仓 sync 是协议。

## 怎么读这个仓

- 5 分钟版：读 `00-essence/research-map.md` + `20-systems/agent-harness/overview.md`
- 30 分钟版：顺着 `00 → 20 → 80 → 90` 读一遍，agent-harness 目录全读
- 深度参与：从 `90-conventions/contributing.md` 开始

## 怎么贡献

欢迎 issue、PR、讨论。但请先读 [`90-conventions/contributing.md`](./90-conventions/contributing.md)。

## 许可

MIT