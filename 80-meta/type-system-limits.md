# 类型系统本身的局限 · 顿悟 M 的升级

> 2026-07-01 · v0.8.10 框架升级
> 起源: 顿悟 M (sas-graph v0.6.14 暴露)
> 关联: `types-as-metadata.md` (v0.8.9)
> 核心命题: **任何严格类型系统都需要 escape hatch, 不然会阻挡正确语义**

## 顿悟 M 现象

`DefaultRule<T>` 模板字面量类型, TS 限制:
- string literal union (VerbType) 跟 regular string (label) 都 `extends string`
- 走同一分支, 限制 'override' | 'keep'
- 但 verb 该 'error', 走不通

修复: 加 `StrictRule<T> = DefaultRule<T> | 'error'` 作为 escape hatch.

## 升级: 类型系统 + escape hatch 设计模式

### 模式 1: 类型推导 + escape hatch

```typescript
// 严格类型 (默认)
type Strict<T> = T extends number ? ... : ...;

// escape hatch
type WithEscape<T> = Strict<T> | 'custom';
```

### 模式 2: 类型 + 默认值 + 显式覆盖

```typescript
type SmartMeta<T> = {
  field: keyof T;
  defaultRule: DefaultRule<T[field]>;  // 自动推导
  userOverride?: 'custom-rule';  // escape
};
```

### 模式 3: 类型 + 文档化 escape 条件

```typescript
// 文档化: 什么时候该 escape
/**
 * escape 'error' 当:
 * - 字段是 enum / string literal union
 * - 字段语义是"决策类型不能改" (verb, type, refType)
 * - 字段是用户身份标识 (id, userId)
 */
```

### 模式 4: 类型 + 运行时检查 (兜底)

```typescript
// 编译时类型 + 运行时验证
const meta = StrictMeta.parse(userInput);  // zod 兜底
// 编译时严格 + 运行时安全
```

## 4 个升级

### 升级 1: 类型系统的 5 个根本限制

| 限制 | TS 例子 | workaround |
|---|---|---|
| **区分 string vs union** | VerbType 跟 string 都 `extends string` | escape hatch |
| **跨类型参数推导** | `T[K]` 在 union 时变 never | 显式 overload |
| **依赖运行时信息** | JSON.parse 返回 any | zod parse |
| **循环依赖** | A extends B, B extends A | 重构成单向 |
| **模板字面量类型推导有限** | `\`${T}\`` 不能拼 union | 显式 union |

### 升级 2: escape hatch 设计原则

- **每个严格类型都要有 escape hatch**
- **escape hatch 必须文档化**
- **escape 不能改变类型系统的语义**
- **escape 不能绕过核心安全检查**

### 升级 3: 元信息层加 escape 文档

```typescript
export const StrictDecisionEntityMeta: StrictFieldMeta<DecisionEntity> = {
  // escape 'error': verb 是 string literal union, TS 不能区分, 必须 escape
  verb: { resolution: 'error', rationale: '决策 verb 冲突需人处理 (escape hatch)' },
  // ...
};
```

### 升级 4: 类型系统扩展 = 2 步

1. **推导**: TS 模板字面量类型推默认
2. **escape**: 用户显式覆盖

```typescript
type MetaInference<T> = {
  inferred: DefaultRule<T>;  // 推导
  final: StrictRule<T>;  // 推导 + escape
};
```

## 反哺 v0.8 框架

### v0.8.9 types-as-metadata 加 "**escape hatch**" 段

之前 v0.8.9 推荐 TS 推导, 没提限制.
加 4 个 escape 设计模式 + 5 个根本限制.

### 44→47 点 rubric 加 "**escape hatch 度**" 子分 (3 点)

之前 44 点 (含元信息度 + 元信息格式 + 类型推导度).
加 "**escape hatch 度**" 子分 (3 点):
- 每个严格类型都有 escape hatch (1 点)
- escape hatch 文档化 (1 点)
- 类型 + 运行时检查双保险 (1 点)

### v0.8.x 爬升链更新 (10 层)

```
v0.8.1 层间 / v0.8.2 层内 / v0.8.3 协同 / v0.8.4 深度 /
v0.8.5 广度 / v0.8.6 集成 / v0.8.7 元信息存在性 /
v0.8.8 元信息格式 / v0.8.9 类型即元信息 /
v0.8.10 类型系统局限 + escape hatch ← 本文
```

**10 个 v0.8.x 互补**:
- v0.8.9 看 **类型推导能力**
- **v0.8.10 看 **类型推导限制 + escape** ← 本文**

## 教训

1. **任何严格类型系统都需要 escape hatch** — 不然会阻挡正确语义
2. **TS 模板字面量类型有根本限制** — 不能区分 regular string 和 union
3. **escape hatch 必须文档化** — 用户不知道什么时候该 escape
4. **类型 + 运行时双保险** — 编译时严, 运行时也验
5. **承认限制 ≠ 放弃严谨** — 加 escape 是更严谨

## 链接

- 起源: 顿悟 M (sas-graph v0.6.14)
- 上承: `types-as-metadata.md` (v0.8.9) - 类型即元信息
- 上承: 顿悟 L (FieldMeta<T> 模式)
- 改进: v0.6.15+ escape hatch 文档化
- 实证: `wcaca/sas-graph` v0.6.14 (StrictRule<T> escape hatch)

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 1 个类型系统局限升级) + 永续 (v0.6.15+ escape 文档化) + 单核心 (严格类型 + escape hatch = 真严谨)