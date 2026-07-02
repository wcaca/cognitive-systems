# Auto-Generated 文档模式 · 顿悟 O 的升级

> 2026-07-02 · v0.8.12 框架升级
> 起源: 顿悟 O (sas-graph v0.6.16 暴露)
> 关联: `escape-decision-table.md` (v0.8.11)
> 核心命题: **文档手写 = 必然过时, 必须 auto-generate + CI 检查**

## 顿悟 O 现象

v0.6.16 写 `scripts/generate-escape-table.ts` auto-generate 决策表, 跑出来发现:
- 文档说 `DecisionEntityMeta.type: 'error'`
- 实际代码 `DecisionEntityMeta.type: 'keep'`
- **v0.6.15 改 Strict 没改原, 漏改 1 个地方**

auto-generate 帮我们抓到这个 bug.

## 升级: Auto-Generated 文档模式

### 模式 1: Auto-generate 脚本

```typescript
// scripts/generate-*.ts
import { /* meta */ } from '../src/...';
// 生成 markdown
writeFileSync('docs/...md', output);
```

**vs 当前**: 文档手写, 必然过时.

### 模式 2: 文档头标记 "auto-generated"

```markdown
# DOC TITLE (auto-generated)

> **自动生成**: 运行 `npm run gen-doc` 重新生成
> **不要手改**: 改源文件, 重跑脚本
```

**vs 当前**: 文档没说"不要手改", 用户可能手动改.

### 模式 3: 文档版本号

```typescript
// 在文档头加版本
> Generated at: 2026-07-02T14:11:00Z
> Source: src/meta.ts commit 9e25a69
```

**vs 当前**: 文档没版本, 不知道什么时候生成的.

### 模式 4: CI 检查 outdated

```yaml
# .github/workflows/docs.yml
- run: npm run gen-doc
- run: git diff --exit-code docs/
```

CI 失败 = 文档跟代码脱节.

## 4 个升级

### 升级 1: Auto-generate 优先于手写

任何**会变**的文档 (决策表, API 文档, schema 文档) 都应该 auto-generate.

**不变的**文档 (README 概述, 架构图) 可以手写.

### 升级 2: 文档头 3 段标记

每份 auto-generated 文档:
- **自动生成**: `npm run gen-X` 重新生成
- **不要手改**: 改源文件
- **生成时间/commit**: 跟源同步

### 升级 3: 跟 meta 一起的"派生文档"分类

| 文档 | 是否 auto-generate |
|---|---|
| README.md | ❌ 手写 (概述不变) |
| docs/META_ESCAPE_DECISION_TABLE.md | ✅ auto |
| docs/INSIGHTS/*.md | ❌ 手写 (顿悟文档) |
| docs/REUSE_RATE.md | ⚠️ 半自动 (数字 + 手写解读) |
| docs/V0_6_*_RETROSPECTIVE.md | ❌ 手写 |

### 升级 4: 文档版本 = 源版本

```typescript
// meta.ts 版本变化时, 文档自动 bump
export const META_VERSION = '0.6.16';
// 文档头:
// Generated from meta v0.6.16
```

## 反哺 v0.8 框架

### v0.8.11 escape-decision-table 加 "**auto-generate**" 段

之前 v0.8.11 只说"决策表", 没提 auto-generate.
加 4 个 auto-generated 文档模式.

### 50→53 点 rubric 加 "**auto-generate 度**" 子分 (3 点)

之前 50 点 (含 escape 文档度).
加 "**auto-generate 度**" 子分 (3 点):
- 派生文档 auto-generate (1 点)
- 文档头有 auto-generated 标记 (1 点)
- CI 检查 outdated (1 点)

### v0.8.x 爬升链更新 (12 层)

```
v0.8.1-0.8.11 (11 层)
v0.8.12 auto-generated 文档 ← 本文
```

**12 个 v0.8.x 互补**:
- v0.8.11 看 **escape 文档化**
- **v0.8.12 看 **文档 auto-generate** ← 本文**

## 教训

1. **文档手写 = 必然过时** — auto-generate 是唯一选择
2. **auto-generate 暴露代码 bug** — 比单元测试更有价值
3. **"不要手改" 标记不够** — 需要 CI 检查
4. **auto-generate + CI 检查 = 完整** — 两者都要
5. **文档版本 = 源版本** — 同步是核心

## 链接

- 起源: 顿悟 O (sas-graph v0.6.16)
- 上承: `escape-decision-table.md` (v0.8.11) - 决策表
- 实证: `wcaca/sas-graph/scripts/generate-escape-table.ts`

---

> 沉淀人: Mavis · 2026-07-02
> 月亮引力模式: 小波 (1 文档, 1 个 auto-generated 模式) + 永续 (v0.6.17+ CI 检查) + 单核心 (文档 auto-generate + CI = 完整)