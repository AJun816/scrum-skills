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
      echo "Usage: sh harness-repo-index.sh [--project-root=PATH]"
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
ARCH_STYLE="$(harness_detect_architecture "$PROJECT_ROOT")"

SHARED_DIR="$PROJECT_ROOT/.cache/shared"
INDEX_FILE="$SHARED_DIR/repo-index.json"
FILES_TMP="$(mktemp "${TMPDIR:-/tmp}/repo-index-files.XXXXXX")"
MODULES_TMP="$(mktemp "${TMPDIR:-/tmp}/repo-index-modules.XXXXXX")"
trap 'rm -f "$FILES_TMP" "$MODULES_TMP"' EXIT HUP INT TERM

mkdir -p "$SHARED_DIR"

find "$PROJECT_ROOT" -type f \
  -not -path "$PROJECT_ROOT/.git/*" \
  -not -path "$PROJECT_ROOT/node_modules/*" \
  -not -path "$PROJECT_ROOT/.cache/shared/repo-index.json" \
  -not -path "$PROJECT_ROOT/.cache/shared/workflow-runtime/*" \
  -not -path "$PROJECT_ROOT/.worktrees/*" \
  -not -path "$PROJECT_ROOT/dist/*" \
  -not -path "$PROJECT_ROOT/build/*" \
  -not -path "$PROJECT_ROOT/target/*" \
  -not -path "$PROJECT_ROOT/.next/*" \
  -not -path "$PROJECT_ROOT/.turbo/*" \
  | sed "s|^$PROJECT_ROOT/||" \
  | sort > "$FILES_TMP"

while IFS= read -r relative_path; do
  [ -z "$relative_path" ] && continue
  case "$relative_path" in
    */*)
      printf '%s\n' "${relative_path%%/*}" >> "$MODULES_TMP"
      ;;
    *)
      printf '.\n' >> "$MODULES_TMP"
      ;;
  esac
done < "$FILES_TMP"

detect_file_kind() {
  FILE_PATH="$1"
  case "$FILE_PATH" in
    *.md|*.txt)
      echo "doc"
      ;;
    *.json|*.yaml|*.yml|*.toml|*.xml|*.ini|*.conf|*.properties)
      echo "config"
      ;;
    *.sh|*.bash|*.zsh|*.ps1)
      echo "script"
      ;;
    *.js|*.jsx|*.ts|*.tsx|*.vue|*.py|*.java|*.go|*.rs|*.rb|*.php|*.c|*.cc|*.cpp|*.h)
      echo "source"
      ;;
    *.png|*.jpg|*.jpeg|*.gif|*.svg|*.ico|*.webp)
      echo "asset"
      ;;
    *)
      echo "other"
      ;;
  esac
}

detect_module_kind() {
  MODULE_NAME="$1"
  case "$MODULE_NAME" in
    .)
      echo "root"
      ;;
    src|app|web|pkg|cmd|lib)
      echo "app"
      ;;
    skills|docs|scripts|bin|config|tests|test)
      echo "support"
      ;;
    .harness)
      echo "harness"
      ;;
    *)
      echo "module"
      ;;
  esac
}

ENTRY_BACKEND=""
ENTRY_FRONTEND=""

for candidate in src/main/java src/main.ts src/main.py src/index.ts src/index.js src/app.ts src/app.js src/app.py main.go cmd/main.go src/main.rs; do
  if [ -f "$PROJECT_ROOT/$candidate" ]; then
    ENTRY_BACKEND="$candidate"
    break
  fi
done

for candidate in src/main.ts src/main.js src/index.tsx src/index.js src/App.vue src/App.tsx; do
  if [ -f "$PROJECT_ROOT/$candidate" ]; then
    ENTRY_FRONTEND="$candidate"
    break
  fi
done

FILE_COUNT="$(wc -l < "$FILES_TMP" | tr -d ' ')"
MODULE_COUNT="$(sort "$MODULES_TMP" | uniq | sed '/^$/d' | wc -l | tr -d ' ')"

{
  printf '{\n'
  printf '  "generated_at": "%s",\n' "$(harness_json_escape "$TIMESTAMP")"
  printf '  "generated_from_commit": "%s",\n' "$(harness_json_escape "$COMMIT_HASH")"
  printf '  "project": {\n'
  printf '    "name": "%s",\n' "$(harness_json_escape "$PROJECT_NAME")"
  printf '    "root": ".",\n'
  printf '    "architecture_style": "%s"\n' "$(harness_json_escape "$ARCH_STYLE")"
  printf '  },\n'
  printf '  "tech_stack": {\n'
  printf '    "backend": "%s",\n' "$(harness_json_escape "$BACKEND")"
  printf '    "frontend": "%s",\n' "$(harness_json_escape "$FRONTEND")"
  printf '    "database": "%s",\n' "$(harness_json_escape "$DATABASE")"
  printf '    "build_tool": "%s"\n' "$(harness_json_escape "$BUILD_TOOL")"
  printf '  },\n'
  printf '  "summary": {\n'
  printf '    "file_count": %s,\n' "${FILE_COUNT:-0}"
  printf '    "module_count": %s\n' "${MODULE_COUNT:-0}"
  printf '  },\n'
  printf '  "entries": [\n'
  ENTRY_FIRST="yes"
  if [ -n "$ENTRY_BACKEND" ]; then
    printf '    {"role":"backend","path":"%s"}' "$(harness_json_escape "$ENTRY_BACKEND")"
    ENTRY_FIRST="no"
  fi
  if [ -n "$ENTRY_FRONTEND" ]; then
    [ "$ENTRY_FIRST" = "yes" ] || printf ',\n'
    printf '    {"role":"frontend","path":"%s"}' "$(harness_json_escape "$ENTRY_FRONTEND")"
    ENTRY_FIRST="no"
  fi
  printf '\n  ],\n'
  printf '  "modules": [\n'
  MODULE_FIRST="yes"
  sort "$MODULES_TMP" | uniq -c | while read -r count module_name; do
    [ -z "$module_name" ] && continue
    [ "$MODULE_FIRST" = "yes" ] || printf ',\n'
    MODULE_FIRST="no"
    if [ "$module_name" = "." ]; then
      module_path="."
    else
      module_path="$module_name"
    fi
    printf '    {"name":"%s","path":"%s","kind":"%s","file_count":%s}' \
      "$(harness_json_escape "$module_name")" \
      "$(harness_json_escape "$module_path")" \
      "$(detect_module_kind "$module_name")" \
      "$count"
  done
  printf '\n  ],\n'
  printf '  "files": [\n'
  FILE_FIRST="yes"
  while IFS= read -r relative_path; do
    [ -z "$relative_path" ] && continue
    case "$relative_path" in
      *.*) ext="${relative_path##*.}" ;;
      *) ext="" ;;
    esac
    case "$relative_path" in
      */*) top_level="${relative_path%%/*}" ;;
      *) top_level="." ;;
    esac
    [ "$FILE_FIRST" = "yes" ] || printf ',\n'
    FILE_FIRST="no"
    printf '    {"path":"%s","ext":"%s","top_level":"%s","kind":"%s"}' \
      "$(harness_json_escape "$relative_path")" \
      "$(harness_json_escape "$ext")" \
      "$(harness_json_escape "$top_level")" \
      "$(detect_file_kind "$relative_path")"
  done < "$FILES_TMP"
  printf '\n  ]\n'
  printf '}\n'
} > "$INDEX_FILE"

echo "Repo index generated: $INDEX_FILE"
