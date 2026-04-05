#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/harness-common.sh"

PROJECT_ROOT="$(pwd)"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --help|-h)
      echo "Usage: sh harness-repo-map.sh [--project-root=PATH]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
PROJECT_NAME="$(harness_project_name "$PROJECT_ROOT")"
TIMESTAMP="$(harness_now_iso)"
COMMIT_HASH="$(harness_git_commit "$PROJECT_ROOT")"
BACKEND="$(harness_detect_backend "$PROJECT_ROOT")"
FRONTEND="$(harness_detect_frontend "$PROJECT_ROOT")"
DATABASE="$(harness_detect_database "$PROJECT_ROOT")"
BUILD_TOOL="$(harness_detect_build "$PROJECT_ROOT")"

SHARED_DIR="$PROJECT_ROOT/.cache/shared"
REPO_MAP="$SHARED_DIR/repo-map.md"
SRC_LIST_FILE="$(mktemp "${TMPDIR:-/tmp}/repo-map-src.XXXXXX")"
trap 'rm -f "$SRC_LIST_FILE"' EXIT HUP INT TERM

mkdir -p "$SHARED_DIR"

if command -v tree >/dev/null 2>&1; then
  DIR_TREE="$(cd "$PROJECT_ROOT" && tree -L 2 -d --noreport -I 'node_modules|.git|dist|build|.cache|.venv|venv|__pycache__|.idea|.vscode|target|.gradle|.worktrees' 2>/dev/null || echo '(tree command failed)')"
else
  DIR_TREE="$(cd "$PROJECT_ROOT" && find . -maxdepth 2 -type d \
    -not -path '*/node_modules*' -not -path '*/.git*' -not -path '*/dist*' \
    -not -path '*/build*' -not -path '*/.cache*' -not -path '*/.venv*' \
    -not -path '*/venv*' -not -path '*/__pycache__*' -not -path '*/.idea*' \
    -not -path '*/.vscode*' -not -path '*/target*' -not -path '*/.gradle*' \
    -not -path '*/.worktrees*' 2>/dev/null | sort || echo '(find failed)')"
fi

ENTRY_BACKEND="(not detected)"
ENTRY_FRONTEND="(not detected)"
CONFIG_FILES=""

for f in src/main/java src/main.ts src/main.py src/index.ts src/index.js src/app.ts src/app.js src/app.py main.go cmd/main.go src/main.rs; do
  if [ -f "$PROJECT_ROOT/$f" ]; then
    ENTRY_BACKEND="$f"
    break
  fi
done

for f in src/main.ts src/main.js src/index.tsx src/index.js src/App.vue src/App.tsx; do
  if [ -f "$PROJECT_ROOT/$f" ]; then
    ENTRY_FRONTEND="$f"
    break
  fi
done

for f in package.json tsconfig.json vite.config.ts vite.config.js webpack.config.js pom.xml build.gradle build.gradle.kts go.mod Cargo.toml pyproject.toml requirements.txt docker-compose.yml docker-compose.yaml Dockerfile .env.example; do
  if [ -f "$PROJECT_ROOT/$f" ]; then
    CONFIG_FILES="${CONFIG_FILES}${f}, "
  fi
done
CONFIG_FILES="$(echo "$CONFIG_FILES" | sed 's/, $//')"

UTILS_DESC="(not found)"
COMMON_DESC="(not found)"
SHARED_DESC="(not found)"
[ -d "$PROJECT_ROOT/src/utils" ] || [ -d "$PROJECT_ROOT/utils" ] && UTILS_DESC="Utility functions"
[ -d "$PROJECT_ROOT/src/common" ] || [ -d "$PROJECT_ROOT/common" ] && COMMON_DESC="Common modules"
[ -d "$PROJECT_ROOT/src/shared" ] || [ -d "$PROJECT_ROOT/shared" ] && SHARED_DESC="Shared resources"
[ -d "$PROJECT_ROOT/src/lib" ] || [ -d "$PROJECT_ROOT/lib" ] && UTILS_DESC="Library utilities"

cat > "$REPO_MAP" <<EOF
# 仓库地图

**生成时间：** ${TIMESTAMP}
**最后更新：** ${TIMESTAMP}
**基于提交：** ${COMMIT_HASH}

## 技术栈概览
- 项目：${PROJECT_NAME}
- 后端：${BACKEND}
- 前端：${FRONTEND}
- 数据库：${DATABASE}
- 构建工具：${BUILD_TOOL}

## 目录结构
\`\`\`
${DIR_TREE}
\`\`\`

## 入口文件
- 后端入口：${ENTRY_BACKEND}
- 前端入口：${ENTRY_FRONTEND}
- 配置文件：${CONFIG_FILES}

## 公共模块（复用扫描参考）
- utils/：${UTILS_DESC}
- common/：${COMMON_DESC}
- shared/：${SHARED_DESC}
EOF

printf '\n## 代码骨架（Code Skeleton）\n\n' >> "$REPO_MAP"
printf '> 自动提取的顶层函数/类/接口签名，帮助 AI 快速理解代码结构\n' >> "$REPO_MAP"

> "$SRC_LIST_FILE"
for search_dir in src lib app cmd pkg; do
  [ ! -d "$PROJECT_ROOT/$search_dir" ] && continue
  find "$PROJECT_ROOT/$search_dir" -type f \
    \( -name '*.js' -o -name '*.ts' -o -name '*.tsx' -o -name '*.jsx' \
       -o -name '*.py' -o -name '*.java' -o -name '*.go' -o -name '*.rs' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/vendor/*' \
    -not -name '*.test.*' -not -name '*.spec.*' -not -name '*_test.go' \
    -not -name '*_test.rs' 2>/dev/null >> "$SRC_LIST_FILE"
done

sort -u "$SRC_LIST_FILE" | sed -n '1,50p' | while IFS= read -r filepath; do
  REL_PATH="$(echo "$filepath" | sed "s|^$PROJECT_ROOT/||")"
  EXT="${filepath##*.}"
  SIGS=""
  case "$EXT" in
    js|ts|tsx|jsx)
      SIGS="$(grep -n '^export \(function\|class\|const\|interface\|type\|enum\)' "$filepath" 2>/dev/null | head -n 10)"
      ;;
    py)
      SIGS="$(grep -n '^def \|^class ' "$filepath" 2>/dev/null | head -n 10)"
      ;;
    java)
      SIGS="$(grep -n '^\(public\|protected\) \(class\|interface\|abstract class\)' "$filepath" 2>/dev/null | head -n 5)"
      METHOD_SIGS="$(grep -n '^\s*public\s\|^\s*protected\s' "$filepath" 2>/dev/null | grep '(' | head -n 5)"
      [ -n "$METHOD_SIGS" ] && SIGS="$(printf '%s\n%s' "$SIGS" "$METHOD_SIGS")"
      SIGS="$(echo "$SIGS" | head -n 10)"
      ;;
    go)
      SIGS="$(grep -n '^func [A-Z]\|^type [A-Z]' "$filepath" 2>/dev/null | head -n 10)"
      ;;
    rs)
      SIGS="$(grep -n '^pub fn \|^pub struct \|^pub enum \|^pub trait ' "$filepath" 2>/dev/null | head -n 10)"
      ;;
  esac

  [ -n "$SIGS" ] || continue
  printf '\n### `%s`\n' "$REL_PATH" >> "$REPO_MAP"
  printf '%s\n' "$SIGS" | while IFS= read -r line; do
    [ -n "$line" ] || continue
    SIG="$(echo "$line" | sed 's/^[0-9]*://' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')"
    [ -n "$SIG" ] && printf -- '- %s\n' "$SIG" >> "$REPO_MAP"
  done
done

echo "Repo map generated: $REPO_MAP"
