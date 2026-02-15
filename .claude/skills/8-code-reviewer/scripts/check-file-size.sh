#!/bin/bash
# 文件大小检查脚本

echo "📏 检查文件大小..."

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

  # 跳过二进制文件
  if file "$file" | grep -q "binary"; then
    continue
  fi

  # 获取文件行数
  lines=$(wc -l < "$file" 2>/dev/null || echo "0")

  # 检查文件大小
  if [ "$lines" -gt 800 ]; then
    echo "❌ $file: $lines 行（超过800行限制）"
    FAILED=1
  elif [ "$lines" -gt 600 ]; then
    echo "⚠️  $file: $lines 行（接近上限，建议重构）"
    WARNINGS=$((WARNINGS + 1))
  else
    echo "✅ $file: $lines 行"
  fi
done

# 输出统计
echo ""
if [ $FAILED -eq 1 ]; then
  echo "❌ 文件大小检查失败：发现超标文件"
  echo "💡 修复建议："
  echo "   1. 按职责拆分类"
  echo "   2. 提取内部类到独立文件"
  echo "   3. 移动工具方法到工具类"
  exit 1
elif [ $WARNINGS -gt 0 ]; then
  echo "⚠️  文件大小检查通过（有 $WARNINGS 个警告）"
  echo "💡 建议：在下次迭代中重构接近上限的文件"
  exit 0
else
  echo "✅ 文件大小检查通过"
  exit 0
fi
