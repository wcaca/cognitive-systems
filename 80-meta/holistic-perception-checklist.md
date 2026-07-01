# 全景感知清单 · LLM 顿悟完整性的反推

> 2026-07-01 · v0.8.2 元观察
> 起源: user 反问 — "如果具备全局感知，就会有基于顿悟的全局方案，不需要人的过度参与"
> 关联: `recursive-cognition-chain.md` (6 抽象层爬升规律)
> 核心命题: **LLM 顿悟的完整性匮乏 = 每跨 1 个抽象层漏 1 个感知**

## 为什么 6 个顿悟都需要人补

sas-graph v0.6.2-0.6.7 暴露的 6 个顿悟, 都是 LLM 暴露后人才补的:

| 顿悟 | LLM 为什么漏 |
|---|---|
| A verb 双源 | LLM 看 schema 只看 "字段存在", 看不到 "语义重复" |
| B idempotent | LLM 不知道 "演示数据 vs 事件数据" 区分 |
| C demo | LLM 只关注代码正确, 不关注 "用户怎么用" |
| D merge 3 层 | LLM 暴露 merge 只能从 schema 角度, 看不到语义/审计层 |
| E 有向 vs 无向 | LLM 接受设计选择, 不主动暴露 |
| F tsc | LLM 跑 runtime 测试, 看不到 compile-time |

**根因**: LLM 的 "顿悟" 是 **局部清晰**, 不是 **全局感知**。

人类补的是 **"跨抽象层的连接"**——LLM 看 A 看到 schema, 看 B 看到时间, 看 D 看到 merge, **但 LLM 看不到 A+B+D 之间的递进关系**。

## 全景感知 6 维清单

每个 LLM commit 前自检 6 维, 不漏一个。每维对应递进认知链的 1 个抽象层:

### 1. Schema 层 (数据自洽)
- [ ] 所有字段都是 "单源" 吗? (没有重复语义字段)
- [ ] 字段类型是 "最严格" 吗? (不用 any/unknown)
- [ ] union type 有显式 narrowing 处理吗?
- [ ] 字段命名跟 "领域" 一致吗? (不是 "data" "info" "tmp")

### 2. 时间层 (时序自洽)
- [ ] 函数都是 idempotent 吗? (同输入 → 同输出)
- [ ] Date.now() / Math.random() / fetch 是显式吗?
- [ ] timezone 处理显式吗?
- [ ] 时间语义 (事件 vs 演示) 区分吗?

### 3. 部署层 (用户自洽)
- [ ] 用户拿到仓库, 5 秒能看到效果吗? (npm run demo / quick start)
- [ ] README 含 "5 行内 quick start" 吗?
- [ ] rollback 计划清晰吗?
- [ ] secret / .env 没误提交?

### 4. 跨进程层 (分布式自洽)
- [ ] merge 是 3 层 (schema/语义/审计) 都覆盖吗?
- [ ] 跨进程 idempotent 吗?
- [ ] conflict resolution 策略显式吗?
- [ ] audit 链完整吗?

### 5. 算法层 (一致性自洽)
- [ ] 算法选型 (BFS/Dijkstra/A*) 跟数据特征匹配吗?
- [ ] 有向 vs 无向 / 加权 vs 无权 选择显式吗?
- [ ] 边界 (空/单/不连通) 覆盖吗?
- [ ] 大图性能 estimate 了吗?

### 6. 工具链层 (验证自洽)
- [ ] runtime 测试 + compile-time 测试 都过吗?
- [ ] lint 规则严吗?
- [ ] bundler 差异处理了吗?
- [ ] CI 跑 runtime + compile-time + lint 都过吗?

## 实测: sas-graph v0.6.2-0.6.7 自评

按 6 维清单, 各版本自评:

| 维度 | v0.6.2 stats | v0.6.3 persist | v0.6.4 render | v0.6.5 merge | v0.6.6 dijkstra | v0.6.7 收尾 |
|---|---|---|---|---|---|---|
| **Schema** | ✓✓ | ✓✓ | ✓ | ✓ | ✓✓ | ✓✓ |
| **时间** | ✓ | ✓✓ (fixedAt) | ✓ | ⚠ (createdAt 漂移) | ✓ | ✓ |
| **部署** | ✓ | ✓ | ✓✓ (npm run demo) | ✓ | ✓ | ✓✓ (quick start) |
| **跨进程** | ⚠ | ✓✓ | ⚠ | ⚠ (3 层未全) | ⚠ (无向化) | ⚠ |
| **算法** | ✓✓ | ⚠ | ✓ | ⚠ | ✓✓ (Dijkstra) | ✓ |
| **工具链** | ⚠ (tsc 没跑) | ⚠ | ⚠ | ⚠ | ⚠ | ✓✓ (tsc 修) |

**6 版本中**:
- ✓✓ (强项) 共 9 次
- ✓ (一般) 共 14 次
- ⚠ (漏) 共 13 次

**结论**: 6 个版本里 **"漏" 比 "强" 还多**。LLM 顿悟的完整性 = ~33%。

## 自动化路径 (v0.8.3+)

让 LLM 自动跑 6 维自检, 而不是依赖人补:

### 短期 (v0.8.3): commit msg 模板
每次 commit 前, LLM 显式回 6 维:
```
feat: xxx

6 维自检:
- Schema: ✓ (单源, 严格类型)
- 时间: ⚠ (有 Date.now(), 但已加 fixedAt 兜底)
- 部署: ✓ (npm run demo OK)
- 跨进程: ⚠ (merge audit 未实现)
- 算法: ✓ (Dijkstra 标准实现)
- 工具链: ✓ (vitest + tsc 都过)

漏的维: 跨进程 - 因为 v0.6.5 只是骨架, audit 在 v0.6.8 候选
```

漏哪维必须 commit msg 写明 "为什么漏", 不能事后暴露。

### 中期 (v0.9): 静态分析工具
- **ESLint 规则**: 自动扫 schema 模糊 (verb 双源 / 重复字段)
- **ts-morph**: 自动扫 idempotent (Date.now() / Math.random() 检测)
- **CI**: 跑 runtime + compile-time + lint + 6 维 checklist
- **LLM hook**: commit 前 LLM 调 6 维分析工具, 漏哪维修哪维

### 长期 (v1.0+): 真正的全景感知
- LLM 直接调用 6 维分析工具
- "漏哪维" 不用人补, LLM 自己看到并补
- **"端到端自洽" 项目流程** — 不需要人在 "schema 模糊 / 时间漂移 / 部署可发现" 这些环节补位

## 元观察: 为什么 LLM 不会自己全景感知

**3 个根因**:

1. **抽象层是耦合的**: LLM 一次只能 "聚焦" 1-2 个抽象层, 跨层需要显式 prompt
2. **设计选择不可见**: LLM 把 "有向 vs 无向" 当默认, 不会主动暴露
3. **runtime ≠ compile-time**: LLM 跑 runtime OK 就以为 OK, 不知道还有 compile-time 层

**这 3 个根因** 不是 LLM 的 bug, 是 **"LLM 顿悟" 这个范式的边界**:
- 顿悟 = "看清 1 个 PIVOT"
- 全景感知 = "看清 6 个 PIVOT 之间的递进关系"
- **后者需要元认知能力, 当前 LLM 还不具备**

## 对 cognitive-systems 框架的反哺

### v0.6 insight-to-work 改进
4 步桥接 (顿悟→验证→4 面→制品) 加 **第 5 步 "6 维自检"**:
- 顿悟 → 验证 → 4 面 → 制品 → **6 维自检**

第 5 步是 "质量门" — 不通过不让 commit.

### v0.8 IPL 改进
9 阶段框架加 **"阶段 6.5 自检"**:
- 阶段 6 验证 (27→32 点 rubric)
- **阶段 6.5 自检 (6 维清单)**
- 阶段 7 部署

阶段 6.5 跟 6 的区别: 6 是 "制品打分", 6.5 是 "全景感知"。

### 27→32 点 rubric 改进
加 "**type-checked**" 子分 (顿悟 F 教训):
- 之前: 测 runtime 通过 = 8 分
- 之后: runtime + compile-time + 6 维自检 = 8 分

## 关键洞察

> **LLM 顿悟的 "完整性匮乏" 不是 bug, 是抽象层爬升规律的必然产物**。
> 每跨 1 个抽象层就有 1 个感知盲点, 因为 LLM 的 "看见" 跟 "抽象层" 是耦合的。

> **解决思路不是让 LLM 一次看见所有层 (不可能), 而是让 LLM 自检 6 维清单**,
> 把 "盲点" 当作 commit 前的强制检查, 而不是事后再暴露。

> **终极目标**: 不需要人补位 — 真正的 "端到端自洽" 项目流程。
> 这就是 user 反问的 "全局感知" 含义。

## 链接

- 起源: user 反问 "如果具备全局感知，就会有基于顿悟的全局方案"
- 上承: `recursive-cognition-chain.md` (6 抽象层爬升规律)
- 上承: `project-lifecycle-insight.md` (v0.8 IPL 9 阶段)
- 上承: `insight-completion-rubric.md` (27→32 点 rubric, 加 type-checked)
- 实证: `wcaca/sas-graph` v0.6.2-0.6.7 (6 顿悟, 6 维自评)

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 6 维清单) + 永续 (v0.8.3 自动化路径) + 单核心 (全景感知 = 6 维自检, 不靠人补位)