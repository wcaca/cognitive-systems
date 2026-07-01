# Insight 4 Persistence Mechanisms · 四个持续机制具体实现

> [draft] 2026-07-01 v0.6.3
>
> 配套 [`80-meta/insight-to-work.md`](./insight-to-work.md) 使用。
>
> **核心目的**：把 v0.6 提及的"4 个持续机制"从口号变成**具体可执行**的实现——每条都有文件名、格式、触发条件、自动检查点。

---

## 一、4 个机制 × 4 个难题 对照表

| 机制 | 解决的 LLM 难题 | 实现位置 |
|---|---|---|
| **Checkpoint** | context window 限制 | `state/checkpoint-N.md` |
| **PIVOT echo** | 丢失焦点 | 每步开头强制 echo |
| **4 面 checklist** | 细节迷失 | 每次 checkpoint 时检查 |
| **多维评分** | 不知道什么时候停 | Step 4 结尾时评分 |

**4 个机制不是孤立的**，它们组成一个**节奏闭环**：

```
Step → [PIVOT echo] → 工作 → [checkpoint + 4面检查] → 下一步
                  ↑                                    ↓
                  └──────[多维评分在最后]←─────────────────┘
```

## 二、机制 1：Checkpoint（解决 context window 限制）

### 问题

长任务中 LLM 会"忘了前面"。context window 不是无限的。

### 解法

**每 N 步做一次状态保存**，写到 checkpoint 文件：

```
state/
├── checkpoint-1.md   ← 第 N 步状态
├── checkpoint-2.md
├── ...
└── checkpoint-N.md
```

### Checkpoint 文件格式

```markdown
# Checkpoint N · YYYY-MM-DD HH:MM

## 当前 Layer 1（顿悟核心）
- 一句话：[原句]

## 当前 Layer 2（4 面状态）
- 历史面：✓ / ⚠ / ✗
- 结构面：✓ / ⚠ / ✗
- 应用面：✓ / ⚠ / ✗
- 限制面：✓ / ⚠ / ✗

## 当前 Layer 3（制品状态）
- 已生成：[列出]
- 进行中：[列出]
- 待办：[列出]

## 当前进度
- 完成度评分：[N 维分数]
- 距离完成：[N 个面 × 剩余]

## 下一步
- [具体下一步动作]
```

### 触发条件

| 触发器 | 频率 |
|---|---|
| 时间触发 | 每 30 分钟 |
| 步数触发 | 每 10 步 |
| 状态触发 | 完成 1 面 / 完成 1 个制品 / 切换主题 |
| 主动触发 | LLM 主动判断"我可能迷失了" |

### 加载时机

**每轮 LLM 启动时**先加载最新 checkpoint，理解当前状态。

## 三、机制 2：PIVOT echo（解决丢失焦点）

### 问题

LLM 做着做着跑去不相干的方向，原来的 connection 被遗忘。

### 解法

**每步工作前 / 后**，强制 echo 一次 PIVOT（枢轴句子）：

```
[工作前 echo]
我的核心 connection：[一句话]

[工作后 echo]
这一步跟 connection 的关系：[1 句话说明]
```

### 触发时机

| 时机 | 做什么 |
|---|---|
| 新一步开始 | echo PIVOT |
| 切换主题 | echo PIVOT + 解释为何切换 |
| LLM 觉得"迷路了" | echo PIVOT |
| checkpoint 时 | echo PIVOT |

### 跟 3 层协议的关系

PIVOT echo = Layer 1（顿悟核心）的**反复强化**。

每次 echo = 重新对齐 Layer 1。
如果发现 echo 跟当前动作**对不上** → 立即报警。

### 实现细节

**主动 PIVOT echo**（推荐）：
- 提示词中加 "在每次回复开头先 echo 你的 connection 核心"
- 让 LLM 自我对齐

**被动 PIVOT echo**（强制）：
- 工具/wrapper 在 LLM 输出前自动追加 PIVOT 句子
- 防止 LLM 跳过

## 四、机制 3：4 面 checklist（解决细节迷失）

### 问题

LLM 优化某个细节忘了大局——4 面失衡。

### 解法

**每次 checkpoint 时强制检查 4 面 checklist**（直接复用 v0.6.1）。

### 检查流程

```
进入 checkpoint：
  1. 加载 4 面 checklist
  2. 检查每面的最低门槛
     ✓ → 该面已达标
     ⚠ → 该面 partial（部分达标）
     ✗ → 该面缺失（未达标）
  3. 失衡检测：
     - 是否有 2+ 面 ⚠ 或 ✗
     - 是否某一面完全 ✗
  4. 失衡 → 暂停新工作，补短板
```

### 失衡处理

发现失衡时：
- **不继续 Step 4 推进**
- **回到 Step 3 补缺失的面**
- **这是硬约束**（参考 v0.6.1）

### 跟 checkpoint 的关系

**checkpoint 文件**自带 4 面状态，所以 checkpoint 机制 ≈ 4 面 checklist 的"周期执行"。

## 五、机制 4：多维评分（解决不知道什么时候停）

### 问题

LLM 不知道什么时候算"做完了"——可能过早停 / 过晚停。

### 解法

按 v0.6 insight-to-work 的"完成度多维评分"，在每个 checkpoint 时计算分数：

```yaml
multi_dim_score:
  layer_1: 9/10  # 顿悟核心清晰度
  layer_2:
    历史面: 8/10
    结构面: 7/10
    应用面: 9/10
    限制面: 6/10
  layer_3:
    制品_1: 9/10
    制品_2: 5/10
  overall: 7.0/10
```

### 完成标准（可调）

按应用场景：
- **科研 / 工程**：overall ≥ 8.0，且每面 ≥ 7.0
- **快速 prototype**：overall ≥ 6.0 即可
- **公开发布**：overall ≥ 9.0 且每面 ≥ 8.0

### 评分时机

每次 checkpoint 后重新评分，分数变化是"是否在做对方向"的指标。

### 评分方法（具体）

每个分数 = 三个子分数的平均：
1. **完整性** (33%)：所有最低门槛都达到？
2. **准确性** (33%)：内容真实 / 正确？
3. **可应用性** (33%)：换场景能用吗？

## 六、4 机制的节奏闭环

```
[Step 开始]
    ↓
[PIVOT echo]  ← 机制 2：避免丢失焦点
    ↓
[执行 1 步]   ← 工作本身
    ↓
[回到 PIVOT echo] 检查是否对齐
    ↓
[积累 N 步]
    ↓
[checkpoint]   ← 机制 1：保存状态
    ↓
[4 面 checklist 检查] ← 机制 3：避免失衡
    ↓
[多维评分]     ← 机制 4：判定完成度
    ↓
[下一步判定]
  - 全部 ✓ 且 overall ≥ 阈值 → 完成
  - 部分 ⚠ → 补短板
  - 整体失衡 → 重置
```

## 七、4 机制的失败模式

### 机制 1：Checkpoint 失败

| 失败 | 修正 |
|---|---|
| LLM 跳过 checkpoint | 强制 wrapper 检查 |
| checkpoint 太频繁 | 调整 N（太多 = 噪音） |
| checkpoint 太稀疏 | 调整 N（太少 = 失效） |

### 机制 2：PIVOT echo 失败

| 失败 | 修正 |
|---|---|
| LLM 不真"echo"，只走流程 | 把 echo 跟动作绑定（先 echo 才动手） |
| echo 后 LLM 仍走偏 | 加大"对齐检测"力度 |
| echo 本身变成噪音 | 改成"必要时"echo，不是每次 |

### 机制 3：4 面 checklist 失败

| 失败 | 修正 |
|---|---|
| checklist 形式化走过场 | 把"自检"留为制品的一部分 |
| 4 面无法平衡 | 允许"某一面 6/10 而另一面 9/10"（不要求平均）|

### 机制 4：多维评分失败

| 失败 | 修正 |
|---|---|
| 评分变成"打分游戏" | 评分+ 1 段解释为什么 |
| 完成标准僵化 | 按场景调整阈值 |

## 八、4 机制的具体实现代码位置

如果用 mavis harness 跑这套：

```
仓结构：
  insights/
    ├── INSIGHT-NAME-core.md           # Layer 1
    ├── INSIGHT-NAME-faces.md          # Layer 2
    ├── INSIGHT-NAME-artifacts/        # Layer 3
    │   └── ...
    └── INDEX.yaml
  state/
    └── checkpoint-N.md
scripts/
  ├── save-checkpoint.sh              # 机制 1
  ├── pivot-echo.sh                   # 机制 2
  ├── check-faces.sh                  # 机制 3
  └── compute-score.sh                # 机制 4
```

**每个机制可以独立用脚本实现**，避免 LLM 自己监督自己。

## 九、案例：用案例 2 的执行追踪

```yaml
checkpoint_1 (Step 3 开始):
  layer_1: ✓ "生态系统和软件系统都依靠自我修复..."
  layer_2:
    历史面: ✗ (待补)
    结构面: ✗
    应用面: ✗
    限制面: ✗

checkpoint_2 (历史面完成):
  layer_1: ✓
  layer_2:
    历史面: ✓ "Lovelock 1972, autonomic 2001, 中医调和"
    结构面: ⚠ (缺平行)
    应用面: ✗
    限制面: ✗

checkpoint_3 (4 面都 ✓):
  layer_1: ✓
  layer_2:
    历史面: ✓
    结构面: ✓ "CAS / watchdog / 免疫系统"
    应用面: ✓ "微服务 + chaos / DB 自适应 / CDN"
    限制面: ✓ "扰动范围 + 反馈信号 + 恢复时间"
  layer_3:
    制品_1: ⚠ (doc 在写)

checkpoint_4 (制品完成):
  overall: 8.5/10
  → 完成！
```

## 十、一句话总结

> **4 个持续机制组成一个节奏闭环：echo（对齐）→ 工作 → checkpoint（保存）→ 4 面检查（平衡）→ 多维评分（完成度）**。
> 
> **每条机制的具体实现都不靠 LLM 自觉，而是靠脚本/工具强制**——避免自我监督的偏差。
> 
> **完成 = 4 面 ✓ + 所有制品产出 + overall ≥ 场景阈值**。

---

## 演进记录

- v0.6.3 (2026-07-01)：4 个持续机制从口号到具体实现
- 待 v0.6.4：完成度多维评分 rubric 细化
- 待 v0.6.5：端到端 prototype 实测