#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/harness-common.sh"

PROJECT_ROOT="$(pwd)"
FORWARD_ARGS=""
FIX_MODE="all"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --staged)
      FIX_MODE="staged"
      FORWARD_ARGS="$FORWARD_ARGS $arg"
      ;;
    --changed-files)
      FIX_MODE="changed"
      FORWARD_ARGS="$FORWARD_ARGS $arg"
      ;;
    --all)
      FIX_MODE="all"
      FORWARD_ARGS="$FORWARD_ARGS $arg"
      ;;
    *)
      FORWARD_ARGS="$FORWARD_ARGS $arg"
      ;;
  esac
done

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"

if [ -f "$PROJECT_ROOT/.harness/bin/harness-init.sh" ]; then
  sh "$PROJECT_ROOT/.harness/bin/harness-init.sh" --project-root="$PROJECT_ROOT" --refresh >/dev/null
fi

if [ -d "$PROJECT_ROOT/.git" ]; then
  (
    cd "$PROJECT_ROOT"
    git config core.hooksPath .harness/git-hooks
  )
fi

chmod +x "$PROJECT_ROOT/.harness/bin/"*.sh "$PROJECT_ROOT/.harness/git-hooks/"* 2>/dev/null || true

if [ -n "$FORWARD_ARGS" ]; then
  # shellcheck disable=SC2086
  if sh "$PROJECT_ROOT/.harness/bin/harness-check.sh" --project-root="$PROJECT_ROOT" $FORWARD_ARGS; then
    CHECK_STATUS=0
  else
    CHECK_STATUS="$?"
  fi
else
  if sh "$PROJECT_ROOT/.harness/bin/harness-check.sh" --project-root="$PROJECT_ROOT"; then
    CHECK_STATUS=0
  else
    CHECK_STATUS="$?"
  fi
fi

FIX_STATUS="failure"
[ "$CHECK_STATUS" -eq 0 ] && FIX_STATUS="success"
harness_append_event "$PROJECT_ROOT" "fix.summary" "$FIX_STATUS" "$FIX_MODE" "$CHECK_STATUS" "" "" "post_fix_exit=$CHECK_STATUS" ""

exit "$CHECK_STATUS"
