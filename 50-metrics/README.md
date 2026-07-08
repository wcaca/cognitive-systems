# 50-metrics (active)

> v0.8.20 起从 [active: draft] 升级为 [active: 可机读 + CI 集成]。
> W 顿悟：指标不被自动化 = 指标不存在。

## 指标体系

- [`completeness-metrics.md`](./completeness-metrics.md) — v0.8.16 起 · 仓完整性指标体系 (M1-M4 + 综合分)，v0.8.20 补可机读脚本 + 实测数据

## 配套工具

- `scripts/completeness-check.sh` (v0.8.20) — 自动跑 M1-M4，输出综合分和健康判断
- 契约见 [`60-tools/completeness-check.md`](../60-tools/completeness-check.md)