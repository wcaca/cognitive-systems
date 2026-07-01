# Agent Harness System · v0.1

> 研究问题：**怎么构建一个完整、严密、适应性强、可恢复性强的 agent harness？**

## 这部分研究什么

Agent harness = 让 agent 跑起来的系统。它不是 agent 本身，而是 agent 赖以生存、协作、恢复的基础设施。

我们关心的问题：
- 建筑师（设计 harness 的 agent）需要什么能力
- 居民（跑在 harness 里的 agent）需要什么内在能力
- 维护系统时需要覆盖哪些能力维度

## 文件清单

- [`overview.md`](./overview.md) — 体系总览：角色-维度矩阵
- [`architect.md`](./architect.md) — 建筑师 agent 的能力要求
- [`resident.md`](./resident.md) — 居民 agent 的能力要求
- [`maintenance-dimensions.md`](./maintenance-dimensions.md) — 10 个维护维度详解
- [`cross-cutting-judgments.md`](./cross-cutting-judgments.md) — 跨维度判断
- [`consistency-governance.md`](./consistency-governance.md) — **v0.2** 行为一致性治理
- [`audit-protocols.md`](./audit-protocols.md) — **v0.2** 行为审计协议
- [`evolution.md`](./evolution.md) — 这个体系怎么演进

## 一句话总结

> **Harness 是个长跑型系统——3 个月后还在、6 个月后还在、出问题还能救回来。**
> 设计时把"被救"当一等公民，把"刚上线好用"当副产品。
