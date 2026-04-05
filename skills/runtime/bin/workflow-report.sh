#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNTIME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$RUNTIME_DIR/lib/runtime-common.sh"

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
      echo "Usage: sh skills/runtime/bin/workflow-report.sh [--project-root=PATH] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(workflow_project_root "$PROJECT_ROOT")"
REPORT_JSON="$(workflow_shared_dir "$PROJECT_ROOT")/workflow-report.json"
REPORT_MD="$(workflow_shared_dir "$PROJECT_ROOT")/workflow-report.md"
EVENT_FILE="$(workflow_events_file "$PROJECT_ROOT")"
NOW="$(workflow_now_iso)"
mkdir -p "$(workflow_shared_dir "$PROJECT_ROOT")"

emit_no_state_report() {
  printf '{\n' > "$REPORT_JSON"
  printf '  "generated_at": "%s",\n' "$(workflow_json_escape "$NOW")" >> "$REPORT_JSON"
  printf '  "project_root": "%s",\n' "$(workflow_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
  printf '  "status": "no_workflow_state",\n' >> "$REPORT_JSON"
  printf '  "summary": "No workflow state found for this project."\n' >> "$REPORT_JSON"
  printf '}\n' >> "$REPORT_JSON"

  {
    echo "# Workflow Report"
    echo ""
    echo "- project_root: \`$PROJECT_ROOT\`"
    echo "- status: \`no_workflow_state\`"
    echo "- summary: No workflow state found for this project."
  } > "$REPORT_MD"

  if [ "$JSON_OUTPUT" = "yes" ]; then
    cat "$REPORT_JSON"
  else
    cat "$REPORT_MD"
  fi
}

workflow_load_meta "$PROJECT_ROOT" || {
  emit_no_state_report
  exit 0
}
workflow_render_state "$PROJECT_ROOT"

count_event() {
  EVENT_NAME="$1"
  if [ -f "$EVENT_FILE" ]; then
    grep -c "\"event\":\"$EVENT_NAME\"" "$EVENT_FILE" 2>/dev/null || true
  else
    echo "0"
  fi
}

TOTAL_STEPS="0"
COMPLETED_STEPS="0"
PENDING_STEPS="0"
IN_PROGRESS_STEPS="0"
REJECTED_STEPS="0"
FORCE_PASSED_STEPS="0"
ERROR_STEPS="0"
TOTAL_REJECTIONS="0"
STEP_ROWS_FILE="$(mktemp "${TMPDIR:-/tmp}/workflow-report-steps.XXXXXX")"
trap 'rm -f "$STEP_ROWS_FILE"' EXIT HUP INT TERM

for STEP_DIR in "$(workflow_steps_root "$PROJECT_ROOT")"/*; do
  [ ! -d "$STEP_DIR" ] && continue
  workflow_load_step_dir "$STEP_DIR" || continue
  TOTAL_STEPS=$((TOTAL_STEPS + 1))
  TOTAL_REJECTIONS=$((TOTAL_REJECTIONS + STEP_REJECTION_COUNT))

  case "$STEP_STATUS" in
    completed) COMPLETED_STEPS=$((COMPLETED_STEPS + 1)) ;;
    pending) PENDING_STEPS=$((PENDING_STEPS + 1)) ;;
    in_progress) IN_PROGRESS_STEPS=$((IN_PROGRESS_STEPS + 1)) ;;
    rejected) REJECTED_STEPS=$((REJECTED_STEPS + 1)) ;;
    force_passed) FORCE_PASSED_STEPS=$((FORCE_PASSED_STEPS + 1)) ;;
    error) ERROR_STEPS=$((ERROR_STEPS + 1)) ;;
  esac

  STEP_END="$STEP_COMPLETED_AT"
  if [ -z "$STEP_END" ] && [ "$STEP_STATUS" = "in_progress" ]; then
    STEP_END="$NOW"
  fi
  STEP_DURATION="$(workflow_duration_seconds "$STEP_STARTED_AT" "$STEP_END")"
  [ -n "$STEP_DURATION" ] || STEP_DURATION="0"

  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$STEP_INDEX" "$STEP_NAME" "$STEP_LABEL" "$STEP_STATUS" "$STEP_REJECTION_COUNT" "$STEP_DURATION" >> "$STEP_ROWS_FILE"
done

TOTAL_DURATION="$(workflow_duration_seconds "$WORKFLOW_STARTED_AT" "$WORKFLOW_UPDATED_AT")"
[ -n "$TOTAL_DURATION" ] || TOTAL_DURATION="0"

HARNESS_CHECK_PASS="$(count_event "harness.check.pass")"
HARNESS_CHECK_FIXABLE="$(count_event "harness.check.fixable")"
HARNESS_FIX_PASS="$(count_event "harness.fix.pass")"
HARNESS_FIX_FAIL="$(count_event "harness.fix.fail")"
HARNESS_CHECK_FAIL="$(count_event "harness.check.fail")"
HARNESS_CHECK_ERROR="$(count_event "harness.check.error")"
WORKFLOW_PAUSE_COUNT="$(count_event "workflow.pause")"
WORKFLOW_ABORT_COUNT="$(count_event "workflow.abort")"
REVIEW_APPROVE_COUNT="$(count_event "review.approve")"
REVIEW_REJECT_COUNT="$(count_event "review.reject")"
REVIEW_FORCE_PASS_COUNT="$(count_event "review.force_pass")"
EVENT_COUNT="0"
if [ -f "$EVENT_FILE" ]; then
  EVENT_COUNT="$(wc -l < "$EVENT_FILE" | tr -d ' ')"
fi

printf '{\n' > "$REPORT_JSON"
printf '  "generated_at": "%s",\n' "$(workflow_json_escape "$NOW")" >> "$REPORT_JSON"
printf '  "project_root": "%s",\n' "$(workflow_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
printf '  "workflow_id": "%s",\n' "$(workflow_json_escape "$WORKFLOW_ID")" >> "$REPORT_JSON"
printf '  "mode": "%s",\n' "$(workflow_json_escape "$WORKFLOW_MODE")" >> "$REPORT_JSON"
printf '  "host": "%s",\n' "$(workflow_json_escape "$WORKFLOW_HOST")" >> "$REPORT_JSON"
printf '  "status": "%s",\n' "$(workflow_json_escape "$WORKFLOW_STATUS")" >> "$REPORT_JSON"
printf '  "current_step": "%s",\n' "$(workflow_json_escape "$WORKFLOW_CURRENT_STEP")" >> "$REPORT_JSON"
printf '  "total_duration_seconds": %s,\n' "$TOTAL_DURATION" >> "$REPORT_JSON"
printf '  "event_count": %s,\n' "$EVENT_COUNT" >> "$REPORT_JSON"
printf '  "step_summary": {\n' >> "$REPORT_JSON"
printf '    "total_steps": %s,\n' "$TOTAL_STEPS" >> "$REPORT_JSON"
printf '    "completed_steps": %s,\n' "$COMPLETED_STEPS" >> "$REPORT_JSON"
printf '    "pending_steps": %s,\n' "$PENDING_STEPS" >> "$REPORT_JSON"
printf '    "in_progress_steps": %s,\n' "$IN_PROGRESS_STEPS" >> "$REPORT_JSON"
printf '    "rejected_steps": %s,\n' "$REJECTED_STEPS" >> "$REPORT_JSON"
printf '    "force_passed_steps": %s,\n' "$FORCE_PASSED_STEPS" >> "$REPORT_JSON"
printf '    "error_steps": %s,\n' "$ERROR_STEPS" >> "$REPORT_JSON"
printf '    "total_rejections": %s\n' "$TOTAL_REJECTIONS" >> "$REPORT_JSON"
printf '  },\n' >> "$REPORT_JSON"
printf '  "harness": {\n' >> "$REPORT_JSON"
printf '    "check_pass": %s,\n' "$HARNESS_CHECK_PASS" >> "$REPORT_JSON"
printf '    "check_fixable": %s,\n' "$HARNESS_CHECK_FIXABLE" >> "$REPORT_JSON"
printf '    "fix_pass": %s,\n' "$HARNESS_FIX_PASS" >> "$REPORT_JSON"
printf '    "fix_fail": %s,\n' "$HARNESS_FIX_FAIL" >> "$REPORT_JSON"
printf '    "check_fail": %s,\n' "$HARNESS_CHECK_FAIL" >> "$REPORT_JSON"
printf '    "check_error": %s\n' "$HARNESS_CHECK_ERROR" >> "$REPORT_JSON"
printf '  },\n' >> "$REPORT_JSON"
printf '  "reviews": {\n' >> "$REPORT_JSON"
printf '    "approve_count": %s,\n' "$REVIEW_APPROVE_COUNT" >> "$REPORT_JSON"
printf '    "reject_count": %s,\n' "$REVIEW_REJECT_COUNT" >> "$REPORT_JSON"
printf '    "force_pass_count": %s,\n' "$REVIEW_FORCE_PASS_COUNT" >> "$REPORT_JSON"
printf '    "pause_count": %s,\n' "$WORKFLOW_PAUSE_COUNT" >> "$REPORT_JSON"
printf '    "abort_count": %s\n' "$WORKFLOW_ABORT_COUNT" >> "$REPORT_JSON"
printf '  },\n' >> "$REPORT_JSON"
printf '  "steps": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r STEP_INDEX STEP_NAME STEP_LABEL STEP_STATUS STEP_REJECTION_COUNT STEP_DURATION; do
  [ -z "$STEP_NAME" ] && continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"index":"%s","step":"%s","label":"%s","status":"%s","rejection_count":%s,"duration_seconds":%s}' \
    "$(workflow_json_escape "$STEP_INDEX")" \
    "$(workflow_json_escape "$STEP_NAME")" \
    "$(workflow_json_escape "$STEP_LABEL")" \
    "$(workflow_json_escape "$STEP_STATUS")" \
    "$STEP_REJECTION_COUNT" \
    "$STEP_DURATION" >> "$REPORT_JSON"
done < "$STEP_ROWS_FILE"
printf '\n  ]\n}\n' >> "$REPORT_JSON"

{
  echo "# Workflow Report"
  echo ""
  echo "- project_root: \`$PROJECT_ROOT\`"
  echo "- workflow_id: \`$WORKFLOW_ID\`"
  echo "- mode: \`$WORKFLOW_MODE\`"
  echo "- host: \`$WORKFLOW_HOST\`"
  echo "- status: \`$WORKFLOW_STATUS\`"
  echo "- current_step: \`$WORKFLOW_CURRENT_STEP\`"
  echo "- total_duration_seconds: \`$TOTAL_DURATION\`"
  echo "- event_count: \`$EVENT_COUNT\`"
  echo ""
  echo "## Step Summary"
  echo ""
  echo "- total_steps: \`$TOTAL_STEPS\`"
  echo "- completed_steps: \`$COMPLETED_STEPS\`"
  echo "- pending_steps: \`$PENDING_STEPS\`"
  echo "- in_progress_steps: \`$IN_PROGRESS_STEPS\`"
  echo "- rejected_steps: \`$REJECTED_STEPS\`"
  echo "- force_passed_steps: \`$FORCE_PASSED_STEPS\`"
  echo "- error_steps: \`$ERROR_STEPS\`"
  echo "- total_rejections: \`$TOTAL_REJECTIONS\`"
  echo ""
  echo "## Harness Metrics"
  echo ""
  echo "- check_pass: \`$HARNESS_CHECK_PASS\`"
  echo "- check_fixable: \`$HARNESS_CHECK_FIXABLE\`"
  echo "- fix_pass: \`$HARNESS_FIX_PASS\`"
  echo "- fix_fail: \`$HARNESS_FIX_FAIL\`"
  echo "- check_fail: \`$HARNESS_CHECK_FAIL\`"
  echo "- check_error: \`$HARNESS_CHECK_ERROR\`"
  echo ""
  echo "| Step | Status | Rejections | Duration(s) |"
  echo "|------|--------|------------|-------------|"
  while IFS="$(printf '\t')" read -r STEP_INDEX STEP_NAME STEP_LABEL STEP_STATUS STEP_REJECTION_COUNT STEP_DURATION; do
    [ -z "$STEP_NAME" ] && continue
    echo "| $STEP_NAME | $STEP_STATUS | $STEP_REJECTION_COUNT | $STEP_DURATION |"
  done < "$STEP_ROWS_FILE"
} > "$REPORT_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_JSON"
else
  cat "$REPORT_MD"
fi
