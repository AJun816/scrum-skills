#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MODE="$1"
ARG1="$2"

run_check_with_fix() {
  STATUS=0
  # shellcheck disable=SC2086
  sh "$SCRIPT_DIR/harness-check.sh" --project-root="$PROJECT_ROOT" $1 || STATUS=$?
  if [ "$STATUS" -eq 2 ]; then
    # shellcheck disable=SC2086
    sh "$SCRIPT_DIR/harness-fix.sh" --project-root="$PROJECT_ROOT" $1 >/dev/null || STATUS=$?
    # shellcheck disable=SC2086
    sh "$SCRIPT_DIR/harness-check.sh" --project-root="$PROJECT_ROOT" $1 || STATUS=$?
  fi
  return "$STATUS"
}

validate_override() {
  COMMIT_MESSAGE="$1"
  OVERRIDE_ID=$(printf '%s' "$COMMIT_MESSAGE" | grep -oE '\[imperial-override:[A-Za-z0-9._-]+\]' | head -1 | sed 's/\[imperial-override://; s/\]//')

  if [ -z "$OVERRIDE_ID" ]; then
    OVERRIDE_ID=$(printf '%s' "$COMMIT_MESSAGE" | sed -n 's/.*Harness-Override:[[:space:]]*\([A-Za-z0-9._-]*\).*/\1/p' | head -1)
  fi

  [ -z "$OVERRIDE_ID" ] && return 0

  OVERRIDE_FILE="$PROJECT_ROOT/.harness/overrides/${OVERRIDE_ID}.yaml"
  if [ ! -f "$OVERRIDE_FILE" ]; then
    echo "❌ Harness override blocked: $OVERRIDE_FILE not found" >&2
    exit 1
  fi

  for field in reason scope owner expires_at approved_by; do
    if ! grep -q "^${field}:" "$OVERRIDE_FILE" 2>/dev/null; then
      echo "❌ Harness override blocked: missing '${field}' in $OVERRIDE_FILE" >&2
      exit 1
    fi
  done
}

case "$MODE" in
  pre-commit)
    STAGED_FILES=$(cd "$PROJECT_ROOT" && git diff --cached --name-only --diff-filter=ACMR 2>/dev/null | tr '\n' ',' | sed 's/,$//')
    [ -z "$STAGED_FILES" ] && exit 0
    if ! run_check_with_fix "--files=$STAGED_FILES"; then
      echo "❌ Pre-commit harness gate blocked the commit." >&2
      exit 1
    fi
    ;;
  pre-push)
    CURRENT_BRANCH=$(cd "$PROJECT_ROOT" && git symbolic-ref --quiet --short HEAD 2>/dev/null || true)
    case "$CURRENT_BRANCH" in
      main|master)
        if [ "${HARNESS_ALLOW_PROTECTED_PUSH:-0}" != "1" ]; then
          echo "❌ Direct push to $CURRENT_BRANCH is blocked by Harness. Use a PR or set HARNESS_ALLOW_PROTECTED_PUSH=1 for an audited emergency push." >&2
          exit 1
        fi
        ;;
    esac
    if ! run_check_with_fix "--all"; then
      echo "❌ Pre-push harness gate blocked the push." >&2
      exit 1
    fi
    ;;
  commit-msg)
    MSG_FILE="$ARG1"
    if [ -z "$MSG_FILE" ] || [ ! -f "$MSG_FILE" ]; then
      echo "commit-msg hook: no message file" >&2
      exit 1
    fi

    COMMIT_MSG=$(cat "$MSG_FILE")
    if ! printf '%s' "$COMMIT_MSG" | grep -q '^✅\[Reviewed\]'; then
      echo "❌ Commit blocked / 提交被阻止" >&2
      echo "   Every commit must start with ✅[Reviewed] prefix" >&2
      echo "   每次提交必须以 ✅[Reviewed] 开头" >&2
      exit 1
    fi

    validate_override "$COMMIT_MSG"
    ;;
  *)
    echo "Unknown harness gate mode: $MODE" >&2
    exit 1
    ;;
esac

exit 0
