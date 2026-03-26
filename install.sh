#!/bin/sh
# Scrum Skills - One-click Installer
# 目标：clone 后执行 `sh install.sh` 即可安装，无需额外依赖管理器
#
# 用法：
#   sh install.sh
#   sh install.sh --agent=claude
#   sh install.sh --target=/custom/path/.claude
#   sh install.sh --keep-settings
#   sh install.sh --lang=en

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Home path (Windows/Git Bash + Unix)
if [ -n "$USERPROFILE" ]; then
  HOME_DIR="$(echo "$USERPROFILE" | sed 's|\\|/|g')"
elif [ -n "$HOME" ]; then
  HOME_DIR="$HOME"
else
  HOME_DIR="$(cd ~ && pwd)"
fi

DEFAULT_AGENT=".claude"
TARGET_BASE=""
LANG="zh"
KEEP_SETTINGS=0

usage() {
  echo "Usage: sh install.sh [OPTIONS]"
  echo ""
  echo "Options:"
  echo "  --agent=NAME       Install to ~/.[name], e.g. claude|warp|cursor"
  echo "  --target=PATH      Install to exact path (higher priority than --agent)"
  echo "  --keep-settings    Keep existing settings.json (do not overwrite)"
  echo "  --lang=zh|en       Installer output language (default: zh)"
  echo "  -h, --help         Show this help"
}

for arg in "$@"; do
  case "$arg" in
    --agent=*)
      AGENT_NAME="${arg#--agent=}"
      AGENT_NAME="$(echo "$AGENT_NAME" | sed 's/^[.]*//')"
      [ -n "$AGENT_NAME" ] && TARGET_BASE="$HOME_DIR/.${AGENT_NAME}"
      ;;
    --target=*)
      TARGET_BASE="${arg#--target=}"
      ;;
    --keep-settings)
      KEEP_SETTINGS=1
      ;;
    --lang=*)
      LANG="${arg#--lang=}"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $arg"
      usage
      exit 1
      ;;
  esac
done

# Auto-detect: if cloned under a known agent directory, install there; else fallback ~/.claude
if [ -z "$TARGET_BASE" ]; then
  for agent in .claude .warp .cursor .windsurf .cline .continue; do
    AGENT_PATH="$HOME_DIR/$agent"
    case "$SCRIPT_DIR" in
      "$AGENT_PATH"*)
        TARGET_BASE="$AGENT_PATH"
        break
        ;;
    esac
  done
fi

[ -z "$TARGET_BASE" ] && TARGET_BASE="$HOME_DIR/$DEFAULT_AGENT"
case "$TARGET_BASE" in
  "~"*) TARGET_BASE="$HOME_DIR${TARGET_BASE#\~}" ;;
esac
TARGET_BASE="$(echo "$TARGET_BASE" | sed 's|\\|/|g')"

SKILLS_SRC="$SCRIPT_DIR/skills"
SETTINGS_SRC="$SCRIPT_DIR/.claude/settings.json"
SKILLS_DST="$TARGET_BASE/skills"
SETTINGS_DST="$TARGET_BASE/settings.json"
HOOKS_DST="$TARGET_BASE/skills/hooks"

if [ ! -d "$SKILLS_SRC" ]; then
  echo "ERROR: skills directory not found: $SKILLS_SRC"
  exit 1
fi

echo ""
echo "=== Scrum Skills Installer ==="
echo "Source : $SCRIPT_DIR"
echo "Target : $TARGET_BASE"
echo ""

mkdir -p "$TARGET_BASE"
mkdir -p "$SKILLS_DST"

echo "📦 Installing skills..."
cp -rf "$SKILLS_SRC/." "$SKILLS_DST/"
echo "  ✅ $SKILLS_DST"

if [ -f "$SETTINGS_SRC" ]; then
  if [ -f "$SETTINGS_DST" ] && [ "$KEEP_SETTINGS" = "1" ]; then
    echo "  ⚠️  Keeping existing settings: $SETTINGS_DST"
    echo "     Existing hook paths are not rewritten in --keep-settings mode."
  else
    if [ -f "$SETTINGS_DST" ]; then
      TS="$(date +%Y%m%d%H%M%S 2>/dev/null || echo backup)"
      BACKUP_PATH="${SETTINGS_DST}.${TS}.bak"
      cp "$SETTINGS_DST" "$BACKUP_PATH"
      echo "  ℹ️  Backed up existing settings to: $BACKUP_PATH"
    fi
    HOOKS_ESCAPED="$(printf '%s' "$HOOKS_DST" | sed 's|\\|/|g' | sed 's|[&]|\\&|g')"
    sed "s|\\.claude/skills/hooks|$HOOKS_ESCAPED|g" "$SETTINGS_SRC" > "$SETTINGS_DST"
    echo "  ✅ $SETTINGS_DST"
  fi
fi

echo ""
echo "⚙️  Running setup..."
SETUP_SCRIPT="$SKILLS_DST/hooks/setup.sh"
if [ -f "$SETUP_SCRIPT" ]; then
  sh "$SETUP_SCRIPT" --default --skip-repo-map --lang="$LANG"
else
  echo "  ⚠️  setup.sh not found at: $SETUP_SCRIPT"
fi

echo ""
echo "================================"
echo "✅ Installation complete."
echo "No repository files were deleted."
echo ""
echo "Next:"
echo "  1) Open your project with Claude Code"
echo "  2) Use /0-emperor or /0-scrum-master"
echo "  3) Optional git hook:"
echo "     sh $TARGET_BASE/skills/hooks/setup.sh --project-root=/path/to/repo"
echo "================================"
echo ""
