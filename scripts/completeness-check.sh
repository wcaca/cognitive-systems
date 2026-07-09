#!/usr/bin/env bash
# completeness-check.sh · 仓完整性指标自动检查 (v0.8.20 / 顿悟 W)
#
# 功能: 自动跑 M1-M4 四个完整性指标,输出综合分 (0-100)
# 输出:
#   1. stdout: 表格化报告 (M1/M2/M3/M4/Score/Health)
#   2. JSON: --json 模式输出到 stdout (用于 CI / 跨仓统计)
#
# 指标定义 (见 50-metrics/completeness-metrics.md):
#   M1 协议使用率: 仓内 commit/文档引用协议次数 / 协议总数
#   M2 空目录诚实率: empty_dirs_with_README / total_empty_dirs
#   M3 evolution 同步率: evolution_commits / total_commits (最近 N=30)
#   M4 跨仓状态新鲜度: now - cross-repo-status.md last_modified (秒)
#
# 用法:
#   bash scripts/completeness-check.sh                  # 默认 cognitive-systems 仓
#   bash scripts/completeness-check.sh --repo=PATH      # 指定仓路径
#   bash scripts/completeness-check.sh --json           # JSON 输出
#   bash scripts/completeness-check.sh --threshold=70   # 自定义健康阈值 (默认 75)
#   bash scripts/completeness-check.sh --no-color       # 关掉 ANSI 颜色
#
# 退出码:
#   0: 健康 (score >= threshold)
#   1: 不健康 (score < threshold)
#   2: 参数错误
#
# 设计原则 (50-metrics 协议):
#   - 4 指标都必须给出真实数字 (不能"感觉")
#   - 综合分 = 4 指标等权平均 (v0.8.16 定义)
#   - 健康阈值默认 75,警告 60-75,失败 < 60

set -uo pipefail
# 不开 -e: awk/gawk 计算分母为零时不中断,让脚本能继续输出健康分

# ===== 默认配置 =====
DEFAULT_REPO="."
DEFAULT_THRESHOLD=75
DEFAULT_N_COMMITS=30
PROTOCOL_DIR="80-meta"

# ===== 颜色 =====
if [[ -t 1 ]] && [[ "${NO_COLOR:-}" != "1" ]] && [[ "${1:-}" != "--no-color" ]]; then
  RED='\033[0;31m'
  GREEN='\033[0;32m'
  YELLOW='\033[0;33m'
  CYAN='\033[0;36m'
  BOLD='\033[1m'
  RESET='\033[0m'
else
  RED='' GREEN='' YELLOW='' CYAN='' BOLD='' RESET=''
fi

# ===== 参数解析 =====
REPO_PATH="$DEFAULT_REPO"
JSON_MODE=false
THRESHOLD=$DEFAULT_THRESHOLD

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo=*)
      REPO_PATH="${1#*=}"
      shift
      ;;
    --json)
      JSON_MODE=true
      shift
      ;;
    --threshold=*)
      THRESHOLD="${1#*=}"
      shift
      ;;
    --no-color)
      NO_COLOR=1
      shift
      ;;
    -h|--help)
      sed -n '2,30p' "$0"
      exit 0
      ;;
    *)
      echo "ERROR: 未知参数 $1" >&2
      exit 2
      ;;
  esac
done

# ===== 校验仓库 =====
if [[ ! -d "$REPO_PATH/.git" ]]; then
  echo "ERROR: $REPO_PATH 不是 git 仓库" >&2
  exit 2
fi

cd "$REPO_PATH"

# ===== M1 协议使用率 =====
# 协议总数 = 80-meta/*.md 文件数
protocol_total=$(find "$PROTOCOL_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null | wc -l)
# 协议被引用 = 在仓所有 .md/.sh/.yml/.ts/.js 文件中,匹配 "协议名引用" 或 "see <file>.md"
# 简化: 取每个协议文件名, 看仓里其他文档/commit 是否提及
protocol_referenced=0
if [[ $protocol_total -gt 0 ]]; then
  while IFS= read -r protocol_file; do
    protocol_name=$(basename "$protocol_file" .md)
    # 搜索引用: 排除自身文件, 包含文件名或核心关键词
    refs=$(grep -rIl --exclude-dir=.git --exclude-dir=node_modules --exclude="$(basename "$protocol_file")" \
      "$protocol_name" . 2>/dev/null | wc -l)
    if [[ "$refs" -gt 0 ]]; then
      protocol_referenced=$((protocol_referenced + 1))
    fi
  done < <(find "$PROTOCOL_DIR" -maxdepth 1 -name "*.md" -type f 2>/dev/null)
fi
m1=$(awk -v ref="$protocol_referenced" -v total="$protocol_total" \
  'BEGIN { if (total > 0) printf "%.2f", ref/total; else print "0.00" }')

# ===== M2 空目录诚实率 =====
# 空目录 = 没文件的目录 (排除 .git / node_modules)
# 空目录诚实 = empty_dir_with_README / total_empty_dirs
empty_total=0
empty_with_readme=0
while IFS= read -r dir; do
  # 跳过 .git 及其子目录, 跳过 node_modules / .next / dist / build / .github/workflows
  case "$dir" in
    */.git|*/.git/*|*/node_modules|*/.next|*/dist|*/build|*/.cache|*/.github/workflows) continue ;;
  esac
  case "$(basename "$dir")" in
    .git|node_modules|.next|dist|build|.cache) continue ;;
  esac
  # 只看空目录 (没文件, 可能含子目录)
  if [[ -z "$(find "$dir" -maxdepth 1 -type f 2>/dev/null)" ]]; then
    empty_total=$((empty_total + 1))
    if [[ -f "$dir/README.md" ]]; then
      empty_with_readme=$((empty_with_readme + 1))
    fi
  fi
done < <(find . -maxdepth 2 -type d 2>/dev/null | grep -v "^\.$")

m2=$(awk -v with="$empty_with_readme" -v total="$empty_total" \
  'BEGIN { if (total > 0) printf "%.2f", with/total; else print "1.00" }')

# ===== M3 evolution 同步率 (v0.8.21 X 顿悟修正) =====
# v0.8.20 算法: 测 commit msg 文本里是否提 evolution/insight/同步 — 容易被污染, 不可靠
# v0.8.21 算法: 测 evolution.md 在该 commit 是否被实际更新 (--diff-filter=AM)
#   - 更准确: 测的是"协议有没有被履行", 而不是"作者有没有写关键词"
#   - 配套协议: 30-protocols/evolution-sync-protocol.md
# 默认 evolution.md 路径; 可通过 EVOLUTION_FILE 环境变量覆盖
EVOLUTION_FILE="${EVOLUTION_FILE:-20-systems/agent-harness/evolution.md}"
total_commits=$(git log --oneline -"$DEFAULT_N_COMMITS" 2>/dev/null | wc -l)
evolution_commits=$(git log --oneline -"$DEFAULT_N_COMMITS" --diff-filter=AM -- "$EVOLUTION_FILE" 2>/dev/null | wc -l)

m3=$(awk -v evo="$evolution_commits" -v total="$total_commits" \
  'BEGIN { if (total > 0) printf "%.2f", evo/total; else print "0.00" }')

# ===== M4 跨仓状态新鲜度 =====
# 检查 insights/cross-repo-status.md 存在性 + 最后修改时间
cross_repo_file="insights/cross-repo-status.md"
if [[ -f "$cross_repo_file" ]]; then
  last_modified=$(stat -c %Y "$cross_repo_file" 2>/dev/null || stat -f %m "$cross_repo_file" 2>/dev/null || echo "0")
  now=$(date +%s)
  age_seconds=$((now - last_modified))
  # 24h = 86400s 内算新鲜
  if [[ $age_seconds -le 86400 ]]; then
    m4="1.00"
  elif [[ $age_seconds -le 86400*3 ]]; then
    m4="0.50"
  elif [[ $age_seconds -le 86400*7 ]]; then
    m4="0.25"
  else
    m4="0.00"
  fi
else
  m4="0.00"
  age_seconds="N/A"
fi

# ===== 综合分 =====
score=$(awk -v a="$m1" -v b="$m2" -v c="$m3" -v d="$m4" \
  'BEGIN { printf "%.1f", (a+b+c+d)/4*100 }')

# ===== 健康判断 =====
health="unhealthy"
if awk -v s="$score" -v t="$THRESHOLD" 'BEGIN { exit !(s >= t) }'; then
  health="healthy"
elif awk -v s="$score" 'BEGIN { exit !(s >= 60) }'; then
  health="warning"
fi

# ===== 输出 =====
if [[ "$JSON_MODE" == "true" ]]; then
  cat <<EOF
{
  "repo": "$REPO_PATH",
  "threshold": $THRESHOLD,
  "metrics": {
    "M1_protocol_adoption": { "value": $m1, "referenced": $protocol_referenced, "total": $protocol_total },
    "M2_skeleton_honesty": { "value": $m2, "with_readme": $empty_with_readme, "empty_total": $empty_total },
    "M3_evolution_sync": { "value": $m3, "evolution_commits": $evolution_commits, "total_commits": $total_commits, "algorithm": "diff-filter-AM on $EVOLUTION_FILE" },
    "M4_cross_repo_freshness": { "value": $m4, "age_seconds": "$age_seconds" }
  },
  "score": $score,
  "health": "$health",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
else
  echo -e "${BOLD}${CYAN}=== completeness-check.sh · $(date -u +%Y-%m-%dT%H:%M:%SZ) ===${RESET}"
  echo -e "Repo: ${BOLD}$REPO_PATH${RESET}    Threshold: $THRESHOLD"
  echo
  printf "%-32s %-8s %s\n" "指标" "值" "详情"
  printf "%-32s %-8s %s\n" "--------------------------------" "--------" "----------------------------------------"
  printf "%-32s %-8s %d/%d 协议被引用\n" "M1 协议使用率" "$m1" "$protocol_referenced" "$protocol_total"
  printf "%-32s %-8s %d/%d 空目录有 README\n" "M2 空目录诚实率" "$m2" "$empty_with_readme" "$empty_total"
  printf "%-32s %-8s %d/%d commit 实际更新 evolution.md\n" "M3 evolution 同步率" "$m3" "$evolution_commits" "$total_commits"
  printf "%-32s %-8s age=%ss (24h=1.0, 3d=0.5, 7d=0.25)\n" "M4 跨仓状态新鲜度" "$m4" "$age_seconds"
  echo
  printf "%-32s ${BOLD}%-8s${RESET}\n" "综合分 (M1-M4 等权平均)" "$score"

  case "$health" in
    healthy)
      echo -e "状态: ${GREEN}${BOLD}$health${RESET} (≥ $THRESHOLD)"
      ;;
    warning)
      echo -e "状态: ${YELLOW}${BOLD}$health${RESET} (60-$THRESHOLD)"
      ;;
    *)
      echo -e "状态: ${RED}${BOLD}$health${RESET} (< 60)"
      ;;
  esac
  echo
  echo "JSON: bash scripts/completeness-check.sh --json"
fi

# 退出码
if [[ "$health" == "healthy" ]]; then
  exit 0
else
  exit 1
fi