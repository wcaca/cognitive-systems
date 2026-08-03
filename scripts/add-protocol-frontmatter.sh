#!/bin/bash
# v0.8.30: 给 8 协议文件加 frontmatter (protocol_names + protocol_h2_match_distance)
# 调研依据: 30-protocols/h2-chapter-protocol-claim.md §方案 C
#
# 8 文件清单 (H1 → protocol_names):
#   cross-repo-z-protocol.md:        跨仓 Z 协议 | Cross-Repo Z Protocol | Z 协议
#   evolution-depth-protocol.md:     Evolution 深度协议 | Evolution Depth Protocol | Y 协议
#   evolution-sync-protocol.md:      Evolution-Sync Protocol | 元方法论同步协议
#   export-protocol-names.md:        Export Protocol Names Protocol | 协议白名单导出协议 | AC 协议
#   fill-order-coordination.md:      Fill-Order Coordination Protocol | 填实顺序协调协议
#   insight-extraction-protocol.md:  Insight Extraction Protocol | 顿悟提取协议
#   multilingual-protocol-self-discovery.md: Multilingual Protocol Self-Discovery Protocol | 多语言协议自发现协议 | AB 协议
#   protocol-disambiguation.md:      Protocol Disambiguation Protocol | 协议 vs 形容词去歧协议 | AA 协议
#   h2-chapter-protocol-claim.md:    H2 Chapter Protocol Claim Protocol | H2 章节协议归属协议

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
PROTOCOLS_DIR="$REPO_ROOT/30-protocols"

# 距离阈值默认 30 (跟 v0.8.29 调研建议一致)
DEFAULT_DISTANCE=30

# 8 文件的 protocol_names 映射 (H1 短名 / 长名 / 别名)
declare -A PROTOCOL_NAMES=(
  ["cross-repo-z-protocol.md"]="跨仓 Z 协议|Cross-Repo Z Protocol|Z 协议"
  ["evolution-depth-protocol.md"]="Evolution 深度协议|Evolution Depth Protocol|Y 协议"
  ["evolution-sync-protocol.md"]="Evolution-Sync Protocol|元方法论同步协议"
  ["export-protocol-names.md"]="Export Protocol Names Protocol|协议白名单导出协议|AC 协议"
  ["fill-order-coordination.md"]="Fill-Order Coordination Protocol|填实顺序协调协议"
  ["insight-extraction-protocol.md"]="Insight Extraction Protocol|顿悟提取协议"
  ["multilingual-protocol-self-discovery.md"]="Multilingual Protocol Self-Discovery Protocol|多语言协议自发现协议|AB 协议"
  ["protocol-disambiguation.md"]="Protocol Disambiguation Protocol|协议 vs 形容词去歧协议|AA 协议"
  ["h2-chapter-protocol-claim.md"]="H2 Chapter Protocol Claim Protocol|H2 章节协议归属协议"
)

# 注入 frontmatter 到指定文件 (在 H1 行前插入)
inject_frontmatter() {
  local file="$1"
  local protocol_names="$2"
  local distance="${3:-$DEFAULT_DISTANCE}"
  local full_path="$PROTOCOLS_DIR/$file"

  if [ ! -f "$full_path" ]; then
    echo "❌ 文件不存在: $file" >&2
    return 1
  fi

  # 检查是否已经有 frontmatter (--- 开头)
  if head -1 "$full_path" | grep -q "^---$"; then
    echo "⏭️  已有 frontmatter, 跳过: $file"
    return 0
  fi

  # 生成 frontmatter (YAML 数组格式: ["a", "b", "c"])
  # 切分 | (避免 xargs -n1 按字符切分)
  local names_yaml
  names_yaml=$(echo "$protocol_names" | tr '|' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | awk '{printf "\"" $0 "\","}' | sed 's/,$//')

  # 在 H1 前插入
  local tmp
  tmp=$(mktemp)
  cat > "$tmp" <<EOF
---
protocol_names: [${names_yaml}]
protocol_h2_match_distance: ${distance}
---

EOF
  cat "$full_path" >> "$tmp"
  mv "$tmp" "$full_path"
  echo "✅ 已注入 frontmatter: $file"
}

# 主流程
main() {
  echo "=== v0.8.30 · 给 8 协议文件加 frontmatter ==="
  echo ""
  for file in "${!PROTOCOL_NAMES[@]}"; do
    inject_frontmatter "$file" "${PROTOCOL_NAMES[$file]}"
  done
  echo ""
  echo "=== 完成 ==="
  echo "跑验证: bash scripts/protocol-disambiguation.sh scan-h2-claims  (v0.8.30 留)"
}

main "$@"
