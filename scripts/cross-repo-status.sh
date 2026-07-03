#!/usr/bin/env bash
# cross-repo-status.sh · 跨仓元数据同步脚本 (v0.8.14)
#
# 功能: 从 4 个仓的 git log 自动抽取 latest commit / version / date / summary
# 输出:
#   1. insights/cross-repo-status.md (人类可读)
#   2. insights/cross-repo-status.json (机器可读)
#
# 用法:
#   bash scripts/cross-repo-status.sh
#   bash scripts/cross-repo-status.sh --repos=/path1,/path2,...
#
# 设计原则 (跨仓 sync 协议):
#   - 各仓 commit message 是 local SSOT
#   - 跨仓视图是 derived, 不手写
#   - 自动生成, 跟 source 同步 (协议 2 + 协议 4)

set -euo pipefail

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
if [[ "${1:-}" == --repos=* ]]; then
  IFS=',' read -ra REPOS <<< "${1#--repos=}"
fi

OUT_DIR="$REPO_ROOT/insights"
OUT_MD="$OUT_DIR/cross-repo-status.md"
OUT_JSON="$OUT_DIR/cross-repo-status.json"

mkdir -p "$OUT_DIR"

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
  # 1. 3 段版本号 (e.g. v0.8.13)
  ver=$(echo "$msg" | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)
  # 2. 2 段版本号 (e.g. v0.6 / v1.0 / v0.12)
  if [[ -z "$ver" ]]; then
    local raw
    raw=$(echo "$msg" | grep -oE 'v[0-9]+\.[0-9]+' | head -1 || true)
    if [[ -n "$raw" ]]; then
      # 过滤假版本: 后面紧跟 描述性英文 / 连字符 / 括号 / 中文
      local after
      after=$(echo "$msg" | sed "s/.*$raw//" | head -c 10)
      # 真版本: 后面是终止 / 冒号 / 中文章符 / 大写英文
      # 假版本: 后面是描述性文本
      if [[ "$after" =~ ^[[:space:]]+(deploy|url|limitations|section|test|stats|upgrade|notes|chapter|appendix|mode|status) ]]; then
        ver=""
      elif [[ "$after" =~ ^-(v[0-9]) ]]; then
        # "v0.10-v0.12" 这种范围
        ver=""
      else
        ver="$raw"
      fi
    fi
  fi
  # 3. V0_6_1 格式
  if [[ -z "$ver" ]]; then
    ver=$(echo "$msg" | grep -oE 'V[0-9]+_[0-9]+(_[0-9]+)?' | head -1 | tr '_' '.' || true)
  fi
  echo "${ver:--}"
}

parse_summary() {
  local msg="$1"
  echo "$msg" | head -1
}

# 往回找带版本号的 commit (最多 10 个)
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

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
JSON_ENTRIES=()

echo "=== Generating cross-repo status at $TIMESTAMP ==="

{
  echo "# Cross-Repository Status (auto-generated)"
  echo ""
  echo "> **自动生成**: 运行 \`bash scripts/cross-repo-status.sh\` 重新生成"
  echo "> **不要手改**: 改各仓的 commit, 重跑脚本"
  echo "> **生成时间**: $TIMESTAMP"
  echo "> **协议版本**: v0.8.14"
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
  echo "  \"protocol_version\": \"v0.8.14\","
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

echo ""
echo "=== Generated ==="
echo "  MD:   $OUT_MD"
echo "  JSON: $OUT_JSON"
echo ""
cat "$OUT_MD"