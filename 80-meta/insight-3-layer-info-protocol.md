# Insight 3-Layer Info Protocol · 三层信息整合协议

> [draft] 2026-07-01 v0.6.2
>
> 配套 [`80-meta/insight-to-work.md`](./insight-to-work.md) 和 [`80-meta/insight-4-faces-checklist.md`](./insight-4-faces-checklist.md) 使用。
>
> **核心目的**：把 v0.6 提及的"3 层信息整合协议"具体化——从骨架变成可执行的协议。

---

## 一、为什么需要 3 层

### 没用 3 层的常见失败

LLM 从顿悟到作品时常见的失败：

1. **核心漂移**：做着做着忘了原来的顿悟核心
2. **展开失衡**：有的展开过度，有的展开不足
3. **制品游离**：做出来的制品跟顿悟核心断链

**3 层的本质 = 强制 LLM 把"顿悟核心 → 4 面展开 → 制品"三层**显式且链接**。

## 二、3 层的具体定义

```
Layer 1：顿悟核心 (Insight Core)
   ↓ 显式链接
Layer 2：4 面展开 (Faces Expansion)
   ↓ 显式链接
Layer 3：制品本身 (Artifacts)
```

### Layer 1：顿悟核心（Insight Core）

**目的**：让顿悟始终保持"一句话可述"

**载体**：**一句话 + 关键性声明**

```yaml
insight_core:
  一句话: "[这个 connection 是什么]"
  关键性: "[为什么这个 connection 是关键的]"
  form: yaml
  storage: 单独文件 insight.md
```

**约束**：
- 必须能在 30 秒内说清
- 必须能从任何制品**回溯**到这一句
- 修改顿悟核心 = 触发"决策反查"流程（参考 v0.2）

**反模式**：把核心写成 5 段（核心被稀释）

### Layer 2：4 面展开（Faces Expansion）

**目的**：把顿悟核心**展开成 4 个面**

**载体**：**结构化 checklist（直接复用 v0.6.1 模板）**

```yaml
faces_expansion:
  历史面:
    起源: "..."
    演化: "..."
    类比: "..."
  结构面:
    上位: "..."
    下位: "..."
    平行: "..."
  应用面:
    场景: ["...", "...", "..."]
    反例: "..."
    操作步骤: "..."
  限制面:
    边界条件: ["...", "...", "..."]
    失效场景: "..."
    误用风险: "..."
  form: yaml 或 markdown table
  storage: 单独文件 faces.md
```

**约束**：
- 4 面**最低门槛**全部达标（参考 v0.6.1）
- 每面都有**显式链接**到 Layer 1 的核心
- 4 面之间**彼此链接**（避免循环引用，参考 v0.6.1 反模式）

**反模式**：把 Layer 2 写成"长篇文档"——失去 checklist 的强制约束

### Layer 3：制品本身（Artifacts）

**目的**：把顿悟"做成"可交付的产物

**载体**：**制品 + 制品元数据**

```yaml
artifact:
  type: doc | code | image | model | protocol
  path: "<相对仓根的路径>"
  core_link: "<引用 Layer 1 的句子>"
  faces_link: "<引用 Layer 2 的相关面>"
  version: "vN.M"
  storage: 文件本身 + artifact-index.yaml
```

**约束**：
- 每个制品必须显式引用 Layer 1 的句子
- 每个制品必须显式链接到 Layer 2 的相关面
- 制品的修改**必须反向通知** Layer 1 和 Layer 2 同步更新

**反模式**：制品独立存在，跟顿悟核心断链

## 三、3 层的链接规则

### 链接类型

| 链接 | 方向 | 何时建立 | 失效条件 |
|---|---|---|---|
| Core → Faces | Layer 1 → Layer 2 | Step 3 开始时 | 4 面任意一面超标 |
| Faces → Artifacts | Layer 2 → Layer 3 | Step 4 开始时 | 制品引用错的面 |
| Artifacts → Core | Layer 3 → Layer 1 | 制品生成时 | 引用句改变 |
| Artifacts → Faces | Layer 3 → Layer 2 | 制品生成时 | 引用的面消失 |

### 链接更新协议

```
制品修改 →
  1. 检查是否影响引用的 Layer 1 句子
     是 → 更新 Layer 1 + 触发"决策反查"
     否 → 继续
  2. 检查是否影响引用的 Layer 2 面
     是 → 更新对应面
     否 → 继续
  3. 更新制品元数据
```

## 四、3 层在制品生命周期的应用

| 阶段 | 3 层做什么 |
|---|---|
| **Step 1（顿悟）** | 写 Layer 1（核心一句话） |
| **Step 2（验证）** | 验证 Layer 1 真对（不能盲信） |
| **Step 3（展开）** | 写 Layer 2（4 面 checklist 达标） |
| **Step 4（整合执行）** | 做 Layer 3（制品）+ 元数据 + 链接 |
| **迭代** | 每次修改，检查反向链接 |

## 五、3 层 vs 单一文档的对比

| 单一文档 | 3 层 |
|---|---|
| 顿悟和细节混在一起 | 顿悟核心被提炼在 Layer 1 |
| 改一处可能影响全文 | 改 Layer 3 不直接污染 Layer 1 |
| 想"链接"很难 | 链接是显式的、可追踪的 |
| 失败是"渐进式腐蚀" | 失败是"显式断链"（易发现） |

**3 层 = 把"顿悟 → 制品"的演化过程**显式化、可回溯、可审计**。

## 六、3 层协议的反模式

### 反模式 1：核心太宽
- Layer 1 写成 5 段而不是 1 句
- **检测**：30 秒内说清测试

### 反模式 2：展开太薄
- 4 面只填一半
- **检测**：v0.6.1 的最低门槛检查

### 反模式 3：制品断链
- 制品不引用 Layer 1 / Layer 2
- **检测**：artifact-index.yaml 强制链接

### 反模式 4：链接过期
- Layer 1 修改后，旧的制品引用还在
- **检测**：定期 audit（参考 v0.2 audit-protocols）

### 反模式 5：层数变多
- 有人加 Layer 4 / Layer 5
- **检测**：3 层是 hardcoded，扩展走"附录"或"comment"

## 七、3 层协议的具体工作流

```
输入：顿悟核心 (一句话)
  ↓
Step 2: 验证
  - 反例/退化/泛化/混淆
  - 通过 → 进入 Step 3
  - 不通过 → 修正顿悟核心，循环
  ↓
Step 3: 4 面展开
  - 历史面 → 结构面 → 应用面 → 限制面
  - 每面达标 → 下一面
  - 4 面都达标 → 进入 Step 4
  ↓
Step 4: 制品生成
  - 选定类型（doc/code/image/model/protocol）
  - 生成制品
  - 写 artifact-index.yaml
  - 链接到 Layer 1 + Layer 2
  ↓
迭代:
  - 制品修改 → 检查链接
  - Layer 1 修改 → 反查（v0.2 决策反查）
  - Layer 2 修改 → 检查制品是否失效
```

## 八、案例：用案例 2（生态系统 vs 软件系统）

### Layer 1
```yaml
insight_core:
  一句话: "生态系统和软件系统都依靠'自我修复/自稳态机制'在没有中央控制的情况下保持平衡"
  关键性: "自我修复让两个看似无关的系统共享同一类生存策略，这一发现翻转了对'自适应'的理解"
  form: yaml
  storage: insights/ecosystem-software-self-repair.md
```

### Layer 2（沿用 v0.6.1 模板）
```yaml
faces_expansion:
  历史面:
    起源: "Lovelock 1972 盖亚假说"
    演化: "autonomic computing 2001 引入 IT"
    类比: "中医'调和' vs 现代控制论 homeostasis"
  结构面:
    上位: "复杂适应系统 (CAS) 理论"
    下位: "watchdog, circuit breaker, load balancer"
    平行: "免疫系统, 蚁群算法, 区块链共识"
  应用面:
    场景: ["微服务 + chaos engineering", "DB 自适应查询", "CDN 自动故障转移"]
    反例: "金融交易系统不能完全自我修复（需审计）"
    操作: "circuit breaker → retry+backoff"
  限制面:
    边界条件: ["扰动在范围内", "有反馈信号", "恢复时间够"]
    失效场景: "雪崩式 cascading failure"
    误用风险: "把'自修复'当成'不需要运维'"
  form: yaml
  storage: insights/ecosystem-software-faces.md
```

### Layer 3（具体制品）
```yaml
artifact:
  type: doc
  path: "articles/ecosystem-software-analogy.md"
  core_link: "insights/ecosystem-software-self-repair.md#一句话"
  faces_link: "insights/ecosystem-software-faces.md#应用面"
  version: "v0.1"
  form: markdown
  storage: 制品文件 + artifact-index.yaml
```

## 九、3 层协议在 mavis harness 的应用

- Layer 1 文件路径：`/workspace/cognitive-systems/insights/<name>.md`
- Layer 2 文件路径：`/workspace/cognitive-systems/insights/<name>-faces.md`
- Layer 3 制品路径：仓内任意位置
- 索引文件：`/workspace/cognitive-systems/insights/INDEX.yaml`

## 十、一句话总结

> **3 层协议 = 强制显式化"顿悟核心 → 4 面展开 → 制品"的演化过程**。
> 
> **每层有显式约束、显式链接、显式反模式**——把"细节完美但核心漂移"风险降到最低。
> 
> **Layer 1 是灵魂，Layer 2 是骨架，Layer 3 是肉**——一个都不能少。

---

## 演进记录

- v0.6.2 (2026-07-01)：3 层信息整合协议具体化（每层定义、链接规则、工作流）
- 待 v0.6.3：4 个持续机制的具体实现
- 待 v0.6.4：完成度多维评分 rubric
- 待 v0.6.5：端到端 prototype 实测