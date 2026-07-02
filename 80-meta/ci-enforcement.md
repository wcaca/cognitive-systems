# CI Enforcement 模式 · 顿悟 P 的升级

> 2026-07-02 · v0.8.13 框架升级
> 起源: 顿悟 P (sas-graph v0.6.17 暴露)
> 关联: `auto-generated-docs.md` (v0.8.12)
> 核心命题: **Auto-generate 是能力, CI 检查是机制, 两者都要**

## 顿悟 P 现象

v0.6.16 加 auto-generate, 但 **不强制跑**:
- user commit 时不跑
- 文档 outdated 不报错
- 跟 v0.6.15 同样的 bug 会再次发生

**auto-generate ≠ auto-synced**. **auto-generate 是 tool, CI 检查是 enforcement**.

## 升级: CI Enforcement 模式

### 模式 1: CI workflow (.github/workflows/*.yml)

```yaml
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - run: npm run gen-doc
      - run: git diff --exit-code docs/
```

### 模式 2: 本地 npm script

```json
{
  "scripts": {
    "check-docs": "npm run gen-doc && git diff --exit-code docs/"
  }
}
```

**vs 当前**: 本地 + CI 各一份, 重复.

### 模式 3: pre-commit hook

```yaml
# .husky/pre-commit
npm run check-docs
```

### 模式 4: Branch protection

```
GitHub → Settings → Branch protection → main
☑ Require status checks to pass before merging
☑ Require branches to be up to date
```

## 4 个升级

### 升级 1: CI 检查 = 强制 enforcement

任何 **自动生成 + 应该同步** 的内容都加 CI 检查:
- 文档 (META_ESCAPE_DECISION_TABLE)
- API 文档
- Schema 文档
- Type 导出

### 升级 2: 本地 + CI 双保险

```json
{
  "scripts": {
    "gen-doc": "...",
    "check-docs": "npm run gen-doc && git diff --exit-code"
  }
}
```

- 本地: `npm run check-docs` (开发时用)
- CI: `npm run check-docs` (强制)

### 升级 3: 4 步 CI 流程

任何 commit 必须过:
1. `npm test` (runtime 测试)
2. `npm run build` (type-check)
3. `npm run check-docs` (文档同步)
4. `git diff --exit-code` (commit 干净)

### 升级 4: Branch protection = 终极保险

GitHub: status check 必须过 + 分支必须 up to date.
即使 CI 配错, merge 也被阻止.

## 反哺 v0.8 框架

### v0.8.12 auto-generated-docs 加 "**CI 检查**" 段

之前 v0.8.12 推荐 auto-generate, 没强制 CI.
加 4 个 CI enforcement 模式.

### 53→56 点 rubric 加 "**CI enforcement 度**" 子分 (3 点)

之前 53 点 (含 auto-generate 度).
加 "**CI enforcement 度**" 子分 (3 点):
- CI workflow 存在 (1 点)
- 本地 + CI 双保险 (1 点)
- Branch protection 启用 (1 点)

### v0.8.x 爬升链更新 (13 层)

```
v0.8.1-0.8.12 (12 层)
v0.8.13 CI enforcement ← 本文
```

**13 个 v0.8.x 互补**:
- v0.8.12 看 **auto-generate 工具**
- **v0.8.13 看 **CI enforcement 机制** ← 本文**

## 教训

1. **Auto-generate ≠ auto-synced** — 需要 CI 检查
2. **CI 检查 = 强制 enforcement** — 没它, auto-gen 是 optional
3. **本地 + CI 双保险** — npm script 给本地, workflow 给 CI
4. **Branch protection = 终极保险** — 阻止 outdated 文档 merge
5. **Tool + enforcement = 完整** — 缺一不可

## 链接

- 起源: 顿悟 P (sas-graph v0.6.17)
- 上承: `auto-generated-docs.md` (v0.8.12) - auto-generate
- 实证: `wcaca/sas-graph/.github/workflows/docs-check.yml`

---

> 沉淀人: Mavis · 2026-07-02
> 月亮引力模式: 小波 (1 文档, 1 个 CI enforcement 模式) + 永续 (v0.6.18+ branch protection) + 单核心 (tool + enforcement = 完整)