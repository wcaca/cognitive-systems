# S2.11 debug-overlay + S2.12 expected-calculator 实验规划

> **时间**: 2026-07-12 (凌晨 5 点长程模式)
> **来源**: thoughtspace-notes 仓 S2 阶段, S2.10 render-pipeline 完成后的下一批
> **关联**: S 顿悟 (insight-extraction-protocol), T 顿悟 (fill-order-coordination)
> **本文件**: 在 cognitive-systems 沉淀规划, 实际代码 commit 到 thoughtspace-notes

## 背景

S2 (念头实体阶段) 已经完成 S2.1-S2.10 (12 个子阶段). 下一批是 S2.11 + S2.12, 一组**排查基础**组件:

- **S2.11 debug-overlay**: 把 S2.10 暴露的 `getStats()` 可视化到屏幕角落, 让 AI 排查时直接读图
- **S2.12 expected-calculator**: 根据实体数量计算"理论帧耗时", 给"快/慢"提供基线

这组实验是为了让 `v25dt++ AI 诊断` 模式 (system-self cobweb 端点) 跟 thoughtspace-notes 的渲染性能**形成闭环**:
- AI 诊断端点发现 thoughtspace-notes 性能问题
- 截图带 debug-overlay, AI 直接读图分析
- expected-calculator 给"此帧该多少 ms", AI 能定位是"渲染层慢"还是"实体多了本应慢"

## 详细规划

完整规划在 thoughtspace-notes 仓:

- [`docs/notes/s2/S2.11-debug-overlay-plan.md`](https://github.com/wcaca/thoughtspace-notes/blob/main/docs/notes/s2/S2.11-debug-overlay-plan.md)
- [`docs/notes/s2/S2.12-expected-calculator-plan.md`](https://github.com/wcaca/thoughtspace-notes/blob/main/docs/notes/s2/S2.12-expected-calculator-plan.md)

## 关键设计决策 (沉淀到 cognitive-systems)

### 1. 排查基础 = 可观察, 不中断

S2.10 决策 (render-pipeline-5-stages) 已经确立: 错误策略是 `warn + 继续`, 不是 throw. S2.11+S2.12 沿用同一原则:

- overlay 自身渲染 < 0.5ms / 帧 (用 canvas 不用 DOM, 避免 reflow)
- calculator 缓存 entity 签名, 实体数没变不重算
- **绝对不能因为排查组件慢, 让被排查对象变慢** (这违反"排查基础"本意)

### 2. 经验常数 → telemetry 校准

S2.12 公式用 5 个经验常数 (v0.1):
- BASE_OVERHEAD_MS = 0.5
- THOUGHT_MS = 0.05
- MEMORY_MS = 0.10
- DRAW_CALL_MS = 0.02
- DISTANCE_MS = 0.01

策略: 启动快, 50 帧后用 telemetry 校准, 校准数据存 localStorage 跨 session 累计. 这跟 Y 顿悟 (evolution-depth-protocol) 的"防集中补"思想一致 — **不要一次写死, 持续校准**.

### 3. 跨仓接口

| 仓 | 角色 | 暴露 |
|---|---|---|
| thoughtspace-notes | 渲染层 | `__v2.renderPipeline.getStats()`, `__v2.debugOverlay`, `__v2.calculator.compute()` |
| system-self | 诊断层 (v25dt++) | 调用端点: `/api/cobweb/diagnose`, 输入 thoughtspace-notes 截图 |
| cognitive-systems | 沉淀层 | 跨仓协调, 协议, 决策记录 |

## 实施状态

- [x] S2.11 规划文档 (90 行, 在 thoughtspace-notes 仓)
- [x] S2.12 规划文档 (124 行, 在 thoughtspace-notes 仓)
- [ ] S2.11 代码实做 (等本机, 沙箱 git push 不通)
- [ ] S2.12 代码实做
- [ ] 跨仓集成 (overlay 截图 → v25dt++ 诊断端点)
- [ ] 50 帧 telemetry 收集 + 校准

## 沉淀的元方法论

- **错误可观察 ≠ 错误可见**: S2.10 让 getStats() 可读 (机器可读), S2.11 让 stats 可见 (人类可读), S2.12 让"快/慢"有标准 (expected vs actual). 三层逐步升维.
- **跨仓闭环**: 排查基础 (thoughtspace-notes) + AI 诊断 (system-self) + 沉淀 (cognitive-systems) 形成三方飞轮. 任何一方独立都不闭环.
