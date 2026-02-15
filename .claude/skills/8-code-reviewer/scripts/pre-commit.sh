#!/bin/bash
# Pre-commit hook - 代码审查

# 检查是否跳过审查
if [ "$SKIP_CODE_REVIEW" = "true" ]; then
  echo "⚠️  跳过代码审查（SKIP_CODE_REVIEW=true）"
  exit 0
fi

echo "🔍 代码审查中..."
echo ""

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查文件大小
$SCRIPT_DIR/check-file-size.sh
FILE_SIZE_RESULT=$?

echo ""

# 检查代码质量
$SCRIPT_DIR/check-code-quality.sh
CODE_QUALITY_RESULT=$?

echo ""

# 检查安全问题
$SCRIPT_DIR/check-security.sh
SECURITY_RESULT=$?

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 汇总结果
FAILED=0
if [ $FILE_SIZE_RESULT -ne 0 ]; then
  FAILED=1
fi

if [ $SECURITY_RESULT -ne 0 ]; then
  FAILED=1
fi

if [ $FAILED -eq 1 ]; then
  echo "❌ 代码审查失败"
  echo ""
  echo "💡 提示："
  echo "   - 修复上述问题后重新提交"
  echo "   - 如需跳过审查（不推荐）：SKIP_CODE_REVIEW=true git commit"
  exit 1
fi

echo "✅ 代码审查通过"
echo ""
exit 0
