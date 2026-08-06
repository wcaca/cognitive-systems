#!/bin/bash
# ==============================================================================
# install-hooks.sh · cognitive-systems (v0.8.34)
# ==============================================================================
# 起源: 30-protocols/protocol-disambiguation.md §pre-commit NOTE
#
# WHY: pre-commit hook 写在 scripts/pre-commit (本仓), .git/hooks/ 是 git
#   内部目录不进版本库. 开发者安装 hook 需要手动 cp 或 ln, 易忘易错.
#   v0.8.34 加 install-hooks.sh: 软链 scripts/pre-commit → .git/hooks/pre-commit,
#   跑一次就装好. 后续改 scripts/pre-commit 自动同步.
#
# WHAT:
#   1. 检查 .git/hooks/pre-commit 是否已存在
#      - 存在且是软链到 scripts/pre-commit: 跳过 (幂等)
#      - 存在但不是软链: 备份为 .pre-commit.bak, 再软链
#      - 不存在: 直接软链
#   2. chmod +x 确保可执行
#   3. 跑一次 pre-commit test 验证链路
#   4. 输出 git config core.hooksPath 提示 (可选, 让团队统一)
#
# USAGE:
#   bash scripts/install-hooks.sh              # 装到 .git/hooks/pre-commit (默认)
#   bash scripts/install-hooks.sh --uninstall  # 卸载
#   bash scripts/install-hooks.sh --status     # 看当前 hook 状态
# ==============================================================================

set -e

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"
HOOKS_DIR="$(git rev-parse --git-dir)/hooks"
HOOK="$HOOKS_DIR/pre-commit"
SRC="../../scripts/pre-commit"  # 相对 .git/hooks/

# === 参数 ===
UNINSTALL=0
STATUS=0
for arg in "$@"; do
  case "$arg" in
    --uninstall) UNINSTALL=1 ;;
    --status) STATUS=1 ;;
  esac
done

# === 状态 ===
if [ "$STATUS" = "1" ]; then
  echo "=== pre-commit hook status ==="
  if [ -L "$HOOK" ]; then
    target=$(readlink "$HOOK")
    if [ "$target" = "$SRC" ]; then
      echo "  ✅ $HOOK → $target (linked)"
    else
      echo "  ⚠️  $HOOK → $target (NOT pointing to scripts/pre-commit)"
    fi
  elif [ -f "$HOOK" ]; then
    echo "  ⚠️  $HOOK 是普通文件 (非软链, git 自带 sample?)"
  else
    echo "  ❌  $HOOK 不存在"
  fi
  exit 0
fi

# === 卸载 ===
if [ "$UNINSTALL" = "1" ]; then
  echo "🗑️  卸载 pre-commit hook..."
  if [ -L "$HOOK" ] && [ "$(readlink "$HOOK")" = "$SRC" ]; then
    rm -f "$HOOK"
    echo "  ✅ $HOOK 已删除 (软链)"
  elif [ -f "$HOOK" ]; then
    echo "  ⚠️  $HOOK 不是软链, 跳过 (手动删)"
  else
    echo "  ⏭️  $HOOK 不存在, 跳过"
  fi
  exit 0
fi

# === 安装 ===
echo "🔗 安装 pre-commit hook (v0.8.34)..."

# 1. 已存在检查
if [ -L "$HOOK" ]; then
  target=$(readlink "$HOOK")
  if [ "$target" = "$SRC" ]; then
    echo "  ⏭️  $HOOK 已软链到 $SRC, 跳过 (幂等)"
  else
    echo "  ⚠️  $HOOK 软链到 $target, 备份为 .pre-commit.bak 重新软链"
    rm -f "$HOOK.pre-commit.bak"
    mv "$HOOK" "$HOOK.pre-commit.bak"
    ln -s "$SRC" "$HOOK"
  fi
elif [ -f "$HOOK" ]; then
  echo "  ⚠️  $HOOK 存在但不是软链, 备份为 .pre-commit.bak 重新软链"
  rm -f "$HOOK.pre-commit.bak"
  mv "$HOOK" "$HOOK.pre-commit.bak"
  ln -s "$SRC" "$HOOK"
else
  ln -s "$SRC" "$HOOK"
  echo "  ✅ $HOOK → $SRC (新建)"
fi

chmod +x "$HOOK" 2>/dev/null || true
chmod +x scripts/pre-commit

# 2. 跑一次 test 验证
echo ""
echo "🧪 验证: bash scripts/pre-commit test"
if bash scripts/pre-commit test >/dev/null 2>&1; then
  echo "  ✅ pre-commit test 通过"
else
  echo "  ❌ pre-commit test 失败, hook 装好了但跑不动 (查 scripts/pre-commit bash 错误)"
  exit 1
fi

# 3. 提示 team 统一用 core.hooksPath
echo ""
echo "💡 team 统一 (可选, 推荐):"
echo "   git config core.hooksPath .githooks    # 所有 hook 集中放 .githooks/"
echo "   ln -sf scripts/pre-commit .githooks/pre-commit"
echo ""
echo "✅ pre-commit hook 安装完成"
echo "   试一次: git commit -m 'feat(30-protocols): v0.8.34 测试' (应自动跑 hook)"
echo "   跳过:   git commit --no-verify"
