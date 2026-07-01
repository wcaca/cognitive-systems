# Schema 元信息框架 · 顿悟 J 的升级

> 2026-07-01 · v0.8.7 框架升级
> 起源: 顿悟 J (sas-graph v0.6.11 暴露)
> 关联: `explicit-dependencies.md` (v0.8.6) + `tri-dimensional-completeness.md` (v0.8.4)
> 核心命题: **类型系统知道"是 number", 但不知道"该用 max"; smart 需要 schema 元信息, 不只是 TS 类型**

## 顿悟 J 现象

`smartMerge` (v0.6.11) 需要 field rules, 但用户**必须手写**:
```typescript
{ field: 'weight', resolution: 'max' }  // weight 是数字, 该用 max?
{ field: 'createdAt', resolution: 'min' }  // createdAt 是事件, 该用 min?
```

**Graph TS 类型**:
```typescript
export interface DecisionEntity {
  weight: number;      // 数字 — 但 merge 语义?
  createdAt: number;   // 数字 — 但事件/状态?
  description: string; // 字符串 — 但可覆盖?
}
```

**TS 类型只说"是 number/string", 不说"该怎么 merge"**.

## 升级: Schema 元信息层

每个字段加 3 个元信息:
1. **kind**: 'numeric' | 'textual' | 'enum' | 'event-time' | 'state-time'
2. **defaultRule**: 'override' | 'keep' | 'min' | 'max' | 'average' | 'skip'
3. **rationale**: 解释为什么选这个 rule

```typescript
// Zod schema 自带元信息
const DecisionEntitySchema = z.object({
  weight: z.number().describe('merge=max; 权重, 取较大表示更新决策'),
  createdAt: z.number().describe('merge=min; 事件时间, 保留最早'),
  description: z.string().describe('merge=override; 描述, 用最新版'),
  // ...
});

// 从 schema 推默认 rules
const rules = defaultSmartMergeRules(DecisionEntitySchema);
// → [{ field: 'weight', resolution: 'max', rationale: '...' }, ...]
```

## 4 个升级

### 1. Schema 元信息 (Zod / JSON Schema)
- TS 类型 + Zod schema 同时定义
- Zod 提供 `.describe()` 和 `.default()` 元信息
- 所有模块从 Zod schema 推默认行为

### 2. 默认行为从 schema 推
```typescript
// 自动从 schema 推 rules
function defaultSmartMergeRules(schema: ZodObject<any>): FieldRule[] {
  return Object.entries(schema.shape).map(([field, validator]) => {
    const description = validator.description ?? '';
    const ruleMatch = description.match(/merge=(\w+)/);
    return {
      field,
      resolution: (ruleMatch?.[1] ?? 'override') as FieldLevelResolution,
    };
  });
}
```

### 3. 用户可覆盖 (显式 > 默认)
```typescript
smartMerge(g1, g2, {
  rules: 'default',  // 从 schema 推
  // 用户可覆盖:
  fieldRules: [{ field: 'weight', resolution: 'average' }],
});
```

### 4. schema 元信息自描述 (JSON Schema)
- schema 本身可导出 (跟 Graph type 一起)
- 跨仓同步时, schema 元信息是关键

## 反哺 v0.6 / v0.8 框架

### v0.6 (insight-to-work) 加第 8 步 "**元信息**"

之前 7 步 (顿悟→推断→验证→4 面→判断→制品→集成).
加第 8 步 "**元信息**":
- 单模块 + 集成测试完, 加 schema 元信息
- 让"smart"模块能从 schema 推默认行为

### v0.8 IPL 加阶段 6.6 "**元信息自检**"

之前阶段 6 验证 + 6.5 自检 + 6.6 集成自检.
加 6.6 "元信息自检":
- 每个字段有 kind + defaultRule + rationale?
- schema 元信息导出可读 (跟 JSON Schema 兼容)?

### 35→38 点 rubric 加 "**元信息度**" 子分 (3 点)

之前 35 点 = L1+L2+L3+type-checked+集成度.
加 "**元信息度**" 子分 (3 点):
- 字段有 kind 元信息 (1 点)
- 字段有 defaultRule 元信息 (1 点)
- 字段有 rationale 元信息 (1 点)

### v0.8.5 可能性域扫描修订

之前 4 维度 (Schema/算法/API/性能) + 第 5 维度 (集成).
**schema 元信息应该是 top 1, 不是第 3**:

| 排名 | 可能性 | 评分 |
|---|---|---|
| **top 1** | **schema 元信息** | **5.0** |
| top 2 | 字段级 merge | 4.5 |
| top 3 | deep-ignore | 3.5 |

v0.6.11 推进证明了这一点 — schema 元信息缺失让 smartMerge 必须手写规则.

## v0.8.x 爬升链更新 (7 层)

```
v0.8.1 层间 (6 抽象层)
v0.8.2 层内 (6 维自检)
v0.8.3 协同 (LLM + user 90%)
v0.8.4 深度 (推断 + 判断 + 验证)
v0.8.5 广度 (可能性域扫描)
v0.8.6 集成 (模块间显式依赖)
v0.8.7 元信息 (schema 元信息) ← 本文
```

**7 个 v0.8.x 互补**:
- v0.8.1 看 **步骤间**
- v0.8.2 看 **步骤内 维度**
- v0.8.3 看 **谁触发**
- v0.8.4 看 **步骤内 深度**
- v0.8.5 看 **步骤内 广度**
- v0.8.6 看 **模块间依赖**
- **v0.8.7 看 **schema 元信息** ← 本文**

## 实测: v0.6.11 smartMerge 暴露 schema 元信息缺失

| 字段 | TS 类型 | 该用 max/min/keep? | 用户必须决策 |
|---|---|---|---|
| `weight` | `number` | max (权重越大越重要) | ✅ |
| `createdAt` | `number` | min (事件时间最早) | ✅ |
| `description` | `string` | override (用最新描述) | ✅ |
| `confidence` | `number` | max (置信度越高越权威) | ✅ |
| `verb` | `VerbType` (enum) | error (决策类型冲突需人处理) | ✅ |

**5 个字段, 5 次决策** — 全靠用户, 不能自动推.

## 教训

1. **TS 类型 ≠ schema 元信息** — TS 知道"是 number", 但不知道"该 max"
2. **smart 模块需要 schema 元信息** — 不只是显式传参数
3. **Zod / JSON Schema 是答案** — 让 schema 自带元信息
4. **元信息缺失 = 强制用户决策** — 每个字段都要 user 写 rule
5. **schema 元信息跟 TS 类型并列存在** — 两者是不同抽象层

## 链接

- 起源: 顿悟 J (sas-graph v0.6.11 暴露)
- 上承: `explicit-dependencies.md` (v0.8.6) - 显式依赖
- 上承: 顿悟 I (隐式依赖) - v0.8.6 解决参数, J 暴露 schema
- 上承: `tri-dimensional-completeness.md` (v0.8.4)
- 实证: `wcaca/sas-graph` v0.6.11 (5 字段 5 决策)
- 改进: v0.6.12+ 加 Zod schema + defaultSmartMergeRules

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 1 个 schema 元信息升级) + 永续 (v0.6.12+ 加 Zod) + 单核心 (smart 需要 schema 元信息, 不只是 TS 类型)