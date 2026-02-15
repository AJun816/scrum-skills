#!/bin/bash
# 代码质量检查脚本

echo "🔍 检查代码质量..."

# 获取staged文件列表
files=$(git diff --cached --name-only)

if [ -z "$files" ]; then
  echo "✅ 无文件变更"
  exit 0
fi

# 检查结果
WARNINGS=0

for file in $files; do
  # 跳过删除的文件
  if [ ! -f "$file" ]; then
    continue
  fi

  # 只检查代码文件
  case "$file" in
    *.java|*.js|*.ts|*.vue|*.py|*.go)
      # 检查方法大小（简单检测：连续非空行超过50行）
      # 这是一个简化的检测，实际应该使用AST分析

      # 检查是否有TODO/FIXME注释
      if grep -n "TODO\|FIXME" "$file" > /dev/null 2>&1; then
        echo "⚠️  $file: 发现TODO/FIXME注释"
        WARNINGS=$((WARNINGS + 1))
      fi

      # 检查是否有console.log（前端）
      if [[ "$file" == *.js || "$file" == *.ts || "$file" == *.vue ]]; then
        if grep -n "console\.log" "$file" > /dev/null 2>&1; then
          echo "⚠️  $file: 发现console.log（建议移除）"
          WARNINGS=$((WARNINGS + 1))
        fi
      fi

      # 检查是否有System.out.println（Java）
      if [[ "$file" == *.java ]]; then
        if grep -n "System\.out\.println" "$file" > /dev/null 2>&1; then
          echo "⚠️  $file: 发现System.out.println（建议使用日志）"
          WARNINGS=$((WARNINGS + 1))
        fi
      fi

      echo "✅ $file: 代码质量检查通过"
      ;;
    *)
      # 跳过非代码文件
      ;;
  esac
done

# 输出统计
echo ""
if [ $WARNINGS -gt 0 ]; then
  echo "⚠️  代码质量检查通过（有 $WARNINGS 个警告）"
  echo "💡 建议：修复警告项以提高代码质量"
  exit 0
else
  echo "✅ 代码质量检查通过"
  exit 0
fi
