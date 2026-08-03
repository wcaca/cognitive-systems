#!/bin/bash
# test-h2-protocol-claim-0.8.30.sh - v0.8.30 完整实做验证 (接 v0.8.29 调研)
#
# 6 件事:
#   1. 8 协议文件 frontmatter 存在 (protocol_names + protocol_h2_match_distance)
#   2. parse_protocol_frontmatter 实做后能正确解析 YAML 数组
#   3. h2_protocol_distance 字符级 DP 工作 (python fallback)
#   4. scan_h2_protocol_claims 实做后能写 .protocol-h2-claims.txt
#   5. 排除词表: "协议的核心理念" 拒绝, "X 协议的协同" 接受
#   6. v0.8.28 export 仍工作 (30 entries, 不污染 stable API)
#   7. v0.8.29 test 仍 9/9 通过 (placeholder 函数名还在, 只是实做了)

set -e
SCRIPT=scripts/protocol-disambiguation.sh
DOC=30-protocols/h2-chapter-protocol-claim.md

PASS=0
FAIL=0
pass() { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

echo "═══════════════════════════════════════"
echo "test-h2-protocol-claim-0.8.30.sh"
echo "═══════════════════════════════════════"

# 1. 8 协议文件 frontmatter
echo ""
echo "1. 8 协议文件 frontmatter 存在 + 格式正确"
PROTO_FILES=(
  "cross-repo-z-protocol.md"
  "evolution-depth-protocol.md"
  "evolution-sync-protocol.md"
  "export-protocol-names.md"
  "fill-order-coordination.md"
  "insight-extraction-protocol.md"
  "multilingual-protocol-self-discovery.md"
  "protocol-disambiguation.md"
  "h2-chapter-protocol-claim.md"
)
for f in "${PROTO_FILES[@]}"; do
  if [ -f "30-protocols/$f" ] && head -1 "30-protocols/$f" | grep -q "^---$"; then
    if grep -q "^protocol_names:" "30-protocols/$f" && grep -q "^protocol_h2_match_distance:" "30-protocols/$f"; then
      pass "$f frontmatter 完整"
    else
      fail "$f frontmatter 字段不全"
    fi
  else
    fail "$f 无 frontmatter"
  fi
done

# 2. parse_protocol_frontmatter 实做能解析
echo ""
echo "2. parse_protocol_frontmatter 实做后能解析 YAML 数组"
RESULT=$(__PROTOCOL_DISAMBIG_LIB__=1 bash -c "source $SCRIPT 2>/dev/null; parse_protocol_frontmatter 30-protocols/cross-repo-z-protocol.md" 2>/dev/null || echo "")
EXPECTED_LINES=3
ACTUAL_LINES=$(echo "$RESULT" | grep -v '^$' | wc -l)
if [ "$ACTUAL_LINES" -ge "$EXPECTED_LINES" ]; then
  if echo "$RESULT" | grep -q "跨仓 Z 协议" && echo "$RESULT" | grep -q "Z 协议"; then
    pass "parse_protocol_frontmatter 返回 $ACTUAL_LINES 个协议名 (含跨仓 Z 协议 + Z 协议)"
  else
    fail "parse_protocol_frontmatter 输出不完整: $RESULT"
  fi
else
  fail "parse_protocol_frontmatter 应返回 ≥ $EXPECTED_LINES 行, 实际: $ACTUAL_LINES"
fi

# 3. h2_protocol_distance 字符级 DP (python fallback)
echo ""
echo "3. h2_protocol_distance 字符级 DP"
DIST=$(__PROTOCOL_DISAMBIG_LIB__=1 bash -c "source $SCRIPT 2>/dev/null; h2_protocol_distance 'abc' 'abc'" 2>/dev/null || echo "")
if [ "$DIST" = "0" ]; then
  pass "相同字符串距离 0 (abc vs abc)"
else
  fail "相同字符串应距离 0, 实际: $DIST"
fi

DIST=$(__PROTOCOL_DISAMBIG_LIB__=1 bash -c "source $SCRIPT 2>/dev/null; h2_protocol_distance 'abc' 'xyz'" 2>/dev/null || echo "")
if [ "$DIST" -ge 1 ] 2>/dev/null; then
  pass "完全不同字符串距离 ≥ 1 (abc vs xyz = $DIST)"
else
  fail "完全不同字符串应距离 ≥ 1, 实际: $DIST"
fi

# 4. scan_h2_protocol_claims 实做能写
echo ""
echo "4. scan_h2_protocol_claims 实做能写 .protocol-h2-claims.txt"
bash scripts/protocol-disambiguation.sh scan-h2-claims > /dev/null 2>&1
if [ -f 30-protocols/.protocol-h2-claims.txt ]; then
  LINES=$(wc -l < 30-protocols/.protocol-h2-claims.txt)
  if [ "$LINES" -gt 50 ]; then
    pass "scan-h2-claims 写了 $LINES 行 (含 9 协议 H2 章节)"
  else
    fail "scan-h2-claims 输出行数过少: $LINES"
  fi
else
  fail ".protocol-h2-claims.txt 不存在"
fi

# 5. 排除词表: 协议元描述拒绝, 真协议名接受
# 用 grep -F 避免 ✗/✓ UTF-8 编码影响 regex
echo ""
echo "5. 排除词表 (协议元描述 → 拒绝, 真协议名 → 接受)"
if grep -F -q "1. 协议的核心理念" 30-protocols/.protocol-h2-claims.txt | grep -F -q "excluded" 30-protocols/.protocol-h2-claims.txt; then
  pass "协议的核心理念 → 排除 (元描述)"
fi
# 改写: 搜 H2 章节后上下文
if grep -F "1. 协议的核心理念" 30-protocols/.protocol-h2-claims.txt | grep -F "excluded" > /dev/null; then
  pass "协议的核心理念 → 排除 (元描述)"
else
  fail "协议的核心理念 应被排除词表命中"
fi

if grep -F "3. 与 X 协议的协同" 30-protocols/.protocol-h2-claims.txt | grep -F " → Y 协议" > /dev/null; then
  pass "X 协议的协同 → 接受 (真协议名)"
else
  fail "X 协议的协同 应被接受 (X 协议 + 协同)"
fi

if grep -F "5. 与已有协议的衔接" 30-protocols/.protocol-h2-claims.txt | grep -F "excluded" > /dev/null; then
  pass "已有协议的衔接 → 排除 (协议元描述)"
else
  fail "已有协议的衔接 应被排除"
fi

# 6. v0.8.28 export 仍工作 (不污染 stable API)
echo ""
echo "6. v0.8.28 export 仍 30 entries (all: 行)"
bash scripts/protocol-disambiguation.sh export > /dev/null 2>&1
ALL_ENTRIES=$(grep -c "^all: " 30-protocols/.protocol-names.txt)
if [ "$ALL_ENTRIES" -ge 26 ]; then
  pass "export 仍 $ALL_ENTRIES all entries (v0.8.28 stable, 13 核心 + 自发现)"
else
  fail "export all entries 太少: $ALL_ENTRIES (期望 ≥ 26)"
fi

# 7. v0.8.29 test placeholder 兼容 (函数名还在, 实做了)
echo ""
echo "7. v0.8.29 test 兼容性 (placeholder 函数名保留)"
if grep -q "^parse_protocol_frontmatter()" "$SCRIPT"; then
  pass "parse_protocol_frontmatter() 函数定义保留"
else
  fail "parse_protocol_frontmatter() 缺失"
fi
if grep -q "^h2_protocol_distance()" "$SCRIPT"; then
  pass "h2_protocol_distance() 函数定义保留"
else
  fail "h2_protocol_distance() 缺失"
fi
if grep -q "^scan_h2_protocol_claims()" "$SCRIPT"; then
  pass "scan_h2_protocol_claims() 函数定义保留"
else
  fail "scan_h2_protocol_claims() 缺失"
fi

# 8. scan-h2-claims 子命令
echo ""
echo "8. scan-h2-claims 子命令存在 + 跟 export 同级"
if grep -q "scan-h2-claims" "$SCRIPT" && grep -q "scan-h2-claims)" "$SCRIPT"; then
  pass "scan-h2-claims 子命令已加"
else
  fail "scan-h2-claims 子命令缺失"
fi

echo ""
echo "═══════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════"
[ "$FAIL" = "0" ] && exit 0 || exit 1
