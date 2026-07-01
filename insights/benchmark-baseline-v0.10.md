# Insight Benchmark Baseline · v0.10 + v0.11

> 2026-07-01 · v0.10 N=2 baseline + v0.11 N=3 扩展
> 协议: `80-meta/llm-insight-evaluation-protocol.md` v0.5.1 (5 级 + 4 维度 + 3 protocol)
> 模型: MiniMax-M3 (单模型, 跨样本对比)

## 0. 更新摘要 (v0.11)

- 加第 3 样本: Music Counterpoint ↔ Software Modularity
- v0.10 假设 "枢轴极简性决定 L4→L5 跨越" 被验证 (Music 案例首入 L5 区间)
- 新发现: 3 案例共同涉及"无中心协调下的全局一致" (元枢轴候选)

## 一、为什么这是 baseline

v0.5 体系搭好, v0.6 流程跑通, v0.7 拿 2 案例自测完. 但**没有把 prototype 转成 benchmark 样本** — 没经过 5 级评分锚定, 没法横向对比.

**v0.10 第一次回填**: 把 2 个 prototype 用 v0.5.1 protocol 正式评分 = baseline.

## 二、3 样本数据 (v0.11 扩展)

| 样本 | 5 级 | 4 维度均分 | 找到枢轴 | 连接度 | 简化度 | 反例力 | 总评 |
|---|---|---|---|---|---|---|---|
| **DNA ↔ Software** | 4.5 (L4-L5 边界) | 4.0 | 5/5 | 4/5 | 4/5 | 3/5 | 高 |
| **Ecosystem ↔ Self-Repair** | 4.0 (L4) | 3.75 | 4/5 | 4/5 | 3/5 | 4/5 | 中高 |
| **Music ↔ Modularity** | 4.7 (L4-L5 边界) | 4.75 | 5/5 | 5/5 | 5/5 | 4/5 | **最高** |

### 关键差异
- **DNA 更接近 L5**: 枢轴"冗余+校验+半保留同步"极简, 翻转"副本"理解
- **Ecosystem 停在 L4**: 枢轴"自稳态"较泛, 翻转"自适应"理解但不够极简

### 经验 (v0.11 验证 + 扩展)
**跨域隐喻任务, 枢轴的极简性决定 L4→L5 跨越**. "副本"是 1 个机制, "自稳态"是 1 个范畴.
- DNA (3字) > Ecosystem (5字) 在 5 级上
- Music (3字) > DNA (3字) 在 4 维度上 → **极简性是必要, 不是充分**
- 还要看"翻转深度"和"反例边界"

### 元枢轴候选 (v0.11 新发现)
3 案例都涉及"无中心协调下的全局一致":
- DNA: 副本+校验 (无中心同步)
- Ecosystem: 自稳态 (无中心反馈)
- Music: 对位法 (无中心协调)
→ **这可能是"跨域隐喻"任务的元枢轴** — 需要 N=4+ 验证

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

## 五、给 v0.12+ 的方向

1. ~~加 1 个新样本 (v0.11)~~ ✓ 完成
2. **加多模型对比 (v0.12)**: 同一 prompt 跑 GPT-4 / Claude / M3, 看 5 级分布
3. **加 anti-leakage probe (v0.13)**: 给 3 案例各加 1 个"看似对但错"的探针, 测 M3 是否会被骗
4. **加稳定性测试 (v0.14)**: 同 prompt 跑 5 次, 看 4 维度均分方差
5. **加 N=4 验证元枢轴 (v0.15)**: 选 1 个不涉及"无中心协调"的领域, 看 M3 是否还能达 L4+

## 六、跟体系其他部分连接

| 部分 | 关系 |
|---|---|
| `80-meta/llm-insight-benchmark.md` v0.5 | 本文是 v0.5 落地 |
| `80-meta/llm-insight-evaluation-protocol.md` v0.5.1 | 本文用其 5 级 + 4 维度 + 3 protocol |
| `80-meta/insight-completion-rubric.md` v0.6.4 | prototype 评分用 27 rubric, benchmark 评分用 5 级 — 两套并存 |
| `insights/dna-software-replication/benchmark-v0.10.md` | 样本 1 详情 |
| `insights/ecosystem-software-self-repair/benchmark-v0.10.md` | 样本 2 详情 |

## 七、一句话总结 (v0.11 更新)

> v0.11 baseline: M3 在跨域隐喻任务上, 3 样本都达 L4+, Music 案例首入 L5 区间 (4 维度 4.75/5).
> **枢轴极简性是 L4→L5 必要条件** (v0.10 假设验证).
> **元枢轴候选发现**: "无中心协调" = 3 案例共同点, 待 N=4+ 验证.
> v0.12+ 方向: 多模型对比 + anti-leakage + 稳定性 + 元枢轴验证.
