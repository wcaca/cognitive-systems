#!/usr/bin/env bash
# cross-repo-status.sh · 跨仓元数据同步脚本 (v0.8.15)
#
# 功能: 从 4 个仓的 git log 自动抽取 latest commit / version / date / next-pending
# 输出:
#   1. insights/cross-repo-status.md (人类可读)
#   2. insights/cross-repo-status.json (机器可读)
#
# 用法:
#   bash scripts/cross-repo-status.sh                 # 跑跨仓视图生成
#   bash scripts/cross-repo-status.sh --repos=PATH... # 指定仓路径
#   bash scripts/cross-repo-status.sh --push          # 生成后自动 pull-push (v0.8.15 协议 2)
#   bash scripts/cross-repo-status.sh --no-lock       # 跳过 lock 检查 (debug 用)
#   bash scripts/cross-repo-status.sh --archive       # v0.8.17 起 · 归档到 70-artifacts/cross-repo-status-archive
#   bash scripts/cross-repo-status.sh --archive=version  # 强制写版本快照 (即使 commit msg 无 vX.Y.Z)
#
# 设计原则 (跨仓 sync 协议):
#   - 各仓 commit message 是 local SSOT
#   - 跨仓视图是 derived, 不手写
#   - 自动生成, 跟 source 同步 (协议 2 + 协议 4)
#   - 多 writer 协调: lock + pull-push + own view per仓 (v0.8.15 协议 1+2+4)

set -euo pipefail

# 解析参数
NO_LOCK=false
DO_PUSH=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
REPO_PARENT="$(cd "$REPO_ROOT/.." && pwd)"

DEFAULT_REPOS=(
  "$REPO_PARENT/cognitive-systems"
  "$REPO_PARENT/sas-graph"
  "$REPO_PARENT/creation-loop"
  "$REPO_PARENT/agent-memory"
)

REPOS=("${DEFAULT_REPOS[@]}")
# v0.8.17 起: --archive 归档模式
ARCHIVE_MODE="none"  # none | daily | version
ARCHIVE_FORCE_VERSION=""
for arg in "$@"; do
  case "$arg" in
    --no-lock) NO_LOCK=true ;;
    --push) DO_PUSH=true ;;
    --archive) ARCHIVE_MODE="daily" ;;
    --archive=daily) ARCHIVE_MODE="daily" ;;
    --archive=version) ARCHIVE_MODE="version" ;;
    --archive-version=*) ARCHIVE_MODE="version"; ARCHIVE_FORCE_VERSION="${arg#--archive-version=}" ;;
    --repos=*) IFS=',' read -ra REPOS <<< "${arg#--repos=}" ;;
    *) echo "Unknown arg: $arg" >&2; exit 1 ;;
  esac
done

OUT_DIR="$REPO_ROOT/insights"
OUT_MD="$OUT_DIR/cross-repo-status.md"
OUT_JSON="$OUT_DIR/cross-repo-status.json"

mkdir -p "$OUT_DIR"

# v0.8.15 多 writer 协调: lock 文件
LOCK_FILE="${CROSS_REPO_LOCK:-/tmp/cross-repo-status.lock}"
LOCK_TIMEOUT="${LOCK_TIMEOUT:-600}"  # 10 分钟超时

acquire_lock() {
  if [[ "$NO_LOCK" == "true" ]]; then return 0; fi
  if [[ -f "$LOCK_FILE" ]]; then
    local lock_age
    lock_age=$(( $(date +%s) - $(stat -c %Y "$LOCK_FILE") ))
    if [[ $lock_age -gt $LOCK_TIMEOUT ]]; then
      echo "WARN: stale lock (${lock_age}s old), removing" >&2
      rm -f "$LOCK_FILE"
    else
      echo "SKIP: another writer holds lock (${lock_age}s old)" >&2
      exit 0
    fi
  fi
  echo "$$" > "$LOCK_FILE"
  trap "rm -f $LOCK_FILE" EXIT
}

release_lock() {
  rm -f "$LOCK_FILE" 2>/dev/null || true
}

# v0.8.17 起: 归档模式
# --archive           → 每日快照 (YYYY-MM-DD-daily.md)
# --archive=version   → 版本快照 (YYYY-MM-DD-vX.Y.Z.md), commit 无版本号则跳
# --archive-version=X.Y.Z → 强制指定版本号 (跳过 auto-detect)
run_archive() {
  if [[ "$ARCHIVE_MODE" == "none" ]]; then return 0; fi

  cd "$REPO_ROOT"
  ARCHIVE_DIR="70-artifacts/cross-repo-status-archive"
  mkdir -p "$ARCHIVE_DIR"
  TODAY=$(date -u +"%Y-%m-%d")
  COGNITIVE_HEAD_SHA=$(git -C "$REPO_ROOT" rev-parse --short HEAD 2>/dev/null || echo "unknown")
  COGNITIVE_HEAD_MSG=$(git -C "$REPO_ROOT" log -1 --format=%s 2>/dev/null || echo "")

  DAILY_FILE="$ARCHIVE_DIR/${TODAY}-daily.md"

  if [[ "$ARCHIVE_MODE" == "daily" ]]; then
    # 每日快照: copy insights/cross-repo-status.md → daily.md
    if [[ ! -f "insights/cross-repo-status.md" ]]; then
      echo "WARN: insights/cross-repo-status.md 不存在, 跳过" >&2
      return 1
    fi
    cp "insights/cross-repo-status.md" "$DAILY_FILE"
    echo ""
    echo "=== Archived (daily) → $DAILY_FILE ==="
  fi

  if [[ "$ARCHIVE_MODE" == "version" ]]; then
    # 版本快照: 先写 daily, 再写 version-named
    if [[ ! -f "insights/cross-repo-status.md" ]]; then
      echo "WARN: insights/cross-repo-status.md 不存在, 跳过" >&2
      return 1
    fi
    cp "insights/cross-repo-status.md" "$DAILY_FILE"
    VERSION_FILE=""
    if [[ -n "$ARCHIVE_FORCE_VERSION" ]]; then
      VERSION_FILE="$ARCHIVE_DIR/${TODAY}-${ARCHIVE_FORCE_VERSION}.md"
    else
      # 从最新 commit msg 提取 vX.Y.Z
      V=$(echo "$COGNITIVE_HEAD_MSG" | grep -oE "v[0-9]+\.[0-9]+(\.[0-9]+)?" | head -1)
      if [[ -n "$V" ]]; then
        VERSION_FILE="$ARCHIVE_DIR/${TODAY}-${V}.md"
      fi
    fi
    if [[ -n "$VERSION_FILE" ]]; then
      cp "insights/cross-repo-status.md" "$VERSION_FILE"
      echo ""
      echo "=== Archived (version) → $VERSION_FILE ==="
      echo "=== Archived (daily)   → $DAILY_FILE ==="
    else
      echo ""
      echo "=== Archived (daily) only → $DAILY_FILE === (no vX.Y.Z in commit msg, use --archive-version=X.Y.Z to force)"
    fi
  fi
}

# 元数据: 按 basename 查找
declare -A DISPLAY_NAMES_BY_BASENAME=(
  ["cognitive-systems"]="cognitive-systems"
  ["sas-graph"]="sas-graph"
  ["creation-loop"]="creation-loop"
  ["agent-memory"]="agent-memory"
)
declare -A REPO_TYPES_BY_BASENAME=(
  ["cognitive-systems"]="research (public)"
  ["sas-graph"]="research (private)"
  ["creation-loop"]="research (private)"
  ["agent-memory"]="memory (private)"
)

display_name() {
  local bn; bn=$(basename "$1")
  echo "${DISPLAY_NAMES_BY_BASENAME[$bn]:-$bn}"
}
repo_type() {
  local bn; bn=$(basename "$1")
  echo "${REPO_TYPES_BY_BASENAME[$bn]:-unknown}"
}

# 解析 commit message: 提取版本号
# 优先级: 3 段 v0.X.Y > 2 段 v1.0
# 过滤: vX.Y 后面紧跟描述 (deploy/section/limitations/...) 是 false positive
parse_version() {
  local msg="$1"
  local ver
  ver=$(echo "$msg" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
  if [[ -z "$ver" ]]; then
    local raw
    raw=$(echo "$msg" | grep -oE 'v[0-9]+\.[0-9]+' | head -1 || true)
    if [[ -n "$raw" ]]; then
      local after
      after=$(echo "$msg" | sed "s/.*$raw//" | head -c 10)
      if [[ "$after" =~ ^[[:space:]]+(deploy|url|limitations|section|test|stats|upgrade|notes|chapter|appendix|mode|status) ]]; then
        ver=""
      elif [[ "$after" =~ ^-(v[0-9]) ]]; then
        ver=""
      else
        ver="$raw"
      fi
    fi
  fi
  if [[ -z "$ver" ]]; then
    ver=$(echo "$msg" | grep -oE 'V[0-9]+_[0-9]+(_[0-9]+)?' | head -1 | tr '_' '.' || true)
  fi
  echo "${ver:--}"
}

parse_summary() {
  local msg="$1"
  echo "$msg" | head -1
}

find_latest_version() {
  while IFS= read -r -d $'\0' msg; do
    local v
    v=$(parse_version "$msg")
    if [[ "$v" != "-" ]]; then
      echo "$v"
      return
    fi
  done < <(git log --oneline -10 | awk '{$1=""; print $0}' | sed 's/^ *//' | tr '\n' '\0')
  echo "-"
}

# v0.8.15 协议 2: pull-push 模式
pull_push() {
  if [[ "$DO_PUSH" != "true" ]]; then return 0; fi
  echo ""
  echo "=== Pull-push mode (v0.8.15 protocol 2) ==="
  cd "$REPO_ROOT"

  # stash unstaged (避免 pull 冲突)
  local stashed=false
  if ! git diff --quiet 2>/dev/null; then
    git stash push -u -m "cross-repo-status pre-pull stash $(date +%s)" >/dev/null 2>&1
    stashed=true
  fi

  # pull --rebase
  if ! git pull --rebase origin main 2>&1 | tail -3; then
    echo "WARN: pull failed, skipping push"
    [[ "$stashed" == "true" ]] && git stash pop >/dev/null 2>&1 || true
    return 0
  fi

  # unstash
  [[ "$stashed" == "true" ]] && git stash pop >/dev/null 2>&1 || true

  # 检查内容是否有变化
  if git diff --quiet "$OUT_MD" "$OUT_JSON" 2>/dev/null; then
    echo "No changes to commit"
    return 0
  fi

  # commit
  git config user.email "Mavis@Mavis.local" 2>/dev/null || true
  git config user.name "Mavis" 2>/dev/null || true
  git add "$OUT_MD" "$OUT_JSON"

  # 计算 content hash
  local hash
  hash=$(sha256sum "$OUT_MD" | head -c 8)
  git commit -m "auto(cross-repo): refresh status ${hash}

Generated at $(date -u +"%Y-%m-%dT%H:%M:%SZ")
Protocol: v0.8.15 multi-writer coordination

Co-authored-by: Mavis <Mavis@Mavis.local>" >/dev/null

  # push (race lost 时重试一次)
  if ! git push 2>&1 | tail -3; then
    echo "WARN: push failed (race?), retry after pull"
    # retry pull: 也要 stash
    local stashed2=false
    if ! git diff --quiet 2>/dev/null; then
      git stash push -u -m "cross-repo-status retry stash $(date +%s)" >/dev/null 2>&1
      stashed2=true
    fi
    git pull --rebase origin main
    [[ "$stashed2" == "true" ]] && git stash pop >/dev/null 2>&1 || true
    git add "$OUT_MD" "$OUT_JSON"
    git commit -m "auto(cross-repo): refresh status ${hash} (retry after race)" >/dev/null
    git push
  fi
}

# 主流程
acquire_lock

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JSON_ENTRIES=()

echo "=== Generating cross-repo status at $TIMESTAMP ==="
echo "Protocol: v0.8.15 multi-writer coordination"
echo "Repos: ${#REPOS[@]}"
echo ""

{
  echo "# Cross-Repository Status (auto-generated)"
  echo ""
  echo "> **自动生成**: 运行 \`bash scripts/cross-repo-status.sh\` 重新生成"
  echo "> **不要手改**: 改各仓的 commit, 重跑脚本"
  echo "> **生成时间**: $TIMESTAMP"
  echo "> **协议版本**: v0.8.15"
  echo ""
  echo "## 4 个仓的最新状态"
  echo ""
  echo "| 仓 | 类型 | 最新 commit | 版本 | 日期 | 主题 |"
  echo "|---|---|---|---|---|---|"
} > "$OUT_MD"

for repo_path in "${REPOS[@]}"; do
  if [[ ! -d "$repo_path/.git" ]]; then
    echo "WARN: $repo_path 不是 git 仓库, 跳过" >&2
    continue
  fi

  cd "$repo_path"

  local_sha=$(git rev-parse --short HEAD)
  local_date=$(git log -1 --format=%cd --date=short)
  local_msg=$(git log -1 --format=%s)
  local_version=$(find_latest_version)
  local_summary=$(parse_summary "$local_msg")

  display=$(display_name "$repo_path")
  rtype=$(repo_type "$repo_path")

  echo "| [$display](https://github.com/wcaca/$(basename "$repo_path")) | $rtype | \`$local_sha\` | $local_version | $local_date | $local_summary |" >> "$OUT_MD"

  JSON_ENTRIES+=$(cat <<EOF
  {
    "name": "$display",
    "type": "$rtype",
    "path": "$repo_path",
    "sha": "$local_sha",
    "version": "$local_version",
    "date": "$local_date",
    "summary": $(printf '%s' "$local_summary" | python3 -c "import json,sys; print(json.dumps(sys.stdin.read()))")
  },
EOF
)
done

{
  echo "{"
  echo "  \"generated_at\": \"$TIMESTAMP\","
  echo "  \"protocol_version\": \"v0.8.15\","
  echo "  \"repos\": ["
  printf '%s\n' "${JSON_ENTRIES[@]}"
  echo "  ]"
  echo "}"
} > "$OUT_JSON"

python3 -c "
import json, re
with open('$OUT_JSON') as f:
    content = f.read()
content = re.sub(r',(\s*\])', r'\1', content)
with open('$OUT_JSON', 'w') as f:
    f.write(content)
"

echo "=== Generated ==="
echo "  MD:   $OUT_MD"
echo "  JSON: $OUT_JSON"
echo ""
cat "$OUT_MD"

# v0.8.15 协议 2: 可选 push
pull_push

# v0.8.17 协议: 归档模式 (per 70-artifacts/cross-repo-status-archive-policy.md)
run_archive

release_lock