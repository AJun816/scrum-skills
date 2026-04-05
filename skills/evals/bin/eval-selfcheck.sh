#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/eval-selfcheck.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

assert_file() {
  [ -f "$1" ] || {
    echo "EVAL SELF-CHECK FAILED: missing file $1" >&2
    exit 1
  }
}

mkdir -p "$TMP_DIR/.harness/evals"
cat > "$TMP_DIR/echo-ok.sh" <<'EOF'
#!/bin/sh
echo "fixture ok"
EOF
chmod +x "$TMP_DIR/echo-ok.sh"

cat > "$TMP_DIR/.harness/evals/echo-ok.case.env" <<'EOF'
EVAL_NAME='echo-ok'
EVAL_DESCRIPTION='fixture eval case'
EVAL_COMMAND='sh ./echo-ok.sh'
EVAL_EXPECT_EXIT='0'
EVAL_EXPECT_STDOUT_CONTAINS='fixture ok'
EOF

sh "$SCRIPT_DIR/eval-run.sh" --project-root="$TMP_DIR" echo-ok --trials=2 >/dev/null
RUN_ROOT="$(ls -1dt "$TMP_DIR/.cache/shared/evals/runs"/* 2>/dev/null | head -n 1)"

assert_file "$RUN_ROOT/summary.json"
assert_file "$RUN_ROOT/summary.tsv"
assert_file "$RUN_ROOT/echo-ok/trial-01/stdout.txt"
assert_file "$RUN_ROOT/echo-ok/trial-01/grade.json"

if ! grep -F '"passed_cases": 1' "$RUN_ROOT/summary.json" >/dev/null 2>&1; then
  echo "EVAL SELF-CHECK FAILED: summary.json missing passed_cases" >&2
  exit 1
fi

COMPARE_ROOT="$TMP_DIR/out/compare"
mkdir -p "$COMPARE_ROOT"
sh "$SCRIPT_DIR/eval-compare.sh" --project-root="$TMP_DIR" --current="$RUN_ROOT" --baseline="$RUN_ROOT" >/dev/null
sh "$SCRIPT_DIR/eval-report.sh" --project-root="$TMP_DIR" --json > "$TMP_DIR/out/eval-report.json"
assert_file "$TMP_DIR/out/eval-report.json"
if ! grep -F '"status": "ok"' "$TMP_DIR/out/eval-report.json" >/dev/null 2>&1; then
  echo "EVAL SELF-CHECK FAILED: eval-report.json missing ok status" >&2
  exit 1
fi

echo "EVAL SELF-CHECK OK"
