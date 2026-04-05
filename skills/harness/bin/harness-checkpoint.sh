#!/bin/sh

set -e

PROJECT_ROOT="$(pwd)"
MESSAGE="$1"

[ -z "$MESSAGE" ] && {
  echo "Usage: sh .harness/bin/harness-checkpoint.sh \"checkpoint message\"" >&2
  exit 1
}

[ -d "$PROJECT_ROOT/.git" ] || {
  echo "Not a git repository: $PROJECT_ROOT" >&2
  exit 1
}

REPORT_FILE="$PROJECT_ROOT/.harness/state/last-report.json"
[ -f "$REPORT_FILE" ] || {
  echo "Missing harness report: $REPORT_FILE" >&2
  exit 1
}

if ! grep -q '"exit_code":[[:space:]]*0' "$REPORT_FILE"; then
  echo "Harness report is not green. Run sh .harness/bin/harness-check.sh first." >&2
  exit 1
fi

git add -A

if git diff --cached --quiet; then
  echo "No staged changes for checkpoint."
  exit 0
fi

COMMIT_MSG_FILE="$(mktemp "${TMPDIR:-/tmp}/harness-checkpoint.XXXXXX")"
cat > "$COMMIT_MSG_FILE" <<EOF
✅[Reviewed] chore: $MESSAGE

Harness-Checks: pass
Harness-Mode: checkpoint
EOF

git commit -F "$COMMIT_MSG_FILE"
rm -f "$COMMIT_MSG_FILE"
