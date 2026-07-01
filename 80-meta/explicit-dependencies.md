# 模块间显式依赖 · 顿悟 I 的框架升级

> 2026-07-01 · v0.8.6 框架升级
> 起源: 顿悟 I (sas-graph v0.6.10 暴露)
> 关联: `tri-dimensional-completeness.md` + `possibility-domain-awareness.md`
> 核心命题: **模块间默认行为改动 = 隐式依赖 = 高风险, 必须显式测试 + 显式传递**

## 顿悟 I 现象

`diffGraphs` 加 `ignoreFields` 默认值 `['createdAt']` (v0.6.10).
**隐式影响**:
- `mergeGraphsAudited` 调 `diffGraphs` 检测冲突
- `mergeGraphsAudited` 默认行为也跟着变
- **没显式测集成路径**

后果: 改了 A 模块默认 = B 模块默默变, 没人发现.

## 升级 1: 显式依赖清单

每个模块**自描述依赖**:

```typescript
// diffGraphs.ts 头部注释
/**
 * 依赖:
 * - mergeGraphsAudited 依赖本模块检测冲突
 * - 默认行为变更需通知 mergeGraphsAudited 维护者
 *
 * 默认值:
 * - ignoreFields: ['createdAt'] (v0.6.10 起)
 *
 * 下游影响:
 * - mergeGraphsAudited 默认不报 createdAt 冲突
 */
```

**vs 当前**: 模块头注释只说"做什么", 不说"被谁用 / 默认值 / 改默认影响谁".

## 升级 2: 显式依赖传递

**vs 隐式依赖**:
```typescript
// 隐式
function mergeGraphsAudited(g1, g2, opts) {
  const d = diffGraphs(g1, g2);  // 用 diffGraphs 默认行为
  // ...
}

// 显式
function mergeGraphsAudited(g1, g2, opts) {
  const d = diffGraphs(g1, g2, { ignoreFields: opts.ignoreFields ?? ['createdAt'] });
  // 显式传依赖, 不让默认行为隐式影响
  // ...
}
```

**好处**:
- 改 diffGraphs 默认 = mergeGraphsAudited 行为不变 (因为显式传)
- 集成测试显式覆盖
- 默认行为改动 = 显式列下游

## 升级 3: 集成测试段

`audit.test.ts` 加 "集成测试" 段:
```typescript
describe('sas-graph · 集成测试 (cross-module)', () => {
  it('mergeGraphsAudited 默认 ignore createdAt (跟 diffGraphs 对齐)', () => {
    // ...
  });
  it('diffGraphs 显式 ignoreFields = [] → mergeGraphsAudited 也按 []]', () => {
    // ...
  });
});
```

**vs 当前**: 集成测试散落各文件, 没显式段.

## 升级 4: 默认行为改动 commit msg 模板

```bash
feat: v0.6.10 diffGraphs 加 ignoreFields 默认 ['createdAt']

⚠️ 默认行为改动 (BREAKING for downstream):
- mergeGraphsAudited 默认不报 createdAt 冲突
- 其他依赖 diffGraphs 的模块跟着变

下游模块:
- mergeGraphsAudited (src/audit.ts)
- 任何未来用 diffGraphs 的代码

集成测试:
- src/audit.test.ts 'mergeGraphsAudited 默认 ignore createdAt'
- src/diff.test.ts '默认 ignore createdAt'
```

**vs 当前**: commit msg 只说"做了什么", 不说"影响谁".

## 反哺 v0.6 / v0.8 框架

### v0.6 (insight-to-work) 加第 7 步 "**集成**"

之前 6 步 (顿悟→推断→验证→4 面→判断→制品).
加第 7 步 "**集成**":
- 单模块测完, 还要测 cross-module 行为
- 默认行为改动 = 显式列下游 + 加集成测试

### v0.8 IPL 加阶段 6.5 "**集成自检**"

之前 9 阶段, 阶段 6 验证 + 阶段 6.5 自检 (v0.8.2).
加 "集成自检" — 跟单模块自检区分:
- 阶段 6 单模块自检: 6 维 + type-checked
- 阶段 6.5 跨模块自检: 默认行为依赖 + 集成路径

### 32 点 rubric 加 "**集成度**" 子分

之前 32 点 = L1 (9) + L2 (9) + L3 (12) + type-checked (2) (v0.8.4 加 type-checked).
加 "**集成度**" 子分 (3 点):
- 默认行为改动 = 显式列下游 (1 点)
- 跨模块集成测试覆盖 (1 点)
- 显式依赖传递 (不靠默认) (1 点)

### v0.8.5 可能性域扫描加 "**集成维度**" 子项

之前 4 维度 (Schema/算法/API/性能).
加第 5 维度 "**集成**":
- 默认行为改动影响哪些下游?
- 隐式依赖路径有哪些?
- 集成测试覆盖哪些 cross-module 行为?

## v0.8.x 爬升链更新

```
v0.8.1 层间 (6 抽象层)
v0.8.2 层内 (6 维)
v0.8.3 协同 (LLM + user)
v0.8.4 深度 (推断 + 判断 + 验证)
v0.8.5 广度 (可能性域扫描)
v0.8.6 集成 (显式依赖) ← 本文
v0.8.7 自动化 (?)
```

**5 个 v0.8.x 互补**:
- v0.8.1 看 **步骤间**
- v0.8.2 看 **步骤内 维度**
- v0.8.3 看 **谁触发**
- v0.8.4 看 **步骤内 深度**
- v0.8.5 看 **步骤内 广度**
- **v0.8.6 看 **模块间依赖** ← 本文**

## 教训

1. **默认行为改动 = 高风险** — 应该显式列下游影响
2. **隐式依赖是技术债的源头** — 改 A 默认 = B 跟着变, 没人测
3. **集成测试 ≠ 单元测试** — 单模块 OK ≠ cross-module OK
4. **"加测试 ≠ 加覆盖"** — 加"易错路径"的测试, 不是加"已知通过"
5. **commit msg 应列下游影响** — 不是只说"做了什么"

## 链接

- 起源: 顿悟 I (sas-graph v0.6.10 暴露)
- 上承: `tri-dimensional-completeness.md` (单步 3 层)
- 上承: `possibility-domain-awareness.md` (可能性域扫描)
- 实证: `wcaca/sas-graph` v0.6.10 (diffGraphs 默认改 + mergeGraphsAudited 隐式跟)
- 改进: v0.8.x 6 个子版本互补 (v0.8.6 = 模块间)

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 1 个跨模块升级) + 永续 (v0.6.11+ 显式依赖) + 单核心 (改默认 = 显式列下游 + 集成测试)