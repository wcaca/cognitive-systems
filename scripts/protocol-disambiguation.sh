#!/bin/bash
# ==============================================================================
# protocol-disambiguation.sh · 协议名 vs 形容词去歧 (v0.8.26 · AA 顿悟)
# ==============================================================================
# 起源: 30-protocols/protocol-disambiguation.md
#
# WHY: v0.8.25 跨仓 Z 协议用关键词 regex 检协议引用, 但协议名 (e.g. 镜子)
#      既指协议又指普通名词, 误报率高 (5/7=71%, N=30 验证)
#
# WHAT: 双白名单 + 距离阈值判定
#       - 协议名白名单 12 个 (X/Y/Z 顿悟, U/V/W 协议, 镜子原则, 拓扑学, 跨仓 Z 协议, 同认知关联, M3b, 飞轮)
#       - 协议标记词白名单 16 个 (协议/顿悟/原则/实做/enforcement/拓扑学/evolution/飞轮/沉淀/落地/闭环/SOTA/总线/加固/同步/跨仓)
#       - 距离阈值 ≤ 8 字符 = 真协议引用
#       - 否则 = 形容词用法, 不计
#
# USAGE:
#   bash scripts/protocol-disambiguation.sh classify "镜子原则 Step 5"
#   bash scripts/protocol-disambiguation.sh test
#   bash scripts/protocol-disambiguation.sh stats
#
# 设计原则 (跟 cross-repo-evolution.sh / z-enforce.sh 一致):
#   - bash 0 依赖
#   - 协议名 + 协议标记词 白名单集中在文件头, 改这里就改判定
#   - 距离阈值经验值 8 字符 (留 v0.8.27+ 加自适应)
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# -----------------------------------------------------------------------------
# 协议名白名单 (12 个, 跟 protocol-disambiguation.md §4.1 对齐)
# -----------------------------------------------------------------------------
PROTOCOL_NAMES=(
  "X 顿悟"
  "Y 顿悟"
  "Z 顿悟"
  "AA 顿悟"
  "U 协议"
  "V 协议"
  "W 协议"
  "镜子原则"
  "拓扑学"
  "跨仓 Z 协议"
  "同认知关联"
  "M3b"
  "飞轮"
)

# -----------------------------------------------------------------------------
# 协议标记词白名单 (16 个, 跟 protocol-disambiguation.md §4.2 对齐)
# -----------------------------------------------------------------------------
PROTOCOL_MARKERS=(
  "协议"
  "顿悟"
  "原则"
  "实做"
  "enforcement"
  "拓扑学"
  "evolution"
  "飞轮"
  "沉淀"
  "落地"
  "闭环"
  "SOTA"
  "总线"
  "加固"
  "同步"
  "跨仓"
)

# 距离阈值 (字符, 经验值)
DISTANCE_THRESHOLD=8

# =============================================================================
# 核心: classify_text — 给一段文本, 返回真协议引用列表 (去重)
# =============================================================================
classify_text() {
  local text="$1"
  local result=""

  # 对每个协议名, 在 text 里找位置
  for proto in "${PROTOCOL_NAMES[@]}"; do
    # 用 bash 字符串替换找所有位置
    local search="$text"
    local pos=0
    local found_proto=0
    local proto_first_pos=-1

    while true; do
      # 找协议名第一次出现位置
      local idx
      idx=$(echo "$search" | grep -boF "$proto" 2>/dev/null | head -1 | cut -d: -f1 || echo "")
      if [ -z "$idx" ]; then
        break
      fi
      found_proto=1
      local abs_pos=$((pos + idx))

      # 记录协议名最早出现位置
      if [ "$proto_first_pos" -lt 0 ]; then
        proto_first_pos=$abs_pos
      fi

      # 找最近的协议标记词 (向前向后 ± 8 字符范围)
      local nearby_marker=0
      for marker in "${PROTOCOL_MARKERS[@]}"; do
        # 向前 8 字符范围找
        local start_back=$((abs_pos - DISTANCE_THRESHOLD))
        if [ "$start_back" -lt 0 ]; then start_back=0; fi
        local back_chunk="${text:$start_back:$((abs_pos - start_back + ${#proto}))}"

        # 向后 8 字符范围找
        local end_fwd=$((abs_pos + ${#proto} + DISTANCE_THRESHOLD))
        if [ "$end_fwd" -gt "${#text}" ]; then end_fwd="${#text}"; fi
        local fwd_chunk="${text:$abs_pos:$((end_fwd - abs_pos))}"

        if echo "$back_chunk$fwd_chunk" | grep -qF "$marker"; then
          nearby_marker=1
          break
        fi
      done

      if [ "$nearby_marker" -eq 1 ]; then
        # 真协议引用, 加入结果
        if [ -z "$result" ]; then
          result="$proto"
        elif ! echo "$result" | grep -qF "$proto"; then
          result="$result, $proto"
        fi
        break  # 一个协议名只算一次 (找最近的标记词)
      fi

      # 找下一个出现位置
      local next_start=$((idx + 1))
      pos=$((pos + next_start))
      search="${search:$next_start}"
    done
  done

  echo "$result"
}

# =============================================================================
# 子命令: classify — 单文本分类
# =============================================================================
cmd_classify() {
  local text="$1"
  local result
  result=$(classify_text "$text")
  if [ -z "$result" ]; then
    echo "(空, 形容词用法 / 无协议引用)"
  else
    echo "$result"
  fi
}

# =============================================================================
# 子命令: test — 跑 12 case 验证
# =============================================================================
cmd_test() {
  local pass=0
  local fail=0
  local total=0

  # 测试用例 (text | expected_substring, 允许空 = 形容词用法)
  # 用例分 3 类: 真协议引用 / 形容词用法 / 边界
  local cases=(
    # 真协议引用 (6 case)
    "镜子原则 Step 4 走新 endpoint|镜子原则"
    "feat(system-self): 镜子原则批量扩展到 4 个 AI endpoint (Step 2 / C9.2)|镜子原则"
    "feat(30-protocols): v0.8.25 跨仓 Z 协议 (Cross-Repo Z Protocol) 实做|跨仓 Z 协议"
    "feat(20-systems/agent-harness): v0.8.24 Z 顿悟 CI enforcement 实做|Z 顿悟"
    "feat(30-protocols): 协议 vs 形容词歧义去歧 (AA 顿悟)|顿悟"
    "feat(20-systems): 拓扑学 U 协议 (双窗口) 实做|U 协议"

    # 形容词用法 (4 case)
    "镜子里能照见自己|"
    "今天天气好, 跟镜子对照看|"
    "协议 vs 形容词歧义 解决|"
    "镜子脏了, 要擦擦|"

    # 边界 (2 case)
    "镜子|"
    "镜子原则|镜子原则"
  )

  echo "=== Protocol Disambiguation Test (v0.8.26) ==="
  echo ""

  for case in "${cases[@]}"; do
    total=$((total + 1))
    local text="${case%|*}"
    local expected="${case#*|}"
    local actual
    actual=$(classify_text "$text")
    if [ -z "$expected" ]; then
      expected="(空)"
    fi

    # 验证: expected 必须出现在 actual 里 (允许 actual 包含额外协议名)
    local test_pass=0
    if [ "$expected" = "(空)" ]; then
      if [ -z "$actual" ]; then
        test_pass=1
      fi
    else
      if echo "$actual" | grep -qF "$expected"; then
        test_pass=1
      fi
    fi

    if [ "$test_pass" -eq 1 ]; then
      pass=$((pass + 1))
      echo "  ✅ case $total: \"$text\" → $actual (期望含 '$expected')"
    else
      fail=$((fail + 1))
      echo "  ❌ case $total: \"$text\" → $actual (期望含 '$expected', 实际不匹配)"
    fi
  done

  echo ""
  echo "=== 总结 ==="
  echo "总 case: $total"
  echo "通过: $pass"
  echo "失败: $fail"

  if [ "$fail" -eq 0 ]; then
    echo "✅ 12/12 cases pass (含真协议引用 6 + 形容词用法 4 + 边界 2)"
    return 0
  else
    echo "❌ $fail case 失败"
    return 1
  fi
}

# =============================================================================
# 子命令: stats — 统计 4 仓最近 N commit 协议引用
# =============================================================================
cmd_stats() {
  local n_commits="${1:-10}"
  local repo_parent
  repo_parent="$(cd "$REPO_ROOT/.." && pwd)"
  local repos=(
    "$repo_parent/system-self"
    "$repo_parent/thoughtspace-notes"
    "$repo_parent/beauty-crm"
    "$repo_parent/agent-memory"
  )

  echo "=== Protocol Disambiguation Stats (N=$n_commits) ==="
  echo ""

  local total_refs=0
  local total_commits_with_ref=0

  for repo_path in "${repos[@]}"; do
    if [ ! -d "$repo_path/.git" ]; then
      echo "⚠️  $repo_path 不是 git 仓, 跳过"
      continue
    fi
    local repo_name
    repo_name="$(basename "$repo_path")"
    echo "─── $repo_name ───"

    local repo_refs=0
    local repo_commits_with_ref=0

    while IFS=$'\t' read -r sha subject; do
      [ -z "$sha" ] && continue
      # 合并 subject + body (前 10 行)
      local body
      body=$(git -C "$repo_path" show -s --format="%b" "$sha" 2>/dev/null | head -10)
      local full_text="$subject $body"

      local refs
      refs=$(classify_text "$full_text")
      if [ -n "$refs" ]; then
        local count
        count=$(echo "$refs" | tr ',' '\n' | wc -l)
        repo_refs=$((repo_refs + count))
        repo_commits_with_ref=$((repo_commits_with_ref + 1))
        echo "  $sha: $refs"
      fi
    done < <(git -C "$repo_path" log --no-merges --format="%H%x09%s" -n "$n_commits" 2>/dev/null)

    echo "  小计: $repo_commits_with_ref commit 含协议引用, $repo_refs 次"
    echo ""
    total_refs=$((total_refs + repo_refs))
    total_commits_with_ref=$((total_commits_with_ref + repo_commits_with_ref))
  done

  echo "=== 总计 ==="
  echo "含协议引用的 commit: $total_commits_with_ref"
  echo "协议引用次数: $total_refs"
}

# =============================================================================
# 主入口
# =============================================================================
if [ $# -lt 1 ]; then
  echo "用法: bash scripts/protocol-disambiguation.sh <classify|test|stats> [args...]"
  echo ""
  echo "  classify <text>  单文本分类"
  echo "  test             跑 12 case 验证"
  echo "  stats [N]        统计 4 仓最近 N commit 协议引用 (默认 N=10)"
  exit 1
fi

case "$1" in
  classify)
    shift
    cmd_classify "$*"
    ;;
  test)
    cmd_test
    ;;
  stats)
    shift
    n="${1:-10}"
    cmd_stats "$n"
    ;;
  *)
    echo "未知子命令: $1"
    exit 1
    ;;
esac
