# 类型即元信息 · 顿悟 L 的升级

> 2026-07-01 · v0.8.9 框架升级
> 起源: 顿悟 L (sas-graph v0.6.13 暴露)
> 关联: `schema-metadata-format.md` (v0.8.8)
> 核心命题: **TS 映射类型 = 元信息的天然载体, 不需要 zod 字符串**

## 顿悟 L 现象

`FieldMeta<T>` = `[K in keyof T]?` = **T 类型的扩展维度**:

```typescript
export type FieldMeta<T> = {
  [K in keyof T]?: {
    resolution: FieldLevelResolution;
    rationale?: string;
  };
};

export const NounEntityMeta: FieldMeta<NounEntity> = {
  id: { resolution: 'keep' },
  // ...
};
```

**洞察**: TS 映射类型 + keyof 让元信息自动跟随字段, 编译时保证对齐.

## 升级: 类型即元信息 (Type-as-Metadata)

### 升级 1: TS 模板字面量类型推 resolution

```typescript
type DefaultRule<T> =
  T extends number ? 'min' | 'max' | 'average' :
  T extends string ? 'override' | 'keep' :
  T extends boolean ? 'override' :
  'error';

type FieldMeta<T> = {
  [K in keyof T]?: {
    resolution: DefaultRule<T[K]>;  // 自动推导
    rationale?: string;
  };
};
```

**好处**: 
- weight (number) → resolution 只能是 'min' | 'max' | 'average'
- label (string) → resolution 只能是 'override' | 'keep'
- 写错 = TS 编译错

### 升级 2: WithMeta<T, M> helper

```typescript
type WithMeta<T, M extends FieldMeta<T>> = T & {
  __meta?: M;  // phantom field, runtime 不存在
};

// 用法
type DecisionEntityWithMeta = WithMeta<DecisionEntity, typeof DecisionEntityMeta>;
```

### 升级 3: meta 自动从 TS 类型生成

```typescript
// 不需要手写 meta 对象, 从 type 推
function generateMeta<T>(): FieldMeta<T> {
  // 自动给每个字段一个 default rule
  // number → max (默认 max)
  // string → override
  // boolean → override
}
```

### 升级 4: meta 是类型的"投影"

```typescript
// meta 是 T 在"merge 维度"的投影
type MetaProjection<T> = {
  [K in keyof T]: FieldMeta<T>[K] extends infer M
    ? M extends { resolution: infer R }
      ? R
      : never
    : never;
};
```

## 反哺 v0.8 框架

### v0.8.8 schema-metadata-format 加 "**TS 推导**" 段

之前 v0.8.8 推荐"独立元信息对象" (格式 2).
加 4 个 TS 推导升级 (模板字面量类型, WithMeta helper, 自动生成, 投影).

### 38→41→44 点 rubric 加 "**类型推导度**" 子分 (3 点)

之前 41 点 (含元信息度 + 元信息格式).
加 "**类型推导度**" 子分 (3 点):
- 模板字面量类型推 resolution (1 点)
- WithMeta<T, M> helper (1 点)
- meta 自动生成 (1 点)

### v0.8.x 爬升链更新 (9 层)

```
v0.8.1 层间
v0.8.2 层内维度
v0.8.3 协同
v0.8.4 深度
v0.8.5 广度
v0.8.6 集成
v0.8.7 元信息存在性
v0.8.8 元信息格式
v0.8.9 类型即元信息 (TS 映射类型) ← 本文
```

**9 个 v0.8.x 互补**:
- v0.8.7 看 **有没有**
- v0.8.8 看 **格式**
- **v0.8.9 看 **TS 推导** ← 本文**

## 教训

1. **TS 映射类型 = 元信息天然载体** — 不需要 zod / JSON Schema
2. **类型即元信息 = 同一抽象层** — 不是两个
3. **运行时 schema 是兜底, 不是首选** — 编译时类型应该足够
4. **模板字面量类型 = TS 最强武器** — 可推导 default rule
5. **类型 + 元信息 一起设计** — 不要先 TS 类型, 后 meta

## 链接

- 起源: 顿悟 L (sas-graph v0.6.13)
- 上承: `schema-metadata-format.md` (v0.8.8) - 格式选择
- 上承: 顿悟 K (字符串 + regex = 反模式)
- 上承: 顿悟 J (smart merge 需要 schema 元信息)
- 实证: `wcaca/sas-graph` v0.6.13 (FieldMeta<T> 模式)
- 改进: v0.6.14+ 模板字面量类型推 resolution

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 1 个类型即元信息升级) + 永续 (v0.6.14+ TS 推导) + 单核心 (TS 映射类型 = 元信息天然载体)