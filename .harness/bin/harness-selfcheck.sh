#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
HARNESS_INIT="$SCRIPT_DIR/harness-init.sh"

fail() {
  echo "HARNESS SELF-CHECK FAILED: $1" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/harness-selfcheck.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

mkdir -p "$TMP_DIR/src"
cat > "$TMP_DIR/package.json" <<'EOF'
{
  "name": "harness-selfcheck-fixture",
  "private": true
}
EOF
cat > "$TMP_DIR/src/main.js" <<'EOF'
export function boot() {
  return "ok";
}
EOF
cat > "$TMP_DIR/README.md" <<'EOF'
# Harness Fixture
EOF

(
  cd "$TMP_DIR"
  git init >/dev/null 2>&1
  git config user.name "Harness Selfcheck"
  git config user.email "harness-selfcheck@example.com"
  git add .
  git commit -m "init fixture" >/dev/null 2>&1
)

sh "$HARNESS_INIT" --project-root="$TMP_DIR" >/dev/null

assert_file "$TMP_DIR/.harness/bin/harness-worktree.sh"
assert_file "$TMP_DIR/.harness/bin/harness-checkpoint.sh"
assert_file "$TMP_DIR/.harness/bin/harness-report.sh"
assert_file "$TMP_DIR/.harness/bin/harness-repo-map.sh"
assert_file "$TMP_DIR/.harness/bin/harness-repo-index.sh"
assert_file "$TMP_DIR/.harness/bin/harness-platform-audit.sh"
assert_file "$TMP_DIR/.cache/shared/repo-map.md"
assert_file "$TMP_DIR/.cache/shared/repo-index.json"

sh "$TMP_DIR/.harness/bin/harness-check.sh" --project-root="$TMP_DIR" --all >/dev/null || fail "harness-check should pass after init"

(
  cd "$TMP_DIR"
  git config core.hooksPath .git/hooks
)

if sh "$TMP_DIR/.harness/bin/harness-check.sh" --project-root="$TMP_DIR" --all >/dev/null 2>&1; then
  fail "harness-check should fail when hooksPath drifts"
fi

sh "$TMP_DIR/.harness/bin/harness-fix.sh" --project-root="$TMP_DIR" --all >/dev/null || fail "harness-fix should repair hooksPath"

(
  cd "$TMP_DIR"
  sh .harness/bin/harness-worktree.sh create TASK-1 >/dev/null
)
assert_file "$TMP_DIR/.worktrees/TASK-1/README.md"

(
  cd "$TMP_DIR"
  sh .harness/bin/harness-worktree.sh remove TASK-1 >/dev/null
)
[ ! -d "$TMP_DIR/.worktrees/TASK-1" ] || fail "worktree should be removed"

sh "$TMP_DIR/.harness/bin/harness-platform-audit.sh" --project-root="$TMP_DIR" --json > "$TMP_DIR/.cache/shared/platform-audit-check.json"
assert_file "$TMP_DIR/.cache/shared/platform-audit-check.json"
grep -F '"overall_status": "local_ready"' "$TMP_DIR/.cache/shared/platform-audit-check.json" >/dev/null 2>&1 || fail "platform audit should report local_ready"

sh "$TMP_DIR/.harness/bin/harness-report.sh" --project-root="$TMP_DIR" --json > "$TMP_DIR/.cache/shared/harness-report-check.json"
assert_file "$TMP_DIR/.cache/shared/harness-report-check.json"
grep -F '"status": "ok"' "$TMP_DIR/.cache/shared/harness-report-check.json" >/dev/null 2>&1 || fail "harness report should report ok"
grep -F '"check_runs":' "$TMP_DIR/.cache/shared/harness-report-check.json" >/dev/null 2>&1 || fail "harness report should include check_runs"

echo "checkpoint smoke" >> "$TMP_DIR/README.md"
(
  cd "$TMP_DIR"
  sh .harness/bin/harness-check.sh --all >/dev/null
  git add README.md
  sh .harness/bin/harness-checkpoint.sh "checkpoint smoke" >/dev/null
  git log -1 --pretty=%B | grep -F "Harness-Mode: checkpoint" >/dev/null 2>&1
) || fail "checkpoint should create commit"

echo "HARNESS SELF-CHECK OK"
