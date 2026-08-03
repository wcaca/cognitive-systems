---
protocol_names: ["Export Protocol Names Protocol","协议白名单导出协议","AC 协议"]
protocol_h2_match_distance: 30
---

# Export Protocol Names Protocol · 协议白名单导出协议

> [active] 2026-08-01 · v0.8.28 · AC 顿悟
>
> **触发 (Why this protocol exists)**: v0.8.27 协议自发现结果只在运行时 (bash 数组), 没写盘, 其他脚本 (pre-commit / CI / 跨仓) 没法引用. v0.8.28 加 `export` 子命令, 写 `30-protocols/.protocol-names.txt` (git ignored, 运行时生成).
>
> **实证 (8-1 跑)**:
> - export 子命令 1 步: `bash scripts/protocol-disambiguation.sh export`
> - 13 核心 + 13 自发现 (短名 + 完整 H1) = 26 entries
> - 输出文件格式: `# 协议名白名单 (v0.8.28 自动导出)` + 注释 + core/discovered/all 3 段
> - 跟 v0.8.27 协议自发现 (AB 顿悟) 完全兼容: scan_protocols() 调用栈不变
>
> **解决 (AC 顿悟)**: SSOT (Single Source of Truth) 离盘可读. git pre-commit hook 可以 grep `.protocol-names.txt` 判定 commit msg 是否引用协议 (留 v0.8.29+ 集成).
>
> 配套: [`multilingual-protocol-self-discovery.md`](./multilingual-protocol-self-discovery.md) · `scripts/protocol-disambiguation.sh` (v0.8.28 升级)

---

## 1. 协议的核心理念

**v0.8.27 局限**:
- 自发现协议名只在 bash 数组 `PROTOCOL_NAMES_DISCOVERED` 里, 进程结束就丢
- 跨进程引用 (pre-commit / CI / 其他脚本) 没法拿到白名单
- 没法在 commit msg lint 阶段判定"是否引用了协议" (需要白名单)

**v0.8.28 升级**:
- `export` 子命令: 跑 `scan_protocols` + 写盘 `30-protocols/.protocol-names.txt`
- 文件分 3 段: `core:` (13 手动维护) / `discovered:` (13 H1 自发现) / `all:` (26 合并)
- `.gitignore` 加 `30-protocols/.protocol-names.txt` (运行时生成, 不入库)
- 配套 v0.8.28 doc (本文件) 沉淀决策背景 + 已知未知

**核心 invariant (v0.8.27 → v0.8.28 不变)**:
- 协议自发现 source of truth 仍是 `30-protocols/*.md` H1 标题
- `export` 只是序列化, 不会修改白名单内容
- `export` 跟 `classify` / `test` / `scan` 完全兼容, 互不影响

---

## 2. 算法 (export_protocol_names)

```bash
export_protocol_names() {
  local protocols_dir="$REPO_ROOT/30-protocols"
  if [ ! -d "$protocols_dir" ]; then
    return 1
  fi
  local out_file="$protocols_dir/.protocol-names.txt"
  {
    echo "# 协议名白名单 (v0.8.28 自动导出)"
    echo "# 源: scripts/protocol-disambiguation.sh scan + export"
    echo "# 生成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "# 核心 (${#PROTOCOL_NAMES_CORE[@]} 个):"
    for p in "${PROTOCOL_NAMES_CORE[@]}"; do
      echo "core: $p"
    done
    echo "# 自发现 (${#PROTOCOL_NAMES_DISCOVERED[@]} 个):"
    for p in "${PROTOCOL_NAMES_DISCOVERED[@]}"; do
      echo "discovered: $p"
    done
    echo "# 合并 (${#PROTOCOL_NAMES[@]} 个):"
    for p in "${PROTOCOL_NAMES[@]}"; do
      echo "all: $p"
    done
  } > "$out_file"
  echo "  → wrote $out_file (${#PROTOCOL_NAMES[@]} entries)"
  return 0
}
```

---

## 3. 输出格式 (v0.8.28)

```
# 协议名白名单 (v0.8.28 自动导出)
# 源: scripts/protocol-disambiguation.sh scan + export
# 生成时间: 2026-08-01T21:23:24Z
# 核心 (13 个):
core: X 顿悟
core: Y 顿悟
... (13 行)
# 自发现 (13 个):
discovered: Cross-Repo Z Protocol
discovered: Cross-Repo Z Protocol · 跨仓 Z 协议
... (13 行, 短名 + 完整 H1 配对)
# 合并 (26 个):
all: X 顿悟
... (26 行)
```

**关键设计**:
- 短名 + 完整 H1 配对: commit msg 写短名 (e.g. "Cross-Repo Z Protocol") 也能命中
- `core:` 跟 `discovered:` 分开: 区分手动维护 vs 自动发现, 便于 audit
- `all:` 合并: 一行一协议名, 供其他脚本 grep / awk 处理
- 注释行 `#` 开头: 人类可读, 脚本可 skip

---

## 4. 跟既有协议关系

| 协议 | 关系 |
|---|---|
| `multilingual-protocol-self-discovery.md` (AB v0.8.27) | AB 协议是 AC 协议的前置 (协议自发现) |
| `protocol-disambiguation.md` (AA v0.8.26) | AA 协议核心算法 + AB 多语言 + AC 导出 = 协议白名单完整生命周期 |
| `cross-repo-z-protocol.md` (Z v0.8.25) | Z 协议是 AC 协议的潜在消费者 (跨仓 commit 引用协议时可 grep `.protocol-names.txt`) |
| `evolution-sync-protocol.md` (X) | X 协议补仓内 evolution; AC 协议让白名单 = 离盘可读 = 跨仓可同步 |

---

## 5. 已知未知 (留 v0.8.29+)

- **commit msg lint / pre-commit hook**: AC 协议让 `.protocol-names.txt` 可被 grep, 但实际 lint 还没集成. 留 v0.8.29+ 写 `scripts/commit-msg-lint.sh` (pre-commit hook 调用)
- **跨语言协议名**: H1 自发现只加短名 + 完整 H1, 跨语言别名 (中/英/日/西) 仍是手动维护 (在 `PROTOCOL_NAMES_CORE`). 留 v0.8.29+ 让 H1 短名后缀 `|lang:en|ja` 自动加入 PROTOCOL_MARKERS 查找表
- **H2 章节扫描**: v0.8.28 调研发现 H2 章节 false positive 太多 (协议元描述被误加进白名单). 留 v0.8.29+ 调研 frontmatter `protocol_h2:` 显式声明
- **协议版本号**: `.protocol-names.txt` 不含协议版本 (e.g. v0.8.26 / v0.8.27). 留 v0.8.29+ 加 `version:` 段
- **H1 多别名解析**: 当前 H1 "Cross-Repo Z Protocol · 跨仓 Z 协议" 拆成 "短名" + "完整 H1" 两条. 留 v0.8.29+ 拆成 "短名" + "完整 H1" + "中文别名" 三条, 跨语言 commit msg 命中更准

---

## 6. 验证清单

- [x] `scripts/protocol-disambiguation.sh export` 写 `.protocol-names.txt`
- [x] 13 核心 + 13 自发现 = 26 entries
- [x] `30-protocols/.gitignore` 加 `.protocol-names.txt` (不入库)
- [x] 22/22 test case pass (含 v0.8.28 新增 3 case H1 自发现回归验证)
- [x] `30-protocols/README.md` 索引加本文件
- [ ] `20-systems/agent-harness/evolution.md` 加 v0.8.28 段 (留 v0.8.29 sprint, 配套 commit msg lint)

---

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-08-01)
