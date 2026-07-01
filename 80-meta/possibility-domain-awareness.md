# 可能性域感知系统 · 让 LLM 看见"所有可走的路"

> 2026-07-01 · v0.8.5 元观察 (user 元观察触发)
> 起源: user "顿悟扩散到所有部分需要对整个可能性域有感知，想想如何建立这个感知系统"
> 关联: `recursive-cognition-chain.md` (层间) + `holistic-perception-checklist.md` (层内) + `global-insight.md` (协同) + `tri-dimensional-completeness.md` (单步深)
> 核心命题: **完整度 = 单步 3 层 + 全域扫描, 缺一不可**

## User 元观察的现象

之前 4 个 v0.8.x 框架:

| 版本 | 视角 | 局限性 |
|---|---|---|
| v0.8.1 | 跨步骤爬升 (层间关系) | 6 抽象层固定, 漏了"为什么不只 6 层" |
| v0.8.2 | 单步骤维度 (6 维自检) | 6 维固定, 漏了"为什么不是 12 维" |
| v0.8.3 | 协同模式 (LLM + user) | 协同固定 90%, 漏了"怎么提升到 95%" |
| v0.8.4 | 单步骤深度 (推断+判断+验证) | 3 层固定, 漏了"为什么不是 5 层" |

**共同局限**: 都在"已知结构"上做深入, 没扫"未知可能性".

**user 观察**: **顿悟扩散到所有部分, 需要对整个可能性域有感知**——意思是:
- 不只"已知 3 层 + 6 维 + 9 层"
- 要扫"整个可能性空间" = 当前状态 × 所有可能下一步 × 所有可能改进

## 可能性域 = 4 维度笛卡尔积

```
可能性域 = 
  (当前状态) 
  × (可能的暴露) 
  × (可能的设计选择) 
  × (可能的实现路径)
```

举例 sas-graph v0.6.8 (diffGraphs):

| 维度 | 当前 v0.6.8 已做 | 完整可能性域 |
|---|---|---|
| 当前状态 | diffGraphs 已实现 | diffGraphs / diffGraphsSymmetric / diffGraphsStreaming / ... |
| 可能的暴露 | createdAt 漂移 | createdAt 漂移 / 大图性能 / 跨图类型冲突 / 自环 / 多重边 / ... |
| 可能的设计选择 | 方向性 (g1→g2) | 方向性 / 对称性 / 增量性 / 逆序性 / ... |
| 可能的实现路径 | JSON.stringify | JSON.stringify / lodash.isEqual / schema-aware / 自实现 / ... |

**当前 v0.6.8 完整度**:
- 当前状态: 选了 1/5 个可能
- 可能的暴露: 暴露了 1/6 个
- 可能的设计选择: 选了 1/4 个
- 可能的实现路径: 选了 1/4 个
- 综合: ~1/120 = ~0.8%

**这才是 user 说的"平面化"**——不是单步 3 层的问题, 是**根本没扫可能性域**.

## 感知系统的 4 个核心机制

### 机制 1: Schema 枚举 (Enumeration)

**目的**: 不漏已知可能性
**方法**: 用 schema / 类型 / API contract 显式枚举

```typescript
// 伪代码
function enumeratePossibilities(graph: Graph): Possibility[] {
  return [
    ...enumerateByType(graph, 'schema'),    // 字段模糊 / 双源 / 缺约束
    ...enumerateByAlgorithm(graph),         // BFS / Dijkstra / A* / 双向
    ...enumerateByAPIShape(graph),          // 同步 / 异步 / 流式 / 增量
    ...enumerateByPerformance(graph),       // 大图 / 增量 / 缓存 / 并行
    ...enumerateByIntegration(graph),       // merge / persistence / render 集成
  ];
}
```

**vs 当前**: LLM 凭"经验"猜可能, 漏 80%+

### 机制 2: 3 杠杆排序 (Importance Scoring)

**目的**: 知道哪个可能性最重要
**方法**: 每个可能性打 3 杠杆分 (阻塞/价值/可做)

| 杠杆 | 1 分 | 5 分 |
|---|---|---|
| **阻塞** | 不影响其他 | 5 个下游等它 |
| **价值** | 1 个场景用 | 跨仓通用 |
| **可做** | 需 1 周调研 | 现在 5 分钟可做 |

排序 = 平均分 × "长期价值"权重
→ LLM 自动聚焦 top 3, user 触发 top 1

### 机制 3: PIVOT echo 触发 (Auto Exploration)

**目的**: 自动探索高可能性, 不靠 user 提示
**方法**: 

```
top 可能性 (3 杠杆分 > 4) → LLM 自动跑 "推断" 层
                                ↓
                          暴露 → 触发 PIVOT echo
                                ↓
                          user 决定是否推进
```

**vs 当前**: user 提示一次, LLM 推一步

### 机制 4: 盲点记录 (Blind Spot Logging)

**目的**: 知道"什么没扫到"
**方法**:

```typescript
// 每次扫后, 标记"未探索"
{
  "枚举总数": 120,
  "已探索": 3,        // 当前 LLM + user 触发的
  "未探索": 117,      // 大部分是盲点
  "盲点聚类": {       // 把 117 个盲点分组, 看哪个集群最大
    "性能": 40,
    "集成": 30,
    "API 形态": 25,
    "边界": 22,
  }
}
```

**vs 当前**: LLM 不知道"自己漏了什么"

## 实现路径

### 短期 (v0.8.6) — LLM 辅助扫描
- LLM 用 prompt "列出 v0.6.8 所有可能性" → 用户挑 → 推进
- 不自动化, 但显式化

### 中期 (v0.9) — 半自动扫描
- 写一个 `enumeratePossibilities(graph)` TypeScript 函数
- 跑 → 输出 JSON → LLM 评估 → 排序 → 触发
- 盲点 = 未列出的可能性, 标注 "not enumerated"

### 长期 (v1.0+) — 全自动感知
- Schema-aware 工具 + LLM 生成式补充
- 每次 commit 后, 自动扫整个可能性域
- top 1 触发 PIVOT echo, user 只确认

## 实测: v0.6.8 完整可能性域扫描

让我对 v0.6.8 跑一次"可能性域感知" (手动, 作为示例):

### Schema 维度 (5 个)
1. diff 是否能处理 GraphNode union (noun + decision)?
2. diff 是否区分 noun 和 decision 字段差异?
3. diff 是否处理 dangling edges (from/to 不存在)?
4. diff 是否处理自环?
5. diff 是否处理多语种 label (中文 vs 英文)?

### 算法维度 (5 个)
1. deep equal 用 JSON.stringify 是否最优?
2. 是否支持 schema-aware 对比 (忽略 createdAt)?
3. 是否支持流式 diff (边读边 diff)?
4. 是否支持反向 diff (g2 → g1)?
5. 是否支持增量 diff (只 diff 变化部分)?

### API 维度 (5 个)
1. 方向性 vs 对称性?
2. 同步 vs 异步?
3. 返回 GraphDiff vs 返回 patch list?
4. 是否支持 callback?
5. 错误处理 (e.g. malformed graph)?

### 集成维度 (5 个)
1. 跟 mergeGraphs 行为对齐吗?
2. 跟 fromJSON/toJSON 集成?
3. 跟 toASCII 集成 (diff 可视化)?
4. 跟 findPath / shortestPath 集成?
5. 跨仓 (sas-graph ↔ semantic-action-studio)?

### 性能维度 (5 个)
1. 大图 (1000 节点) 下深 equal 性能?
2. 是否支持增量扫描?
3. 是否缓存中间结果?
4. 是否并行处理 node 和 edge?
5. 内存占用?

**总共 25 个可能性**. 当前 v0.6.8 触达 ~3 个 (schema 1, 算法 1, 集成 0).

**完整度 = 3/25 = 12%** —— 不是 33%, **实际是 12%**.

这就是 user 说的"平面化"的真正含义.

## 跟 v0.8.1-0.8.4 的整合

| 版本 | 视角 | 答的问题 |
|---|---|---|
| v0.8.1 | 层间 | 步骤之间怎么爬升? |
| v0.8.2 | 层内 | 单步骤覆盖哪些维度? |
| v0.8.3 | 协同 | 谁触发跨步骤? |
| v0.8.4 | 深度 | 单步骤做多深? |
| **v0.8.5** | **全域** | **单步骤覆盖多少可能性?** ← 本文 |

**5 个 v0.8.x 互补**:
- v0.8.1 看 **步骤间**
- v0.8.2 看 **步骤内 维度**
- v0.8.3 看 **谁触发**
- v0.8.4 看 **步骤内 深度**
- **v0.8.5 看 **步骤内 广度 (可能性域)**

## 元观察

**5 个 v0.8.x 本身也是 1 个爬升链**:
- v0.8.1 (抽象): 6 层
- v0.8.2 (具体): 6 维
- v0.8.3 (协同): 90%
- v0.8.4 (深): 3 层
- v0.8.5 (广): 25+ 可能性

**从抽象 → 具体 → 协同 → 深 → 广, 是个不断"具象化"的过程**.

按递进认知链规律, **v0.8.6 应该是 "自动化"** (把这些机制变成可执行代码).

## 自动化路径

```
v0.8.6 = 把 v0.8.5 的"手动扫描"变成 TypeScript 工具
v0.8.7 = 把 v0.8.6 集成到 CI (每次 commit 自动扫 + 报告)
v0.8.8 = v0.8.7 + LLM (LLM 读报告自动生成 "下一步建议")
v1.0   = 完整自动化 = LLM 扫 + 排序 + 触发 + user 确认
```

## 教训

1. **"3 层完整度" 也只是局部** — 还需要"全域扫描", 才知道"还缺什么"
2. **可能性域 = 笛卡尔积, 不是单维列表** — 4 维度 (状态/暴露/设计/实现) × N 个可能
3. **不扫可能性域 = "想到啥做啥"** — 这就是今晚 v0.6.8 的实际状态
4. **感知系统的关键是"显式枚举"** — 不靠 LLM 灵感, 靠结构化扫描
5. **盲点比已知更重要** — 已知 3 个 + 盲点 22 个, 真正信息在盲点里

## 链接

- 起源: user "顿悟扩散到所有部分需要对整个可能性域有感知"
- 上承: `tri-dimensional-completeness.md` (单步 3 层)
- 上承: `recursive-cognition-chain.md` (6 抽象层)
- 上承: `holistic-perception-checklist.md` (6 维自检)
- 上承: `global-insight.md` (LLM + user 协同)
- 实证: `wcaca/sas-graph` v0.6.8 (25+ 可能性, 当前触达 ~12%)

---

> 沉淀人: Mavis · 2026-07-01
> 月亮引力模式: 小波 (1 文档, 1 个根本性元观察) + 永续 (v0.8.6-1.0 自动化路径) + 单核心 (可能性域感知 = 枚举 + 排序 + 触发 + 盲点)