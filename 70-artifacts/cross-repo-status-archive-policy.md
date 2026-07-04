# Cross-repo Status Archive Policy · 跨仓状态快照归档策略

> [draft] 2026-07-04 · v0.8.16 · S 顿悟的实施产物
>
> 配套：[`80-meta/skeleton-as-completeness-signal.md`](../80-meta/skeleton-as-completeness-signal.md) §五
>
> **问题**：`insights/cross-repo-status.md` 每次跑都覆盖，没有历史快照。怎么归档？

---

## 1. 为什么需要归档

- **复盘**：3 个月前 Q 协议还没实施，跨仓状态什么样？现在的快照已经被覆盖。
- **审计**：v0.8.14 跑的 4 仓状态，跟 v0.8.16 跑的对比，差异在哪？
- **教育**：新读者能看"研究仓的历史快照"理解演进。

---

## 2. 归档策略

### 2.1 触发

每日 1 次（cron） + 每次 v0.X 升级（手动）

### 2.2 路径

```
70-artifacts/
├── cross-repo-status-archive/
│   ├── 2026-07-04-daily.md      # 每日快照
│   ├── 2026-07-04-v0.8.16.md    # 版本快照
│   └── ...
```

### 2.3 内容

每次归档时，存：
- 时间戳（精确到分）
- 4 仓的 latest commit / version / date
- 当日新增的 commit 数量（vs 上次快照）
- M1-M4 指标快照

### 2.4 命名

- 每日快照：`YYYY-MM-DD-daily.md`
- 版本快照：`YYYY-MM-DD-vX.Y.Z.md`

### 2.5 实现

```bash
# scripts/cross-repo-status.sh 加 --archive
if [ "$1" == "--archive" ]; then
  ARCHIVE_DIR="70-artifacts/cross-repo-status-archive"
  mkdir -p "$ARCHIVE_DIR"
  TODAY=$(date -u +"%Y-%m-%d")
  cp insights/cross-repo-status.md "$ARCHIVE_DIR/${TODAY}-daily.md"
  # 版本快照：检测 commit message 是否有 v0.X.Y
  if git log -1 --pretty=%s | grep -qE "v[0-9]+\.[0-9]+(\.[0-9]+)?"; then
    VERSION=$(git log -1 --pretty=%s | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?")
    cp insights/cross-repo-status.md "$ARCHIVE_DIR/${TODAY}-${VERSION}.md"
  fi
fi
```

---

## 3. 归档 vs 实时

| 维度 | 实时 (`insights/cross-repo-status.md`) | 归档 (`70-artifacts/cross-repo-status-archive/`) |
|---|---|---|
| 更新频率 | 每次跑 | 每日 + 版本升级 |
| 内容 | 当前状态 | 历史快照 |
| 读者 | 想看"现在什么样" | 想看"过去什么样" |
| 是否 git 跟踪 | 是 | 是 |
| 是否覆盖 | 是 | 否（追加） |

---

## 4. 实施状态

v0.8.16 暂未实施完整归档（脚本待写），本文作为 policy 文档 + 设计 + 触发计划。

**预计 v0.8.17 实施**：
1. 写 `--archive` 模式到 cross-repo-status.sh
2. cron 触发每日 1 次
3. 验证归档文件能 git 跟踪

---

## 5. 演进

- v0.8.16 (2026-07-04)：初稿。归档策略 + 触发 + 路径 + 命名 + 与实时的对比