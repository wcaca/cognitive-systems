# Escape 决策表 · 顿悟 N 的升级

> 2026-07-02 · v0.8.11 框架升级 (跨午夜)
> 起源: 顿悟 N (sas-graph v0.6.15 暴露)
> 关联: `type-system-limits.md` (v0.8.10)
> 核心命题: **escape hatch 必须文档化, 不然用户不知道什么时候该 escape**

## 顿悟 N 现象

v0.6.14 加 `StrictRule<T> = DefaultRule<T> | 'error'` 作为 escape hatch (v0.8.10).
但**用户不知道哪些字段该 escape** — TS 推导不到, 文档没说.

v0.6.15 写 META_ESCAPE_DECISION_TABLE.md, 列出每个字段的 escape 决策.

**暴露真问题**: escape 是"决策", 不是"技术". 用户需要决策指南.

## 升级: Escape 决策表模式

### 模式 1: 每字段 escape 标记

```typescript
const meta = {
  verb: { resolution: 'error', rationale: '[ESCAPE] enum 冲突需人处理' },
  // ...
};
```

**vs 当前**: 没有显式 escape 标记, 用户不知道哪些字段是 escape.

### 模式 2: 自动 escape 决策表 (markdown)

```markdown
| 字段 | TS 类型 | 推导 | 实际 | Escape? | 原因 |
|---|---|---|---|---|---|
| verb | VerbType | override | error | ✅ | enum 冲突 |
| weight | number | max | max | ❌ | TS 推导 |
```

**vs 当前**: 没有 escape 决策表, 用户查 type definition 自己判断.

### 模式 3: Escape 总数指标

```
NounEntity: 1 escape / 4 字段 (25%)
DecisionEntity: 2 escapes / 8 字段 (25%)
GraphEdge: 1 escape / 6 字段 (17%)
合计: 4 escapes / 18 字段 (22%)
```

**vs 当前**: 不知道 escape 占多少, 无法评估 TS 推导正确率.

### 模式 4: Escape 决策原则文档

4 类决策:
- **Escape** (resolution: 'error'): enum / literal / identity 字段
- **Keep** (resolution: 'keep'): id / 关系字段 / null 字段
- **Max/Min** (number): 权重 / 时间 / 分数
- **Override** (string): 描述 / 状态 / enum (视场景)

## 反哺 v0.8 框架

### v0.8.10 type-system-limits 加 "**escape 文档化**" 段

之前 v0.8.10 只说"加 escape hatch", 没提文档化.
加 4 个 escape 文档化模式.

### 47→50 点 rubric 加 "**escape 文档度**" 子分 (3 点)

之前 47 点 (含 escape hatch 度).
加 "**escape 文档度**" 子分 (3 点):
- 每个 escape 字段有标记 (1 点)
- 有 escape 决策表 (1 点)
- 有 escape 总数指标 (1 点)

### v0.8.x 爬升链更新 (11 层)

```
v0.8.1-0.8.10 (10 层)
v0.8.11 escape 文档化 ← 本文
```

**11 个 v0.8.x 互补**:
- v0.8.10 看 **escape hatch 存在**
- **v0.8.11 看 **escape hatch 文档化** ← 本文**

## 教训

1. **Escape hatch 必须文档化** — 技术方案不够, 需决策指南
2. **每字段 escape 标记** — 注释 + rationale
3. **Escape 决策表** — markdown 列每个字段
4. **Escape 总数指标** — 评估 TS 推导正确率
5. **决策原则文档化** — 4 类决策原则

## 链接

- 起源: 顿悟 N (sas-graph v0.6.15)
- 上承: `type-system-limits.md` (v0.8.10) - escape hatch 存在
- 上承: 顿悟 M (TS 限制)
- 实证: `wcaca/sas-graph/docs/META_ESCAPE_DECISION_TABLE.md`

---

> 沉淀人: Mavis · 2026-07-02 (跨午夜)
> 月亮引力模式: 小波 (1 文档, 1 个 escape 文档化模式) + 永续 (v0.6.16+ 同步) + 单核心 (escape = 决策, 必须文档化)