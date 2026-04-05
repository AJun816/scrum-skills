#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/harness-common.sh"

PROJECT_ROOT="$(pwd)"
FORWARD_ARGS=""

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
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
  sh "$PROJECT_ROOT/.harness/bin/harness-check.sh" --project-root="$PROJECT_ROOT" $FORWARD_ARGS
else
  sh "$PROJECT_ROOT/.harness/bin/harness-check.sh" --project-root="$PROJECT_ROOT"
fi
