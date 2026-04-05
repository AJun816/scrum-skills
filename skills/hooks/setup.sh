#!/bin/sh
# Scrum Skills - Setup Script
# Configures nickname and project harness hooks
# Claude hooks are auto-configured via .claude/settings.json when installed to ~/.claude
#
# Usage:
#   sh ~/.claude/skills/hooks/setup.sh               # auto-detect (terminal=interactive, pipe=default)
#   sh ~/.codex/skills/hooks/setup.sh --default      # non-interactive, use all defaults
#   sh ~/.claude/skills/hooks/setup.sh --interactive # force interactive mode
#   sh ~/.claude/skills/hooks/setup.sh --lang=en --nickname=John --no-git-hook
#   sh ~/.claude/skills/hooks/setup.sh --project-root=/path/to/repo

set -e

# ---- Detect paths ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILLS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$SCRIPT_DIR"
SKILLS_HOME="$(cd "$SKILLS_DIR/.." && pwd)"
AGENT_HOME_NAME="$(basename "$SKILLS_HOME")"

if [ -f "$SKILLS_HOME/install.sh" ] && [ -f "$SKILLS_HOME/README.md" ] && [ -f "$SKILLS_HOME/skills/README.md" ]; then
  # Repo mode: project/skills
  PROJECT_ROOT="$SKILLS_HOME"
  SKILLS_LAYOUT="repo"
else
  # Embedded mode: ~/.claude/skills, ~/.codex/skills, project/.claude/skills, custom target/skills
  PROJECT_ROOT="$(cd "$SKILLS_HOME/.." && pwd)"
  SKILLS_LAYOUT="embedded"
fi

if [ "$SKILLS_LAYOUT" = "repo" ]; then
  AGENT_HOME_NAME="repo"
fi

case "$AGENT_HOME_NAME" in
  repo)
    AGENT_LABEL="本地 Agent"
    AGENT_COMMAND_HINT_EN="0-scrum-master or 0-emperor"
    AGENT_COMMAND_HINT_ZH="0-scrum-master 或 0-emperor"
    AGENT_HOOKS_NOTE_ZH="仓库调试模式：本 setup 会准备本地 .claude/.codex 技能链接，并可初始化项目 Harness / Git hooks / repo-map"
    AGENT_HOOKS_NOTE_EN="Repository debug mode: this setup prepares local .claude/.codex skill links and can initialize project harness / git hooks / repo-map"
    ;;
  .claude)
    AGENT_LABEL="Claude Code"
    AGENT_COMMAND_HINT_EN="/0-scrum-master or /0-emperor"
    AGENT_COMMAND_HINT_ZH="/0-scrum-master 或 /0-emperor"
    AGENT_HOOKS_NOTE_ZH="Claude hooks 已通过 .claude/settings.json 自动配置，无需手动设置"
    AGENT_HOOKS_NOTE_EN="Claude hooks auto-configured via .claude/settings.json"
    ;;
  .codex)
    AGENT_LABEL="Codex"
    AGENT_COMMAND_HINT_EN="0-scrum-master or 0-emperor"
    AGENT_COMMAND_HINT_ZH="0-scrum-master 或 0-emperor"
    AGENT_HOOKS_NOTE_ZH="Codex 不使用 Claude 的 settings.json hooks；本 setup 仅负责用户配置、git hook 和 repo-map"
    AGENT_HOOKS_NOTE_EN="Codex does not use Claude settings.json hooks; this setup only prepares user config, git hook and repo-map"
    ;;
  *)
    AGENT_LABEL="${AGENT_HOME_NAME#.}"
    AGENT_COMMAND_HINT_EN="0-scrum-master or 0-emperor"
    AGENT_COMMAND_HINT_ZH="0-scrum-master 或 0-emperor"
    AGENT_HOOKS_NOTE_ZH="当前目标目录不是 Claude 专用目录；本 setup 仅负责用户配置、git hook 和 repo-map"
    AGENT_HOOKS_NOTE_EN="Current target is not a Claude-specific directory; this setup only prepares user config, git hook and repo-map"
    ;;
esac

if [ "$SKILLS_LAYOUT" = "repo" ]; then
  GSTACK_SETUP_HINT_EN=".claude/skills/gstack/setup or .codex/skills/gstack/setup"
  GSTACK_SETUP_HINT_ZH=".claude/skills/gstack/setup 或 .codex/skills/gstack/setup"
else
  GSTACK_SETUP_HINT_EN="$SKILLS_HOME/skills/gstack/setup"
  GSTACK_SETUP_HINT_ZH="$SKILLS_HOME/skills/gstack/setup"
fi

# ---- Defaults ----
MODE=""
LANG="zh"
NICKNAME="吴彦祖"
INSTALL_GIT_HOOK="yes"
GENERATE_REPO_MAP="yes"
PROJECT_ROOT_OVERRIDE=""

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
    --skip-repo-map)
      GENERATE_REPO_MAP="no"
      ;;
    --project-root=*)
      PROJECT_ROOT_OVERRIDE="${arg#--project-root=}"
      ;;
    --help|-h)
      echo "Usage: sh setup.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --default        Non-interactive mode, use all defaults"
      echo "  --interactive    Force interactive mode (even in pipe)"
      echo "  --lang=LANG      Set language: zh (default) or en"
      echo "  --nickname=NAME  Set nickname (default: 吴彦祖)"
      echo "  --no-git-hook    Skip repository core.hooksPath wiring"
      echo "  --skip-repo-map  Skip .cache/shared/repo-map.md generation"
      echo "  --project-root=PATH Install git hook/repo-map against specific project root"
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

if [ -n "$PROJECT_ROOT_OVERRIDE" ]; then
  case "$PROJECT_ROOT_OVERRIDE" in
    "~"*) PROJECT_ROOT_OVERRIDE="${HOME}${PROJECT_ROOT_OVERRIDE#\~}" ;;
  esac
  PROJECT_ROOT="$PROJECT_ROOT_OVERRIDE"
fi

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
    MSG_GIT="Install repository harness hooks? [Y/n]: "
    MSG_DONE="Setup complete!"
    MSG_NEXT="Open your project in ${AGENT_LABEL} and start with ${AGENT_COMMAND_HINT_EN}"
    MSG_HOOKS_AUTO="$AGENT_HOOKS_NOTE_EN"
    MSG_GIT_OK="Repository harness hooks installed"
    MSG_SKIP="Skipped"
    MSG_LANG_PROMPT="Select language / 选择语言 [1=中文, 2=English] (1): "
    MSG_DEFAULT_MODE="Running in non-interactive mode with defaults"
  else
    MSG_BANNER="=== Scrum Skills 技能组配置 ==="
    MSG_NICKNAME="你希望AI怎么称呼你？(默认: 吴彦祖): "
    MSG_GIT="是否安装仓库 Harness hooks？[Y/n]: "
    MSG_DONE="配置完成！"
    MSG_NEXT="在 ${AGENT_LABEL} 中使用 ${AGENT_COMMAND_HINT_ZH} 开始"
    MSG_HOOKS_AUTO="$AGENT_HOOKS_NOTE_ZH"
    MSG_GIT_OK="仓库 Harness hooks 已安装"
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

# ---- Create local agent skill links (repo layout only) ----
if [ "$SKILLS_LAYOUT" = "repo" ]; then
  prepare_repo_agent_skills() {
    AGENT_DIR_NAME="$1"
    AGENT_SKILLS_DIR="$PROJECT_ROOT/$AGENT_DIR_NAME/skills"
    LINK_COUNT=0
    COPY_COUNT=0

    mkdir -p "$AGENT_SKILLS_DIR"

    if [ ! -L "$AGENT_SKILLS_DIR/hooks" ] && [ ! -e "$AGENT_SKILLS_DIR/hooks" ]; then
      if ln -sf "../../skills/hooks" "$AGENT_SKILLS_DIR/hooks" 2>/dev/null; then
        LINK_COUNT=$((LINK_COUNT + 1))
      else
        cp -R "$SKILLS_DIR/hooks" "$AGENT_SKILLS_DIR/hooks"
        COPY_COUNT=$((COPY_COUNT + 1))
      fi
    fi

    for SKILL_FILE in "$SKILLS_DIR"/*/SKILL.md; do
      [ ! -f "$SKILL_FILE" ] && continue
      SKILL_DIR=$(dirname "$SKILL_FILE")
      SKILL_NAME=$(basename "$SKILL_DIR")
      DEST_PATH="$AGENT_SKILLS_DIR/$SKILL_NAME"
      if [ -L "$DEST_PATH" ] || [ -e "$DEST_PATH" ]; then
        continue
      fi
      if ln -sf "../../skills/${SKILL_NAME}" "$DEST_PATH" 2>/dev/null; then
        LINK_COUNT=$((LINK_COUNT + 1))
      else
        cp -R "$SKILL_DIR" "$DEST_PATH"
        COPY_COUNT=$((COPY_COUNT + 1))
      fi
    done

    if [ "$LANG" = "en" ]; then
      echo "  $AGENT_DIR_NAME/skills ready (links: $LINK_COUNT, copies: $COPY_COUNT)"
    else
      echo "  $AGENT_DIR_NAME/skills 已就绪（软链接 $LINK_COUNT，复制 $COPY_COUNT）"
    fi
  }

  prepare_repo_agent_skills ".claude"
  prepare_repo_agent_skills ".codex"
else
  if [ "$LANG" = "en" ]; then
    echo "  Embedded layout detected, skip symlink creation"
  else
    echo "  检测到嵌入式目录结构，跳过软链接创建"
  fi
fi

if [ -d "$SKILLS_DIR/gstack" ] && [ -f "$SKILLS_DIR/gstack/setup" ]; then
  if [ "$LANG" = "en" ]; then
    echo "  gstack vendored: run $GSTACK_SETUP_HINT_EN to enable its full skill pack"
    if ! command -v bun >/dev/null 2>&1; then
      echo "  note: bun is required before gstack can finish setup"
    fi
  else
    echo "  已检测到 vendored gstack：如需启用其完整技能组，请执行 $GSTACK_SETUP_HINT_ZH"
    if ! command -v bun >/dev/null 2>&1; then
      echo "  提示：gstack 需要先安装 bun 才能完成 setup"
    fi
  fi
fi

# ---- Project Harness Initialization ----
HOME_DIR_CURRENT="${HOME:-$USERPROFILE}"
HOME_DIR_CURRENT="$(echo "$HOME_DIR_CURRENT" | sed 's|\\|/|g')"
PROJECT_ROOT_NORMALIZED="$(echo "$PROJECT_ROOT" | sed 's|\\|/|g')"
HARNESS_INIT_SCRIPT="$SKILLS_DIR/harness/bin/harness-init.sh"

if [ "$SKILLS_LAYOUT" = "embedded" ] && [ "$PROJECT_ROOT_NORMALIZED" = "$HOME_DIR_CURRENT" ] && [ -z "$PROJECT_ROOT_OVERRIDE" ]; then
  if [ "$LANG" = "en" ]; then
    echo "  Skipped project harness init in home directory (use --project-root=PATH for a repo)"
  else
    echo "  检测为用户主目录，跳过项目 Harness 初始化（可用 --project-root=PATH 指定仓库）"
  fi
elif [ ! -f "$HARNESS_INIT_SCRIPT" ]; then
  echo "  harness-init.sh not found, skipped"
else
  sh "$HARNESS_INIT_SCRIPT" --project-root="$PROJECT_ROOT" --lang="$LANG"
  if [ "$INSTALL_GIT_HOOK" = "yes" ]; then
    echo "  $MSG_GIT_OK"
  elif [ -d "$PROJECT_ROOT/.git" ]; then
    (
      cd "$PROJECT_ROOT"
      git config --unset core.hooksPath 2>/dev/null || true
    )
    if [ "$LANG" = "en" ]; then
      echo "  Harness artifacts created, git hook wiring skipped"
    else
      echo "  已生成 Harness 产物，但跳过 git hook 接线"
    fi
  else
    echo "  $MSG_SKIP"
  fi
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

# ---- Generate Code Skeleton (appended to repo-map.md) ----
generate_code_skeleton() {
  SHARED_DIR="$PROJECT_ROOT/.cache/shared"
  REPO_MAP="$SHARED_DIR/repo-map.md"
  [ ! -f "$REPO_MAP" ] && return 0

  # Collect source files (max 50, exclude test/spec/node_modules/vendor/.git)
  SRC_FILES=""
  FILE_COUNT=0
  for search_dir in src lib app cmd pkg; do
    [ ! -d "$PROJECT_ROOT/$search_dir" ] && continue
    FOUND=$(find "$PROJECT_ROOT/$search_dir" -type f \
      \( -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' \
         -o -name '*.py' -o -name '*.java' -o -name '*.go' -o -name '*.rs' \) \
      -not -path '*/node_modules/*' -not -path '*/.git/*' \
      -not -path '*/vendor/*' \
      -not -name '*.test.*' -not -name '*.spec.*' \
      -not -name '*_test.go' -not -name '*_test.rs' \
      2>/dev/null | head -n $((50 - FILE_COUNT)))
    for f in $FOUND; do
      SRC_FILES="$SRC_FILES $f"
      FILE_COUNT=$((FILE_COUNT + 1))
      [ "$FILE_COUNT" -ge 50 ] && break
    done
    [ "$FILE_COUNT" -ge 50 ] && break
  done

  [ -z "$SRC_FILES" ] && return 0

  # Append skeleton header
  printf '\n## 代码骨架（Code Skeleton）\n\n' >> "$REPO_MAP"
  printf '> 自动提取的顶层函数/类/接口签名，帮助 AI 快速理解代码结构\n' >> "$REPO_MAP"

  for filepath in $SRC_FILES; do
    REL_PATH=$(echo "$filepath" | sed "s|^$PROJECT_ROOT/||")
    EXT="${filepath##*.}"
    SIGS=""
    case "$EXT" in
      js|ts|tsx|jsx)
        SIGS=$(grep -n '^export \(function\|class\|const\|interface\|type\|enum\)' "$filepath" 2>/dev/null | head -n 10)
        ;;
      py)
        SIGS=$(grep -n '^def \|^class ' "$filepath" 2>/dev/null | head -n 10)
        ;;
      java)
        SIGS=$(grep -n '^\(public\|protected\) \(class\|interface\|abstract class\)' "$filepath" 2>/dev/null | head -n 5)
        METHOD_SIGS=$(grep -n '^\s*public\s\|^\s*protected\s' "$filepath" 2>/dev/null | grep '(' | head -n 5)
        [ -n "$METHOD_SIGS" ] && SIGS=$(printf '%s\n%s' "$SIGS" "$METHOD_SIGS")
        SIGS=$(echo "$SIGS" | head -n 10)
        ;;
      go)
        SIGS=$(grep -n '^func [A-Z]\|^type [A-Z]' "$filepath" 2>/dev/null | head -n 10)
        ;;
      rs)
        SIGS=$(grep -n '^pub fn \|^pub struct \|^pub enum \|^pub trait ' "$filepath" 2>/dev/null | head -n 10)
        ;;
    esac

    [ -z "$SIGS" ] && continue

    printf '\n### `%s`\n' "$REL_PATH" >> "$REPO_MAP"
    echo "$SIGS" | while IFS= read -r line; do
      [ -z "$line" ] && continue
      # Strip line number prefix, trim whitespace
      SIG=$(echo "$line" | sed 's/^[0-9]*://' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
      [ -n "$SIG" ] && printf -- '- %s\n' "$SIG" >> "$REPO_MAP"
    done
  done

  if [ "$LANG" = "en" ]; then
    echo "  Code skeleton appended to repo-map.md"
  else
    echo "  代码骨架已追加到 repo-map.md"
  fi
}

REPO_MAP_SCRIPT="$SKILLS_DIR/harness/bin/harness-repo-map.sh"

if [ "$GENERATE_REPO_MAP" = "yes" ] && [ -d "$PROJECT_ROOT/.git" ]; then
  if [ -f "$REPO_MAP_SCRIPT" ]; then
    sh "$REPO_MAP_SCRIPT" --project-root="$PROJECT_ROOT"
  else
    generate_repo_map
    generate_code_skeleton
  fi
else
  if [ "$GENERATE_REPO_MAP" = "no" ]; then
    if [ "$LANG" = "en" ]; then
      echo "  Repo-map generation skipped by option"
    else
      echo "  已按参数跳过 repo-map 生成"
    fi
  else
    if [ "$LANG" = "en" ]; then
      echo "  No .git repository at project root, skipping repo-map generation"
    else
      echo "  项目根目录无 .git，跳过 repo-map 生成"
    fi
  fi
fi

echo ""
echo "$MSG_DONE"
echo ""
echo "  $MSG_NEXT"
echo ""
