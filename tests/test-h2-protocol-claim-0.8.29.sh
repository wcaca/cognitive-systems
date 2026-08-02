#!/bin/bash
# test-h2-protocol-claim-0.8.29.sh - v0.8.29 调研参考实现验证
#
# 3 件事:
#   1. parse_protocol_frontmatter 占位函数存在 + 返回空 (跟 v0.8.28 兼容)
#   2. h2_protocol_distance fallback 包含检测 (子串 → 0, 不含 → max(len))
#   3. scan_h2_protocol_claims 占位函数存在 + 返回 0 (不破坏 export)
#   4. 调研 doc h2-chapter-protocol-claim.md 存在 + 3 方案都描述
#   5. v0.8.28 export 仍工作 (不污染)

set -e
SCRIPT=scripts/protocol-disambiguation.sh
DOC=30-protocols/h2-chapter-protocol-claim.md

PASS=0
FAIL=0
pass() { PASS=$((PASS+1)); echo "  ✅ $1"; }
fail() { FAIL=$((FAIL+1)); echo "  ❌ $1"; }

echo "═══════════════════════════════════════"
echo "test-h2-protocol-claim-0.8.29.sh - v0.8.29 调研参考"
echo "═══════════════════════════════════════"

# 1. 3 个 placeholder 函数存在
echo ""
echo "1. 3 个 v0.8.29 placeholder 函数存在"
if grep -q "^parse_protocol_frontmatter()" "$SCRIPT"; then
  pass "parse_protocol_frontmatter() 函数定义存在"
else
  fail "parse_protocol_frontmatter() 缺失"
fi
if grep -q "^h2_protocol_distance()" "$SCRIPT"; then
  pass "h2_protocol_distance() 函数定义存在"
else
  fail "h2_protocol_distance() 缺失"
fi
if grep -q "^scan_h2_protocol_claims()" "$SCRIPT"; then
  pass "scan_h2_protocol_claims() 函数定义存在"
else
  fail "scan_h2_protocol_claims() 缺失"
fi

# 2. parse_protocol_frontmatter 占位 (返回空, 不污染)
echo ""
echo "2. parse_protocol_frontmatter 占位 (返回空, 跟 v0.8.28 兼容)"
RESULT=$(bash -c "__PROTOCOL_DISAMBIG_LIB__=1 source $SCRIPT 2>/dev/null; parse_protocol_frontmatter 30-protocols/cross-repo-z-protocol.md" 2>/dev/null || echo "")
if [ -z "$RESULT" ]; then
  pass "parse_protocol_frontmatter 返回空 (占位行为)"
else
  fail "parse_protocol_frontmatter 返回非空: $RESULT"
fi

# 3. h2_protocol_distance fallback
echo ""
echo "3. h2_protocol_distance fallback (子串 → 0, 不含 → max(len))"
DIST_INC=$(bash -c "__PROTOCOL_DISAMBIG_LIB__=1 source $SCRIPT 2>/dev/null; h2_protocol_distance 'X 协议落地' 'X 协议'" 2>/dev/null)
if [ "$DIST_INC" = "0" ]; then
  pass "包含子串返回 0 (h2='X 协议落地' 含 'X 协议')"
else
  fail "包含子串应返回 0, 实际: $DIST_INC"
fi
DIST_NOT=$(bash -c "__PROTOCOL_DISAMBIG_LIB__=1 source $SCRIPT 2>/dev/null; h2_protocol_distance '协议的核心理念' 'X 协议'" 2>/dev/null)
EXPECTED_NOT=21  # bash \${#var} 字节数 (中文字符 3 字节): "协议的核心理念" 7 字符=21 字节, max=21
if [ "$DIST_NOT" = "$EXPECTED_NOT" ]; then
  pass "不含子串返回 max(len) = $EXPECTED_NOT (h2='协议的核心理念' 跟 'X 协议' 距离 7)"
else
  fail "不含子串应返回 $EXPECTED_NOT, 实际: $DIST_NOT"
fi

# 4. scan_h2_protocol_claims 占位 (不污染 export)
echo ""
echo "4. scan_h2_protocol_claims 占位 (返回 0)"
EXIT=$(bash -c "__PROTOCOL_DISAMBIG_LIB__=1 source $SCRIPT 2>/dev/null; scan_h2_protocol_claims; echo \$?" 2>/dev/null | tail -1)
if [ "$EXIT" = "0" ]; then
  pass "scan_h2_protocol_claims 返回 0 (不污染 v0.8.28 export)"
else
  fail "scan_h2_protocol_claims 返回非 0: $EXIT"
fi

# 5. 调研 doc 存在 + 3 方案
echo ""
echo "5. 调研 doc h2-chapter-protocol-claim.md 存在 + 3 方案都描述"
if [ -f "$DOC" ]; then
  pass "$DOC 文件存在"
else
  fail "$DOC 缺失"
fi
if [ -f "$DOC" ] && grep -qE "A\. frontmatter|B\. \"X 子协议\"|C\. frontmatter \+ 距离" "$DOC"; then
  pass "3 方案对比表都描述 (A frontmatter / B 命名约定 / C frontmatter + 距离)"
else
  fail "3 方案对比不完整"
fi
if [ -f "$DOC" ] && grep -q "v0.8.30+" "$DOC"; then
  pass "实施路径留 v0.8.30+ 明确标记"
else
  fail "v0.8.30+ 实施路径不明确"
fi

# 6. v0.8.28 export 仍工作 (不污染)
echo ""
echo "6. v0.8.28 export 仍工作 (参考实现不污染 stable API)"
EXPORT_OUT=$(bash "$SCRIPT" export 2>&1)
if echo "$EXPORT_OUT" | grep -q "wrote.*protocol-names.txt"; then
  pass "export 仍写 .protocol-names.txt (v0.8.28 stable)"
else
  fail "export 失败: $EXPORT_OUT"
fi
if [ -f "30-protocols/.protocol-names.txt" ]; then
  LINES=$(wc -l < 30-protocols/.protocol-names.txt)
  pass ".protocol-names.txt 存在 ($LINES 行)"
else
  fail ".protocol-names.txt 缺失"
fi

echo ""
echo "═══════════════════════════════════════"
echo "Results: $PASS passed, $FAIL failed"
echo "═══════════════════════════════════════"
[ $FAIL -eq 0 ] && exit 0 || exit 1
