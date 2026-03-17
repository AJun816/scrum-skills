#!/bin/sh
# Scrum Skills - PreToolUse Hook: Bash
# Enforce on every git commit:
#   1. ✅[Reviewed] prefix (mandatory)
#   2. Lint check on staged files (mandatory, error = block)
#   3. Related test check on staged files (mandatory, failure = block)
# [skip-review] bypasses all checks

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')
COMMAND=$(echo "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*[,}].*//' | sed 's/\\"/"/g' | head -1)

[ "$TOOL_NAME" != "Bash" ] && exit 0
[ -z "$COMMAND" ] && exit 0

# ---- Only intercept git commit ----
echo "$COMMAND" | grep -qE '\bgit\s+commit\b' || exit 0

COMMIT_MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*['"'"'"]\([^'"'"'"]*\).*/\1/p')
if [ -z "$COMMIT_MSG" ]; then
  COMMIT_MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*\([^[:space:]]*\).*/\1/p')
fi

# Allow [skip-review] bypass for all checks (check parsed msg, raw command, and raw input)
if echo "$COMMAND" | grep -q '\[skip-review\]'; then
  exit 0
fi
if echo "$INPUT" | grep -q '\[skip-review\]'; then
  exit 0
fi

# ---- Check 0a: Co-Authored-By warning ----
if ! echo "$COMMAND" | grep -q 'Co-Authored-By' && ! echo "$INPUT" | grep -q 'Co-Authored-By'; then
  echo "⚠️ 建议添加 Co-Authored-By 标签" >&2
fi

# ---- Check 0b: Commit summary to change-log ----
LOG_DIR=".cache/shared"
LOG_FILE="$LOG_DIR/change-log.md"
STAGED_SUMMARY=$(git diff --cached --name-only 2>/dev/null | tr '\n' ', ' | sed 's/,$//')
if [ -n "$STAGED_SUMMARY" ]; then
  mkdir -p "$LOG_DIR"
  if [ ! -s "$LOG_FILE" ]; then
    printf "| 时间 | 文件 | 类型 | 工具 |\n" > "$LOG_FILE"
    printf "| --- | --- | --- | --- |\n" >> "$LOG_FILE"
  fi
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
  printf "| %s | [COMMIT] %s | commit | git |\n" "$TIMESTAMP" "$STAGED_SUMMARY" >> "$LOG_FILE"
fi

# ---- Check 1: Enforce ✅[Reviewed] prefix ----
if echo "$COMMAND" | grep -q '✅\[Reviewed\]'; then
  : # pass
elif echo "$INPUT" | grep -q '✅\[Reviewed\]'; then
  : # pass
elif [ -n "$COMMIT_MSG" ] && echo "$COMMIT_MSG" | grep -q '^✅\[Reviewed\]'; then
  : # pass
else
  echo "❌ Commit blocked / 提交被阻止" >&2
  echo "   Every commit must start with ✅[Reviewed] prefix" >&2
  echo "   每次提交必须以 ✅[Reviewed] 开头" >&2
  echo "   Format / 格式: ✅[Reviewed] your commit message" >&2
  echo "   Run @8-code-reviewer first / 请先执行 @8-code-reviewer 代码审查" >&2
  echo "   Or add [skip-review] to bypass / 或添加 [skip-review] 跳过" >&2
  exit 2
fi

# ---- Get staged code files ----
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACMR 2>/dev/null || true)
[ -z "$STAGED_FILES" ] && exit 0

CODE_EXTENSIONS='js|ts|jsx|tsx|vue|java|py|go|rs|rb|php|cs|cpp|c|h|kt|swift'
STAGED_CODE=$(echo "$STAGED_FILES" | grep -iE "\.($CODE_EXTENSIONS)$" || true)

# ---- Check 2: Lint check on staged code files ----
if [ -n "$STAGED_CODE" ]; then
  LINT_ERRORS=""

  for FILE in $STAGED_CODE; do
    [ ! -f "$FILE" ] && continue
    EXT=$(echo "$FILE" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')

    case "$EXT" in
      js|jsx|ts|tsx|vue)
        if command -v npx >/dev/null 2>&1 && [ -f "node_modules/.bin/eslint" ]; then
          RESULT=$(npx eslint --no-error-on-unmatched-pattern --format compact "$FILE" 2>/dev/null || true)
          if echo "$RESULT" | grep -qE '[0-9]+ error'; then
            LINT_ERRORS="${LINT_ERRORS}\n  ${FILE}: $(echo "$RESULT" | grep -oE '[0-9]+ error' | head -1)"
          fi
        fi
        ;;
      py)
        if command -v ruff >/dev/null 2>&1; then
          RESULT=$(ruff check "$FILE" 2>/dev/null || true)
          if [ -n "$RESULT" ]; then
            ERR_COUNT=$(echo "$RESULT" | grep -cE '^' 2>/dev/null || echo "0")
            LINT_ERRORS="${LINT_ERRORS}\n  ${FILE}: ${ERR_COUNT} issues"
          fi
        elif command -v flake8 >/dev/null 2>&1; then
          RESULT=$(flake8 --max-line-length=120 "$FILE" 2>/dev/null || true)
          if [ -n "$RESULT" ]; then
            ERR_COUNT=$(echo "$RESULT" | grep -cE '^' 2>/dev/null || echo "0")
            LINT_ERRORS="${LINT_ERRORS}\n  ${FILE}: ${ERR_COUNT} issues"
          fi
        fi
        ;;
      go)
        if command -v go >/dev/null 2>&1; then
          RESULT=$(go vet "$FILE" 2>&1 || true)
          if [ -n "$RESULT" ]; then
            LINT_ERRORS="${LINT_ERRORS}\n  ${FILE}: go vet errors"
          fi
        fi
        ;;
      java)
        if command -v checkstyle >/dev/null 2>&1; then
          RESULT=$(checkstyle -c /google_checks.xml "$FILE" 2>/dev/null || true)
          if echo "$RESULT" | grep -qiE 'error'; then
            LINT_ERRORS="${LINT_ERRORS}\n  ${FILE}: checkstyle errors"
          fi
        fi
        ;;
    esac
  done

  if [ -n "$LINT_ERRORS" ]; then
    echo "❌ Commit blocked: Lint errors / 提交被阻止：Lint 错误" >&2
    printf "   Files with errors / 存在错误的文件:%b\n" "$LINT_ERRORS" >&2
    echo "" >&2
    echo "   Fix lint errors then retry / 修复 Lint 错误后重试" >&2
    echo "   Or add [skip-review] to bypass / 或添加 [skip-review] 跳过" >&2
    exit 2
  fi
fi

# ---- Check 3: Related test check on staged code files ----
if [ -n "$STAGED_CODE" ]; then
  TEST_FILES=""
  HAS_TEST_RUNNER=""

  for FILE in $STAGED_CODE; do
    [ ! -f "$FILE" ] && continue
    # Skip test files themselves
    echo "$FILE" | grep -qiE '(test|spec|_test)\.' && continue
    echo "$FILE" | grep -qiE '(__tests__|test/|tests/)' && continue

    BASENAME=$(basename "$FILE" | sed 's/\.[^.]*$//')
    DIRNAME=$(dirname "$FILE")
    EXT=$(echo "$FILE" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]')

    # Search for related test files
    case "$EXT" in
      js|jsx|ts|tsx|vue)
        FOUND=$(find . -type f \( \
          -name "${BASENAME}.test.ts" -o \
          -name "${BASENAME}.test.tsx" -o \
          -name "${BASENAME}.test.js" -o \
          -name "${BASENAME}.test.jsx" -o \
          -name "${BASENAME}.spec.ts" -o \
          -name "${BASENAME}.spec.tsx" -o \
          -name "${BASENAME}.spec.js" -o \
          -name "${BASENAME}.spec.jsx" \
        \) -not -path '*/node_modules/*' 2>/dev/null | head -5 || true)
        if [ -n "$FOUND" ]; then
          TEST_FILES="${TEST_FILES} ${FOUND}"
        fi
        # Check test runner availability
        if [ -f "node_modules/.bin/vitest" ]; then
          HAS_TEST_RUNNER="vitest"
        elif [ -f "node_modules/.bin/jest" ]; then
          HAS_TEST_RUNNER="jest"
        fi
        ;;
      py)
        # Look in tests/ or same directory
        FOUND=$(find . -type f \( \
          -name "test_${BASENAME}.py" -o \
          -name "${BASENAME}_test.py" \
        \) -not -path '*/.venv/*' -not -path '*/venv/*' 2>/dev/null | head -5 || true)
        if [ -n "$FOUND" ]; then
          TEST_FILES="${TEST_FILES} ${FOUND}"
        fi
        if command -v pytest >/dev/null 2>&1; then
          HAS_TEST_RUNNER="pytest"
        fi
        ;;
      java)
        FOUND=$(find . -path "*/test/*" -name "${BASENAME}Test.java" 2>/dev/null | head -5 || true)
        if [ -n "$FOUND" ]; then
          TEST_FILES="${TEST_FILES} ${FOUND}"
        fi
        ;;
      go)
        TEST_GO="${DIRNAME}/${BASENAME}_test.go"
        if [ -f "$TEST_GO" ]; then
          TEST_FILES="${TEST_FILES} ${TEST_GO}"
        fi
        if command -v go >/dev/null 2>&1; then
          HAS_TEST_RUNNER="go"
        fi
        ;;
    esac
  done

  # Deduplicate test files
  if [ -n "$TEST_FILES" ]; then
    TEST_FILES=$(echo "$TEST_FILES" | tr ' ' '\n' | sort -u | tr '\n' ' ')
  fi

  # Run related tests if found and runner available
  if [ -n "$TEST_FILES" ] && [ -n "$HAS_TEST_RUNNER" ]; then
    TEST_FAILED=""
    case "$HAS_TEST_RUNNER" in
      vitest)
        # Run specific test files
        for TF in $TEST_FILES; do
          RESULT=$(npx vitest run "$TF" --reporter=verbose 2>&1 || true)
          if echo "$RESULT" | grep -qiE '(FAIL|failed|error)'; then
            TEST_FAILED="${TEST_FAILED}\n  ${TF}"
          fi
        done
        ;;
      jest)
        for TF in $TEST_FILES; do
          RESULT=$(npx jest "$TF" --no-coverage 2>&1 || true)
          if echo "$RESULT" | grep -qiE '(FAIL|failed)'; then
            TEST_FAILED="${TEST_FAILED}\n  ${TF}"
          fi
        done
        ;;
      pytest)
        for TF in $TEST_FILES; do
          RESULT=$(pytest "$TF" -x --tb=short 2>&1 || true)
          if echo "$RESULT" | grep -qiE '(FAILED|ERROR)'; then
            TEST_FAILED="${TEST_FAILED}\n  ${TF}"
          fi
        done
        ;;
      go)
        for TF in $TEST_FILES; do
          DIR=$(dirname "$TF")
          RESULT=$(go test "./$DIR" -run "." -count=1 2>&1 || true)
          if echo "$RESULT" | grep -qiE 'FAIL'; then
            TEST_FAILED="${TEST_FAILED}\n  ${TF}"
          fi
        done
        ;;
    esac

    if [ -n "$TEST_FAILED" ]; then
      echo "❌ Commit blocked: Related tests failed / 提交被阻止：关联测试失败" >&2
      printf "   Failed tests / 失败的测试:%b\n" "$TEST_FAILED" >&2
      echo "" >&2
      echo "   Fix failing tests then retry / 修复失败的测试后重试" >&2
      echo "   Or add [skip-review] to bypass / 或添加 [skip-review] 跳过" >&2
      exit 2
    fi
  fi
fi

exit 0
