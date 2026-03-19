#!/bin/sh
# Scrum Skills - One-click Installer
# 双击或运行此脚本，自动检测环境并安装技能组
#
# 支持的 Agent 目录：
#   ~/.claude/        Claude Code
#   ~/.warp/          Warp Terminal AI
#   ~/.cursor/        Cursor IDE
#   ~/.windsurf/      Windsurf IDE
#   ~/.cline/         Cline
#   ~/.continue/      Continue
#
# 用法：
#   sh install.sh            # 自动检测
#   sh install.sh --force    # 跳过确认直接安装

set -e

# ---- 路径检测 ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# 获取 home 目录（兼容 Windows/Mac/Linux）
if [ -n "$USERPROFILE" ]; then
  HOME_DIR="$(echo "$USERPROFILE" | sed 's|\\|/|g')"
elif [ -n "$HOME" ]; then
  HOME_DIR="$HOME"
else
  HOME_DIR="$(cd ~ && pwd)"
fi

# 支持的 agent 根目录
AGENT_DIRS=".claude .warp .cursor .windsurf .cline .continue"

# ---- 检测当前是否在 agent 目录下 ----
DETECTED_AGENT=""
DETECTED_AGENT_DIR=""

for agent in $AGENT_DIRS; do
  AGENT_PATH="$HOME_DIR/$agent"
  case "$SCRIPT_DIR" in
    "$AGENT_PATH"*)
      DETECTED_AGENT="$agent"
      DETECTED_AGENT_DIR="$AGENT_PATH"
      break
      ;;
  esac
done

echo ""
echo "=== Scrum Skills 技能组安装 ==="
echo ""

# ---- 确认安装目标 ----
FORCE=0
for arg in "$@"; do
  case "$arg" in --force) FORCE=1 ;; esac
done

if [ -n "$DETECTED_AGENT" ]; then
  echo "✅ 检测到 Agent 目录：$DETECTED_AGENT_DIR"
  INSTALL_BASE="$DETECTED_AGENT_DIR"
else
  echo "⚠️  未检测到已知 Agent 目录"
  echo "   当前路径：$SCRIPT_DIR"
  echo ""
  if [ "$FORCE" = "0" ]; then
    printf "是否仍要安装到 ~/.claude/ ？[y/N]: "
    read CONFIRM
    case "$CONFIRM" in
      [yY]*) ;;
      *)
        echo "已取消安装。"
        echo "请将本仓库 clone 到以下目录之一后重试："
        for agent in $AGENT_DIRS; do
          echo "  $HOME_DIR/$agent/"
        done
        exit 0
        ;;
    esac
  fi
  INSTALL_BASE="$HOME_DIR/.claude"
  mkdir -p "$INSTALL_BASE"
fi

SKILLS_DST="$INSTALL_BASE/skills"
SETTINGS_DST="$INSTALL_BASE/settings.json"

echo ""
echo "安装目标：$INSTALL_BASE"
echo ""

# ---- 复制 skills/ ----
echo "📦 复制技能组..."
mkdir -p "$SKILLS_DST"
cp -rf "$SCRIPT_DIR/skills/." "$SKILLS_DST/"
echo "   ✅ skills/ → $SKILLS_DST"

# ---- 复制 settings.json（不覆盖已有配置）----
if [ -f "$SCRIPT_DIR/.claude/settings.json" ]; then
  if [ -f "$SETTINGS_DST" ]; then
    echo "   ⚠️  $SETTINGS_DST 已存在，跳过（避免覆盖现有配置）"
    echo "      如需更新，手动复制：$SCRIPT_DIR/.claude/settings.json"
  else
    cp "$SCRIPT_DIR/.claude/settings.json" "$SETTINGS_DST"
    echo "   ✅ settings.json → $SETTINGS_DST"
  fi
fi

# ---- 运行 setup.sh ----
echo ""
echo "⚙️  运行配置脚本..."
SETUP_SCRIPT="$SKILLS_DST/hooks/setup.sh"
if [ -f "$SETUP_SCRIPT" ]; then
  sh "$SETUP_SCRIPT" --default
else
  echo "   ⚠️  setup.sh 未找到，跳过"
fi

# ---- 清理仓库文件 ----
echo ""
echo "🧹 清理仓库文件..."
cd "$SCRIPT_DIR"
rm -rf .git/ .claude/ .cache/
rm -f README.md LICENSE sync-skills.sh install.sh install.bat .gitignore
rm -rf skills/
echo "   ✅ 安装完成，仓库文件已清理"

# ---- 完成 ----
echo ""
echo "================================"
echo "✅ 安装完成！"
echo ""
echo "在你的项目中启动 Claude Code："
echo "  cd your-project && claude"
echo ""
echo "然后输入："
echo "  /0-emperor 开发用户登录功能    # 三省六部模式（复杂任务）"
echo "  /0-scrum-master 修复某个bug    # 敏捷模式（简单任务）"
echo "================================"
echo ""
