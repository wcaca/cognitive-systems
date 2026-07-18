#!/bin/bash
# ==============================================================================
# cross-repo-evolution.sh · 跨仓 evolution collector (v0.8.25)
# ==============================================================================
# 起源: 30-protocols/cross-repo-z-protocol.md (Z 顿悟 v0.8.25)
#
# WHY: z-enforce.sh (v0.8.24) 只检 cognitive-systems 仓内部 commit
#      但 5 仓飞轮里, 其他 4 仓的 feat commit 同样产生元方法论信号
#      这些信号需要被汇总到 cognitive-systems, 形成"总线"
#
# WHAT: 本脚本拉 4 仓最近 N=10 commit, 抽 feat(scope) + 检 cognitive-systems
#       协议引用 (v0.8.X / 顿悟 / 协议 / 拓扑 / 镜子 / M3 等关键词)
#       生成 insights/cross-repo-evolution.md (人类可读)
#
# USAGE:
#   bash scripts/cross-repo-evolution.sh                  # 跑 4 仓视图生成
#   bash scripts/cross-repo-evolution.sh --push           # 生成后自动 commit+push
#   bash scripts/cross-repo-evolution.sh --n=30           # 看最近 30 commit
#   bash scripts/cross-repo-evolution.sh --repos=PATH...  # 指定仓路径
#   bash scripts/cross-repo-evolution.sh --no-lock        # 跳过 lock
#
# 设计原则 (跟 cross-repo-status.sh 一致):
#   - 各仓 commit msg 是 local SSOT
#   - cognitive-systems insights/cross-repo-evolution.md 是 derived
#   - 跟 cross-repo-status 平行, 但维度不同: commit (latest only) vs evolution (N=10+ history)
# ==============================================================================

set -euo pipefail

NO_LOCK=false
DO_PUSH=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_PARENT="$(cd "$REPO_ROOT/.." && pwd)"

N_COMMITS=10
REPOS=(
  "$REPO_PARENT/system-self"
  "$REPO_PARENT/thoughtspace-notes"
  "$REPO_PARENT/beauty-crm"
  "$REPO_PARENT/agent-memory"
)
# 关键词: 跟 cross-repo-z-protocol.md §2 对齐
KEYWORDS_REGEX='(v0\.8\.[0-9]+|顿悟|协议|拓扑|镜子|M[0-9]|evolution|insight)'

# 解析参数
for arg in "$@"; do
  case "$arg" in
    --no-lock) NO_LOCK=true ;;
    --push) DO_PUSH=true ;;
    --n=*) N_COMMITS="${arg#--n=}" ;;
    --repos=*)
      IFS=',' read -ra CUSTOM <<< "${arg#--repos=}"
      REPOS=()
      for r in "${CUSTOM[@]}"; do REPOS+=("$r"); done
      ;;
  esac
done

OUTPUT="$REPO_ROOT/insights/cross-repo-evolution.md"

echo "=== Cross-Repo Evolution Collector (v0.8.25) ==="
echo "源仓: ${#REPOS[@]} 仓"
echo "每个仓最近 commit 数: $N_COMMITS"
echo "输出: $OUTPUT"
echo ""

# 锁机制 (跟 cross-repo-status.sh 协议 1 对齐)
LOCK_FILE="$REPO_ROOT/.cross-repo-evolution.lock"
if [ "$NO_LOCK" = false ] && [ -f "$LOCK_FILE" ]; then
  if kill -0 "$(cat "$LOCK_FILE")" 2>/dev/null; then
    echo "⚠️  另一个 cross-repo-evolution 实例运行中 (PID $(cat "$LOCK_FILE")), 跳过"
    exit 0
  else
    echo "⚠️  残留 lock 文件, 清理"
    rm -f "$LOCK_FILE"
  fi
fi
[ "$NO_LOCK" = false ] && echo "$$" > "$LOCK_FILE"
trap '[ "$NO_LOCK" = false ] && rm -f "$LOCK_FILE"' EXIT

# 拉所有源仓的 feat commit
TMPDIR_LOCAL="$(mktemp -d)"
trap '[ "$NO_LOCK" = false ] && rm -f "$LOCK_FILE"; rm -rf "$TMPDIR_LOCAL"' EXIT

total_segments=0
all_segments_md=""

for repo_path in "${REPOS[@]}"; do
  if [ ! -d "$repo_path/.git" ]; then
    echo "⚠️  $repo_path 不是 git 仓, 跳过"
    continue
  fi
  repo_name="$(basename "$repo_path")"
  echo "─── 拉 $repo_name 最近 $N_COMMITS commit ───"

  # 拿所有 commit (不限制类型, 后过滤)
  while IFS=$'\t' read -r sha date subject; do
    [ -z "$sha" ] && continue

    # 跳过 chore/auto/docs/style/test/refactor/build/ci
    if echo "$subject" | grep -qE "^(chore|auto|docs|style|test|refactor|build|ci)[:(]"; then
      continue
    fi
    if echo "$subject" | grep -qE "auto\(cross-repo\)"; then
      continue
    fi

    # 必须是 feat(XX) 或 fix(XX) 类型
    if ! echo "$subject" | grep -qE "^(feat|fix)\("; then
      continue
    fi

    # 检是否引用 cognitive-systems 协议关键词
    if ! echo "$subject" | grep -qE "$KEYWORDS_REGEX"; then
      continue
    fi

    # 检 commit body 是否有更多协议上下文
    body=$(git -C "$repo_path" show -s --format="%b" "$sha" 2>/dev/null | head -20)
    body_keywords=""
    if echo "$body" | grep -qE "$KEYWORDS_REGEX"; then
      body_keywords="✓"
    fi

    # 生成段
    scope=$(echo "$subject" | sed -E 's/^(feat|fix)\(([^)]*)\).*/\2/')
    type=$(echo "$subject" | grep -oE "^(feat|fix)")
    date_short=$(echo "$date" | cut -c1-10)
    segment="### $date_short · $repo_name $type($scope)

| 项 | 值 |
|---|---|
| 源仓 | $repo_name |
| commit | \`$sha\` |
| 触发协议 | $(echo "$subject $body" | grep -oE "v0\.[0-9]+\.[0-9]+|X 顿悟|Y 顿悟|Z 顿悟|U 协议|拓扑|镜子|M[0-9]" | head -3 | tr '\n' ',' | sed 's/,$//' || echo '元方法论') |
| body 关键词 | $body_keywords |
| 描述 | $(echo "$subject" | head -c 120) |

"
    all_segments_md+="$segment"
    total_segments=$((total_segments + 1))
  done < <(git -C "$repo_path" log --no-merges --date=iso --format="%H%x09%ad%x09%s" -n "$N_COMMITS" 2>/dev/null)
done

# 生成 insights/cross-repo-evolution.md
mkdir -p "$(dirname "$OUTPUT")"
cat > "$OUTPUT" << EOF
# Cross-Repository Evolution (auto-generated)

> **自动生成**: 运行 \`bash scripts/cross-repo-evolution.sh\` 重新生成
> **不要手改**: 改各仓的 commit, 重跑脚本
> **生成时间**: $(date -u +"%Y-%m-%dT%H:%M:%SZ")
> **协议版本**: v0.8.25 (Cross-Repo Z Protocol)
> **源仓数**: ${#REPOS[@]} (system-self / thoughtspace-notes / beauty-crm / agent-memory)
> **每个仓 commit 数**: $N_COMMITS
> **总段数**: $total_segments

## 4 仓 feat/fix commit 触发 cognitive-systems 协议

> 跟 \`cross-repo-status.md\` (latest commit 视图) 平行, 这里是 evolution 视图 (N=$N_COMMITS 累积)

EOF

if [ "$total_segments" -eq 0 ]; then
  cat >> "$OUTPUT" << EOF
> ⚠️  最近 $N_COMMITS commit 没找到符合规则的跨仓 commit
> 规则: \`feat(scope)\` 或 \`fix(scope)\` + commit msg 引用 v0.8.X / 顿悟 / 协议 / 拓扑 / 镜子 / M3 等关键词

EOF
else
  echo "$all_segments_md" >> "$OUTPUT"
fi

cat >> "$OUTPUT" << 'EOF'

---

## 协议 vs 段统计

| 协议 | 段数 | 源仓 |
|---|---|---|
EOF

# 协议分布统计
echo "$all_segments_md" | grep -oE "(v0\.[0-9]+\.[0-9]+|X 顿悟|Y 顿悟|Z 顿悟|U 协议|拓扑|镜子|M[0-9])" | sort | uniq -c | sort -rn | head -20 | while read -r count proto; do
  echo "| $proto | $count | (累计) |" >> "$OUTPUT"
done

cat >> "$OUTPUT" << 'EOF'

---

## 维护说明

- **执行者**: `scripts/cross-repo-evolution.sh` (bash, 0 依赖)
- **写入位置**: `insights/cross-repo-evolution.md`
- **触发方式**:
  - 手动: `bash scripts/cross-repo-evolution.sh`
  - Cron: 6h 一次 (跟 cross-repo-status 同频)
  - CI: z-enforce.yml v0.8.25+ 加 job 调它
- **commit 策略**: `--push` 时 auto commit, message `auto(cross-repo-evolution): refresh N=10 segments (YYYY-MM-DD)`

---

沉淀人: Mavis · 凌晨 5 点长程推进 (2026-07-18) · 跨仓 Z 协议 v0.8.25
EOF

echo ""
echo "=== Cross-Repo Evolution 总结 ==="
echo "总段数: $total_segments"
echo "输出: $OUTPUT"
echo "段数/源仓: $(echo "scale=1; $total_segments / ${#REPOS[@]}" | bc 2>/dev/null || echo "$total_segments/${#REPOS[@]}")"

if [ "$DO_PUSH" = true ]; then
  if [ ! -d "$REPO_ROOT/.git" ]; then
    echo "⚠️  cognitive-systems 不是 git 仓, 跳过 push"
  else
    cd "$REPO_ROOT"
    git add insights/cross-repo-evolution.md
    if git diff --cached --quiet; then
      echo "无变更, 跳过 commit"
    else
      git -c user.email=Mavis@noteverse.space -c user.name=Mavis commit -q -m "auto(cross-repo-evolution): refresh N=$N_COMMITS segments ($total_segments total) ($(date -u +%Y-%m-%d))"
      echo "✅ 已 commit"
    fi
  fi
fi

echo ""
echo "✅ Cross-Repo Evolution 完成"
