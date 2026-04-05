#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNTIME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
ROOT_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$RUNTIME_DIR/lib/runtime-common.sh"

PROJECT_ROOT="$(pwd)"
TARGET=""
AGENT="claude"
JSON_OUTPUT="no"
RECENT_WINDOW="5"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --target=*)
      TARGET="${arg#--target=}"
      ;;
    --agent=*)
      AGENT="${arg#--agent=}"
      ;;
    --recent=*)
      RECENT_WINDOW="${arg#--recent=}"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh skills-report.sh [--project-root=PATH] [--target=PATH] [--agent=claude|codex] [--recent=N] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

case "$RECENT_WINDOW" in
  ''|*[!0-9]*|0)
    echo "Invalid --recent value: $RECENT_WINDOW" >&2
    exit 1
    ;;
esac

PROJECT_ROOT="$(workflow_project_root "$PROJECT_ROOT")"
[ -n "$TARGET" ] || TARGET="$PROJECT_ROOT"
PACK_TARGET_ROOT="$TARGET"
REPORT_JSON="$(workflow_shared_dir "$PROJECT_ROOT")/skills-report.json"
REPORT_MD="$(workflow_shared_dir "$PROJECT_ROOT")/skills-report.md"
NOW="$(workflow_now_iso)"

mkdir -p "$(workflow_shared_dir "$PROJECT_ROOT")"

WORKFLOW_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-workflow.XXXXXX")"
HARNESS_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-harness.XXXXXX")"
EVAL_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-eval.XXXXXX")"
PACK_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-pack.XXXXXX")"
WORKFLOW_RECENT_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-workflow-recent.XXXXXX")"
HARNESS_RECENT_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-harness-recent.XXXXXX")"
EVAL_RECENT_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-eval-recent.XXXXXX")"
PACK_RECENT_FILE="$(mktemp "${TMPDIR:-/tmp}/skills-report-pack-recent.XXXXXX")"
trap 'rm -f "$WORKFLOW_FILE" "$HARNESS_FILE" "$EVAL_FILE" "$PACK_FILE" "$WORKFLOW_RECENT_FILE" "$HARNESS_RECENT_FILE" "$EVAL_RECENT_FILE" "$PACK_RECENT_FILE"' EXIT HUP INT TERM

sh "$SCRIPT_DIR/workflow-report.sh" --project-root="$PROJECT_ROOT" --json > "$WORKFLOW_FILE"
sh "$ROOT_DIR/harness/bin/harness-report.sh" --project-root="$PROJECT_ROOT" --json > "$HARNESS_FILE"
sh "$ROOT_DIR/evals/bin/eval-report.sh" --project-root="$PROJECT_ROOT" --json > "$EVAL_FILE"
sh "$ROOT_DIR/registry/bin/pack-report.sh" --target="$PACK_TARGET_ROOT" --agent="$AGENT" --json > "$PACK_FILE"

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

json_string_from_line() {
  LINE="$1"
  KEY="$2"
  printf '%s\n' "$LINE" | sed -n "s/.*\"$KEY\":\"\\([^\"]*\\)\".*/\\1/p"
}

WORKFLOW_STATUS="$(json_string_field "$WORKFLOW_FILE" "status")"
WORKFLOW_EVENT_COUNT="$(json_number_field "$WORKFLOW_FILE" "event_count")"
WORKFLOW_CURRENT_STEP="$(json_string_field "$WORKFLOW_FILE" "current_step")"
WORKFLOW_REJECTIONS="$(json_number_field "$WORKFLOW_FILE" "total_rejections")"

HARNESS_STATUS="$(json_string_field "$HARNESS_FILE" "status")"
HARNESS_CHECK_RUNS="$(json_number_field "$HARNESS_FILE" "check_runs")"
HARNESS_CHECK_BLOCKED="$(json_number_field "$HARNESS_FILE" "check_blocked")"
HARNESS_FIX_SUCCESS="$(json_number_field "$HARNESS_FILE" "fix_success")"
HARNESS_FIX_FAILURE="$(json_number_field "$HARNESS_FILE" "fix_failure")"
HARNESS_RULES="$(json_number_field "$HARNESS_FILE" "unique_rule_count")"

EVAL_STATUS="$(json_string_field "$EVAL_FILE" "status")"
EVAL_RUN_COUNT="$(json_number_field "$EVAL_FILE" "run_count")"
EVAL_FAILED_CASES="$(json_number_field "$EVAL_FILE" "failed_cases")"
EVAL_REGRESSIONS="$(json_number_field "$EVAL_FILE" "regressions")"
EVAL_LATEST_RUN_ID="$(json_string_field "$EVAL_FILE" "run_id")"

PACK_STATUS="$(json_string_field "$PACK_FILE" "status")"
PACK_TOTAL_EVENTS="$(json_number_field "$PACK_FILE" "total_events")"
PACK_FAILURE_EVENTS="$(json_number_field "$PACK_FILE" "failure_events")"
PACK_UNIQUE_PACKS="$(json_number_field "$PACK_FILE" "unique_packs")"

[ -n "$WORKFLOW_EVENT_COUNT" ] || WORKFLOW_EVENT_COUNT="0"
[ -n "$WORKFLOW_REJECTIONS" ] || WORKFLOW_REJECTIONS="0"
[ -n "$HARNESS_CHECK_RUNS" ] || HARNESS_CHECK_RUNS="0"
[ -n "$HARNESS_CHECK_BLOCKED" ] || HARNESS_CHECK_BLOCKED="0"
[ -n "$HARNESS_FIX_SUCCESS" ] || HARNESS_FIX_SUCCESS="0"
[ -n "$HARNESS_FIX_FAILURE" ] || HARNESS_FIX_FAILURE="0"
[ -n "$HARNESS_RULES" ] || HARNESS_RULES="0"
[ -n "$EVAL_RUN_COUNT" ] || EVAL_RUN_COUNT="0"
[ -n "$EVAL_FAILED_CASES" ] || EVAL_FAILED_CASES="0"
[ -n "$EVAL_REGRESSIONS" ] || EVAL_REGRESSIONS="0"
[ -n "$PACK_TOTAL_EVENTS" ] || PACK_TOTAL_EVENTS="0"
[ -n "$PACK_FAILURE_EVENTS" ] || PACK_FAILURE_EVENTS="0"
[ -n "$PACK_UNIQUE_PACKS" ] || PACK_UNIQUE_PACKS="0"

WORKFLOW_EVENTS_SOURCE="$(workflow_events_file "$PROJECT_ROOT")"
HARNESS_EVENTS_SOURCE="$(harness_runs_file "$PROJECT_ROOT")"
EVAL_RUNS_SOURCE="$PROJECT_ROOT/.cache/shared/evals/runs"
PACK_EVENTS_SOURCE="$PACK_TARGET_ROOT/.cache/shared/pack-runs.jsonl"

tail_recent_lines() {
  FILE="$1"
  COUNT="$2"
  [ -f "$FILE" ] || return 0
  tail -n "$COUNT" "$FILE" 2>/dev/null || true
}

if [ -f "$WORKFLOW_EVENTS_SOURCE" ]; then
  tail_recent_lines "$WORKFLOW_EVENTS_SOURCE" "$RECENT_WINDOW" | while IFS= read -r LINE; do
    [ -n "$LINE" ] || continue
    EVENT_TS="$(json_string_from_line "$LINE" "timestamp")"
    EVENT_NAME="$(json_string_from_line "$LINE" "event")"
    EVENT_STATUS="$(json_string_from_line "$LINE" "status")"
    EVENT_STEP="$(json_string_from_line "$LINE" "current_step")"
    ATTENTION="false"
    case "$EVENT_NAME" in
      workflow.pause|workflow.abort|review.reject|harness.check.fail|harness.fix.fail|harness.check.error)
        ATTENTION="true"
        ;;
    esac
    printf '%s\t%s\t%s\t%s\t%s\n' "$EVENT_TS" "$EVENT_NAME" "$EVENT_STATUS" "$EVENT_STEP" "$ATTENTION" >> "$WORKFLOW_RECENT_FILE"
  done
fi

if [ -f "$HARNESS_EVENTS_SOURCE" ]; then
  grep -E '"event":"(check.summary|fix.summary)"' "$HARNESS_EVENTS_SOURCE" 2>/dev/null | tail -n "$RECENT_WINDOW" | while IFS= read -r LINE; do
    [ -n "$LINE" ] || continue
    EVENT_TS="$(printf '%s\n' "$LINE" | sed -n 's/.*"generated_at":"\([^"]*\)".*/\1/p')"
    EVENT_NAME="$(printf '%s\n' "$LINE" | sed -n 's/.*"event":"\([^"]*\)".*/\1/p')"
    EVENT_STATUS="$(printf '%s\n' "$LINE" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    EVENT_MODE="$(printf '%s\n' "$LINE" | sed -n 's/.*"mode":"\([^"]*\)".*/\1/p')"
    ATTENTION="false"
    case "$EVENT_NAME:$EVENT_STATUS" in
      check.summary:0|fix.summary:success) ;;
      *) ATTENTION="true" ;;
    esac
    printf '%s\t%s\t%s\t%s\t%s\n' "$EVENT_TS" "$EVENT_NAME" "$EVENT_STATUS" "$EVENT_MODE" "$ATTENTION" >> "$HARNESS_RECENT_FILE"
  done
fi

if [ -d "$EVAL_RUNS_SOURCE" ]; then
  find "$EVAL_RUNS_SOURCE" -mindepth 2 -maxdepth 2 -type f -name summary.json | sort | tail -n "$RECENT_WINDOW" | while IFS= read -r SUMMARY_FILE; do
    [ -f "$SUMMARY_FILE" ] || continue
    RUN_TS="$(json_string_field "$SUMMARY_FILE" "generated_at")"
    RUN_ID_RECENT="$(json_string_field "$SUMMARY_FILE" "run_id")"
    FAILED_CASES_RECENT="$(json_number_field "$SUMMARY_FILE" "failed_cases")"
    PASSED_CASES_RECENT="$(json_number_field "$SUMMARY_FILE" "passed_cases")"
    TOTAL_CASES_RECENT="$(json_number_field "$SUMMARY_FILE" "total_cases")"
    [ -n "$FAILED_CASES_RECENT" ] || FAILED_CASES_RECENT="0"
    [ -n "$PASSED_CASES_RECENT" ] || PASSED_CASES_RECENT="0"
    [ -n "$TOTAL_CASES_RECENT" ] || TOTAL_CASES_RECENT="0"
    ATTENTION="false"
    [ "$FAILED_CASES_RECENT" -gt 0 ] && ATTENTION="true"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$RUN_TS" "$RUN_ID_RECENT" "$TOTAL_CASES_RECENT" "$PASSED_CASES_RECENT" "$FAILED_CASES_RECENT" "$ATTENTION" >> "$EVAL_RECENT_FILE"
  done
fi

if [ -f "$PACK_EVENTS_SOURCE" ]; then
  tail_recent_lines "$PACK_EVENTS_SOURCE" "$RECENT_WINDOW" | while IFS= read -r LINE; do
    [ -n "$LINE" ] || continue
    EVENT_TS="$(printf '%s\n' "$LINE" | sed -n 's/.*"generated_at":"\([^"]*\)".*/\1/p')"
    ACTION_NAME="$(printf '%s\n' "$LINE" | sed -n 's/.*"action":"\([^"]*\)".*/\1/p')"
    PACK_NAME_RECENT="$(printf '%s\n' "$LINE" | sed -n 's/.*"pack":"\([^"]*\)".*/\1/p')"
    PACK_STATUS_RECENT="$(printf '%s\n' "$LINE" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
    PACK_REASON_RECENT="$(printf '%s\n' "$LINE" | sed -n 's/.*"reason":"\([^"]*\)".*/\1/p')"
    ATTENTION="false"
    [ "$PACK_STATUS_RECENT" = "failure" ] && ATTENTION="true"
    printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$EVENT_TS" "$ACTION_NAME" "$PACK_NAME_RECENT" "$PACK_STATUS_RECENT" "$PACK_REASON_RECENT" "$ATTENTION" >> "$PACK_RECENT_FILE"
  done
fi

recent_attention_count() {
  FILE="$1"
  COLUMN="$2"
  [ -f "$FILE" ] || {
    echo "0"
    return
  }
  awk -F '\t' -v col="$COLUMN" '$col == "true" {count++} END {print count+0}' "$FILE"
}

WORKFLOW_RECENT_ATTENTION="$(recent_attention_count "$WORKFLOW_RECENT_FILE" 5)"
HARNESS_RECENT_ATTENTION="$(recent_attention_count "$HARNESS_RECENT_FILE" 5)"
EVAL_RECENT_ATTENTION="$(recent_attention_count "$EVAL_RECENT_FILE" 6)"
PACK_RECENT_ATTENTION="$(recent_attention_count "$PACK_RECENT_FILE" 6)"

OVERALL_STATUS="ok"
SUMMARY_MESSAGE="Subsystem reports look healthy."

if [ "$WORKFLOW_STATUS" = "no_workflow_state" ] && \
   [ "$HARNESS_STATUS" = "no_harness_activity" ] && \
   [ "$EVAL_STATUS" = "no_eval_activity" ] && \
   [ "$PACK_STATUS" = "no_pack_activity" ]; then
  OVERALL_STATUS="empty"
  SUMMARY_MESSAGE="No workflow, harness, eval, or pack activity found yet."
elif [ "$HARNESS_CHECK_BLOCKED" -gt 0 ] || \
     [ "$HARNESS_FIX_FAILURE" -gt 0 ] || \
     [ "$EVAL_FAILED_CASES" -gt 0 ] || \
     [ "$EVAL_REGRESSIONS" -gt 0 ] || \
     [ "$PACK_FAILURE_EVENTS" -gt 0 ] || \
     [ "$WORKFLOW_STATUS" = "aborted" ] || \
     [ "$WORKFLOW_STATUS" = "paused" ]; then
  OVERALL_STATUS="attention"
  SUMMARY_MESSAGE="At least one subsystem report contains failures, regressions, or blocked state."
fi

printf '{\n' > "$REPORT_JSON"
printf '  "generated_at": "%s",\n' "$(workflow_json_escape "$NOW")" >> "$REPORT_JSON"
printf '  "project_root": "%s",\n' "$(workflow_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
printf '  "pack_target_root": "%s",\n' "$(workflow_json_escape "$PACK_TARGET_ROOT")" >> "$REPORT_JSON"
printf '  "recent_window": %s,\n' "$RECENT_WINDOW" >> "$REPORT_JSON"
printf '  "overall_status": "%s",\n' "$(workflow_json_escape "$OVERALL_STATUS")" >> "$REPORT_JSON"
printf '  "summary": "%s",\n' "$(workflow_json_escape "$SUMMARY_MESSAGE")" >> "$REPORT_JSON"
printf '  "workflow": {"status":"%s","event_count":%s,"current_step":"%s","total_rejections":%s},\n' \
  "$(workflow_json_escape "$WORKFLOW_STATUS")" \
  "$WORKFLOW_EVENT_COUNT" \
  "$(workflow_json_escape "$WORKFLOW_CURRENT_STEP")" \
  "$WORKFLOW_REJECTIONS" >> "$REPORT_JSON"
printf '  "harness": {"status":"%s","check_runs":%s,"check_blocked":%s,"fix_success":%s,"fix_failure":%s,"unique_rule_count":%s},\n' \
  "$(workflow_json_escape "$HARNESS_STATUS")" \
  "$HARNESS_CHECK_RUNS" \
  "$HARNESS_CHECK_BLOCKED" \
  "$HARNESS_FIX_SUCCESS" \
  "$HARNESS_FIX_FAILURE" \
  "$HARNESS_RULES" >> "$REPORT_JSON"
printf '  "eval": {"status":"%s","run_count":%s,"latest_run_id":"%s","failed_cases":%s,"regressions":%s},\n' \
  "$(workflow_json_escape "$EVAL_STATUS")" \
  "$EVAL_RUN_COUNT" \
  "$(workflow_json_escape "$EVAL_LATEST_RUN_ID")" \
  "$EVAL_FAILED_CASES" \
  "$EVAL_REGRESSIONS" >> "$REPORT_JSON"
printf '  "pack": {"status":"%s","total_events":%s,"failure_events":%s,"unique_packs":%s},\n' \
  "$(workflow_json_escape "$PACK_STATUS")" \
  "$PACK_TOTAL_EVENTS" \
  "$PACK_FAILURE_EVENTS" \
  "$PACK_UNIQUE_PACKS" >> "$REPORT_JSON"
printf '  "recent_attention": {"workflow":%s,"harness":%s,"eval":%s,"pack":%s},\n' \
  "$WORKFLOW_RECENT_ATTENTION" \
  "$HARNESS_RECENT_ATTENTION" \
  "$EVAL_RECENT_ATTENTION" \
  "$PACK_RECENT_ATTENTION" >> "$REPORT_JSON"
printf '  "recent_activity": {\n' >> "$REPORT_JSON"
printf '    "workflow_events": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r EVENT_TS EVENT_NAME EVENT_STATUS EVENT_STEP ATTENTION; do
  [ -n "$EVENT_TS" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '      {"timestamp":"%s","event":"%s","status":"%s","current_step":"%s","attention":%s}' \
    "$(workflow_json_escape "$EVENT_TS")" \
    "$(workflow_json_escape "$EVENT_NAME")" \
    "$(workflow_json_escape "$EVENT_STATUS")" \
    "$(workflow_json_escape "$EVENT_STEP")" \
    "$ATTENTION" >> "$REPORT_JSON"
done < "$WORKFLOW_RECENT_FILE"
printf '\n    ],\n' >> "$REPORT_JSON"
printf '    "harness_runs": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r EVENT_TS EVENT_NAME EVENT_STATUS EVENT_MODE ATTENTION; do
  [ -n "$EVENT_TS" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '      {"generated_at":"%s","event":"%s","status":"%s","mode":"%s","attention":%s}' \
    "$(workflow_json_escape "$EVENT_TS")" \
    "$(workflow_json_escape "$EVENT_NAME")" \
    "$(workflow_json_escape "$EVENT_STATUS")" \
    "$(workflow_json_escape "$EVENT_MODE")" \
    "$ATTENTION" >> "$REPORT_JSON"
done < "$HARNESS_RECENT_FILE"
printf '\n    ],\n' >> "$REPORT_JSON"
printf '    "eval_runs": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r RUN_TS RUN_ID_RECENT TOTAL_CASES_RECENT PASSED_CASES_RECENT FAILED_CASES_RECENT ATTENTION; do
  [ -n "$RUN_TS" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '      {"generated_at":"%s","run_id":"%s","total_cases":%s,"passed_cases":%s,"failed_cases":%s,"attention":%s}' \
    "$(workflow_json_escape "$RUN_TS")" \
    "$(workflow_json_escape "$RUN_ID_RECENT")" \
    "$TOTAL_CASES_RECENT" \
    "$PASSED_CASES_RECENT" \
    "$FAILED_CASES_RECENT" \
    "$ATTENTION" >> "$REPORT_JSON"
done < "$EVAL_RECENT_FILE"
printf '\n    ],\n' >> "$REPORT_JSON"
printf '    "pack_events": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r EVENT_TS ACTION_NAME PACK_NAME_RECENT PACK_STATUS_RECENT PACK_REASON_RECENT ATTENTION; do
  [ -n "$EVENT_TS" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '      {"generated_at":"%s","action":"%s","pack":"%s","status":"%s","reason":"%s","attention":%s}' \
    "$(workflow_json_escape "$EVENT_TS")" \
    "$(workflow_json_escape "$ACTION_NAME")" \
    "$(workflow_json_escape "$PACK_NAME_RECENT")" \
    "$(workflow_json_escape "$PACK_STATUS_RECENT")" \
    "$(workflow_json_escape "$PACK_REASON_RECENT")" \
    "$ATTENTION" >> "$REPORT_JSON"
done < "$PACK_RECENT_FILE"
printf '\n    ]\n' >> "$REPORT_JSON"
printf '  }\n' >> "$REPORT_JSON"
printf '}\n' >> "$REPORT_JSON"

{
  echo "# Skills Report"
  echo ""
  echo "- project_root: \`$PROJECT_ROOT\`"
  echo "- pack_target_root: \`$PACK_TARGET_ROOT\`"
  echo "- recent_window: \`$RECENT_WINDOW\`"
  echo "- overall_status: \`$OVERALL_STATUS\`"
  echo "- summary: $SUMMARY_MESSAGE"
  echo ""
  echo "## Recent Attention"
  echo ""
  echo "- workflow: \`$WORKFLOW_RECENT_ATTENTION\`"
  echo "- harness: \`$HARNESS_RECENT_ATTENTION\`"
  echo "- eval: \`$EVAL_RECENT_ATTENTION\`"
  echo "- pack: \`$PACK_RECENT_ATTENTION\`"
  echo ""
  echo "## Workflow"
  echo ""
  echo "- status: \`$WORKFLOW_STATUS\`"
  echo "- event_count: \`$WORKFLOW_EVENT_COUNT\`"
  echo "- current_step: \`${WORKFLOW_CURRENT_STEP:-}\`"
  echo "- total_rejections: \`$WORKFLOW_REJECTIONS\`"
  echo ""
  echo "## Harness"
  echo ""
  echo "- status: \`$HARNESS_STATUS\`"
  echo "- check_runs: \`$HARNESS_CHECK_RUNS\`"
  echo "- check_blocked: \`$HARNESS_CHECK_BLOCKED\`"
  echo "- fix_success: \`$HARNESS_FIX_SUCCESS\`"
  echo "- fix_failure: \`$HARNESS_FIX_FAILURE\`"
  echo "- unique_rule_count: \`$HARNESS_RULES\`"
  echo ""
  echo "## Eval"
  echo ""
  echo "- status: \`$EVAL_STATUS\`"
  echo "- run_count: \`$EVAL_RUN_COUNT\`"
  echo "- latest_run_id: \`${EVAL_LATEST_RUN_ID:-}\`"
  echo "- failed_cases: \`$EVAL_FAILED_CASES\`"
  echo "- regressions: \`$EVAL_REGRESSIONS\`"
  echo ""
  echo "## Pack"
  echo ""
  echo "- status: \`$PACK_STATUS\`"
  echo "- total_events: \`$PACK_TOTAL_EVENTS\`"
  echo "- failure_events: \`$PACK_FAILURE_EVENTS\`"
  echo "- unique_packs: \`$PACK_UNIQUE_PACKS\`"
  echo ""
  echo "## Recent Workflow Events"
  echo ""
  echo "| Timestamp | Event | Status | Step | Attention |"
  echo "|-----------|-------|--------|------|-----------|"
  while IFS="$(printf '\t')" read -r EVENT_TS EVENT_NAME EVENT_STATUS EVENT_STEP ATTENTION; do
    [ -n "$EVENT_TS" ] || continue
    echo "| $EVENT_TS | $EVENT_NAME | $EVENT_STATUS | $EVENT_STEP | $ATTENTION |"
  done < "$WORKFLOW_RECENT_FILE"
  echo ""
  echo "## Recent Harness Runs"
  echo ""
  echo "| Timestamp | Event | Status | Mode | Attention |"
  echo "|-----------|-------|--------|------|-----------|"
  while IFS="$(printf '\t')" read -r EVENT_TS EVENT_NAME EVENT_STATUS EVENT_MODE ATTENTION; do
    [ -n "$EVENT_TS" ] || continue
    echo "| $EVENT_TS | $EVENT_NAME | $EVENT_STATUS | $EVENT_MODE | $ATTENTION |"
  done < "$HARNESS_RECENT_FILE"
  echo ""
  echo "## Recent Eval Runs"
  echo ""
  echo "| Timestamp | Run | Total | Passed | Failed | Attention |"
  echo "|-----------|-----|-------|--------|--------|-----------|"
  while IFS="$(printf '\t')" read -r RUN_TS RUN_ID_RECENT TOTAL_CASES_RECENT PASSED_CASES_RECENT FAILED_CASES_RECENT ATTENTION; do
    [ -n "$RUN_TS" ] || continue
    echo "| $RUN_TS | $RUN_ID_RECENT | $TOTAL_CASES_RECENT | $PASSED_CASES_RECENT | $FAILED_CASES_RECENT | $ATTENTION |"
  done < "$EVAL_RECENT_FILE"
  echo ""
  echo "## Recent Pack Events"
  echo ""
  echo "| Timestamp | Action | Pack | Status | Reason | Attention |"
  echo "|-----------|--------|------|--------|--------|-----------|"
  while IFS="$(printf '\t')" read -r EVENT_TS ACTION_NAME PACK_NAME_RECENT PACK_STATUS_RECENT PACK_REASON_RECENT ATTENTION; do
    [ -n "$EVENT_TS" ] || continue
    echo "| $EVENT_TS | $ACTION_NAME | $PACK_NAME_RECENT | $PACK_STATUS_RECENT | $PACK_REASON_RECENT | $ATTENTION |"
  done < "$PACK_RECENT_FILE"
} > "$REPORT_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_JSON"
else
  cat "$REPORT_MD"
fi
