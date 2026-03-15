#!/bin/bash
# 技能同步脚本
# 将 skills/ 目录下的各技能同步到 ~/.cc-switch/skills/（Claude Code 实际读取位置）
#
# 使用方式：
#   bash sync-skills.sh          # 同步所有技能
#   bash sync-skills.sh --check  # 仅检查差异，不执行同步

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$SCRIPT_DIR/skills"
DST="$HOME/.cc-switch/skills"

SKILLS=(
  0-scrum-master
  1-business-expert
  2-product-manager
  3-system-architect
  4-backend-dev
  4-frontend-design
  4-frontend-dev
  4-nielsen-ui-design
  5-devops-engineer
  5-webapp-testing
  6-bug-handler
  7-skill-creator
  8-code-reviewer
)

# 检查目标目录是否存在
if [ ! -d "$DST" ]; then
  echo "❌ 目标目录不存在：$DST"
  echo "   请确认 cc-switch 已安装并初始化"
  exit 1
fi

# 仅检查模式
if [ "$1" = "--check" ]; then
  echo "=== 检查技能差异 ==="
  HAS_DIFF=0
  for skill in "${SKILLS[@]}"; do
    RESULT=$(diff -rq "$SRC/$skill" "$DST/$skill" 2>/dev/null)
    if [ -n "$RESULT" ]; then
      echo "⚠️  $skill 存在差异"
      echo "$RESULT" | sed 's/^/   /'
      HAS_DIFF=1
    else
      echo "✅ $skill"
    fi
  done
  if [ $HAS_DIFF -eq 0 ]; then
    echo ""
    echo "✅ 所有技能已是最新，无需同步"
  else
    echo ""
    echo "运行 bash sync-skills.sh 执行同步"
  fi
  exit 0
fi

# 同步模式
echo "=== 同步技能到 $DST ==="
for skill in "${SKILLS[@]}"; do
  if [ ! -d "$SRC/$skill" ]; then
    echo "⚠️  跳过（源目录不存在）：$skill"
    continue
  fi
  cp -rf "$SRC/$skill/." "$DST/$skill/"
  echo "✅ $skill"
done

echo ""
echo "=== 同步完成 ==="
