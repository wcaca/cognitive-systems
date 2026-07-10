# Evolution 深度协议 (Evolution Depth Protocol)

**版本**: v0.8.22 (Y 顿悟)
**状态**: active
**配套指标**: M3b (completeness-check.sh v0.8.22+)
**前置协议**: [evolution-sync-protocol.md](./evolution-sync-protocol.md) (X 顿悟 v0.8.21)

---

## 1. 为什么需要 Y 协议

X 协议 (v0.8.21) 修了一个作弊：测"嘴上说" → 测"实际做"。但 X 协议只测**频次**，防不了**集中补**。

**典型作弊模式**：
- 一个月不补 evolution.md
- 周末 1 次写 5KB 总结，commit 一次
- 频次上：1/30 = 3% (M3 不及格) ← 这反而能被抓
- 进阶作弊：每周 1 次写 1 行"## v0.8.xx 修复某 bug" = 7/30 = 23% (M3 看起来 OK，但内容是空话)

Y 协议 = 测"每次更新是不是真在思考"，**频次 + 深度双合格才算合格**。

## 2. 指标定义

### M3b evolution 深度

```
M3b = min(1.0, avg_added_chars / 100)
其中 avg_added_chars = total_added_chars_in_evolution_commits / evolution_commits_count
total = 最近 N=30 commit 中 evolution 提交的总 + 字符数
```

**阈值**:
- 100 字符/提交 = 合格下限
- 200+ 字符/提交 = 理想 (本次 v0.8.22 实测 190 = 合格)
- < 50 字符/提交 = "集中补"信号, 触发审查

### 综合分

v0.8.22 起, 综合分 = (M1 + M2 + M3 + M3b + M4) / 5 × 100

5 指标等权:
- M1 协议使用率
- M2 空目录诚实率
- M3 evolution 同步率 (频次) ← X 顿悟
- **M3b evolution 深度 (平均 + 字符数) ← Y 顿悟**
- M4 跨仓状态新鲜度

## 3. 与 X 协议的协同

| 场景 | M3 (频次) | M3b (深度) | 判定 |
|------|----------|----------|------|
| 5/30 commit 补, 平均 +500 chars | 0.17 | 1.00 | ✅ 真合规 (本次 v0.8.22) |
| 5/30 commit 补, 平均 +30 chars | 0.17 | 0.30 | ⚠️ 半合规, 凑数 |
| 25/30 commit 补, 平均 +20 chars | 0.83 | 0.20 | ❌ 作弊 (高频空话) |
| 0/30 commit 补 | 0.00 | 0.00 | ❌ 沉默 (X 已能抓) |

**X 抓沉默, Y 抓空话。两者互补。**

## 4. 实施步骤

1. `scripts/completeness-check.sh` 加 M3b 段 (numstat + awk 算 avg)
2. 综合分从 4 指标 → 5 指标
3. JSON 输出 + 文本输出加 M3b 行
4. evolution.md 补 v0.8.22 段 (本文)
5. 50-metrics/completeness-metrics.md §M3b 描述 + §6.2 算法对比

## 5. 已知未知 (Z 顿悟伏笔)

- 100 字符阈值: 200 chars/次, 100 chars/次, 50 chars/次 哪个更合理? — 需要更多 4-仓数据
- 跨仓 enforcement: 4 仓的 M3b 是否一致? — Z 协议 v0.8.23+ 调研
- AI 辅助 commit 的 evolution 写作: 当 LLM 帮你写 evolution, "深度"是 AI 深度还是人深度? — 未知
- 模板化 evolution 写作: 如果 5 次 evolution 都是 "### 目的/状态/方法/..." 同模板, avg + 字符数仍高 — Y 协议会被绕过? ← **Y.1 顿悟候选**: 测模板多样性

## 6. 历史

- v0.8.20: W 协议 (M1-M4 可机读化)
- v0.8.21: X 协议 (M3 频次 = 测协议履行, 不是测嘴上说)
- **v0.8.22: Y 协议 (M3b 深度 = 防集中补, 测真思考) — 本文**

## 7. 基调

"X 抓'说不说', Y 抓'说得有没有'。X+Y = evolution 协议真正诚实。"
