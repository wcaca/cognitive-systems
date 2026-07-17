#!/bin/bash
# ==============================================================================
# Z 协议 enforcement · cognitive-systems v0.8.23+ (Z 顿悟)
# ==============================================================================
# 起源: 30-protocols/evolution-sync-protocol.md (X 顿悟 v0.8.21)
#       30-protocols/evolution-depth-protocol.md (Y 顿悟 v0.8.22)
#       Z 顿悟 v0.8.23 (本脚本)
#
# WHY: X 协议 (频次) + Y 协议 (深度) 解决"作弊", 但需要 CI 强制 enforcement
#      否则元方法论被表演而非履行.
#      Z = 强制: feat: / fix(XX-systems) / fix(80-meta) commit 必须有 evolution.md
#      v0.X.Y 段, 否则阻断 push.
#
# WHAT: 本脚本被 .github/workflows/z-enforce.yml 调用
#       - 拉最近 N=10 commit
#       - 筛 feat/fix(scope) 类型
#       - 检每个 commit 是否动了 20-systems/*/evolution.md 或加 v0.X.Y 段
#       - 没动 = exit 1 (CI fail)
#
# USAGE: bash scripts/z-enforce.sh
#   返 0 = 通过, 1 = 阻断
# ==============================================================================

set -e

EVOLUTION_FILES=(
  "20-systems/agent-harness/evolution.md"
  "20-systems/research-loop/evolution.md"
  "20-systems/cobweb/evolution.md"
  "20-systems/world-model/evolution.md"
  # 80-meta 自身 = 元方法论, 也算 evolution 容器
  "80-meta/global-insight.md"
)

# Z_N_COMMITS: 检查最近 N 个 commit (默认 1 = push 时只看最新 commit)
#   - 1: push 模式 (CI push trigger), 只检最新 1 个, 避免历史 commit 拉低分数
#   - 10: cron 模式 (每 6h), 看最近 10 个, 累积性 enforcement
#   - 30: 全量审查, 每月 1 次
N_COMMITS=${Z_N_COMMITS:-1}

echo "=== Z 协议 enforcement (v0.8.23+) ==="
echo "检查最近 $N_COMMITS 个 commit 中 feat/fix(scope) 是否补 evolution"
echo ""

errors=0
warnings=0
checked=0

# 拿最近 N=10 commit (按时间倒序, 跟 cross-repo-status.sh 一致)
recent_commits=$(git log --oneline -n "$N_COMMITS" --no-merges 2>/dev/null || echo "")

if [ -z "$recent_commits" ]; then
  echo "⚠️  仓库无 commit, 跳过 (init 阶段)"
  exit 0
fi

# 遍历每个 commit
while IFS= read -r line; do
  sha=$(echo "$line" | awk '{print $1}')
  subject=$(echo "$line" | cut -d' ' -f2-)
  
  # 跳过 merge commit (--no-merges 已经过滤, 但保险)
  if echo "$subject" | grep -qE "^Merge "; then continue; fi
  
  # 跳过 chore/auto/docs 类型
  if echo "$subject" | grep -qE "^(chore|auto|docs|style|test|refactor|build|ci)\("; then
    continue
  fi
  if echo "$subject" | grep -qE "^(chore|auto|docs|style|test|refactor|build|ci):"; then
    continue
  fi
  
  # 跳过跨仓自动同步 commit (auto(cross-repo) etc)
  if echo "$subject" | grep -qE "auto\(cross-repo\)"; then
    continue
  fi
  
  # 看是否是 Z 协议要求补 evolution 的 commit 类型
  # 跟 evolution-sync-protocol.md §2 表格对齐:
  #   - feat(20-systems) / feat(80-meta) / feat(10-frameworks) / feat(30-protocols): 必须补
  #   - fix(20-systems) / fix(80-meta): 必须补
  #   - feat(cross-repo) / feat(50-metrics) / feat(40-experiments) / feat(70-artifacts): 不要求
  is_significant=0
  if echo "$subject" | grep -qE "^feat\((20-systems|80-meta|10-frameworks|30-protocols)"; then
    is_significant=1
    commit_type="feat"
  elif echo "$subject" | grep -qE "^fix\((20-systems|80-meta)"; then
    is_significant=1
    commit_type="fix"
  fi
  
  if [ "$is_significant" -eq 0 ]; then
    continue
  fi
  
  checked=$((checked + 1))
  echo "─── [$commit_type] $sha $subject"
  
  # 拿 commit 改动的 file list
  files_changed=$(git show --name-only --format="" "$sha" 2>/dev/null)
  
  # 检: 是否动了 evolution 文件 OR 加了 v0.X.Y 段
  touched_evolution=0
  for evo_file in "${EVOLUTION_FILES[@]}"; do
    if echo "$files_changed" | grep -qF "$evo_file"; then
      touched_evolution=1
      break
    fi
  done
  
  # 备选: commit 内容里有 v0.X.Y 段
  if [ "$touched_evolution" -eq 0 ]; then
    # 看 commit diff 是否有 "## v0.X.Y" 段
    if git show "$sha" 2>/dev/null | grep -qE "^## v0\.[0-9]+\.[0-9]+"; then
      touched_evolution=1
    fi
  fi
  
  if [ "$touched_evolution" -eq 0 ]; then
    echo "  ❌ FAIL: $commit_type commit 没补 evolution.md / 加 v0.X.Y 段"
    echo "     期望: 改 20-systems/agent-harness/evolution.md 或 80-meta/global-insight.md"
    echo "     或: 任何文件 diff 包含 '## v0.X.Y' 段"
    errors=$((errors + 1))
  else
    echo "  ✅ PASS: evolution 已补"
  fi
done <<< "$recent_commits"

echo ""
echo "=== Z 协议 enforcement 总结 ==="
echo "检查 commit 数: $checked"
echo "errors: $errors"
echo "warnings: $warnings"
echo ""

if [ "$errors" -gt 0 ]; then
  echo "❌ Z 协议 enforcement 失败 — 阻断 push"
  echo "   修法: 补 evolution.md 段, 或 amend commit 加 v0.X.Y 段"
  exit 1
fi

if [ "$checked" -eq 0 ]; then
  echo "⚠️  没找到 feat/fix(scope) commit, 跳过 (最近 N=$N_COMMITS 全是 chore/auto/docs)"
  exit 0
fi

echo "✅ Z 协议 enforcement 通过"
exit 0
