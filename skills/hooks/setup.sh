#!/bin/sh
# Scrum Skills - Setup Script
# Configures nickname and git commit-msg hook
# Hooks are auto-configured via .claude/settings.json (no manual setup needed)
#
# Usage:
#   sh .claude/skills/hooks/setup.sh
#   (run from project root)

set -e

# ---- Detect paths ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$SCRIPT_DIR"
PROJECT_ROOT="$(cd "$SKILLS_DIR/../.." && pwd)"

echo ""
echo "=== Scrum Skills Setup / 技能组配置 ==="
echo ""

# ---- Interactive: Language ----
printf "Select language / 选择语言 [1=中文, 2=English] (1): "
read LANG_CHOICE
case "$LANG_CHOICE" in
  2) LANG="en" ;;
  *) LANG="zh" ;;
esac

if [ "$LANG" = "zh" ]; then
  MSG_NICKNAME="你希望AI怎么称呼你？(默认: 吴彦祖): "
  MSG_GIT="是否安装 git commit-msg hook？[Y/n]: "
  MSG_DONE="配置完成！"
  MSG_NEXT="在 Claude Code 中使用 @0-scrum-master 开始"
  MSG_HOOKS_AUTO="Claude hooks 已通过 .claude/settings.json 自动配置，无需手动设置"
  MSG_GIT_OK="Git commit-msg hook 已安装"
  MSG_SKIP="已跳过"
else
  MSG_NICKNAME="What should AI call you? (default: 吴彦祖): "
  MSG_GIT="Install git commit-msg hook? [Y/n]: "
  MSG_DONE="Setup complete!"
  MSG_NEXT="Use @0-scrum-master in Claude Code to get started"
  MSG_HOOKS_AUTO="Claude hooks auto-configured via .claude/settings.json"
  MSG_GIT_OK="Git commit-msg hook installed"
  MSG_SKIP="Skipped"
fi

echo "ℹ️  $MSG_HOOKS_AUTO"
echo ""

# ---- Interactive: Nickname ----
printf "$MSG_NICKNAME"
read NICKNAME
NICKNAME="${NICKNAME:-吴彦祖}"

# Save user config
CACHE_DIR="$SKILLS_DIR/.cache"
mkdir -p "$CACHE_DIR"
cat > "$CACHE_DIR/user-config.json" << EOFCFG
{
  "language": "$LANG",
  "nickname": "$NICKNAME",
  "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)"
}
EOFCFG

# Update nickname in mandatory-rules.md if changed
if [ "$NICKNAME" != "吴彦祖" ]; then
  RULES_FILE="$SKILLS_DIR/config/mandatory-rules.md"
  if [ -f "$RULES_FILE" ]; then
    if command -v sed >/dev/null 2>&1; then
      sed -i.bak "s/吴彦祖/$NICKNAME/g" "$RULES_FILE" 2>/dev/null && rm -f "$RULES_FILE.bak" || true
    fi
  fi
  # Also update all SKILL.md files
  find "$SKILLS_DIR" -name "SKILL.md" -exec sed -i.bak "s/吴彦祖/$NICKNAME/g"  \; 2>/dev/null
  find "$SKILLS_DIR" -name "*.bak" -delete 2>/dev/null || true
fi

# ---- Git commit-msg Hook ----
printf "$MSG_GIT"
read GIT_CHOICE
case "$GIT_CHOICE" in
  [nN]*) echo "  $MSG_SKIP" ;;
  *)
    GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
    if [ -d "$PROJECT_ROOT/.git" ]; then
      mkdir -p "$GIT_HOOKS_DIR"
      cp "$HOOKS_DIR/commit-msg.sh" "$GIT_HOOKS_DIR/commit-msg"
      chmod +x "$GIT_HOOKS_DIR/commit-msg" 2>/dev/null || true
      echo "  $MSG_GIT_OK"
    else
      echo "  .git not found, skipped"
    fi
    ;;
esac

echo ""
echo "$MSG_DONE"
echo ""
echo "  $MSG_NEXT"
echo ""
