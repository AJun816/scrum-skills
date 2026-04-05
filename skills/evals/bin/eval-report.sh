#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVALS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$EVALS_DIR/lib/eval-common.sh"

PROJECT_ROOT="$(pwd)"
JSON_OUTPUT="no"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh eval-report.sh [--project-root=PATH] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(eval_project_root "$PROJECT_ROOT")"
REPORT_JSON="$(eval_report_json "$PROJECT_ROOT")"
REPORT_MD="$(eval_report_md "$PROJECT_ROOT")"
RUNS_ROOT="$(eval_runs_root "$PROJECT_ROOT")"
COMPARISONS_ROOT="$(eval_comparisons_root "$PROJECT_ROOT")"
NOW="$(eval_now_iso)"

mkdir -p "$(eval_shared_dir "$PROJECT_ROOT")/evals"

json_string_field() {
  FILE="$1"
  KEY="$2"
  sed -n "s/.*\"$KEY\":[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p" "$FILE" | head -n 1
}

json_number_field() {
  FILE="$1"
  KEY="$2"
  sed -n "s/.*\"$KEY\":[[:space:]]*\\([-0-9][0-9]*\\).*/\\1/p" "$FILE" | head -n 1
}

latest_dir() {
  ROOT="$1"
  if [ ! -d "$ROOT" ]; then
    return 1
  fi
  ls -1dt "$ROOT"/* 2>/dev/null | head -n 1
}

emit_no_activity_report() {
  printf '{\n' > "$REPORT_JSON"
  printf '  "generated_at": "%s",\n' "$(eval_json_escape "$NOW")" >> "$REPORT_JSON"
  printf '  "project_root": "%s",\n' "$(eval_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
  printf '  "status": "no_eval_activity",\n' >> "$REPORT_JSON"
  printf '  "summary": "No eval runs found for this project."\n' >> "$REPORT_JSON"
  printf '}\n' >> "$REPORT_JSON"

  {
    echo "# Eval Report"
    echo ""
    echo "- project_root: \`$PROJECT_ROOT\`"
    echo "- status: \`no_eval_activity\`"
    echo "- summary: No eval runs found for this project."
  } > "$REPORT_MD"

  if [ "$JSON_OUTPUT" = "yes" ]; then
    cat "$REPORT_JSON"
  else
    cat "$REPORT_MD"
  fi
}

LATEST_RUN_DIR="$(latest_dir "$RUNS_ROOT" || true)"
[ -n "$LATEST_RUN_DIR" ] || {
  emit_no_activity_report
  exit 0
}

RUN_SUMMARY_JSON="$LATEST_RUN_DIR/summary.json"
[ -f "$RUN_SUMMARY_JSON" ] || {
  emit_no_activity_report
  exit 0
}

RUN_ID="$(json_string_field "$RUN_SUMMARY_JSON" "run_id")"
RUN_GENERATED_AT="$(json_string_field "$RUN_SUMMARY_JSON" "generated_at")"
TRIALS_PER_CASE="$(json_number_field "$RUN_SUMMARY_JSON" "trials_per_case")"
TOTAL_CASES="$(json_number_field "$RUN_SUMMARY_JSON" "total_cases")"
PASSED_CASES="$(json_number_field "$RUN_SUMMARY_JSON" "passed_cases")"
FAILED_CASES="$(json_number_field "$RUN_SUMMARY_JSON" "failed_cases")"

[ -n "$TRIALS_PER_CASE" ] || TRIALS_PER_CASE="0"
[ -n "$TOTAL_CASES" ] || TOTAL_CASES="0"
[ -n "$PASSED_CASES" ] || PASSED_CASES="0"
[ -n "$FAILED_CASES" ] || FAILED_CASES="0"

RUN_COUNT="0"
if [ -d "$RUNS_ROOT" ]; then
  RUN_COUNT="$(find "$RUNS_ROOT" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ')"
fi

LATEST_COMPARISON_DIR="$(latest_dir "$COMPARISONS_ROOT" || true)"
COMPARISON_STATUS="no_comparison"
COMPARISON_PATH=""
COMPARISON_GENERATED_AT=""
IMPROVEMENTS="0"
REGRESSIONS="0"

if [ -n "$LATEST_COMPARISON_DIR" ] && [ -f "$LATEST_COMPARISON_DIR/comparison.json" ]; then
  COMPARISON_PATH="$LATEST_COMPARISON_DIR/comparison.json"
  COMPARISON_STATUS="available"
  COMPARISON_GENERATED_AT="$(json_string_field "$COMPARISON_PATH" "generated_at")"
  IMPROVEMENTS="$(json_number_field "$COMPARISON_PATH" "improvements")"
  REGRESSIONS="$(json_number_field "$COMPARISON_PATH" "regressions")"
  [ -n "$IMPROVEMENTS" ] || IMPROVEMENTS="0"
  [ -n "$REGRESSIONS" ] || REGRESSIONS="0"
fi

REPORT_STATUS="ok"
SUMMARY_MESSAGE="Latest eval run passed."
if [ "$FAILED_CASES" -gt 0 ] || [ "$REGRESSIONS" -gt 0 ]; then
  REPORT_STATUS="attention"
  SUMMARY_MESSAGE="Latest eval activity contains failures or regressions."
fi

printf '{\n' > "$REPORT_JSON"
printf '  "generated_at": "%s",\n' "$(eval_json_escape "$NOW")" >> "$REPORT_JSON"
printf '  "project_root": "%s",\n' "$(eval_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
printf '  "status": "%s",\n' "$(eval_json_escape "$REPORT_STATUS")" >> "$REPORT_JSON"
printf '  "summary": "%s",\n' "$(eval_json_escape "$SUMMARY_MESSAGE")" >> "$REPORT_JSON"
printf '  "run_count": %s,\n' "$RUN_COUNT" >> "$REPORT_JSON"
printf '  "latest_run": {\n' >> "$REPORT_JSON"
printf '    "run_id": "%s",\n' "$(eval_json_escape "$RUN_ID")" >> "$REPORT_JSON"
printf '    "generated_at": "%s",\n' "$(eval_json_escape "$RUN_GENERATED_AT")" >> "$REPORT_JSON"
printf '    "trials_per_case": %s,\n' "$TRIALS_PER_CASE" >> "$REPORT_JSON"
printf '    "total_cases": %s,\n' "$TOTAL_CASES" >> "$REPORT_JSON"
printf '    "passed_cases": %s,\n' "$PASSED_CASES" >> "$REPORT_JSON"
printf '    "failed_cases": %s\n' "$FAILED_CASES" >> "$REPORT_JSON"
printf '  },\n' >> "$REPORT_JSON"
printf '  "latest_comparison": {\n' >> "$REPORT_JSON"
printf '    "status": "%s",\n' "$(eval_json_escape "$COMPARISON_STATUS")" >> "$REPORT_JSON"
printf '    "generated_at": "%s",\n' "$(eval_json_escape "$COMPARISON_GENERATED_AT")" >> "$REPORT_JSON"
printf '    "improvements": %s,\n' "$IMPROVEMENTS" >> "$REPORT_JSON"
printf '    "regressions": %s\n' "$REGRESSIONS" >> "$REPORT_JSON"
printf '  }\n' >> "$REPORT_JSON"
printf '}\n' >> "$REPORT_JSON"

{
  echo "# Eval Report"
  echo ""
  echo "- project_root: \`$PROJECT_ROOT\`"
  echo "- status: \`$REPORT_STATUS\`"
  echo "- summary: $SUMMARY_MESSAGE"
  echo "- run_count: \`$RUN_COUNT\`"
  echo ""
  echo "## Latest Run"
  echo ""
  echo "- run_id: \`$RUN_ID\`"
  echo "- generated_at: \`$RUN_GENERATED_AT\`"
  echo "- trials_per_case: \`$TRIALS_PER_CASE\`"
  echo "- total_cases: \`$TOTAL_CASES\`"
  echo "- passed_cases: \`$PASSED_CASES\`"
  echo "- failed_cases: \`$FAILED_CASES\`"
  echo ""
  echo "## Latest Comparison"
  echo ""
  echo "- status: \`$COMPARISON_STATUS\`"
  echo "- generated_at: \`${COMPARISON_GENERATED_AT:-}\`"
  echo "- improvements: \`$IMPROVEMENTS\`"
  echo "- regressions: \`$REGRESSIONS\`"
} > "$REPORT_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_JSON"
else
  cat "$REPORT_MD"
fi
