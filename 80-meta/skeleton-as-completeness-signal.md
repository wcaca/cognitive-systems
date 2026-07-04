# Skeleton-as-Completeness Signal · 空目录作为完整性信号

> [draft → active] 2026-07-04 · v0.8.16 · 顿悟 S
>
> **核心命题**：在认知系统研究仓里，**空的目录不是 bug，是诚实**——它告诉读者和作者自己"什么还没做"。但前提是这个空目录有 `.gitkeep` + 在 README 中被显式承认 + 在 evolution.md 中被记录。否则就是混乱，不是诚实。
>
> 配套文档：v0.8.14 [`cross-repo-sync.md`](./cross-repo-sync.md) + v0.8.15 [`multi-writer-coordination.md`](./multi-writer-coordination.md)

---

## 一、问题

cognitive-systems 仓在 v0.8.13 时，**6 个目录是空的**（仅 `.gitkeep`）：

| 目录 | README 中描述 | 实际状态 |
|---|---|---|
| `10-frameworks/` | 通用框架 | 0 文件 |
| `30-protocols/` | 协议 / 接口规范 | 0 文件 |
| `40-experiments/` | 实验 / 案例 | 0 文件 |
| `50-metrics/` | 指标 / 测度 | 0 文件 |
| `60-tools/` | 工具 | 0 文件 |
| `70-artifacts/` | 制品 | 0 文件 |

这是个"事实"，不是 bug。但**研究仓用 git 时，空目录不会被跟踪**——所以读者看不到"什么还没做"。

更糟的是，**README 把这些目录描述得像它们已经有内容**——读者读完不知道哪些是"已有"，哪些是"计划中"。

---

## 二、3 种"空目录"区分

不是所有空目录都是同一回事：

### 2.1 框架预留 (framework-reserved)
**典型例子**：`10-frameworks/` `30-protocols/` `40-experiments/` `50-metrics/` `60-tools/` `70-artifacts/`
- 仓结构图里有，但内容是后续填的
- 是**已知未知**的物理形态
- **应该**被 git 跟踪（通过 `.gitkeep`）+ 在 README 中显式标注 `[empty: 计划中]`

### 2.2 临时未填 (pending-content)
**典型例子**：刚决定要做的新方向，还没到填内容的时机
- 不是"骨架"，是"中转站"
- **应该**在 notes/decisions 里留下"为什么空"，否则会变成 2.3

### 2.3 遗忘 (abandoned)
**典型例子**：作者忘了这目录是干嘛的，git 也忘了它存在
- **应该**被删除，或者被填充
- 如果长期空着 = 方法论没贯彻

**核心**：git 跟踪的不是"内容"，是"承认"。承认一个目录存在 = 承认它有意义 / 承认它还没填。

---

## 三、3 条协议

为了让"空目录"成为**诚实信号**而不是**混乱信号**，3 条协议：

### 协议 1：每个空目录必须有 README 占位
```bash
mkdir 30-protocols
cat > 30-protocols/README.md <<EOF
# 30-protocols

> **[empty: 计划中]** — 协议 / 接口规范 / RFC 风格文档
>
> 预期内容：
> - insight-extraction-protocol.md
> - meta-evidence-protocol.md
> - cross-tool-protocol.md
>
> 触发填实的顿悟：当 [context-preservation.md](../80-meta/context-preservation.md) 中的"协议"维度落地具体协议时。
EOF
```

**作用**：
- 读者能看出"这是空的，但有计划"
- git 能跟踪这个目录
- CI 检查可以扫"哪些占位目录还没填"作为健康度指标

### 协议 2：每个空目录必须在 README 中标 `[empty: 原因]`
在仓根 README 的结构图中：

```markdown
10-frameworks/      通用框架 [empty: 等 30-protocols 完成后再抽]
30-protocols/       协议 [empty: v0.8.16 填]
40-experiments/     实验 [empty: v0.8.16 填]
50-metrics/         指标 [empty: 计划 v0.8.18]
60-tools/           工具 [active: scripts/cross-repo-status.sh 在用]
70-artifacts/       制品 [empty: 等 cross-repo-status 输出]
```

### 协议 3：填实后必须删 README 占位
当一个目录从空变有内容时，**README 占位要替换成 README 索引**，不是删掉 README 而是把 README 占位升级成 README 索引：

```markdown
# 30-protocols (active)

## 协议清单
- [`insight-extraction-protocol.md`](./insight-extraction-protocol.md) — v0.8.16 起
- [`meta-evidence-protocol.md`](./meta-evidence-protocol.md) — v0.8.16 起
```

---

## 四、S 顿悟：诚实比完成重要

v0.8.14 (Q 顿悟) 的核心是"跨仓同步 = 元方法论自己违反元方法论"。
v0.8.15 (R 顿悟) 的核心是"多 writer 协调 = race condition 真的会发生"。

**v0.8.16 (S 顿悟)** 的核心：

> **研究仓的诚实，比它的完成更重要。**
> 一个说"我有 7 个空目录，但这是计划"的仓，比一个说"我有 7 个目录（其实空的）"的仓更有研究价值。
> 自我承认"还没做"是研究方法论的关键环节，不是缺陷。

### 4.1 为什么这很重要

研究的可信度不来自"完成了多少"，来自"诚实地承认完成了多少 + 没完成多少 + 接下来的计划"。

- 一篇论文如果在"future work"里写"我们的方法在 X 上没验证"，比"我们声称 Y 是最优的"更可信
- 一个工程仓如果在 README 里写"我们还没做认证"，比"我们假装有认证"更可信
- 一个研究仓如果在结构图里标 `[empty: 计划中]`，比"假装这些目录有内容"更可信

### 4.2 跟其他顿悟的关系

| 顿悟 | 核心 | 跟 S 的关系 |
|---|---|---|
| P (v0.8.13) | CI enforcement 模式 | S 的实现机制（CI 检查 `[empty:]` 标注的目录健康度） |
| Q (v0.8.14) | 跨仓元数据同步 | S 的扩展（每个仓的"空目录"也是元数据，应该同步） |
| R (v0.8.15) | 多 writer 协调 | S 的应用（空目录的填实是有顺序的，多 writer 会争抢） |
| **S (v0.8.16)** | **空目录 = 诚实信号** | **本顿悟** |

---

## 五、实施：填实 4 个空目录

v0.8.16 把 4 个空目录填实，每个至少放 1 个文档：

| 目录 | 填什么 | 文档 |
|---|---|---|
| `30-protocols/` | insight-extraction-protocol | 当从 conversation / commit message 提取 insight 时的协议 |
| `40-experiments/` | 跨仓 sync 实证记录 | 实施 Q+R 协议的过程数据（涉及哪些 commit, 哪些 race, 哪些修复） |
| `50-metrics/` | 完整性指标体系 | 怎么度量"一个仓完成了多少"（不是 LOC，是"覆盖率 / 文档完整度 / 协议使用率"） |
| `70-artifacts/` | auto-generated 报告归档 | cross-repo-status 的快照（每日自动存档） |

`60-tools/` 已经有内容（scripts/ 目录本身），不需要单独填。

---

## 六、什么不是 S 顿悟

避免**过度泛化**：

- S 不是说"空目录总是好的" — S 是说"空目录要诚实地承认自己是空的"
- S 不是说"研究仓不应该填完" — S 是说"在填的过程中，诚实地标进度比假装填完了好"
- S 不是说"完成度不重要" — S 是说"完成度里包含'诚实地承认没完成'这个维度"

---

## 七、跟 v0.8.13 (CI enforcement) 的连接

v0.8.13 加了 CI 检查 commit message 规范。
v0.8.16 加 CI 检查空目录健康度：

```yaml
# .github/workflows/skeleton-check.yml
name: Skeleton-as-completeness check
on: [push, pull_request]
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Check empty directories have README 占位
        run: |
          for dir in 10-frameworks 30-protocols 40-experiments 50-metrics 70-artifacts; do
            if [ -d "$dir" ] && [ -z "$(ls -A $dir | grep -v gitkeep)" ]; then
              if [ ! -f "$dir/README.md" ]; then
                echo "ERROR: $dir is empty but has no README 占位"
                exit 1
              fi
              if ! grep -q "empty" "$dir/README.md"; then
                echo "WARN: $dir/README.md should mention 'empty'"
              fi
            fi
          done
```

---

## 八、总结

**S 顿悟 = "诚实地承认没完成" 比 "假装完成" 更有研究价值**。

3 条协议：
1. 空目录有 README 占位 + `.gitkeep`
2. README 根目录标 `[empty: 原因]`
3. 填实后 README 占位升级为 README 索引

**预测下一个顿悟 T**：当 v0.8.17 实施本顿悟时（CI 检查 + 4 个目录填实），会暴露"填实过程本身的可观测性不足"——**填实了什么 + 怎么填的 + 填得对不对**需要元层记录。这可能是 v0.8.17 的内容。

---

## 演进

- v0.8.16 (2026-07-04)：初稿。3 协议 + S 顿悟核心 + 实施计划