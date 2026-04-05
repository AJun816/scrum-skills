#!/bin/sh
# Scrum Skills - PostToolUse Hook: Write/Edit
# Code quality checks after file write
# Post hooks: exit 0 = warn, exit 2 = block (used for lint errors)

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')

[ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ] && exit 0

FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"//')
[ -z "$FILE_PATH" ] && exit 0
[ ! -f "$FILE_PATH" ] && exit 0

# Skip non-code files
echo "$FILE_PATH" | grep -qiE '\.(js|ts|jsx|tsx|vue|java|py|go|rs|rb|php|cs|cpp|c|h|kt|swift)$' || exit 0

WARNINGS=""

# ---- 0. Append change log ----
append_change_log() {
  LOG_DIR=".cache/shared"
  LOG_FILE="$LOG_DIR/change-log.md"
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  FILE_ARG="$1"
  TOOL_ARG="$2"

  # Determine change type: add or modify
  if git ls-files --error-unmatch "$FILE_ARG" >/dev/null 2>&1; then
    CHANGE_TYPE="modify"
  else
    CHANGE_TYPE="add"
  fi

  # Ensure directory exists
  mkdir -p "$LOG_DIR"

  # Create header if file doesn't exist or is empty
  if [ ! -s "$LOG_FILE" ]; then
    printf "| 时间 | 文件 | 类型 | 工具 |\n" > "$LOG_FILE"
    printf "| --- | --- | --- | --- |\n" >> "$LOG_FILE"
  fi

  # Append record
  printf "| %s | %s | %s | %s |\n" "$TIMESTAMP" "$FILE_ARG" "$CHANGE_TYPE" "$TOOL_ARG" >> "$LOG_FILE"
}

append_change_log "$FILE_PATH" "$TOOL_NAME"

# ---- 1. File size warning (Edit may push file over limit) ----
LINE_COUNT=$(wc -l < "$FILE_PATH" 2>/dev/null || echo "0")
LINE_COUNT=$(echo "$LINE_COUNT" | tr -d ' ')
if [ "$LINE_COUNT" -gt 800 ]; then
  WARNINGS="${WARNINGS}\n  - ❌ File has $LINE_COUNT lines (>800), must split / 文件${LINE_COUNT}行，必须拆分"
elif [ "$LINE_COUNT" -gt 600 ]; then
  WARNINGS="${WARNINGS}\n  - ⚠️ File has $LINE_COUNT lines (>600), consider splitting / 文件${LINE_COUNT}行，建议拆分"
fi

# ---- 2. Long function/method detection (>50 lines) ----
# Detect function definitions and count lines to closing brace
check_long_functions() {
  FILE="$1"
  THRESHOLD=50
  EXT=$(echo "$FILE" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')

  case "$EXT" in
    py)
      # Python: count lines after def/class until next def/class or dedent
      awk '
        /^[[:space:]]*(def |class )/ {
          if (fname != "" && count > '"$THRESHOLD"') {
            printf "    %s (%d lines)\n", fname, count
          }
          fname = $0; sub(/^[[:space:]]*/, "", fname); sub(/[(:].*/,"", fname)
          count = 0; next
        }
        { count++ }
        END {
          if (fname != "" && count > '"$THRESHOLD"') {
            printf "    %s (%d lines)\n", fname, count
          }
        }
      ' "$FILE"
      ;;
    js|ts|jsx|tsx|vue|java|go|rs|cs|cpp|c|h|kt|swift|php|rb)
      # Brace-based languages: track { } depth
      awk '
        /^[[:space:]]*(function |def |fn |func |pub fn |pub func |public |private |protected |static |async |export ).*\{/ ||
        /^[[:space:]]*(function |def |fn |func |pub fn |pub func |public |private |protected |static |async |export )/ {
          if (fname != "" && count > '"$THRESHOLD"') {
            printf "    %s (%d lines)\n", fname, count
          }
          fname = $0; sub(/^[[:space:]]*/, "", fname); sub(/\{.*/,"", fname)
          gsub(/[[:space:]]+$/, "", fname)
          count = 0; in_func = 1; next
        }
        in_func { count++ }
        END {
          if (fname != "" && count > '"$THRESHOLD"') {
            printf "    %s (%d lines)\n", fname, count
          }
        }
      ' "$FILE"
      ;;
  esac
}

LONG_FUNCS=$(check_long_functions "$FILE_PATH" 2>/dev/null || true)
if [ -n "$LONG_FUNCS" ]; then
  WARNINGS="${WARNINGS}\n  - ⚠️ Long functions (>50 lines) / 过长方法:\n${LONG_FUNCS}"
fi

# ---- 3. Nesting depth check (>4 levels) ----
MAX_NESTING=$(awk '
  BEGIN { max = 0; depth = 0 }
  {
    for (i = 1; i <= length($0); i++) {
      ch = substr($0, i, 1)
      if (ch == "{") { depth++; if (depth > max) max = depth }
      if (ch == "}") { depth-- }
    }
  }
  END { print max }
' "$FILE_PATH" 2>/dev/null || echo "0")

if [ "$MAX_NESTING" -gt 6 ]; then
  WARNINGS="${WARNINGS}\n  - ❌ Nesting depth $MAX_NESTING (>6), must refactor / 嵌套${MAX_NESTING}层，必须重构"
elif [ "$MAX_NESTING" -gt 4 ]; then
  WARNINGS="${WARNINGS}\n  - ⚠️ Nesting depth $MAX_NESTING (>4), consider refactoring / 嵌套${MAX_NESTING}层，建议重构"
fi

# ---- 4. Code smell detection ----
if grep -nE '\bconsole\.(log|debug|info)\b' "$FILE_PATH" >/dev/null 2>&1; then
  COUNT=$(grep -cE '\bconsole\.(log|debug|info)\b' "$FILE_PATH" 2>/dev/null || echo "0")
  WARNINGS="${WARNINGS}\n  - ⚠️ console.log detected ($COUNT occurrences) / 检测到console.log (${COUNT}处)"
fi

if grep -niE '//\s*(TODO|FIXME|HACK|XXX)\b' "$FILE_PATH" >/dev/null 2>&1; then
  COUNT=$(grep -ciE '//\s*(TODO|FIXME|HACK|XXX)\b' "$FILE_PATH" 2>/dev/null || echo "0")
  WARNINGS="${WARNINGS}\n  - ⚠️ TODO/FIXME comments ($COUNT) / TODO/FIXME注释 (${COUNT}处)"
fi

# Python TODO/FIXME (# style comments)
if echo "$FILE_PATH" | grep -qiE '\.py$'; then
  if grep -niE '#\s*(TODO|FIXME|HACK|XXX)\b' "$FILE_PATH" >/dev/null 2>&1; then
    COUNT=$(grep -ciE '#\s*(TODO|FIXME|HACK|XXX)\b' "$FILE_PATH" 2>/dev/null || echo "0")
    WARNINGS="${WARNINGS}\n  - ⚠️ TODO/FIXME comments ($COUNT) / TODO/FIXME注释 (${COUNT}处)"
  fi
fi

# ---- 5. Run project linter if available (errors block, warnings report) ----
EXT=$(echo "$FILE_PATH" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')
LINTER_OUTPUT=""
LINT_HAS_ERROR=""

case "$EXT" in
  js|jsx|ts|tsx|vue)
    if command -v npx >/dev/null 2>&1 && [ -f "node_modules/.bin/eslint" ]; then
      LINTER_OUTPUT=$(npx eslint --no-error-on-unmatched-pattern --format compact "$FILE_PATH" 2>/dev/null | tail -5 || true)
      if echo "$LINTER_OUTPUT" | grep -qE '[0-9]+ error'; then
        LINT_HAS_ERROR="yes"
      fi
    fi
    ;;
  py)
    if command -v ruff >/dev/null 2>&1; then
      LINTER_OUTPUT=$(ruff check "$FILE_PATH" 2>/dev/null | tail -5 || true)
      if [ -n "$LINTER_OUTPUT" ]; then
        LINT_HAS_ERROR="yes"
      fi
    elif command -v flake8 >/dev/null 2>&1; then
      LINTER_OUTPUT=$(flake8 --max-line-length=120 "$FILE_PATH" 2>/dev/null | tail -5 || true)
      if [ -n "$LINTER_OUTPUT" ]; then
        LINT_HAS_ERROR="yes"
      fi
    fi
    ;;
  go)
    if command -v go >/dev/null 2>&1; then
      LINTER_OUTPUT=$(go vet "$FILE_PATH" 2>&1 | tail -5 || true)
      if [ -n "$LINTER_OUTPUT" ]; then
        LINT_HAS_ERROR="yes"
      fi
    fi
    ;;
esac

if [ -n "$LINTER_OUTPUT" ]; then
  if [ "$LINT_HAS_ERROR" = "yes" ]; then
    WARNINGS="${WARNINGS}\n  - ❌ Lint errors detected (must fix) / 检测到Lint错误（必须修复）:\n    ${LINTER_OUTPUT}"
  else
    WARNINGS="${WARNINGS}\n  - ⚠️ Lint warnings / Lint警告:\n    ${LINTER_OUTPUT}"
  fi
fi

# ---- Output ----
if [ -n "$WARNINGS" ]; then
  printf "📋 Code quality report / 代码质量报告 [%s]:%b\n" "$(basename "$FILE_PATH")" "$WARNINGS" >&2
fi

# Block if lint errors found — AI must fix before continuing
if [ "$LINT_HAS_ERROR" = "yes" ]; then
  echo "" >&2
  echo "🚫 Lint errors block further edits. Fix the errors above first." >&2
  echo "   Lint 错误阻止后续编辑，请先修复上述错误。" >&2
  exit 2
fi

# ---- 6. Harness drift check ----
if [ -x ".harness/bin/harness-check.sh" ]; then
  HARNESS_STATUS=0
  sh ./.harness/bin/harness-check.sh --files="$FILE_PATH" >/dev/null 2>&1 || HARNESS_STATUS=$?

  if [ "$HARNESS_STATUS" -eq 2 ] && [ -x ".harness/bin/harness-fix.sh" ]; then
    sh ./.harness/bin/harness-fix.sh --files="$FILE_PATH" >/dev/null 2>&1 || HARNESS_STATUS=$?
    sh ./.harness/bin/harness-check.sh --files="$FILE_PATH" >/dev/null 2>&1 || HARNESS_STATUS=$?
  fi

  if [ "$HARNESS_STATUS" -ne 0 ]; then
    echo "" >&2
    echo "🚫 Harness drift detected. Repository contract rejected this edit." >&2
    echo "   检测到 Harness 漂移，仓库合同拒绝这次修改。" >&2
    sh ./.harness/bin/harness-check.sh --files="$FILE_PATH" || true
    exit 2
  fi
fi

exit 0
