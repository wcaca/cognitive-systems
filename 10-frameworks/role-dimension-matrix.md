# Role × Dimension Matrix

> **核心抽象**：把所有 agent harness 都涉及的"角色 × 维护维度"组合矩阵化。这是 20-systems/agent-harness/overview.md + maintenance-dimensions.md 的抽象层 — 抽出"重复出现的模式"。

> **顿悟 U 起源 (v0.8.18)**：跨系统 (agent harness / cobweb / creation-loop) 都涉及"角色 + 维度"组合, 把这些组合抽出来 = 跨系统对比的最小单元。

## 角色 (3 类)

| 角色 | 定义 | 典型操作 |
|------|------|----------|
| **Architect** | 设计 / 维护 harness 本身的人 (或 agent) | 失败想象力、协议思维、分层、不可逆敏感、运维代入、极简偏好 |
| **Resident** | 跑在 harness 里执行任务的 agent | 接受任务、调用工具、回报进度、维护自身状态 |
| **Auditor** | 跨 session / 跨 harness 的监测诊断 agent | log 聚合、metric 收集、一致性检查、告警分级 |

## 维度 (10 个, 从 maintenance-dimensions.md 抽取)

1. **身份与会话** (Identity & Sessions) — session 创建 / 归档 / 父子关系
2. **记忆与状态** (Memory & State) — agent / user / project memory 隔离与共享
3. **工具与 I/O** (Tooling & I/O) — 注册 / 版本 / 幂等 / 危险工具
4. **调度与生命周期** (Scheduling & Lifecycle) — cron / event / manual 三入口
5. **通信** (Communication) — agent↔agent / agent↔human / agent↔外系统
6. **观测** (Observability) — log / metric / 报警 / trace 关联
7. **安全与权限** (Security & Permissions) — 工具白名单 / secret / prompt injection
8. **成本与配额** (Cost & Quota) — token 预算 / 超额预警 / 归因
9. **版本与迁移** (Version & Migration) — schema 迁移 / 配置升级 / 回滚
10. **恢复** (Recovery) — 状态快照 / 断点恢复 / 故障转移

## 矩阵 (Role × Dimension = 30 单元)

| | Architect | Resident | Auditor |
|---|-----------|----------|---------|
| **1. 身份会话** | 设计 session 生命周期 | 维护自身 session | 孤儿/僵尸检测 |
| **2. 记忆状态** | 设计 memory 隔离规则 | 写自己的 memory | 记忆膨胀审计 |
| **3. 工具 I/O** | 工具注册/降级路径 | 工具调用/幂等 | 工具调用频次/失败率 |
| **4. 调度生命周期** | 设计调度入口抽象 | 接受任务/回报进度 | 死任务检测 |
| **5. 通信** | 设计 peer 协议 | 发送/接收消息 | 消息丢失/重传检测 |
| **6. 观测** | 设计 log 格式/trace ID | 写结构化 log | log 聚合/异常检测 |
| **7. 安全权限** | 设计 secret 轮转 | 用 prompt 注入防护 | 危险操作审计 |
| **8. 成本配额** | 设 token 预算/告警阈值 | 监控自身消耗 | 成本归因 |
| **9. 版本迁移** | 设计 migrate.js | 接受 schema 升级 | schema 一致性检查 |
| **10. 恢复** | 设计快照机制 | 接受回滚指令 | 故障检测/告警 |

## 跨系统对照

每个 agent harness 都填这个矩阵 — 填得越满 = 系统越成熟, 留空 = 待补功能。

**示例：beauty-crm**

- Architect 维度 9: ✅ schema_version + migrate.js
- Resident 维度 3: ✅ 工具白名单 (.git/ 拒绝)
- Auditor 维度 6: ✅ audit_log 表
- 留空：维度 1 (无 session 概念, 单进程 server) / 维度 4 (无 cron, 外部脚本)

**示例：system-self**

- Architect 维度 10: ✅ 镜子原则 (从 RFL 失败回滚)
- Resident 维度 3: ✅ 工具契约 (tool-call 返回 schema)
- 留空：维度 8 (无 token 预算, 待补)

**示例：cognitive-systems (本仓)**

- Auditor 维度 6: ✅ cross-repo-status.sh + JSON + 日报
- Auditor 维度 10: ✅ 70-artifacts/cross-repo-status-archive/ 归档
- 留空：维度 5 (peer session 间通信未设计)

## 抽象价值

抽这个矩阵的好处：

1. **跨系统对比统一语言** — 讨论"工具版本管理"不用每次重新定义
2. **空白检测自动化** — 矩阵里空白单元 = 待补功能清单
3. **新系统 onboarding 加速** — 给一个新 harness, 填这个矩阵就能 30 分钟评估成熟度
4. **模式复用** — Architect 维度 7 的 secret 轮转模式, 可直接复制到任何新系统

## 何时更新

- 新增一个 agent harness → 必填矩阵
- harness 增删功能 → 必更新矩阵对应单元
- 跨系统出现"重复模式" → 抽到矩阵 (本框架的核心)

## 来源

- `20-systems/agent-harness/overview.md` — 3 角色来源
- `20-systems/agent-harness/maintenance-dimensions.md` — 10 维度来源
- `30-protocols/fill-order-coordination.md` — T 顿悟的"抽模式"原则
- `30-protocols/insight-extraction-protocol.md` — 顿悟抽取协议

## 版本

- v0.1 (2026-07-07, v0.8.18 / 顿悟 U): 初版, 从 agent-harness 单系统抽 30 单元矩阵

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-07-07)