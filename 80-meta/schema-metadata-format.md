# Schema 元信息格式 · 顿悟 K 的升级

> 2026-07-01 · v0.8.8 框架升级
> 起源: 顿悟 K (sas-graph v0.6.12 暴露)
> 关联: `schema-metadata-framework.md` (v0.8.7)
> 核心命题: **schema 元信息格式 ≠ 元信息内容, 同样重要; 字符串 + regex 解析 = 反模式**

## 顿悟 K 现象

v0.6.12 用 zod `.describe('merge=max; rationale=...')` + regex 解析:

```typescript
weight: z.number().describe('merge=max; weight 大 = 更重要')

// 解析
const match = desc.match(/merge=(\w+)/);
```

**问题**:
- 字符串 + regex 解析易错
- rationale 字段不能被代码访问
- 跟 TS 类型推导脱节

## 升级: 元信息的 4 种格式 + 推荐路径

### 格式 1: 字符串描述 (当前 v0.6.12)
```typescript
z.number().describe('merge=max; weight 大 = 更重要')
```
**优点**: 简单, 任何 schema 库都能用
**缺点**: regex 解析, 易错, 不可类型化

### 格式 2: 独立元信息对象
```typescript
export const DecisionEntityMeta = {
  weight: { merge: 'max', rationale: 'weight 大 = 更重要' },
  createdAt: { merge: 'min', rationale: 'event-time 保留最早' },
};

function defaultRules(entityType: string): FieldRule[] {
  const meta = DecisionEntityMeta;  // 显式传
  return Object.entries(meta).map(([field, { merge }]) => ({
    field,
    resolution: merge,
  }));
}
```
**优点**: 完全可控, 类型化
**缺点**: 跟 schema 脱节 (两份真相)

### 格式 3: zod 4.x metadata API
```typescript
z.number().register(z.globalRegistry, {
  merge: 'max',
  rationale: 'weight 大 = 更重要',
});
```
**优点**: 跟 schema 集成, 类型化
**缺点**: zod 4.x API 文档不全

### 格式 4: OpenAPI / JSON Schema 标准
```typescript
const DecisionEntitySchema = {
  type: 'object',
  properties: {
    weight: { type: 'number', 'x-merge': 'max', 'x-rationale': '...' },
  },
};
```
**优点**: 标准, 跨语言
**缺点**: 复杂, mini-app overkill

## 推荐路径

### 短期 (v0.6.13)
- **用格式 2 (独立元信息对象)** — 完全可控, 不依赖 zod API 不全
- 元信息跟 schema 并列存在 (v0.8.7 升级补充)

### 中期 (v0.7)
- 写 `mergeMeta` 类型 + `FieldRule` 自动推导
- TS 推导: `type FieldRule<T> = ... <T 字段, 推 resolution>`

### 长期 (v0.8+)
- 跨仓同步 schema + meta (sas-graph ↔ semantic-action-studio)
- OpenAPI / JSON Schema 标准化

## 4 个升级

### 升级 1: schema 元信息跟 TS 类型并列

```typescript
// TS 类型
export interface DecisionEntity {
  weight: number;
  // ...
}

// TS 类型 + 元信息 (并列)
export interface DecisionEntityMeta {
  weight: { merge: 'max'; rationale: string };
  // ...
}
```

### 升级 2: 元信息可被代码访问
```typescript
function defaultRules(meta: DecisionEntityMeta): FieldRule[] {
  // 直接访问 meta.weight.merge (不是 regex 解析)
}
```

### 升级 3: TS 类型推导 defaultRule
```typescript
type DefaultRule<T> = T extends 'number' ? 'min' | 'max' | 'average' : 'override' | 'keep';

type FieldRule<T> = {
  field: keyof T;
  resolution: DefaultRule<T[keyof T]>;
};
```

### 升级 4: schema 元信息自描述
```typescript
// 元信息可以导出, 跟 schema 一起
export const DecisionEntityPackage = {
  schema: DecisionEntitySchema,
  meta: DecisionEntityMeta,
};
```

## 反哺 v0.8 框架

### v0.8.7 schema-metadata-framework 加 "**格式选择**" 段

之前 v0.8.7 只说"用 Zod schema", 没说什么格式.
加 4 种格式对比 + 推荐路径.

### 35→38→41 点 rubric 加 "**元信息格式**" 子分 (3 点)

之前 38 点 (含元信息度 3 点).
加 "**元信息格式**" 子分 (3 点):
- 元信息结构化 (不是字符串) (1 点)
- TS 类型推导 defaultRule (1 点)
- 元信息可被代码访问 (1 点)

### v0.8.x 爬升链更新 (8 层)

```
v0.8.1 层间
v0.8.2 层内维度
v0.8.3 协同
v0.8.4 深度
v0.8.5 广度
v0.8.6 集成
v0.8.7 元信息 (Zod)
v0.8.8 元信息格式 (字符串 vs 结构化) ← 本文
```

**8 个 v0.8.x 互补**:
- v0.8.7 看 **schema 有没有元信息**
- **v0.8.8 看 **元信息格式对不对** ← 本文**

## 教训

1. **元信息格式 ≠ 元信息内容** — 同样重要
2. **字符串 + regex = 反模式** — 易错, 不可类型化
3. **schema 跟元信息应该并列** — 两份真相总比一份 + 字符串好
4. **TS 类型推导可延伸到元信息** — `DefaultRule<T>` 类型
5. **mini-app 不需要 OpenAPI** — 但格式选择要清楚

## 链接

- 起源: 顿悟 K (sas-graph v0.6.12)
- 上承: `schema-metadata-framework.md` (v0.8.7) - schema 元信息存在性
- 上承: 顿悟 J (smart merge 需要 schema 元信息)
- 改进: v0.6.13+ 用独立元信息对象, 不靠 zod describe
- 实证: `wcaca/sas-graph` v0.6.12 (zod .describe() + regex)

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 1 个元信息格式升级) + 永续 (v0.6.13+ 结构化元信息) + 单核心 (格式选择 = 元信息质量的另一半)