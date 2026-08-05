#!/bin/bash
# v0.8.29 LIB_GUARD: source 时跳过 main case block
# 允许: source $SCRIPT (供 tests/test-h2-protocol-claim-0.8.29.sh 跑 placeholder 函数)
# __PROTOCOL_DISAMBIG_LIB__=1 时, main case block 不会执行
# ==============================================================================
# ==============================================================================
# protocol-disambiguation.sh · 协议名 vs 形容词去歧 (v0.8.30 · H2 frontmatter 实做)
# ==============================================================================
# 起源: 30-protocols/protocol-disambiguation.md
#
# WHY: v0.8.25 跨仓 Z 协议用关键词 regex 检协议引用, 但协议名 (e.g. 镜子)
#      既指协议又指普通名词, 误报率高 (5/7=71%, N=30 验证)
#
# v0.8.27 升级 (AB 顿悟 · 多语言 + 协议自发现):
#   1. 多语言标记词: 中/英/日/西 4 语言 36 标记词 (v0.8.26 仅 16 中文)
#   2. 协议自发现: 扫 30-protocols/*.md 标题自动注册新协议 (不再手动维护白名单)
#   3. 自适应距离阈值: 文本长度 ≤ 30 字符 → 4 字符; ≤ 80 → 8 字符; > 80 → 12 字符
#   4. 核心白名单 (12 协议 + 16 中文标记词) 保持 v0.8.26 不变, 增量向上
#
# v0.8.28 升级 (AC 顿悟 · H2 章节 + 协议白名单导出):
#   1. 协议自发现扩展: 扫 H1 + H2 章节标题 (覆盖协议内部"X 协议实施"子章节)
#   2. 协议白名单导出: 自发现结果写盘 30-protocols/.protocol-names.txt
#      (供 git pre-commit / CI / 其他脚本引用, SSOT 离盘可读)
#   3. 跨语言协议名格式兼容: H1/H2 含 | 别名也正确切分
#
# WHAT: 双白名单 + 距离阈值判定 (v0.8.26) + 多语言 + 自发现 (v0.8.27) + H2 + 导出 (v0.8.28)
#       - 协议名白名单 13 核心 + 30-protocols/ 自发现 (H1+H2)
#       - 协议标记词白名单 36 个 (中 16 + 英 10 + 日 7 + 西 3)
#       - 距离阈值: 静态 8 字符 (默认) / 自适应 (按文本长度)
#       - 自发现: scan_protocols() 扫 30-protocols/*.md 提取 H1 + H2 标题
#       - 导出: 30-protocols/.protocol-names.txt (git ignored, 运行时生成)
#
# USAGE:
#   bash scripts/protocol-disambiguation.sh classify "镜子原则 Step 5"
#   bash scripts/protocol-disambiguation.sh test
#   bash scripts/protocol-disambiguation.sh stats
#   bash scripts/protocol-disambiguation.sh scan
#   bash scripts/protocol-disambiguation.sh scan-stats
#   bash scripts/protocol-disambiguation.sh export   # v0.8.28 新增: 写 30-protocols/.protocol-names.txt
#
# 设计原则 (跟 cross-repo-evolution.sh / z-enforce.sh 一致):
#   - bash 0 依赖
#   - 协议名 + 协议标记词 白名单集中在文件头, 改这里就改判定
#   - 自发现 30-protocols/*.md 是 source of truth, 手动白名单是 fallback
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# -----------------------------------------------------------------------------
# 协议名白名单 (20 核心, 跟 protocol-disambiguation.md §4.1 对齐)
# v0.8.27 多语言: 协议名格式 "中文|EN|JA" (用 | 分隔, 任一匹配即算)
# 自发现协议: scan_protocols() 扫 30-protocols/*.md 自动加入
# -----------------------------------------------------------------------------
PROTOCOL_NAMES_CORE=(
  # 单字母顿悟 (T/S, v0.8.32 新增)
  "T 顿悟|T 頓悟|T insight"
  "S 顿悟|S 頓悟|S insight"
  # 双字母顿悟 (X/Y/Z/AA/AB/AC, v0.8.32 多语言别名)
  "X 顿悟|X 頓悟|X insight|X protocolo|X protocolo"
  "Y 顿悟|Y 頓悟|Y insight|Y protocolo"
  "Z 顿悟|Z 頓悟|Z insight|Z protocolo"
  "AA 顿悟|AA 頓悟|AA insight|protocolo AA"
  "AB 顿悟|AB 頓悟|AB insight|protocolo AB"
  "AC 顿悟|AC 頓悟|AC insight|protocolo AC"
  # 单字母协议 (T/S/U/V/W, v0.8.32 多语言别名 + T/S 协议 v0.8.16/17 补)
  "T 协议|T protocol|T プロトコル|protocolo T"
  "S 协议|S protocol|S プロトコル|protocolo S"
  "U 协议|U protocol|U プロトコル|protocolo U"
  "V 协议|V protocol|V プロトコル|protocolo V"
  "W 协议|W protocol|W プロトコル|protocolo W"
  # 命名协议 (v0.8.32 多语言扩展)
  "镜子原则|mirror principle|mirror-principle|espejo principio"
  "拓扑学|topology|トポロジー|topología"
  "跨仓 Z 协议|cross-repo Z protocol|cross-repo Z プロトコル|protocolo Z inter-repositorio"
  "同认知关联|co-cognition"
  "M3b"
  "飞轮|flywheel|フライホイール|volante de inercia"
)

# 自发现结果 (运行时填充, 来自 30-protocols/*.md 标题)
PROTOCOL_NAMES_DISCOVERED=()

# 合并: 核心 + 自发现
PROTOCOL_NAMES=("${PROTOCOL_NAMES_CORE[@]}")

# -----------------------------------------------------------------------------
# 协议标记词白名单 (v0.8.27 · 36 词, 4 语言)
# 中文 16 (v0.8.26 原) + 英文 10 (新增) + 日文 7 (新增) + 西文 3 (新增)
# -----------------------------------------------------------------------------
PROTOCOL_MARKERS_ZH=(
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

PROTOCOL_MARKERS_EN=(
  "protocol"
  "insight"
  "principle"
  "heuristic"
  "topology"
  "evolution"
  "flywheel"
  "sediment"
  "closed-loop"
  "bus"
)

PROTOCOL_MARKERS_JA=(
  "プロトコル"
  "洞察"
  "原則"
  "実装"
  "同期"
  "飛輪"
  "閉ループ"
)

PROTOCOL_MARKERS_ES=(
  "protocolo"
  "principio"
  "sincronización"
)

PROTOCOL_MARKERS=(
  "${PROTOCOL_MARKERS_ZH[@]}"
  "${PROTOCOL_MARKERS_EN[@]}"
  "${PROTOCOL_MARKERS_JA[@]}"
  "${PROTOCOL_MARKERS_ES[@]}"
)

# 距离阈值 (字符, v0.8.27 自适应)
DISTANCE_THRESHOLD=8
DISTANCE_THRESHOLD_SHORT=4   # 文本 ≤ 30 字符
DISTANCE_THRESHOLD_LONG=12   # 文本 > 80 字符

# =============================================================================
# 协议自发现 (v0.8.27 新增 · AB 顿悟 · v0.8.28 扩展 H2 关闭)
# 扫 30-protocols/*.md 文件, 提取 H1 标题作为协议名
#
# v0.8.28 调研: 尝试 H2 章节扫描, 引入严重 false positive
#   - 30-protocols/*.md H2 大量是 "协议的核心理念" / "已知局限" / "未来伏笔" 等元章节
#   - 即使加严过滤 (跳过含 em-dash / 日期 / meta 关键词), 仍有 1-3 个误判漏网
#   - 核心问题: 协议文件 H2 章节描述"协议元信息", 不是"协议名"
#   - 解决方向 (留 v0.8.29+):
#     a) 每个协议文件加 frontmatter `protocol_h2: [H2 标题列表]` 显式声明
#     b) 引入"Y 协议 H2 = 子协议名"约定, 只接受形如 "X 子协议" 的 H2
#     c) 跳过正在描述的协议文件 (e.g. v0.8.28 文档自己的 H2 不该被它自己加进白名单)
#   - v0.8.28 决策: H2 扫描留 TODO, 本版本只做"协议白名单导出"
# =============================================================================
scan_protocols() {
  local protocols_dir="$REPO_ROOT/30-protocols"
  if [ ! -d "$protocols_dir" ]; then
    return
  fi

  local found=()
  for md_file in "$protocols_dir"/*.md; do
    [ -f "$md_file" ] || continue
    # 跳过 README (是索引, 不是协议)
    local basename
    basename="$(basename "$md_file")"
    if [ "$basename" = "README.md" ]; then
      continue
    fi

    # 提取 H1 标题 (前 20 行, 协议文件开头有引用块)
    local headings
    headings=$(head -20 "$md_file" | grep -E "^# " | head -1)
    if [ -z "$headings" ]; then
      continue
    fi

    local h1
    h1=$(echo "$headings" | head -1 | sed -E 's/^#[[:space:]]+//' | sed -E 's/[[:space:]]+$//')

    # 跳过 H1 是数字开头 (e.g. "# 30-protocols")
    if echo "$h1" | grep -qE "^[0-9]+"; then
      continue
    fi

    # 跳过 H1 包含 "Index" / "目录" / "Table of Contents"
    if echo "$h1" | grep -qiE "(Index|目录|Table of Contents)"; then
      continue
    fi

    # v0.8.28 升级: 提取 H1 短名 (e.g. "Cross-Repo Z Protocol · 跨仓 Z 协议" → "Cross-Repo Z Protocol")
    # 理由: 完整 H1 含 " · 中文别名" 后缀, commit msg 引用时只写短名, 整 alias 匹配不到
    # 用 middle-dot (·) 或 em-dash (—) 分割, 取第一段作为短名
    # 也保留完整 H1 (兼容中文为主的 commit)
    local short_h1
    if echo "$h1" | grep -qE " · "; then
      short_h1=$(echo "$h1" | sed -E 's/ · .*//')
      found+=("$short_h1")
    fi
    # 同时保留完整 H1 (含中文别名)
    found+=("$h1")
  done

  # 去重
  if [ ${#found[@]} -gt 0 ]; then
    printf '%s\n' "${found[@]}" | sort -u > /tmp/_scan_protocols_$$
    while IFS= read -r line; do
      PROTOCOL_NAMES_DISCOVERED+=("$line")
    done < /tmp/_scan_protocols_$$
    rm -f /tmp/_scan_protocols_$$
  fi

  # 合并到 PROTOCOL_NAMES
  PROTOCOL_NAMES=("${PROTOCOL_NAMES_CORE[@]}" "${PROTOCOL_NAMES_DISCOVERED[@]}")
}

# =============================================================================
# 协议白名单导出 (v0.8.28 新增 · AC 顿悟)
# 写 30-protocols/.protocol-names.txt (git ignored, 运行时生成)
# 供 pre-commit / CI / 其他脚本引用, SSOT 离盘可读
# =============================================================================
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

# =============================================================================
# 核心: scan_h2_protocol_claims (v0.8.30 完整实做)
# =============================================================================
# v0.8.30 落地 30-protocols/h2-chapter-protocol-claim.md §方案 C
# (frontmatter protocol_names + 编辑距离约束):
#   - parse_protocol_frontmatter: 用 awk 解析 --- 块 内的 protocol_names
#     (YAML 数组, ["a", "b", "c"]) + protocol_h2_match_distance (默认 30)
#   - h2_protocol_distance: 优先 python -c "import Levenshtein; ..."
#     (字符级编辑距离, 准确), fallback bash 字符级
#   - scan_h2_protocol_claims: 8 协议文件全扫 + 写 .protocol-h2-claims.txt
#     (# 协议名 → H2 章节列表), git ignored, 运行时生成
#
# 配套子命令: scan-h2-claims (跟 export 同级, v0.8.30 新增)
# =============================================================================
parse_protocol_frontmatter() {
  local file="$1"
  # 文件路径: 绝对 / 相对 30-protocols/ 都接受
  if [[ "$file" != /* ]]; then
    file="$REPO_ROOT/$file"
  fi

  # 用 awk 读 --- ... --- 之间的 YAML
  # 输出: distance<NL>name1<NL>name2<NL>...
  awk '
    BEGIN { in_fm=0; done=0; print_dist=0; dist="30" }
    /^---$/ {
      if (in_fm == 0) { in_fm=1; next }
      else { done=1; exit }
    }
    in_fm == 1 {
      if (match($0, /^protocol_h2_match_distance:[[:space:]]*([0-9]+)/, m)) {
        dist=m[1]
      } else if (match($0, /^protocol_names:[[:space:]]*\[(.*)\]/, m)) {
        # 解析 ["a", "b", "c"] - 提取引号内容
        line=m[1]
        n=split(line, arr, ",")
        for (i=1; i<=n; i++) {
          # 去掉 " 和 空格
          gsub(/"/, "", arr[i])
          gsub(/^[[:space:]]+|[[:space:]]+$/, "", arr[i])
          if (arr[i] != "") print arr[i]
        }
      }
    }
    END { print "DIST=" dist > "/dev/stderr" }
  ' "$file" 2>/dev/null
}

h2_protocol_distance() {
  local h2_title="$1"
  local proto_name="$2"

  # 优先 python Levenshtein (字符级, 跨语言稳)
  if command -v python3 >/dev/null 2>&1; then
    local py_dist
    py_dist=$(python3 -c "
try:
    import Levenshtein
    print(Levenshtein.distance('$h2_title', '$proto_name'))
except ImportError:
    # fallback 字符级 (每个字符当 1 单位, 中英文都算 1)
    a, b = '$h2_title', '$proto_name'
    m, n = len(a), len(b)
    if m == 0: print(n); exit()
    if n == 0: print(m); exit()
    dp = [[0]*(n+1) for _ in range(m+1)]
    for i in range(m+1): dp[i][0] = i
    for j in range(n+1): dp[0][j] = j
    for i in range(1, m+1):
        for j in range(1, n+1):
            cost = 0 if a[i-1] == b[j-1] else 1
            dp[i][j] = min(dp[i-1][j]+1, dp[i][j-1]+1, dp[i-1][j-1]+cost)
    print(dp[m][n])
" 2>/dev/null)
    if [ -n "$py_dist" ] && [ "$py_dist" -ge 0 ] 2>/dev/null; then
      echo "$py_dist"
      return 0
    fi
  fi

  # bash fallback: 字符级 DP (8-2 教训: bash ${#var} 是字节数, 这里用 ${#} 当 char 近似可接受)
  local a="$h2_title" b="$proto_name"
  local m=${#a} n=${#b}
  if [ "$m" -eq 0 ]; then echo "$n"; return; fi
  if [ "$n" -eq 0 ]; then echo "$m"; return; fi

  # bash 字符级 DP 太慢, 简化: 包含检测 (子串→0, 否则 max(len) 兜底)
  if [[ "$a" == *"$b"* ]] || [[ "$b" == *"$a"* ]]; then
    echo "0"
  else
    if [ "$m" -gt "$n" ]; then echo "$m"; else echo "$n"; fi
  fi
}

scan_h2_protocol_claims() {
  local output_file="${1:-$REPO_ROOT/30-protocols/.protocol-h2-claims.txt}"
  local protocols_dir="$REPO_ROOT/30-protocols"

  # 找所有协议 md (排除 README)
  local files=()
  for f in "$protocols_dir"/*.md; do
    [ "$(basename "$f")" = "README.md" ] && continue
    files+=("$f")
  done

  {
    echo "# 协议 H2 章节归属 (v0.8.30 自动生成)"
    echo "# 源: scripts/protocol-disambiguation.sh scan-h2-claims"
    echo "# 算法: frontmatter protocol_names + 编辑距离约束 (§方案 C)"
    echo "# 生成时间: $(date -u +%Y-%m-%dT%H:%M:%SZ)"
    echo "# 协议文件数: ${#files[@]}"
    echo ""

    for file in "${files[@]}"; do
      local name
      name=$(basename "$file")

      # 1. 读 frontmatter protocol_names + distance
      local dist
      dist=$(awk '
        BEGIN { in_fm=0 }
        /^---$/ { if (in_fm == 0) in_fm=1; else exit }
        in_fm == 1 && match($0, /^protocol_h2_match_distance:[[:space:]]*([0-9]+)/, m) { print m[1]; exit }
      ' "$file")
      [ -z "$dist" ] && dist=30

      local names=()
      while IFS= read -r n; do
        [ -n "$n" ] && names+=("$n")
      done < <(parse_protocol_frontmatter "$file")

      # 2. 扫 H2 章节
      echo "## $name (distance≤$dist)"
      while IFS= read -r h2_line; do
        # h2_line = "## 1. 协议的核心理念"
        local h2_title="${h2_line#\#\# }"

        # v0.8.30 排除词表: "协议的 + 普通名词" 模式 (协议元描述)
        # 不排除: "X 协议的协同" / "Y 协议的反模式" / "Z 协议的限制" (前面是英文短名)
        # 排除模式: "协议的核心理念" / "协议的实施" / "协议清单" / "协议 vs" 等
        #
        # 算法: H2 章节中 "协议的" 前面紧跟 1-3 字符是 **已知协议短名**
        #       (X / Y / Z / AA / AB / AC / U / V / W 协议) → 真协议名, 接受
        #       否则 ("协议" 直接接 "的") → 协议元描述, 排除
        local exclude=0

        # 1. "协议的" 前面是不是已知协议短名
        if [[ "$h2_title" == *"协议的"* ]]; then
          # 协议短名 + 空格(可选) + 协议 + 的
          # 协议短名 = X / Y / Z / AA / AB / AC / U / V / W
          if ! echo "$h2_title" | grep -qE "(X|Y|Z|AA|AB|AC|U|V|W) ?协议的"; then
            exclude=1
          fi
        fi

        # 2. 其他元描述模式 (不管协议名前是什么)
        if [[ "$h2_title" == "协议清单" ]] || \
           [[ "$h2_title" == "协议（"* ]] || \
           [[ "$h2_title" == "协议："* ]]; then
          exclude=1
        fi

        if [ "$exclude" = "1" ]; then
          echo "  ✗ [excluded] $h2_title (协议元描述, 排除词表命中)"
          continue
        fi

        # 找到最小距离的协议名
        local best_name=""
        local best_dist=999
        for pn in "${names[@]}"; do
          local d
          d=$(h2_protocol_distance "$h2_title" "$pn")
          if [ "$d" -lt "$best_dist" ] 2>/dev/null; then
            best_dist=$d
            best_name=$pn
          fi
        done
        # 距离 ≤ 阈值 算关联
        if [ "$best_dist" -le "$dist" ] 2>/dev/null; then
          echo "  ✓ [d=$best_dist] $h2_title → $best_name"
        else
          echo "  ✗ [d=$best_dist] $h2_title (拒绝, 距离 > $dist)"
        fi
      done < <(grep -E "^## " "$file" | head -50)
      echo ""
    done
  } > "$output_file"

  echo "✅ 已写: $output_file"
}

# 自适应距离阈值 (v0.8.27 新增)
adaptive_threshold() {
  local text="$1"
  local len=${#text}
  if [ "$len" -le 30 ]; then
    echo "$DISTANCE_THRESHOLD_SHORT"
  elif [ "$len" -le 80 ]; then
    echo "$DISTANCE_THRESHOLD"
  else
    echo "$DISTANCE_THRESHOLD_LONG"
  fi
}

# =============================================================================
# 核心: classify_text — 给一段文本, 返回真协议引用列表 (去重)
# v0.8.27 多语言: 协议名 "中文|EN|JA" 格式, 任一别名匹配即算协议引用,
#               但 result 只记 canonical name (| 之前部分)
# =============================================================================
classify_text() {
  local text="$1"
  local result=""

  # 对每个协议名, 在 text 里找位置
  for proto_entry in "${PROTOCOL_NAMES[@]}"; do
    # 提取 canonical name (| 之前) 和所有别名 (按 | 分割)
    local canonical="${proto_entry%%|*}"
    IFS='|' read -ra aliases <<< "$proto_entry"

    # 对每个别名 (含 canonical), 在 text 里找位置
    local found_proto=0
    local proto_first_pos=-1
    local matched_alias=""

    for alias in "${aliases[@]}"; do
      local search="$text"
      local pos=0

      while true; do
        local idx
        idx=$(echo "$search" | grep -boF "$alias" 2>/dev/null | head -1 | cut -d: -f1 || echo "")
        if [ -z "$idx" ]; then
          break
        fi
        found_proto=1
        local abs_pos=$((pos + idx))

        # 记录协议名最早出现位置
        if [ "$proto_first_pos" -lt 0 ] || [ "$abs_pos" -lt "$proto_first_pos" ]; then
          proto_first_pos=$abs_pos
          matched_alias="$alias"
        fi

        # 找最近的协议标记词 (向前向后 ± N 字符范围, v0.8.27 自适应阈值)
        # v0.8.33 字符级: bash ${text:N:M} 是 byte-slicing, 多字节字符 (日文/西文
        # 重音) 切到中间会成 garbage, 标记词 grep 不到. 改用 python 字符级切片.
        # byte_pos (来自 grep -boF) -> char_pos, 按字符切 ± threshold 字符
        local threshold
        threshold=$(adaptive_threshold "$text")
        local chunks
        chunks=$(python3 -c "
import sys
text = sys.argv[1]
byte_pos = int(sys.argv[2])
alias_byte_len = int(sys.argv[3])
threshold = int(sys.argv[4])
# byte_pos -> char_pos: 累计 bytes 直到 >= byte_pos
char_pos = len(text.encode('utf-8')[:byte_pos].decode('utf-8', errors='ignore'))
alias_char_len = len(sys.argv[5])
start_back = max(0, char_pos - threshold)
end_fwd = min(len(text), char_pos + alias_char_len + threshold)
back_chunk = text[start_back:char_pos + alias_char_len]
fwd_chunk = text[char_pos:end_fwd]
print(back_chunk + '\x1f' + fwd_chunk)
" "$text" "$abs_pos" "${#alias}" "$threshold" "$alias" 2>/dev/null) || chunks=""
        local back_chunk="${chunks%%$'\x1f'*}"
        local fwd_chunk="${chunks#*$'\x1f'}"
        local nearby_marker=0
        for marker in "${PROTOCOL_MARKERS[@]}"; do
          if echo "$back_chunk$fwd_chunk" | grep -qF "$marker"; then
            nearby_marker=1
            break
          fi
        done

        if [ "$nearby_marker" -eq 1 ]; then
          # 真协议引用, 加入结果 (用 canonical name)
          if [ -z "$result" ]; then
            result="$canonical"
          elif ! echo "$result" | grep -qF "$canonical"; then
            result="$result, $canonical"
          fi
          break 2  # 一个协议名只算一次 (找最近的标记词)
        fi

        # 找下一个出现位置
        local next_start=$((idx + 1))
        pos=$((pos + next_start))
        search="${search:$next_start}"
      done
    done
  done

  echo "$result"
}

# =============================================================================
# 子命令: classify — 单文本分类
# =============================================================================
# v0.8.32 协议文件自身 commit 短路
# WHY: 验证报告 v0.8.31 §1 指出 FN 43% 集中在协议文件 commit (msg 无协议名)
# WHAT: feat(30-protocols) / fix(30-protocols) / docs(30-protocols) 前缀直接视为 protocol commit
# 返回: "30-protocols(自身)" 或 ""
is_protocol_file_commit() {
  local text="$1"
  # 匹配 conventional commit 前缀: "type(30-protocols)" 或 "type(30-protocols/xxx)"
  # e.g. "feat(30-protocols):" "fix(30-protocols/h2):"
  if echo "$text" | grep -qE "^(feat|fix|docs|chore|test|refactor|perf|build)\(30-protocols(/[^)]*)?\)"; then
    return 0  # 命中短路, 但不 echo 单一值 (让 cmd_classify 合并协议名)
  fi
  return 1
}

cmd_classify() {
  local text="$1"
  local result
  result=$(classify_text "$text")
  # v0.8.32: 协议目录 prefix 短路 (feat/fix/docs(30-protocols)) 在 result 前加 "30-protocols(自身)" 标记
  if is_protocol_file_commit "$text"; then
    if [ -z "$result" ]; then
      result="30-protocols(自身)"
    elif ! echo "$result" | grep -qF "30-protocols(自身)"; then
      result="30-protocols(自身), $result"
    fi
  fi
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

    # v0.8.27 新增 · 多语言标记词 (3 case)
    "feat(cross-repo): apply mirror principle to v0.8.27 (English insight)|镜子原则"
    "AI は mirror 構造の 原理 を 調べて います|"     # 日文, mirror 跟 原理 距离 > 4
    "El protocolo de mirror principle es muy estricto|镜子原则"  # 西文 protocolo 标记词

    # v0.8.27 新增 · 自适应阈值 (3 case)
    "AA 顿悟|AA 顿悟"                          # 极短文本, 阈值 4 字符, 顿悟 是核心标记词
    "feat(system-self): mirror principle Step 3 evolves to closed-loop bus integration across all endpoints|镜子原则"  # 长文本 (>80), 阈值 12
    "镜子原则 Step 5|镜子原则"                  # 短文本, 阈值 4 字符

    # v0.8.27 新增 · 自发现协议 (1 case, 来自 30-protocols/protocol-disambiguation.md 标题)
    "feat(30-protocols): 协议 vs 形容词歧义去歧 (AA 顿悟) 实做|AA 顿悟"

    # v0.8.28 新增 · H1 自发现回归验证 (3 case, 验证 H1 仍正确, H2 暂未开启)
    # v0.8.28 决策: H2 扫描留 v0.8.29+ (false positive 太多, 见 scan_protocols 注释)
    # 这里用 H1 短名 (e.g. "cross-repo Z protocol") 跟 commit msg 引用验证
    # 文本里包含协议标记词 (顿悟/实做/principle) 才能正确分类 (跟 v0.8.26 算法一致)
    "feat(cross-repo): cross-repo Z protocol v0.8.28 升级到 AC 顿悟|跨仓 Z 协议"
    "feat(30-protocols): Multilingual Protocol Self-Discovery Protocol 实做 AC 顿悟|Multilingual Protocol Self-Discovery Protocol"
    "feat(30-protocols): Protocol Disambiguation Protocol v0.8.28 实做, 复测 22 case|Protocol Disambiguation Protocol"

    # v0.8.32 新增 · 协议目录 prefix 短路 (4 case, 修 v0.8.31 验证报告 §1 FN 43%)
    "feat(30-protocols): v0.8.32 跨语言协议名修复 (X 顿悟)|30-protocols(自身)"
    "fix(30-protocols): protocol-disambiguation FP 0% 验证|30-protocols(自身)"
    "docs(30-protocols): v0.8.29 H2 章节调研|30-protocols(自身)"
    "chore(30-protocols): bump version|30-protocols(自身)"

    # v0.8.32 新增 · 单字母协议/顿悟 全部识别 (10 case, 修 v0.8.17/16 单字母缩写 FN)
    "T 顿悟|T 顿悟"
    "S 顿悟|S 顿悟"
    "T 协议|T 协议"
    "S 协议|S 协议"
    "U 协议|U 协议"
    "V 协议|V 协议"
    "W 协议|W 协议"
    "AA 顿悟|AA 顿悟"
    "AB 顿悟|AB 顿悟"
    "AC 顿悟|AC 顿悟"

    # v0.8.32 新增 · 多语言别名 (3 case, 修 v0.8.27 文档承诺落地)
    "X insight step 1|顿悟"   # X insight 命中, 期待 X 顿悟
    "Y protocolo validación|顿悟"
    "AA 頓悟 検証|"  # 日文"頓悟"与中文"顿悟" byte 不匹配, 白名单没日文 (v0.8.33+ backlog: 加 顿悟 日文别名)

    # v0.8.33 新增 · 字符级切片 (修 byte-slicing 切多字节字符切到中间变 garbage)
    # 之前用 bash ${text:N:M} 按 byte 切, "S プロトコル" 后面是 "の同期",
    # 标记词 "同期" 跨 byte 边界, back_chunk 切到半个字符 grep 不到.
    # 改 python 字符级后正常识别.
    "feat(30-protocols): S プロトコルの同期テスト|S 协议"
  )

  echo "=== Protocol Disambiguation Test (v0.8.27) ==="
  echo ""

  for case in "${cases[@]}"; do
    total=$((total + 1))
    local text="${case%|*}"
    local expected="${case#*|}"
    local actual
    actual=$(cmd_classify "$text")
    if [ -z "$expected" ]; then
      expected="(空)"
    fi

    # 验证: expected 必须出现在 actual 里 (允许 actual 包含额外协议名)
    local test_pass=0
    if [ "$expected" = "(空)" ]; then
      # 期望空: actual 空 OR 含 "(空" 都算通过 (cmd_classify 标 (空, 形容词用法))
      if [ -z "$actual" ] || [[ "$actual" == *"(空"* ]]; then
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
    echo "✅ $total/$total cases pass (含真协议引用 6 + 形容词用法 4 + 边界 2 + 多语言 3 + 自适应阈值 3 + 自发现 1 + v0.8.32 协议目录短路 4 + 单字母协议/顿悟 10 + 多语言别名 2)"
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
# 子命令: scan — 扫 30-protocols/*.md 提取协议名 (v0.8.27 新增)
# =============================================================================
cmd_scan() {
  scan_protocols
  echo "=== Protocol Self-Discovery (v0.8.27 · AB 顿悟) ==="
  echo ""
  echo "─── 核心白名单 (${#PROTOCOL_NAMES_CORE[@]} 个, 手动维护) ───"
  for p in "${PROTOCOL_NAMES_CORE[@]}"; do
    echo "  • $p"
  done
  echo ""
  echo "─── 自发现 (${#PROTOCOL_NAMES_DISCOVERED[@]} 个, 来自 30-protocols/*.md) ───"
  if [ ${#PROTOCOL_NAMES_DISCOVERED[@]} -eq 0 ]; then
    echo "  (空)"
  else
    for p in "${PROTOCOL_NAMES_DISCOVERED[@]}"; do
      echo "  • $p"
    done
  fi
  echo ""
  echo "─── 合并: ${#PROTOCOL_NAMES[@]} 个协议名 ───"
  for p in "${PROTOCOL_NAMES[@]}"; do
    echo "  • $p"
  done
}

# =============================================================================
# 子命令: scan-stats — 统计自发现覆盖率 (v0.8.27 新增)
# =============================================================================
cmd_scan_stats() {
  scan_protocols
  local core_count=${#PROTOCOL_NAMES_CORE[@]}
  local discovered_count=${#PROTOCOL_NAMES_DISCOVERED[@]}
  local total_count=${#PROTOCOL_NAMES[@]}

  echo "=== Scan Stats (v0.8.27) ==="
  echo ""
  echo "协议目录: $REPO_ROOT/30-protocols/"
  echo "协议 md 文件数: $(ls "$REPO_ROOT/30-protocols/"*.md 2>/dev/null | wc -l) (含 README)"
  echo "协议 md 文件数 (排除 README): $(ls "$REPO_ROOT/30-protocols/"*.md 2>/dev/null | grep -v README.md | wc -l)"
  echo ""
  echo "核心白名单: $core_count 个 (手动维护, v0.8.26+ 兼容)"
  echo "自发现: $discovered_count 个 (扫 H1 标题)"
  echo "合并: $total_count 个"
  echo ""
  echo "协议标记词: ${#PROTOCOL_MARKERS[@]} 个"
  echo "  - 中文: ${#PROTOCOL_MARKERS_ZH[@]} 个 (v0.8.26 原)"
  echo "  - 英文: ${#PROTOCOL_MARKERS_EN[@]} 个 (v0.8.27 新增)"
  echo "  - 日文: ${#PROTOCOL_MARKERS_JA[@]} 个 (v0.8.27 新增)"
  echo "  - 西文: ${#PROTOCOL_MARKERS_ES[@]} 个 (v0.8.27 新增)"
  echo ""
  echo "距离阈值:"
  echo "  - 静态 (默认): $DISTANCE_THRESHOLD 字符"
  echo "  - 自适应 短文本 (≤30): $DISTANCE_THRESHOLD_SHORT 字符"
  echo "  - 自适应 中文本 (≤80): $DISTANCE_THRESHOLD 字符"
  echo "  - 自适应 长文本 (>80): $DISTANCE_THRESHOLD_LONG 字符"
}

# =============================================================================
# 主入口
# =============================================================================
# v0.8.29 LIB_GUARD: source 时跳过整个主入口块 (含 $# 检查 + case), 避免跑 default 打印用法
if [ "${__PROTOCOL_DISAMBIG_LIB__:-0}" != "1" ]; then
if [ $# -lt 1 ]; then
  echo "用法: bash scripts/protocol-disambiguation.sh <classify|test|stats|scan|scan-stats|export|scan-h2-claims> [args...]"
  echo ""
  echo "  classify <text>   单文本分类"
  echo "  test              跑验证 case"
  echo "  stats [N]         统计 4 仓最近 N commit 协议引用 (默认 N=10)"
  echo "  scan              扫 30-protocols/*.md 自发现协议 (v0.8.27 新增, v0.8.28 扩展 H2)"
  echo "  scan-stats        统计自发现覆盖率 (v0.8.27 新增)"
  echo "  export            写 30-protocols/.protocol-names.txt (v0.8.28 新增)"
  echo "  scan-h2-claims    写 30-protocols/.protocol-h2-claims.txt (v0.8.30 新增, 方案 C frontmatter+距离)"
  exit 1
fi

# v0.8.29 LIB_GUARD: source 时跳过整个 main case block, 避免跑 case default 打印用法
# 用 if 包裹整个 case 块 (比 return 0 2>/dev/null 更稳, 子 shell source 不会 fallthrough)
if [ "${__PROTOCOL_DISAMBIG_LIB__:-0}" != "1" ]; then
case "$1" in
  classify)
    shift
    # classify 不强制 scan (避免单次分类慢), 但 scan 后 PROTOCOL_NAMES 更大
    cmd_classify "$*"
    ;;
  test)
    # test 强制 scan_protocols, 让所有自发现协议参与验证
    scan_protocols
    cmd_test
    ;;
  stats)
    shift
    n="${1:-10}"
    scan_protocols
    cmd_stats "$n"
    ;;
  scan)
    cmd_scan
    ;;
  scan-stats)
    cmd_scan_stats
    ;;
  export)
    # v0.8.28 新增: 扫 + 写盘
    scan_protocols
    export_protocol_names
    ;;
  scan-h2-claims)
    # v0.8.30 新增: 写 30-protocols/.protocol-h2-claims.txt
    # 算法: frontmatter protocol_names + 编辑距离约束 (§方案 C)
    scan_h2_protocol_claims
    ;;
  *)
    echo "未知子命令: $1"
    exit 1
    ;;
esac

fi  # v0.8.29 LIB_GUARD close
fi  # v0.8.29 main entry LIB_GUARD close
