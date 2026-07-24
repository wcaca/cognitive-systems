# Protocol Disambiguation Protocol · 协议 vs 形容词去歧协议

> [active] 2026-07-24 · v0.8.26 · AA 顿悟
>
> **触发 (Why this protocol exists)**: v0.8.25 跨仓 Z 协议 (cross-repo-z-protocol.md) 用关键词 regex 检 "commit msg 引用 cognitive-systems 协议"——但关键词 (e.g. `镜子`) 既指 **协议名** (镜子原则 Step 1-4) 又指 **普通名词/形容词** ("镜子里", "跟镜子对照"). v0.8.25 evolution §已知未知 留 v0.8.26+ 加语义去歧。
>
> **实证** (7-24 跑 cross-repo-evolution.sh N=30): 7 段里 5 段只是 `镜子` 一词, 协议标记词 (协议/顿悟/原则/实做/enforcement/拓扑学/总线) 0 出现. 这些 commit **真的引用了镜子原则**, 但 v0.8.25 算法的 "触发协议" 列填 "镜子,镜子,镜子" 是误报——不是因为算法错, 是因为协议名本身是多义词。
>
> **解决 (AA 顿悟)**: 双白名单 + 距离阈值 = 协议名 vs 形容词去歧。协议名出现在协议标记词 ≤ N 字符内 = 协议引用; 否则 = 形容词用法, 不计。
>
> 配套: [`cross-repo-z-protocol.md`](./cross-repo-z-protocol.md) · [`evolution-sync-protocol.md`](./evolution-sync-protocol.md) · `scripts/cross-repo-evolution.sh` (v0.8.26 升级) · `scripts/protocol-disambiguation.sh` (v0.8.26 新增, 可独立跑)

---

## 1. 协议的核心理念

**v0.8.25 盲点**: 关键词 regex 区分不开 "协议 X" (引用) 跟 "物 X" (形容词用法). 这导致:
- 误报: commit msg 写 "镜子" 但不指协议, 仍被算作 protocol trigger
- 误判: 协议标记词不够强, 协议名跟形容词不区分
- 噪声: "触发协议" 列填一串相同词 ("镜子,镜子,镜子")

**v0.8.26 协议强制协议语义判定**:
- 协议名白名单: 12 个 cognitive-systems 核心协议 (X/Y/Z 顿悟, U 协议, 镜子原则, 拓扑学, 跨仓 Z 协议, 同认知关联, M3/M3b, evolution-sync, 跨仓 evolution, 飞轮)
- 协议标记词白名单: 16 个协议语义词 (协议 / 顿悟 / 原则 / 实做 / enforcement / 拓扑学 / evolution / 飞轮 / 沉淀 / 落地 / 闭环 / SOTA / 总线 / 加固 / 同步 / 跨仓)
- 协议名 + 协议标记词 距离 ≤ 8 字符 = 真协议引用
- 协议名 + 协议标记词 距离 > 8 字符 (或只有协议名没有协议标记词) = 形容词用法, 不计
- 强制 cross-repo-evolution.sh 用此判定, 误报下降 ≥ 50%

---

## 2. WHEN — 什么时候触发协议去歧

| 场景 | 必须触发? | 理由 |
|---|---|---|
| 跨仓 commit 检 (cross-repo-evolution.sh) | ✅ 是 | v0.8.25 已暴露误报, 必走 v0.8.26 |
| 仓内 commit 检 (z-enforce.sh) | ⚠ 视情况 | 仓内 commit 通常有完整 evolution 段, 不需去歧 |
| 手动 case-by-case 判定 | ✅ 是 | 协议创建时 + 协议升级时, 走 `protocol-disambiguation.sh classify "string"` |
| commit msg lint / pre-commit hook | 🔜 v0.8.27+ | 留 v0.8.27+ 集成到 z-enforce cron |

**默认行为**: 任何协议名出现在文本里, 立即查协议标记词距离, 距离 ≤ 8 字符才计协议引用。

---

## 3. WHO — 谁来执行协议去歧

- **执行者**:
  - `scripts/cross-repo-evolution.sh` v0.8.26 升级 (内嵌判定)
  - `scripts/protocol-disambiguation.sh` v0.8.26 新增 (可独立跑: classify / test / stats)
- **写入位置**:
  - `insights/cross-repo-evolution.md` v0.8.26 升级: "触发协议" 列只列真协议引用
  - `30-protocols/protocol-disambiguation.md` (本文件)
- **触发方式**:
  - 手动: `bash scripts/cross-repo-evolution.sh --n=30` (自动应用 v0.8.26 判定)
  - 单测: `bash scripts/protocol-disambiguation.sh test` (跑 12 case 验证)
  - 分类: `bash scripts/protocol-disambiguation.sh classify "镜子原则 Step 5"`
- **CI**: z-enforce.yml v0.8.26+ 加 protocol-disambiguation test job, 失败则阻断 push

---

## 4. HOW — 实施细节

### 4.1 协议名白名单 (12 个)

```bash
# cognitive-systems 仓核心协议 (v0.8.0+ 出现过的)
PROTOCOL_NAMES=(
  "X 顿悟"   # 测错对象修正
  "Y 顿悟"   # 指标防集中补作弊
  "Z 顿悟"   # CI enforcement
  "U 协议"   # 拓扑学 / role-dimension-matrix
  "V 协议"   # 工具契约化
  "W 协议"   # 指标可机读化
  "镜子原则" # system-self 5 仓飞轮 (Step 1-4)
  "拓扑学"   # U 协议别名
  "跨仓 Z 协议"  # v0.8.25
  "同认知关联"   # evolution 段 5 维度
  "M3b"     # 深度指标
  "飞轮"    # 跨仓元方法论
)
```

### 4.2 协议标记词白名单 (16 个)

```bash
# 协议标记词 (出现在协议名 ≤ 8 字符内 = 协议语义)
PROTOCOL_MARKERS=(
  "协议"     # 通用协议标记
  "顿悟"     # 顿悟 A-Z 系列
  "原则"     # 镜子原则 / 三原则
  "实做"     # v0.8.24+ 实施
  "enforcement"  # Z 协议 enforcement
  "拓扑学"   # U 协议别名
  "evolution"  # evolution 段
  "飞轮"    # 跨仓飞轮
  "沉淀"    # evolution 沉淀
  "落地"    # 协议落地
  "闭环"    # 协议闭环
  "SOTA"   # state of the art
  "总线"    # cognitive-systems 跨仓总线
  "加固"    # 协议加固
  "同步"    # evolution-sync
  "跨仓"    # 跨仓协议
)
```

### 4.3 距离判定算法

```bash
# classify(text) 算法 (bash 0 依赖)
#
# 1. 在 text 里找所有协议名 PROTO 的位置
# 2. 在 text 里找所有协议标记词 MARK 的位置
# 3. 对每对 (PROTO_pos, MARK_pos), 距离 = abs(PROTO_pos - MARK_pos)
# 4. 距离 ≤ 8 字符 = 真协议引用, 加入 protocol_refs 列表
# 5. 距离 > 8 字符 = 形容词用法, 不计
# 6. 协议名出现 0 次协议标记词 = 形容词用法, 不计
# 7. 返回 protocol_refs (去重)
```

### 4.4 段格式升级 (v0.8.25 → v0.8.26)

| 字段 | v0.8.25 (regex 误报) | v0.8.26 (去歧) |
|---|---|---|
| 触发协议 | 镜子,镜子,镜子 | 镜子原则 (距离 0) |
| body 关键词 | ✓ | ✓ |
| 描述 | feat(system-self): 镜子原则 Step 4 | feat(system-self): 镜子原则 Step 4 — +2 endpoint 走镜子 (C9.4) |
| 误报率 | 5/7 (71%) | 0/7 (0%, 验证后) |

### 4.5 protocol-disambiguation.sh 独立脚本

```bash
# 独立跑 (跟 cross-repo-evolution.sh 互补)
bash scripts/protocol-disambiguation.sh classify "镜子原则 Step 5 走新 endpoint"
# 输出: 镜子原则 (距离 0, 协议引用)

bash scripts/protocol-disambiguation.sh classify "镜子里能照见自己"
# 输出: (空, 形容词用法)

bash scripts/protocol-disambiguation.sh test
# 输出: 12/12 cases pass
```

---

## 5. 验证清单

- [x] `scripts/protocol-disambiguation.sh` 新增 (bash, 0 依赖, classify / test / stats 3 子命令)
- [x] `scripts/cross-repo-evolution.sh` v0.8.26 升级: 触发协议列走去歧判定
- [x] `insights/cross-repo-evolution.md` v0.8.26 升级: N=30 跑 0 误报
- [x] `30-protocols/README.md` 加 protocol-disambiguation 索引项
- [x] `20-systems/agent-harness/evolution.md` 加 v0.8.26 段 (5 维度 + 决策回顾 + 验证 + 同认知)
- [x] `scripts/z-enforce.sh` v0.8.26 扩展: 跨仓检分支走 protocol-disambiguation 判定

---

## 6. 跟既有协议关系

| 协议 | 关系 |
|---|---|
| cross-repo-z-protocol.md (Z v0.8.25) | Z 协议是 v0.8.26 的载体 (Z 协议检的 commit 走 v0.8.26 判定) |
| evolution-sync-protocol.md (X) | X 协议补仓内 evolution; v0.8.26 补跨仓 evolution 判定 |
| evolution-depth-protocol.md (Y) | Y 测深度 (字符/commit); v0.8.26 测语义 (协议名 vs 形容词) |
| z-enforce.sh (Z v0.8.24) | 仓内 enforcement; v0.8.26 帮跨仓检分支去歧 |
| cross-repo-status.sh | 元数据视图 (commit/version/date); 跟 v0.8.26 平行, 各自独立 |

---

## 7. 已知局限 (留 v0.8.27+)

- **多语言**: 当前只支持中英文, 协议标记词白名单 16 个, 协议名白名单 12 个. 留 v0.8.27+ 加日语 / 西班牙语
- **协议新增**: 新协议 (v0.8.27+) 需手动加白名单, 不自动发现. 留 v0.8.28+ 加协议名自发现 (扫 30-protocols/*.md 标题)
- **距离阈值 8 字符**: 经验值, 可能在某些 commit msg 不准. 留 v0.8.27+ 加自适应阈值 (基于 commit msg 平均长度)
- **跨语言协议名**: 协议标记词 "协议" 在英文 commit msg 不存在, 留 v0.8.27+ 加英文标记词 ("protocol" / "insight" / "principle")

---

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-07-24)
