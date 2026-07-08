# completeness-check.sh · 仓完整性指标检查工具

> **60-tools 第二篇 (v0.8.20 / 顿悟 W)** — 工具契约 (contract) + 使用指南
>
> **顿悟 W 起源**：T 协议 (填实顺序协调) 实施时, 50-metrics/completeness-metrics.md 已经写了 M1-M4 4 个指标 + 综合分算法, 但从未被自动跑过。v0.8.16 的"实测 87.5"是手动算的数, 不是脚本算的。**指标不被自动化 = 指标不存在**。把 4 个指标从 [draft] 文字描述升级为可执行脚本 = 让仓能自我检查完整性。
>
> **路径不动, 契约抽出来** — 脚本本身仍在 `scripts/completeness-check.sh` (与 cross-repo-status.sh 同样的契约策略, 见 60-tools/cross-repo-status.md), 60-tools/ 只放契约 + 例子 + 故障排查。

## 工具身份

| 字段 | 值 |
|------|-----|
| **name** | completeness-check.sh |
| **version** | v0.8.20 |
| **path** | `scripts/completeness-check.sh` (199 行 bash) |
| **language** | bash (set -uo pipefail, **不** -e) |
| **dependencies** | git, find, grep, awk, stat (GNU 或 BSD 兼容) |
| **runtime** | < 2s (cognitive-systems 仓实测 1.2s) |

## 功能

自动跑 50-metrics/completeness-metrics.md 定义的 4 个完整性指标, 输出综合分 (0-100) 和健康判断。

指标:
1. **M1 协议使用率** — 仓内 commit/文档引用协议次数 / 80-meta/ 协议总数
2. **M2 空目录诚实率** — empty_dirs_with_README / total_empty_dirs
3. **M3 evolution 同步率** — evolution_commits / total_commits (最近 30 个)
4. **M4 跨仓状态新鲜度** — `insights/cross-repo-status.md` 最后修改时间与现在距离

健康阈值 (默认 75): ≥75 = healthy, 60-75 = warning, <60 = unhealthy。

## 调用契约

### 输入

| flag | 类型 | 默认 | 说明 |
|------|------|------|------|
| `--repo=PATH` | string | `.` (当前目录) | 检查的仓路径 |
| `--json` | bool | false | 输出 JSON (用于 CI / 跨仓统计) |
| `--threshold=N` | int | 75 | 健康阈值 (0-100) |
| `--no-color` | bool | false | 关闭 ANSI 颜色 (CI / pipe 用) |

### 输出

人类可读 (默认):
```
=== completeness-check.sh · <timestamp> ===
Repo: .    Threshold: 75

指标                           值      详情
-------------------------------- -------- ----------------------------------------
M1 协议使用率               0.97     28/29 协议被引用
M2 空目录诚实率            1.00     0/0 空目录有 README
M3 evolution 同步率           0.07     2/30 commit 涉及 evolution
M4 跨仓状态新鲜度         1.00     age=698s

综合分 (M1-M4 等权平均)   76.0
状态: healthy (≥ 75)
```

JSON (`--json`):
```json
{
  "repo": ".",
  "threshold": 75,
  "metrics": {
    "M1_protocol_adoption": { "value": 0.97, "referenced": 28, "total": 29 },
    "M2_skeleton_honesty": { "value": 1.00, "with_readme": 0, "empty_total": 0 },
    "M3_evolution_sync": { "value": 0.07, "evolution_commits": 2, "total_commits": 30 },
    "M4_cross_repo_freshness": { "value": 1.00, "age_seconds": "698" }
  },
  "score": 76.0,
  "health": "healthy",
  "timestamp": "2026-07-08T21:14:42Z"
}
```

### 退出码

- 0: healthy (score ≥ threshold)
- 1: warning / unhealthy (score < threshold)
- 2: 参数错误 (未知 flag / 非 git 仓)

### 副作用

- 无文件写入 (纯只读检查)
- 不修改 git 状态
- 不 push 任何东西

## 设计原则 (50-metrics 协议)

1. **每个指标必须给真实数字** — 不允许 "感觉" / "大约"
2. **4 指标等权平均** — v0.8.16 定义, v0.8.20 实现
3. **健康阈值默认 75** — 与 50-metrics/completeness-metrics.md §3 一致
4. **set -uo pipefail 但不 -e** — awk 分母为零 / grep 无匹配时不中断, 让脚本能继续输出报告

## 与其他工具的关系

| 工具 | 关系 |
|------|------|
| `cross-repo-status.sh` | 上游: M4 依赖 `insights/cross-repo-status.md` 存在 + 新鲜 |
| `ci-enforcement.md` (80-meta) | 下游: 建议在 CI workflow 里跑 completeness-check |
| `evolution.md` (50-metrics/..) | 同根: M3 evolution 同步率是 evolution.md 的可机读版本 |

## 已知故障

| 故障 | 现象 | 修复 |
|------|------|------|
| `M2 0%` 但仓无真空目录 | `.git/` 子目录被错误统计 | 已修 v0.8.20: case 排除 `*/.git/*` |
| `M4 0.00` 永久 | `insights/cross-repo-status.md` 不存在 | 跑 `cross-repo-status.sh` 生成 |
| `M3 0%` | evolution 模式未启动 | v0.8.20 暴露, 留待后续改进 commit 习惯 |
| macOS stat 不识别 `-c %Y` | 退出 1 | 已修 v0.8.20: 兼容 BSD stat `-f %m` |

## 实施历史

- v0.8.20 (2026-07-08): 初版。199 行 bash + 60-tools/ 契约 = W 顿悟落地
- v0.8.20+ 待办: 集成进 CI workflow, 跨仓 score 统计 (cross-repo-status.sh --completeness)

[PROTOCOL]: 变更时更新此头部,然后检查 ../CLAUDE.md