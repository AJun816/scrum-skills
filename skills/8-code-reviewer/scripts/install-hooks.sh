#!/bin/bash
# 安装Git Hooks脚本

echo "🔧 安装Git Hooks..."

# 获取脚本目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 检查是否在Git仓库中
if [ ! -d ".git" ]; then
  echo "❌ 错误：当前目录不是Git仓库"
  exit 1
fi

# 复制hooks
echo "📋 复制hooks..."
cp "$SCRIPT_DIR/pre-commit.sh" .git/hooks/pre-commit
cp "$SCRIPT_DIR/pre-push.sh" .git/hooks/pre-push 2>/dev/null || echo "⚠️  pre-push.sh不存在，跳过"

# 添加执行权限
echo "🔑 添加执行权限..."
chmod +x .git/hooks/pre-commit
chmod +x .git/hooks/pre-push 2>/dev/null

# 添加脚本执行权限
chmod +x "$SCRIPT_DIR/check-file-size.sh"
chmod +x "$SCRIPT_DIR/check-code-quality.sh"
chmod +x "$SCRIPT_DIR/check-security.sh"

echo ""
echo "✅ Git Hooks安装完成"
echo ""
echo "📝 说明："
echo "   - pre-commit: 提交前自动检查代码"
echo "   - 如需跳过检查：SKIP_CODE_REVIEW=true git commit"
echo ""
echo "🧪 测试："
echo "   git add ."
echo "   git commit -m \"test\""
echo ""
