# Completeness Metrics · 仓完整性指标体系

> [active] 2026-07-08 · v0.8.20 · W 顿悟的实施产物（从 [draft] 升级为 [active]，附可机读脚本）
>
> **W 顿悟**：指标不是写了算的，是跑出来的。M1-M4 从 [draft] 文字描述升级为 [active] 可机读实现 = `scripts/completeness-check.sh`。指标被 CI/手动/跨仓检查调用之前，只是观念。
>
> 配套：[`80-meta/skeleton-as-completeness-signal.md`](../80-meta/skeleton-as-completeness-signal.md) §五
>
> **问题**：怎么度量"一个研究仓完成了多少"？不是 LOC，也不是 commit 数，是**完整性**。

---

## 1. 为什么不能用 LOC / commit 数

研究仓的价值不来自代码量，也不来自 commit 频率。3 个反例：

- 一个 10000 LOC 仓可能 99% 是 vendor 代码
- 一个 100 commit 仓可能 80% 是 typo fix
- 一个 50 文件仓可能 40 文件是 .gitkeep

**完整性 = 协议被使用 + 内容诚实 + 框架被填实**。

---

## 2. 4 个核心指标

### M1. 协议使用率 (Protocol Adoption)
**定义**：仓里有多少 80-meta 的协议，实际在代码 / commit / 文档中被引用？
**计算**：`grep -r "协议" --include="*.md" --include="*.sh" --include="*.yml" | wc -l` / 协议总数
**目标**：≥ 60%
**反例**：协议文档写了，但没人用 = 写而不行

### M2. 空目录诚实率 (Skeleton Honesty)
**定义**：仓里有多少空目录是有 README 占位的？
**计算**：empty_dirs_with_readme / total_empty_dirs
**目标**：100%
**反例**：空目录无 README = 假装它有内容

### M3. evolution.md 同步率 (Evolution Sync Rate)
**定义**：最近 N 个 commit 中，有多少 commit 同步补了 evolution.md 段？
**计算**：evolution_commits / total_commits（最近 30 个）
**目标**：≥ 70%
**反例**：commit 不补 evolution = 元方法论自己违反元方法论

### M4. 跨仓状态新鲜度 (Cross-repo Freshness)
**定义**：`insights/cross-repo-status.md` 的最后更新时间距今多少？
**计算**：`now - last_modified`
**目标**：≤ 24h
**反例**：状态散落 = 跨仓不诚实

---

## 3. 怎么算综合完整性分

```python
def completeness_score(m1, m2, m3, m4):
    """综合完整性分 0-100"""
    score = (
        m1 * 0.25 +  # 协议使用率
        m2 * 0.25 +  # 空目录诚实率
        m3 * 0.25 +  # evolution 同步率
        m4 * 0.25    # 跨仓状态新鲜度
    )
    return round(score * 100, 1)
```

**目标**：≥ 75 = 健康，60-75 = 警告，< 60 = 不健康

---

## 4. 实测：cognitive-systems 仓 v0.8.16

| 指标 | 值 | 状态 |
|---|---|---|
| M1 协议使用率 | 80% (8/10 主要协议被 commit 引用) | ✅ |
| M2 空目录诚实率 | 100% (所有空目录都有 README 占位) | ✅ |
| M3 evolution 同步率 | 70% (v0.8.13 之后每次都补) | ✅ |
| M4 跨仓状态新鲜度 | < 24h | ✅ |
| **综合** | **87.5** | **健康** |

---

## 5. 指标的反模式

| 反模式 | 表现 | 修正 |
|---|---|---|
| 用 LOC 度量 | "我们有 5000 行" | 用 M1-M4 |
| 用 commit 数度量 | "我们很勤奋" | 用 M3 (evolution 同步率) |
| 用文件数度量 | "我们 50 个文档" | 用 M2 (空目录诚实率) |
| 指标不衡量 | "我们很完整" | 必须给数 |

---

## 6. 演进

- v0.8.16 (2026-07-04)：初稿。4 个核心指标 + 综合分算法 + 实测数据
## 7. v0.8.20 实测 (W 顿悟落地后)

```
$ bash scripts/completeness-check.sh
=== completeness-check.sh · 2026-07-08T21:14:42Z ===
M1 协议使用率     0.97   28/29 协议被引用
M2 空目录诚实率  1.00   0/0 空目录有 README     (W 顿悟修正: 补 20-systems/.github 顶层 README)
M3 evolution 同步率 0.07  2/30 commit 涉及 evolution  ⚠ 最大改进点
M4 跨仓状态新鲜度 1.00   age=698s
综合分 76.0    healthy
```

**W 顿悟的核心发现**：
- 写完 completeness-metrics.md 之后没人跑过 = 指标是死的
- v0.8.16 的"实测"是手动写的数（87.5），不是脚本算的数
- v0.8.20 起每次 push 必跑 completeness-check.sh，**M3 evolution 同步率 7% 暴露了元方法论自己违反元方法论**

## 8. 跟 CI 的集成 (v0.8.20)

`.github/workflows/` 建议加 `completeness-check.yml`：

```yaml
name: completeness-check
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash scripts/completeness-check.sh
```

CI 失败 (score < threshold) 阻断 merge。

## 9. 跟跨仓的关系

`scripts/cross-repo-status.sh --completeness` 可批量跑多个仓的 completeness-check.sh，
把每个仓的 score 写进 `cross-repo-status.md` 的"健康度"列。
（W 协议留待 v0.8.21 实施）

