# 维护维度 · Maintenance Dimensions

> 把 harness 当一个产品看，运维至少要 10 个维度。每个维度都要支持"**监测 / 诊断 / 修复 / 升级 / 回滚**"五件事。

## 1. 身份与会话（Identity & Sessions）
- session 创建、归档、清理策略
- 父子 session 关系、peer 关系图
- 身份凭证轮转、过期检测
- **健康指标**：活跃 session 数、孤儿 session 数、僵尸 session 比例

## 2. 记忆与状态（Memory & State）
- agent memory、user memory、project memory 的隔离与共享规则
- 状态快照与 diff 机制
- 记忆膨胀治理（老 entry 归档 / 总结）
- **恢复能力**：从任意时间点回滚

## 3. 工具与 I/O（Tooling & I/O）
- 工具的注册、版本、降级路径
- 工具调用的幂等性保证
- 超时、重试、熔断策略
- **危险工具**（写文件、推送、对外发消息）的二次确认

## 4. 调度与生命周期（Scheduling & Lifecycle）
- cron、event-driven、manual trigger 三种入口的统一抽象
- 任务依赖、并发限制、队列
- 长时任务的进度回报机制
- **死任务检测**：超时无响应怎么办

## 5. 通信（Communication）
- agent ↔ agent（peer）
- agent ↔ human（notification）
- agent ↔ 外系统（IM / email / webhook）
- 消息的有序、丢失、重传、幂等

## 6. 观测（Observability）
- 统一 log 格式（每条 log 必须含 session_id、agent、task、action）
- 关键 metric：token 消耗、调用次数、失败率、延迟分布
- 报警分级（info / warn / critical）
- 跨 session 的 trace 关联

## 7. 安全与权限（Security & Permissions）
- 每个 agent 能用什么工具、读写什么路径、访问什么 secret
- secret 的轮转和最小暴露
- prompt injection 防护
- 危险操作的 audit log

## 8. 成本与配额（Cost & Quota）
- 每个 session / cron / 用户级别的 token 预算
- 超额预警和硬切断
- 成本归因（这个钱花在哪了）

## 9. 版本与迁移（Versioning & Migration）
- harness 自己的版本管理
- 协议变更的 backward compatibility
- 旧 agent 实例在升级期间的兼容窗口
- 数据迁移工具和回滚脚本

## 10. 恢复与灾备（Recovery & Disaster）
- 状态快照频率策略
- 部分恢复（不是只能全恢复或全不恢复）
- 灾难场景剧本（数据库炸了、LLM provider 挂了、磁盘满）

---

## 五件事检查清单

每个维度都要能回答：

- [ ] **监测**：我有什么 metric / log / alert 能看到它的状态？
- [ ] **诊断**：出问题时，我能不能 5 分钟内定位到具体维度？
- [ ] **修复**：常规故障的修复步骤有 runbook 吗？< 30 分钟能恢复吗？
- [ ] **升级**：这个维度能独立升级而不影响其他维度吗？
- [ ] **回滚**：升级出问题能 5 分钟回滚吗？数据会丢吗？

如果任何一个是 NO，这个维度就是欠债。
