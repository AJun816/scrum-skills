#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW_BIN="$SCRIPT_DIR/workflow.sh"
WORKFLOW_REPORT_BIN="$SCRIPT_DIR/workflow-report.sh"
HARNESS_INIT_BIN="$(cd "$SCRIPT_DIR/../../harness/bin" && pwd)/harness-init.sh"

fail() {
  echo "SELF-CHECK FAILED: $1" >&2
  exit 1
}

assert_file() {
  [ -f "$1" ] || fail "missing file: $1"
}

assert_contains() {
  FILE="$1"
  PATTERN="$2"
  grep -F "$PATTERN" "$FILE" >/dev/null 2>&1 || fail "pattern not found: $PATTERN in $FILE"
}

setup_project_fixture() {
  ROOT="$1"
  mkdir -p "$ROOT/src"
  cat > "$ROOT/src/main.js" <<'EOF'
export function boot() {
  return "fixture";
}
EOF
  cat > "$ROOT/package.json" <<'EOF'
{
  "name": "workflow-selfcheck-fixture",
  "private": true
}
EOF
  sh "$HARNESS_INIT_BIN" --project-root="$ROOT" >/dev/null
}

run_imperial_check() {
  ROOT="$1"
  sh "$WORKFLOW_BIN" start --mode=imperial --host=codex --project-root="$ROOT" --request="imperial selfcheck" >/dev/null
  assert_file "$ROOT/.cache/shared/workflow-state.json"
  assert_file "$ROOT/.cache/shared/workflow-runs.jsonl"
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"mode": "imperial"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"current_step": "taizi-triage"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"repo_index": ".cache/shared/repo-index.json"'

  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="taizi approved" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="zhongshu approved" >/dev/null
  sh "$SCRIPT_DIR/workflow-reject.sh" --project-root="$ROOT" --reason="need more plan detail" >/dev/null
  sh "$SCRIPT_DIR/workflow-resume.sh" --project-root="$ROOT" --message="resume plan" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="plan updated" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="plan review approved" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="dispatch approved" >/dev/null

  sh "$SCRIPT_DIR/workflow-reject.sh" --project-root="$ROOT" --reason="code review reject 1" >/dev/null
  sh "$SCRIPT_DIR/workflow-resume.sh" --project-root="$ROOT" --message="resume dispatch 1" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="dispatch rerun 1" >/dev/null
  sh "$SCRIPT_DIR/workflow-reject.sh" --project-root="$ROOT" --reason="code review reject 2" >/dev/null
  sh "$SCRIPT_DIR/workflow-resume.sh" --project-root="$ROOT" --message="resume dispatch 2" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="dispatch rerun 2" >/dev/null
  sh "$SCRIPT_DIR/workflow-reject.sh" --project-root="$ROOT" --reason="code review reject 3" >/dev/null

  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"status": "running"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"current_step": "zhongshu-report"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"step":"menxia-review-code"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"status":"force_passed"'

  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="report approved" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="emperor approved" >/dev/null
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"status": "completed"'
  assert_contains "$ROOT/.cache/shared/workflow-runs.jsonl" '"event":"review.force_pass"'
  sh "$WORKFLOW_REPORT_BIN" --project-root="$ROOT" --json > "$ROOT/.cache/shared/workflow-report-check.json"
  assert_contains "$ROOT/.cache/shared/workflow-report-check.json" '"force_passed_steps": 1'
  assert_contains "$ROOT/.cache/shared/workflow-report-check.json" '"event_count":'
}

run_agile_check() {
  ROOT="$1"
  sh "$WORKFLOW_BIN" reset --project-root="$ROOT" >/dev/null
  sh "$WORKFLOW_BIN" start --mode=agile --host=codex --project-root="$ROOT" --request="agile selfcheck" >/dev/null
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"mode": "agile"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"current_step": "scrum-analyze"'

  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="analyze done" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="plan done" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="execute done" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="review done" >/dev/null
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"status": "completed"'
}

run_reset_abort_check() {
  ROOT="$1"
  sh "$WORKFLOW_BIN" reset --project-root="$ROOT" >/dev/null
  sh "$WORKFLOW_BIN" start --mode=imperial --project-root="$ROOT" --request="abort selfcheck" >/dev/null
  sh "$SCRIPT_DIR/workflow-abort.sh" --project-root="$ROOT" --message="abort smoke" >/dev/null
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"status": "aborted"'
  sh "$SCRIPT_DIR/workflow-reset.sh" --project-root="$ROOT" >/dev/null
  [ ! -f "$ROOT/.cache/shared/workflow-state.json" ] || fail "reset should remove workflow-state.json"
}

run_missing_harness_check() {
  ROOT="$1/no-harness"
  mkdir -p "$ROOT"
  cat > "$ROOT/package.json" <<'EOF'
{
  "name": "workflow-no-harness-fixture",
  "private": true
}
EOF

  sh "$WORKFLOW_BIN" start --mode=agile --project-root="$ROOT" --request="missing harness selfcheck" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="analyze done" >/dev/null
  sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="plan done" >/dev/null

  if sh "$SCRIPT_DIR/workflow-approve.sh" --project-root="$ROOT" --message="execute blocked" >/dev/null 2>&1; then
    fail "approve should fail when harness is missing"
  fi

  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"status": "paused"'
  assert_contains "$ROOT/.cache/shared/workflow-state.json" '"current_step": "scrum-execute"'
}

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/workflow-selfcheck.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

setup_project_fixture "$TMP_DIR"
run_imperial_check "$TMP_DIR"
run_agile_check "$TMP_DIR"
run_reset_abort_check "$TMP_DIR"
run_missing_harness_check "$TMP_DIR"

echo "SELF-CHECK OK"
