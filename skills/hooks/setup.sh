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
PROJECT_ROOT="$(cd "$SKILLS_DIR/.." && pwd)"

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

# ---- Create .claude/skills symlinks ----
CLAUDE_SKILLS_DIR="$PROJECT_ROOT/.claude/skills"
mkdir -p "$CLAUDE_SKILLS_DIR"
LINK_COUNT=0

# Link hooks directory (critical for settings.json hook paths)
if [ ! -L "$CLAUDE_SKILLS_DIR/hooks" ]; then
  ln -sf "../../skills/hooks" "$CLAUDE_SKILLS_DIR/hooks"
  LINK_COUNT=$((LINK_COUNT + 1))
fi

# Link all skill directories
for SKILL_DIR in "$SKILLS_DIR"/0-* "$SKILLS_DIR"/1-* "$SKILLS_DIR"/2-* "$SKILLS_DIR"/3-* "$SKILLS_DIR"/4-* "$SKILLS_DIR"/5-* "$SKILLS_DIR"/6-* "$SKILLS_DIR"/7-* "$SKILLS_DIR"/8-*; do
  [ ! -d "$SKILL_DIR" ] && continue
  SKILL_NAME=$(basename "$SKILL_DIR")
  LINK_TARGET="../../skills/${SKILL_NAME}"
  if [ ! -L "$CLAUDE_SKILLS_DIR/$SKILL_NAME" ]; then
    ln -sf "$LINK_TARGET" "$CLAUDE_SKILLS_DIR/$SKILL_NAME"
    LINK_COUNT=$((LINK_COUNT + 1))
  fi
done
if [ "$LANG" = "en" ]; then
  echo "  Skills symlinks ready ($LINK_COUNT new) in .claude/skills/"
else
  echo "  技能软连接就绪（新增 $LINK_COUNT 个）：.claude/skills/"
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

# ---- Generate Repo Map (.cache/shared/repo-map.md) ----
generate_repo_map() {
  SHARED_DIR="$PROJECT_ROOT/.cache/shared"
  mkdir -p "$SHARED_DIR"
  REPO_MAP="$SHARED_DIR/repo-map.md"

  TIMESTAMP=$(date -u +"%Y-%m-%d %H:%M:%S UTC" 2>/dev/null || date +"%Y-%m-%d %H:%M:%S")
  COMMIT_HASH=$(cd "$PROJECT_ROOT" && git rev-parse --short HEAD 2>/dev/null || echo "unknown")

  # Detect tech stack
  TECH_BACKEND="unknown"
  TECH_FRONTEND="unknown"
  TECH_DB="unknown"
  TECH_BUILD="unknown"

  if [ -f "$PROJECT_ROOT/pom.xml" ]; then
    TECH_BACKEND="Java + Spring Boot"
    TECH_BUILD="Maven"
  elif [ -f "$PROJECT_ROOT/build.gradle" ] || [ -f "$PROJECT_ROOT/build.gradle.kts" ]; then
    TECH_BACKEND="Java/Kotlin + Spring Boot"
    TECH_BUILD="Gradle"
  elif [ -f "$PROJECT_ROOT/go.mod" ]; then
    TECH_BACKEND="Go"
    TECH_BUILD="Go Modules"
  elif [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
    TECH_BACKEND="Python"
    TECH_BUILD="pip/poetry"
  elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
    TECH_BACKEND="Rust"
    TECH_BUILD="Cargo"
  fi

  if [ -f "$PROJECT_ROOT/package.json" ]; then
    if grep -q '"vue"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      TECH_FRONTEND="Vue"
    elif grep -q '"react"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      TECH_FRONTEND="React"
    elif grep -q '"angular"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      TECH_FRONTEND="Angular"
    elif grep -q '"svelte"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      TECH_FRONTEND="Svelte"
    fi
    if grep -q '"vite"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      TECH_BUILD="Vite"
    elif grep -q '"webpack"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
      TECH_BUILD="Webpack"
    fi
    # If backend is unknown but package.json exists, detect Node.js backend
    if [ "$TECH_BACKEND" = "unknown" ]; then
      if grep -q '"express"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
        TECH_BACKEND="Node.js + Express"
      elif grep -q '"@nestjs/core"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
        TECH_BACKEND="Node.js + NestJS"
      elif grep -q '"fastify"' "$PROJECT_ROOT/package.json" 2>/dev/null; then
        TECH_BACKEND="Node.js + Fastify"
      fi
    fi
  fi

  # Detect database from config files
  if [ -f "$PROJECT_ROOT/docker-compose.yml" ] || [ -f "$PROJECT_ROOT/docker-compose.yaml" ]; then
    COMPOSE_FILE=$([ -f "$PROJECT_ROOT/docker-compose.yml" ] && echo "$PROJECT_ROOT/docker-compose.yml" || echo "$PROJECT_ROOT/docker-compose.yaml")
    if grep -qi 'mysql' "$COMPOSE_FILE" 2>/dev/null; then
      TECH_DB="MySQL"
    elif grep -qi 'postgres' "$COMPOSE_FILE" 2>/dev/null; then
      TECH_DB="PostgreSQL"
    elif grep -qi 'mongo' "$COMPOSE_FILE" 2>/dev/null; then
      TECH_DB="MongoDB"
    elif grep -qi 'redis' "$COMPOSE_FILE" 2>/dev/null; then
      TECH_DB="Redis"
    fi
  fi

  # Generate directory tree (depth 2, exclude common noise)
  DIR_TREE=""
  if command -v tree >/dev/null 2>&1; then
    DIR_TREE=$(cd "$PROJECT_ROOT" && tree -L 2 -d --noreport -I 'node_modules|.git|dist|build|.cache|.venv|venv|__pycache__|.idea|.vscode|target|.gradle' 2>/dev/null || echo "(tree command failed)")
  else
    DIR_TREE=$(cd "$PROJECT_ROOT" && find . -maxdepth 2 -type d \
      -not -path '*/node_modules*' -not -path '*/.git*' -not -path '*/dist*' \
      -not -path '*/build*' -not -path '*/.cache*' -not -path '*/.venv*' \
      -not -path '*/venv*' -not -path '*/__pycache__*' -not -path '*/.idea*' \
      -not -path '*/.vscode*' -not -path '*/target*' -not -path '*/.gradle*' \
      2>/dev/null | sort || echo "(find failed)")
  fi

  # Detect entry files
  ENTRY_BACKEND="(not detected)"
  ENTRY_FRONTEND="(not detected)"
  CONFIG_FILES=""

  # Backend entries
  for f in src/main/java src/main.ts src/main.py src/index.ts src/index.js src/app.ts src/app.js src/app.py main.go cmd/main.go src/main.rs; do
    if [ -f "$PROJECT_ROOT/$f" ]; then
      ENTRY_BACKEND="$f"
      break
    fi
  done

  # Frontend entries
  for f in src/main.ts src/main.js src/index.tsx src/index.js src/App.vue src/App.tsx; do
    if [ -f "$PROJECT_ROOT/$f" ]; then
      ENTRY_FRONTEND="$f"
      break
    fi
  done

  # Config files
  for f in package.json tsconfig.json vite.config.ts vite.config.js webpack.config.js pom.xml build.gradle go.mod Cargo.toml pyproject.toml requirements.txt docker-compose.yml docker-compose.yaml Dockerfile .env.example; do
    if [ -f "$PROJECT_ROOT/$f" ]; then
      CONFIG_FILES="${CONFIG_FILES}${f}, "
    fi
  done
  CONFIG_FILES=$(echo "$CONFIG_FILES" | sed 's/, $//')

  # Detect public/shared modules
  UTILS_DESC="(not found)"
  COMMON_DESC="(not found)"
  SHARED_DESC="(not found)"
  [ -d "$PROJECT_ROOT/src/utils" ] || [ -d "$PROJECT_ROOT/utils" ] && UTILS_DESC="Utility functions"
  [ -d "$PROJECT_ROOT/src/common" ] || [ -d "$PROJECT_ROOT/common" ] && COMMON_DESC="Common modules"
  [ -d "$PROJECT_ROOT/src/shared" ] || [ -d "$PROJECT_ROOT/shared" ] && SHARED_DESC="Shared resources"
  [ -d "$PROJECT_ROOT/src/lib" ] || [ -d "$PROJECT_ROOT/lib" ] && UTILS_DESC="Library utilities"

  # Write repo map
  cat > "$REPO_MAP" << EOFMAP
# 仓库地图

**生成时间：** ${TIMESTAMP}
**最后更新：** ${TIMESTAMP}
**基于提交：** ${COMMIT_HASH}

## 技术栈概览
- 后端：${TECH_BACKEND}
- 前端：${TECH_FRONTEND}
- 数据库：${TECH_DB}
- 构建工具：${TECH_BUILD}

## 目录结构
\`\`\`
${DIR_TREE}
\`\`\`

## 核心模块
| 模块 | 路径 | 职责 | 关键文件 |
|------|------|------|----------|
| (初始化时自动填充或手动补充) | | | |

## 入口文件
- 后端入口：${ENTRY_BACKEND}
- 前端入口：${ENTRY_FRONTEND}
- 配置文件：${CONFIG_FILES}

## 公共模块（复用扫描参考）
- utils/：${UTILS_DESC}
- common/：${COMMON_DESC}
- shared/：${SHARED_DESC}
EOFMAP

  if [ "$LANG" = "en" ]; then
    echo "  Repo map generated: .cache/shared/repo-map.md"
  else
    echo "  仓库地图已生成：.cache/shared/repo-map.md"
  fi
}

generate_repo_map

echo ""
echo "$MSG_DONE"
echo ""
echo "  $MSG_NEXT"
echo ""
