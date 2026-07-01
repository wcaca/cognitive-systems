# 跨维度判断 · Cross-Cutting Judgments

> 这些判断不属于某一个维护维度，而是所有维度的元规则。

## 判断 1：复杂度预算（Complexity Budget）

Harness 的复杂度有上限。一旦超过，调试成本指数上升。

**一般原则**：
- **核心机制**（调度、记忆、I/O）稳如老狗
- **外围能力**（不同 LLM provider、不同 IM 集成）允许激进变化

判断标准：核心机制在 6 个月内**不应该**有 breaking change。

## 判断 2：协议优先，实现其次

先把"session 是什么、memory 怎么存、tool 怎么声明"这些协议钉死，再写实现。

协议不对，实现再漂亮也得重写。协议对了，实现可以慢慢演化。

**协议文档的标准**：
- 一份文档只讲一件事
- 必填/可选/错误码必须显式列出
- 必须有"不做什么"一节
- 必须有版本号

## 判断 3：把"agent 的诚实"当基础设施

**不要假设 agent 永远诚实**。

要在 harness 层面用机制保证"agent 即使出错，harness 也能知道它错了"：
- 独立校验（不让 agent 自己判断自己成功）
- 双盲审计（关键决策两个人 / 两个 agent 都同意）
- 结果反查（agent 说做完了，harness 验一下实际状态）

**这条比"agent 变聪明"更重要**。

## 判断 4：恢复粒度越细越好

- 能从 5 分钟前恢复就别只能从 1 小时前恢复
- 能恢复到具体某个失败步骤就别只能从头来
- 能保留部分工作成果就别全丢

**粒度是 harness 价值的核心**。

衡量指标：RPO（Recovery Point Objective）和 RTO（Recovery Time Objective）。每个维度都应该有这两个目标值。

## 判断 5：把"被救"当一等公民

Harness 是个长跑型系统——3 个月后还在、6 个月后还在、出问题还能救回来。

设计时把「被救」当一等公民，把「刚上线好用」当副产品。

**短跑型决策**（赶 deadline、堆 feature）会快速腐蚀这个系统。

具体表现：
- 不留调试 hook = 出事救不回来
- 不写 runbook = 3am 救不回来
- 不做 partial recovery = 一炸全丢
- 不做 protocol versioning = 升级一次坏一次

## 判断 6：边界即安全

Agent 系统的所有危险，都来自边界模糊：
- agent 和 harness 的边界
- 工具和数据的边界
- 用户和系统的边界
- 信任和不信任的边界

**每加一个新能力，先问：这动了哪条边界？边界变了吗？**

## 判断 7：观测先于功能

> "If you can't measure it, you can't improve it. If you can't observe it, you can't recover it."

新功能上线前必须有：
- log 字段
- metric 指标
- 报警规则
- 排障 runbook

不满足这四件的不上。

## 一句话

> 这 7 条判断是 harness 的"宪法"。任何 feature 设计违反其中一条，要么改设计，要么改判断（写清楚为什么改）。
