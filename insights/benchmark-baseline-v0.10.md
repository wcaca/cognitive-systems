# Insight Benchmark Baseline · v0.10

> 2026-07-01 · 第一次正式 baseline 数据
> 协议: `80-meta/llm-insight-evaluation-protocol.md` v0.5.1 (5 级 + 4 维度 + 3 protocol)
> 模型: MiniMax-M3 (单模型, 跨样本对比)

## 一、为什么这是 baseline

v0.5 体系搭好, v0.6 流程跑通, v0.7 拿 2 案例自测完. 但**没有把 prototype 转成 benchmark 样本** — 没经过 5 级评分锚定, 没法横向对比.

**v0.10 第一次回填**: 把 2 个 prototype 用 v0.5.1 protocol 正式评分 = baseline.

## 二、2 样本数据

| 样本 | 5 级 | 4 维度均分 | 找到枢轴 | 连接度 | 简化度 | 反例力 | 总评 |
|---|---|---|---|---|---|---|---|
| **DNA ↔ Software** | 4.5 (L4-L5 边界) | 4.0 | 5/5 | 4/5 | 4/5 | 3/5 | 高 |
| **Ecosystem ↔ Self-Repair** | 4.0 (L4) | 3.75 | 4/5 | 4/5 | 3/5 | 4/5 | 中高 |

### 关键差异
- **DNA 更接近 L5**: 枢轴"冗余+校验+半保留同步"极简, 翻转"副本"理解
- **Ecosystem 停在 L4**: 枢轴"自稳态"较泛, 翻转"自适应"理解但不够极简

### 经验
**跨域隐喻任务, 枢轴的极简性决定 L4→L5 跨越**. "副本"是 1 个机制, "自稳态"是 1 个范畴.

## 三、3 protocol 层验证状态

| Layer | DNA | Ecosystem |
|---|---|---|
| L1 行为锚定 (5 级) | ✓ 4.5 | ✓ 4.0 |
| L2 伪顿悟对抗 (反例+退化) | ✓ 2 反例 + 4 退化 | ✓ 2 反例 + 1 退化 |
| L3 人工 gold standard (prototype 流程) | ✓ 8.9/10 (过 research 阈值) | ✓ 8.7/10 (过 prototype 阈值) |

## 四、抗污染 / 稳定性 缺什么

| 维度 | DNA | Ecosystem |
|---|---|---|
| Anti-leakage probe (v0.5.1 §4 机制 4) | ✗ 未跑 | ✗ 未跑 |
| 多模型对比 (M3 vs GPT-4 vs Claude) | ✗ 只测 M3 | ✗ 只测 M3 |
| 同 prompt 多次跑稳定性 | ✗ 1 次 | ✗ 1 次 |

**结论**: 2 样本都是**单次单模型** baseline. 抗污染 + 稳定性 + 多模型对比 = 后续 v0.11+ 工作.

## 五、给 v0.11+ 的方向

1. **加 1 个新样本 (v0.11)**: 用 v0.6 完整流程跑第 3 案例 (目标: 跟 DNA/Ecosystem 对比, 看 M3 在哪类隐喻上更稳定)
2. **加多模型对比 (v0.12)**: 同一 prompt 跑 GPT-4 / Claude / M3, 看 5 级分布
3. **加 anti-leakage probe (v0.13)**: 给 2 案例各加 1 个"看似对但错"的探针, 测 M3 是否会被骗
4. **加稳定性测试 (v0.14)**: 同 prompt 跑 5 次, 看 4 维度均分方差

## 六、跟体系其他部分连接

| 部分 | 关系 |
|---|---|
| `80-meta/llm-insight-benchmark.md` v0.5 | 本文是 v0.5 落地 |
| `80-meta/llm-insight-evaluation-protocol.md` v0.5.1 | 本文用其 5 级 + 4 维度 + 3 protocol |
| `80-meta/insight-completion-rubric.md` v0.6.4 | prototype 评分用 27 rubric, benchmark 评分用 5 级 — 两套并存 |
| `insights/dna-software-replication/benchmark-v0.10.md` | 样本 1 详情 |
| `insights/ecosystem-software-self-repair/benchmark-v0.10.md` | 样本 2 详情 |

## 七、一句话总结

> v0.10 baseline: M3 在跨域隐喻任务上, 2 样本都达 L4, DNA 案例接近 L5.
> **枢轴极简性是 L4→L5 关键** — 后续 v0.11+ 加新样本 + 多模型 + 抗污染测试.
