#!/bin/sh
# Scrum Skills - Setup Script
# Configures nickname and git commit-msg hook
# Hooks are auto-configured via .claude/settings.json (no manual setup needed)
#
# Usage:
#   sh .claude/skills/hooks/setup.sh              # auto-detect (terminal=interactive, pipe=default)
#   sh .claude/skills/hooks/setup.sh --default    # non-interactive, use all defaults
#   sh .claude/skills/hooks/setup.sh --interactive # force interactive mode
#   sh .claude/skills/hooks/setup.sh --lang=en --nickname=John --no-git-hook

set -e

# ---- Detect paths ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$SCRIPT_DIR"
PROJECT_ROOT="$(cd "$SKILLS_DIR/../.." && pwd)"

# ---- Defaults ----
MODE=""
LANG="zh"
NICKNAME="吴彦祖"
INSTALL_GIT_HOOK="yes"

# ---- Parse arguments ----
for arg in "$@"; do
  case "$arg" in
    --default)
      MODE="default"
      ;;
    --interactive)
      MODE="interactive"
      ;;
    --lang=*)
      LANG="${arg#--lang=}"
      ;;
    --nickname=*)
      NICKNAME="${arg#--nickname=}"
      ;;
    --no-git-hook)
      INSTALL_GIT_HOOK="no"
      ;;
    --help|-h)
      echo "Usage: sh setup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --default        Non-interactive mode, use all defaults"
      echo "  --interactive    Force interactive mode (even in pipe)"
      echo "  --lang=LANG      Set language: zh (default) or en"
      echo "  --nickname=NAME  Set nickname (default: 吴彦祖)"
      echo "  --no-git-hook    Skip git commit-msg hook installation"
      echo "  -h, --help       Show this help"
      echo ""
      echo "Without flags: auto-detect (terminal=interactive, pipe/CI=default)"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg (use --help for usage)"
      exit 1
      ;;
  esac
done

# ---- Auto-detect mode if not specified ----
if [ -z "$MODE" ]; then
  if [ -t 0 ]; then
    MODE="interactive"
  else
    MODE="default"
  fi
fi

# ---- Setup i18n messages ----
setup_messages() {
  if [ "$LANG" = "en" ]; then
    MSG_BANNER="=== Scrum Skills Setup ==="
    MSG_NICKNAME="What should AI call you? (default: 吴彦祖): "
    MSG_GIT="Install git commit-msg hook? [Y/n]: "
    MSG_DONE="Setup complete!"
    MSG_NEXT="Use /0-scrum-master in Claude Code to get started"
    MSG_HOOKS_AUTO="Claude hooks auto-configured via .claude/settings.json"
    MSG_GIT_OK="Git commit-msg hook installed"
    MSG_SKIP="Skipped"
    MSG_LANG_PROMPT="Select language / 选择语言 [1=中文, 2=English] (1): "
    MSG_DEFAULT_MODE="Running in non-interactive mode with defaults"
  else
    MSG_BANNER="=== Scrum Skills 技能组配置 ==="
    MSG_NICKNAME="你希望AI怎么称呼你？(默认: 吴彦祖): "
    MSG_GIT="是否安装 git commit-msg hook？[Y/n]: "
    MSG_DONE="配置完成！"
    MSG_NEXT="在 Claude Code 中使用 /0-scrum-master 开始"
    MSG_HOOKS_AUTO="Claude hooks 已通过 .claude/settings.json 自动配置，无需手动设置"
    MSG_GIT_OK="Git commit-msg hook 已安装"
    MSG_SKIP="已跳过"
    MSG_LANG_PROMPT="Select language / 选择语言 [1=中文, 2=English] (1): "
    MSG_DEFAULT_MODE="使用默认配置（非交互模式）"
  fi
}

# ---- Interactive mode ----
run_interactive() {
  echo ""
  echo "=== Scrum Skills Setup / 技能组配置 ==="
  echo ""

  # Language selection
  printf "%s" "$MSG_LANG_PROMPT"
  read LANG_CHOICE
  case "$LANG_CHOICE" in
    2) LANG="en" ;;
    *) LANG="zh" ;;
  esac
  setup_messages

  echo ""
  echo "ℹ️  $MSG_HOOKS_AUTO"
  echo ""

  # Nickname
  printf "%s" "$MSG_NICKNAME"
  read INPUT_NICKNAME
  if [ -n "$INPUT_NICKNAME" ]; then
    NICKNAME="$INPUT_NICKNAME"
  fi

  # Git hook
  printf "%s" "$MSG_GIT"
  read GIT_CHOICE
  case "$GIT_CHOICE" in
    [nN]*) INSTALL_GIT_HOOK="no" ;;
    *) INSTALL_GIT_HOOK="yes" ;;
  esac
}

# ---- Default (non-interactive) mode ----
run_default() {
  setup_messages
  echo ""
  echo "$MSG_BANNER"
  echo ""
  echo "ℹ️  $MSG_DEFAULT_MODE"
  echo "  lang=$LANG, nickname=$NICKNAME, git-hook=$INSTALL_GIT_HOOK"
  echo ""
}

# ---- Execute mode ----
if [ "$MODE" = "interactive" ]; then
  setup_messages
  run_interactive
else
  run_default
fi

# ---- Save user config ----
CACHE_DIR="$SKILLS_DIR/.cache"
mkdir -p "$CACHE_DIR"
cat > "$CACHE_DIR/user-config.json" << EOFCFG
{
  "language": "$LANG",
  "nickname": "$NICKNAME",
  "installedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date +%Y-%m-%dT%H:%M:%S)"
}
EOFCFG

# ---- Update nickname in files if changed ----
if [ "$NICKNAME" != "吴彦祖" ]; then
  RULES_FILE="$SKILLS_DIR/config/mandatory-rules.md"
  if [ -f "$RULES_FILE" ]; then
    if command -v sed >/dev/null 2>&1; then
      sed -i.bak "s/吴彦祖/$NICKNAME/g" "$RULES_FILE" 2>/dev/null && rm -f "$RULES_FILE.bak" || true
    fi
  fi
  # Also update all SKILL.md files
  find "$SKILLS_DIR" -name "SKILL.md" -exec sed -i.bak "s/吴彦祖/$NICKNAME/g" {} \; 2>/dev/null
  find "$SKILLS_DIR" -name "*.bak" -delete 2>/dev/null || true
fi

# ---- Git commit-msg Hook ----
if [ "$INSTALL_GIT_HOOK" = "yes" ]; then
  GIT_HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
  if [ -d "$PROJECT_ROOT/.git" ]; then
    mkdir -p "$GIT_HOOKS_DIR"
    cp "$HOOKS_DIR/commit-msg.sh" "$GIT_HOOKS_DIR/commit-msg"
    chmod +x "$GIT_HOOKS_DIR/commit-msg" 2>/dev/null || true
    echo "  $MSG_GIT_OK"
  else
    echo "  .git not found, skipped"
  fi
else
  echo "  $MSG_SKIP"
fi

echo ""
echo "$MSG_DONE"
echo ""
echo "  $MSG_NEXT"
echo ""
