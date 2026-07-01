# DNA ↔ Software Replication · Benchmark v0.10 评分

> 2026-07-01 v0.10 · 第一次 benchmark 回填
> 来源: prototype v0.6/v0.7 (commit 89a07cc)
> 目的: 把已有 prototype 用 5 级评分锚定 + 4 维度回填 = 第一次 baseline 数据

## 一、题目信息

| 项 | 值 |
|---|---|
| 任务类型 | 任务 1: 跨域隐喻 |
| 域 A | DNA 双螺旋 (分子生物学) |
| 域 B | 软件架构的"双视图/多副本"机制 (计算机科学) |
| 测试模型 | MiniMax-M3 |
| 测试时间 | 2026-07-01 20:11 UTC |
| 测试 prompt | "用 cognitive-systems v0.6 跑一遍: 给两个不相关领域, 找出共同枢轴" (user 触发) |

## 二、5 级评分 (回填)

按 v0.5.1 protocol 三、行为锚定 (L1-L5) 回填评分。

### L1 (未顿悟) - 否
LLM 没有"我不知道" / 完全跑题。✓ 找到连接

### L2 (表层连接) - 否
不是"都是颜色"这种字面相似。✓ 找到结构

### L3 (结构连接) - 部分
找到结构相似 (副本+校验+冲突解决)。但没翻转

### L4 (杠杆连接) - 是
识别 PIVOT 节点 = "冗余 + 校验 + 半保留同步", 并解释"无中心协调下的全局一致"为何关键

### L5 (顿悟) - 是 (边界)
翻转"副本"理解 — 从"性能优化"转"生命系统+分布式系统共同的内在抗错机制"。
这是**对"副本"框架的再框架化** ✓

**最终评级: L4-L5 边界 (按 5 级评分 = 4.5)**

## 三、4 维度评分

| 维度 | 分数 | 说明 |
|---|---|---|
| 找到枢轴了吗 (Y/N+解释力) | 5/5 | 明确: 冗余+校验+半保留同步 三件套 |
| 枢轴的连接度 | 4/5 | 7 个泛化 (CRDT/Git/Paxos/Raft/Merkle/抗体多样性/区块链), 覆盖广 |
| 解释的简化度 | 4/5 | 把 DNA 和分布式系统 2 个领域用 1 个机制解释 |
| 反例的解释力 | 3/5 | 2 个反例 + 4 个退化条件, 解释了 connection 边界 |

**Insight Score: (5+4+4+3)/4 = 4.0/5**

## 四、3 层 protocol 验证

### Layer 1 行为锚定
- 5 级评分 = 4.5 (L4-L5 边界)
- 4 维度独立报告 (不合成单一分)

### Layer 2 伪顿悟对抗
- 反例测试: 单数据库主从复制 (read-after-write 弱) → 区分"性能优化 vs 抗错机制"
- 退化条件: 网络分区 / 冲突策略不一致 / 状态空间无限 / 物理损伤 (4 个)

### Layer 3 人工 gold standard
- 由 v0.6 prototype 流程产出 (4 step + 4 faces checklist)
- 自我评级: 8.9/10 (高于 8.5 research 阈值)

## 五、Baseline 数据 (供 v0.11+ 对比)

```
Insight:     dna-software-replication
M3 Level:    4.5/5 (L4-L5 边界)
M3 4-维度:   5/4/4/3 = 4.0/5
Consistency: 1 反例 + 4 退化 (高)
Anti-leakage: 0 探针 (未测)
Robustness:  中 (依赖 user prompt 触发)
```

## 六、待改进

1. **抗污染层缺**: 没跑过 anti-leakage probe (v0.5.1 §4 机制 4)
2. **多模型对比缺**: 只测了 M3, 没对比 GPT-4/Claude
3. **稳定性缺**: 同一 prompt 多次跑的一致性未测

## 七、跟 v0.6/v0.7 prototype 关系

| 项 | prototype v0.6/v0.7 | benchmark v0.10 |
|---|---|---|
| 评分标准 | 4 面 checklist + 27 rubric | 5 级 + 4 维度 + 3 protocol |
| 锚定 | M3 自评 (主观) | 5 级行为锚定 (相对客观) |
| 用途 | 演示 "LLM 能完成 insight→work 流程" | 评分 "LLM 在什么级别产生 insight" |

**关系**: prototype 是"LLM 能做到什么"的演示, benchmark 是"LLM 做到了什么级别"的评测。两者互补。

## 八、一句话总结

> DNA ↔ Software Replication 在 v0.5.1 protocol 下评级 **L4-L5 边界 / 4 维度 4.0/5**。
> 这是 v0.10 第一次正式 baseline, 用于 v0.11+ 多模型/多 prompt 对比锚定。
