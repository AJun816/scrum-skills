#!/bin/bash
# 安全检查脚本

echo "🔒 检查安全问题..."

# 获取staged文件列表
files=$(git diff --cached --name-only)

if [ -z "$files" ]; then
  echo "✅ 无文件变更"
  exit 0
fi

# 检查结果
FAILED=0
WARNINGS=0

for file in $files; do
  # 跳过删除的文件
  if [ ! -f "$file" ]; then
    continue
  fi

  # 检查敏感信息
  # 检查密码关键词
  if grep -nE "(password|passwd|pwd)\s*=\s*['\"][^'\"]+['\"]" "$file" > /dev/null 2>&1; then
    echo "❌ $file: 发现硬编码密码"
    FAILED=1
  fi

  # 检查API密钥
  if grep -nE "(api[_-]?key|apikey|access[_-]?key)\s*=\s*['\"][^'\"]+['\"]" "$file" > /dev/null 2>&1; then
    echo "❌ $file: 发现硬编码API密钥"
    FAILED=1
  fi

  # 检查数据库连接字符串
  if grep -nE "jdbc:mysql://.*:.*@" "$file" > /dev/null 2>&1; then
    echo "❌ $file: 发现硬编码数据库连接字符串"
    FAILED=1
  fi

  # 检查SQL注入风险（Java）
  if [[ "$file" == *.java ]]; then
    if grep -nE "\"SELECT.*\+.*\"" "$file" > /dev/null 2>&1; then
      echo "❌ $file: 发现SQL字符串拼接（SQL注入风险）"
      FAILED=1
    fi
  fi

  # 检查XSS风险（JavaScript/Vue）
  if [[ "$file" == *.js || "$file" == *.ts || "$file" == *.vue ]]; then
    if grep -n "innerHTML\s*=" "$file" > /dev/null 2>&1; then
      echo "⚠️  $file: 发现innerHTML使用（可能存在XSS风险）"
      WARNINGS=$((WARNINGS + 1))
    fi
  fi

  # 如果没有发现问题
  if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "✅ $file: 安全检查通过"
  fi
done

# 输出统计
echo ""
if [ $FAILED -eq 1 ]; then
  echo "❌ 安全检查失败：发现安全问题"
  echo "💡 修复建议："
  echo "   1. 使用环境变量存储敏感信息"
  echo "   2. 使用参数化查询防止SQL注入"
  echo "   3. 使用textContent或框架的文本插值防止XSS"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo "⚠️  安全检查通过（有 $WARNINGS 个警告）"
  echo "💡 建议：检查警告项，确保没有安全风险"
  exit 0
else
  echo "✅ 安全检查通过"
  exit 0
fi
