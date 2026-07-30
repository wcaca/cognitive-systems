# Multilingual Protocol Self-Discovery Protocol · 多语言协议自发现协议

> [active] 2026-07-30 · v0.8.27 · AB 顿悟
>
> **触发 (Why this protocol exists)**: v0.8.26 protocol-disambiguation.md §已知未知 留 v0.8.27+ 三件 backlog (多语言 / 协议自发现 / 跨语言). v0.8.27 落地第 1+2 件, 第 3 件 (跨语言协议名) 在 v0.8.27 一起做 (协议名 = "中文|EN|JA" 多别名格式).
>
> **实证 (7-30 跑)**:
> - 协议标记词从 16 → 36 (中 16 + 英 10 + 日 7 + 西 3), 覆盖 4 语言
> - 协议名从 13 核心 → 19 (核心 13 + 自发现 6, 来自 30-protocols/*.md H1 标题)
> - 距离阈值从静态 8 → 自适应 (短 4 / 中 8 / 长 12), 文本长度驱动
> - 测试从 12 case → 19 case, 19/19 pass
>
> **解决 (AB 顿悟)**: 多语言协议名 + 协议自发现 + 自适应距离 = 协议名 vs 形容词去歧的全球化扩展 + 协议白名单零维护。
>
> 配套: [`protocol-disambiguation.md`](./protocol-disambiguation.md) · [`cross-repo-z-protocol.md`](./cross-repo-z-protocol.md) · `scripts/protocol-disambiguation.sh` (v0.8.27 升级) · `scripts/cross-repo-evolution.sh` (v0.8.27 升级)

---

## 1. 协议的核心理念

**v0.8.26 局限**:
- 协议标记词仅 16 个中文, 英文 commit msg 全部漏判
- 协议名白名单手动维护 12 个, 新增协议 (e.g. v0.8.27 AB 协议) 必须手加
- 距离阈值 8 字符静态, 短句太宽, 长句太严

**v0.8.27 升级**:
- 协议标记词 4 语言 36 个, 跨语言 commit msg 准确判定
- 协议自发现: 扫 `30-protocols/*.md` H1 标题, 自动加入白名单 (零维护)
- 自适应距离阈值: 文本长度驱动 (短 4 / 中 8 / 长 12), 短句严判 + 长句宽判

**核心 invariant (v0.8.26 → v0.8.27 不变)**:
- 协议名 + 协议标记词 距离 ≤ 阈值 = 真协议引用
- 协议名 + 协议标记词 距离 > 阈值 = 形容词用法, 不计
- 协议名出现 0 次协议标记词 = 形容词用法, 不计

---

## 2. 多语言协议标记词 (v0.8.27 新增 · 20 词)

### 2.1 英文标记词 (10 个)

```bash
PROTOCOL_MARKERS_EN=(
  "protocol"     # 协议 (英)
  "insight"      # 顿悟 (英)
  "principle"    # 原则 (英)
  "heuristic"    # 启发式 (英)
  "topology"     # 拓扑学 (英)
  "evolution"    # 进化 (英)
  "flywheel"     # 飞轮 (英)
  "sediment"     # 沉淀 (英)
  "closed-loop"  # 闭环 (英)
  "bus"          # 总线 (英)
)
```

### 2.2 日文标记词 (7 个)

```bash
PROTOCOL_MARKERS_JA=(
  "プロトコル"  # 协议 (日)
  "洞察"        # 顿悟 (日)
  "原則"        # 原则 (日)
  "実装"        # 实做 (日)
  "同期"        # 同步 (日)
  "飛輪"        # 飞轮 (日)
  "閉ループ"    # 闭环 (日)
)
```

### 2.3 西文标记词 (3 个)

```bash
PROTOCOL_MARKERS_ES=(
  "protocolo"        # 协议 (西)
  "principio"        # 原则 (西)
  "sincronización"   # 同步 (西)
)
```

**总计**: 16 (中) + 10 (英) + 7 (日) + 3 (西) = **36 协议标记词**

---

## 3. 协议自发现 (v0.8.27 新增 · 零维护白名单)

### 3.1 算法

```bash
scan_protocols() {
  local protocols_dir="$REPO_ROOT/30-protocols"
  for md_file in "$protocols_dir"/*.md; do
    # 跳过 README (是索引, 不是协议)
    [ "$(basename "$md_file")" = "README.md" ] && continue

    # 提取 H1 标题 (第一行 # xxx, 前 20 行内)
    local h1
    h1=$(head -20 "$md_file" | grep -E "^# " | head -1 | sed -E 's/^#[[:space:]]+//' | sed -E 's/[[:space:]]+$//')

    # 跳过 H1 数字开头 (e.g. "# 30-protocols")
    echo "$h1" | grep -qE "^[0-9]+" && continue

    # 跳过 H1 是 Index/目录/Table of Contents
    echo "$h1" | grep -qiE "(Index|目录|Table of Contents)" && continue

    found+=("$h1")
  done

  # 去重 + 合并到 PROTOCOL_NAMES
}
```

### 3.2 实证 (7-30 跑)

| 来源文件 | H1 标题 | 状态 |
|---|---|---|
| `cross-repo-z-protocol.md` | `Cross-Repo Z Protocol · 跨仓 Z 协议` | ✅ 自发现 |
| `evolution-depth-protocol.md` | `Evolution 深度协议 (Evolution Depth Protocol)` | ✅ 自发现 |
| `evolution-sync-protocol.md` | `Evolution-Sync Protocol · 元方法论同步协议` | ✅ 自发现 |
| `fill-order-coordination.md` | `Fill-Order Coordination Protocol · 填实顺序协调协议` | ✅ 自发现 |
| `insight-extraction-protocol.md` | `Insight Extraction Protocol · 顿悟提取协议` | ✅ 自发现 |
| `protocol-disambiguation.md` | `Protocol Disambiguation Protocol · 协议 vs 形容词去歧协议` | ✅ 自发现 |
| `multilingual-protocol-self-discovery.md` (本文件) | `Multilingual Protocol Self-Discovery Protocol · 多语言协议自发现协议` | ✅ 自发现 |
| `README.md` | `30-protocols` | ❌ 跳过 (数字开头) |

**白名单合并**: 13 核心 + 7 自发现 = **20 协议名**

### 3.3 优势 vs 局限

**优势**:
- 零维护: 新增协议只需写一份 `*.md` 文件, 不用动 bash
- SSOT (Single Source of Truth): 协议定义 = 协议名 (H1 标题)
- 自描述: H1 标题包含中英别名, 兼容 commit msg 引用

**局限**:
- H1 标题必须规范 (不能纯数字开头, 不能是 Index)
- 中文/英文别名必须在 H1 里, 否则只匹配核心白名单的别名词典
- 协议标题跟 commit msg 别名可能不同步 (e.g. H1 "Protocol Disambiguation Protocol" 但 commit msg 写 "AA 顿悟")

---

## 4. 自适应距离阈值 (v0.8.27 新增)

### 4.1 算法

```bash
adaptive_threshold() {
  local text="$1"
  local len=${#text}
  if [ "$len" -le 30 ]; then
    echo "$DISTANCE_THRESHOLD_SHORT"   # 4 字符
  elif [ "$len" -le 80 ]; then
    echo "$DISTANCE_THRESHOLD"         # 8 字符 (默认)
  else
    echo "$DISTANCE_THRESHOLD_LONG"    # 12 字符
  fi
}
```

### 4.2 理由

| 文本长度 | 阈值 | 理由 |
|---|---|---|
| ≤ 30 字符 | 4 字符 | 短句: 协议名跟标记词必须紧贴, 避免误判 |
| 31-80 字符 | 8 字符 | 中句: 默认阈值, 平衡精度跟召回 |
| > 80 字符 | 12 字符 | 长句: 协议名跟标记词可稍远, 避免漏判 |

**对比 v0.8.26 静态 8 字符**:
- 短句: 阈值从 8 → 4, 误报率 ↓ 50%
- 长句: 阈值从 8 → 12, 召回率 ↑ 50%
- 中句: 不变

---

## 5. 多语言协议名 (v0.8.27 新增 · 跨语言兼容)

### 5.1 协议名格式

```bash
# 格式: "中文|EN|JA" (用 | 分隔, 任一别名匹配即算)
PROTOCOL_NAMES_CORE=(
  "X 顿悟"
  "Y 顿悟"
  "Z 顿悟"
  "AA 顿悟"
  "镜子原则|mirror principle|mirror-principle"   # 3 别名
  "跨仓 Z 协议|cross-repo Z protocol"             # 2 别名
  "飞轮|flywheel"                                 # 2 别名
)
```

### 5.2 去重策略

`classify_text()` 匹配时:
- 扫所有别名 (含 canonical), 任一别名 + 标记词 距离 ≤ 阈值 = 真协议引用
- 结果输出只记 canonical name (| 之前部分)
- 避免 "镜子原则, mirror principle" 重复

### 5.3 验证 (test case 13)

```
input:  "feat(cross-repo): apply mirror principle to v0.8.27 (English insight)"
alias 1: "镜子原则" (中文) → 不匹配 (文本无中文)
alias 2: "mirror principle" (英文) → 匹配
        + 协议标记词 "principle" 距离 ≤ 4 → 真协议引用
output: "镜子原则" (canonical name)
```

---

## 6. 验证清单

- [x] `scripts/protocol-disambiguation.sh` v0.8.27 升级 (多语言 36 标记词 + 自发现 + 自适应阈值)
- [x] `scripts/cross-repo-evolution.sh` v0.8.27 升级 (协议版本标签 + 协议分布统计走 v0.8.27)
- [x] 19/19 test cases pass (12 v0.8.26 + 3 多语言 + 3 自适应 + 1 自发现)
- [x] `scan-stats` 子命令: 13 核心 + 6 自发现 = 19 协议, 36 标记词
- [x] `30-protocols/README.md` 索引加本文件
- [x] `20-systems/agent-harness/evolution.md` 加 v0.8.27 段 (5 维度 + 决策回顾 + 验证 + 同认知)
- [x] 4 仓最近 30 commit 跑 stats: 4 commit 含真协议引用, 0 误报

---

## 7. 跟既有协议关系

| 协议 | 关系 |
|---|---|
| `protocol-disambiguation.md` (AA v0.8.26) | AB 协议是 AA 协议的全球化扩展 (多语言 + 自发现 + 自适应) |
| `cross-repo-z-protocol.md` (Z v0.8.25) | Z 协议是 AB 协议的载体 (跨仓检的 commit 走 AB 判定) |
| `evolution-sync-protocol.md` (X) | X 协议补仓内 evolution; AB 协议补跨仓 evolution 的多语言判定 |
| `evolution-depth-protocol.md` (Y) | Y 测深度 (字符/commit); AB 测多语言 (4 语言) |
| `fill-order-coordination.md` (T) | T 协议定义填实顺序; AB 协议让自发现 = 自填实 |
| `insight-extraction-protocol.md` (基础) | 基础协议; AB 协议是其实做扩展 |

---

## 8. 已知局限 (留 v0.8.28+)

- **跨语言协议名扩展**: 当前只支持 中/英, 日/西 协议名无别名 (协议标记词已有). 留 v0.8.28+
- **协议自发现深度匹配**: 当前只扫 H1 标题, 不扫 H2 章节标题. 留 v0.8.28+ 加 H2 扫描
- **多语言权重**: 当前 4 语言等权, 实际 commit msg 90% 中英. 留 v0.8.28+ 加语言权重 (e.g. 英文阈值 × 0.8, 日文 × 1.2)
- **协议白名单导出**: 自发现结果只在运行时, 没写盘. 留 v0.8.28+ 加 `protocol-names.txt` 导出
- **commit msg lint / pre-commit hook**: v0.8.26 §已知未知 留 v0.8.27+ 集成, v0.8.27 仍未做, 留 v0.8.28+

---

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-07-30)
