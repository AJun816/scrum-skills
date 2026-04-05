#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/harness-common.sh"

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
      echo "Usage: sh harness-report.sh [--project-root=PATH] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
RUNS_FILE="$(harness_runs_file "$PROJECT_ROOT")"
REPORT_JSON="$(harness_report_json "$PROJECT_ROOT")"
REPORT_MD="$(harness_report_md "$PROJECT_ROOT")"
NOW="$(harness_now_iso)"

mkdir -p "$(harness_shared_dir "$PROJECT_ROOT")"

emit_no_activity_report() {
  printf '{\n' > "$REPORT_JSON"
  printf '  "generated_at": "%s",\n' "$(harness_json_escape "$NOW")" >> "$REPORT_JSON"
  printf '  "project_root": "%s",\n' "$(harness_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
  printf '  "status": "no_harness_activity",\n' >> "$REPORT_JSON"
  printf '  "summary": "No harness check or fix activity found for this project."\n' >> "$REPORT_JSON"
  printf '}\n' >> "$REPORT_JSON"

  {
    echo "# Harness Report"
    echo ""
    echo "- project_root: \`$PROJECT_ROOT\`"
    echo "- status: \`no_harness_activity\`"
    echo "- summary: No harness check or fix activity found for this project."
  } > "$REPORT_MD"

  if [ "$JSON_OUTPUT" = "yes" ]; then
    cat "$REPORT_JSON"
  else
    cat "$REPORT_MD"
  fi
}

[ -f "$RUNS_FILE" ] || {
  emit_no_activity_report
  exit 0
}

RULES_TSV="$(mktemp "${TMPDIR:-/tmp}/harness-report-rules.XXXXXX")"
FAILURES_TSV="$(mktemp "${TMPDIR:-/tmp}/harness-report-failures.XXXXXX")"
trap 'rm -f "$RULES_TSV" "$FAILURES_TSV"' EXIT HUP INT TERM

TOTAL_EVENTS=0
CHECK_RUNS=0
CHECK_PASS=0
CHECK_FIXABLE=0
CHECK_BLOCKED=0
CHECK_HARD_FAILURE=0
FIX_RUNS=0
FIX_SUCCESS=0
FIX_FAILURE=0
LAST_EVENT_AT=""

while IFS= read -r LINE; do
  [ -n "$LINE" ] || continue
  EVENT_NAME="$(printf '%s\n' "$LINE" | sed -n 's/.*"event":"\([^"]*\)".*/\1/p')"
  STATUS="$(printf '%s\n' "$LINE" | sed -n 's/.*"status":"\([^"]*\)".*/\1/p')"
  RULE_ID="$(printf '%s\n' "$LINE" | sed -n 's/.*"rule_id":"\([^"]*\)".*/\1/p')"
  AUTO_FIXABLE="$(printf '%s\n' "$LINE" | sed -n 's/.*"auto_fixable":"\([^"]*\)".*/\1/p')"
  GENERATED_AT="$(printf '%s\n' "$LINE" | sed -n 's/.*"generated_at":"\([^"]*\)".*/\1/p')"
  MESSAGE="$(printf '%s\n' "$LINE" | sed -n 's/.*"message":"\([^"]*\)".*/\1/p')"

  TOTAL_EVENTS=$((TOTAL_EVENTS + 1))
  LAST_EVENT_AT="$GENERATED_AT"

  case "$EVENT_NAME" in
    check.summary)
      CHECK_RUNS=$((CHECK_RUNS + 1))
      case "$STATUS" in
        0) CHECK_PASS=$((CHECK_PASS + 1)) ;;
        2) CHECK_FIXABLE=$((CHECK_FIXABLE + 1)) ;;
        3) CHECK_BLOCKED=$((CHECK_BLOCKED + 1)) ;;
        4) CHECK_HARD_FAILURE=$((CHECK_HARD_FAILURE + 1)) ;;
      esac
      ;;
    fix.summary)
      FIX_RUNS=$((FIX_RUNS + 1))
      case "$STATUS" in
        success) FIX_SUCCESS=$((FIX_SUCCESS + 1)) ;;
        *) FIX_FAILURE=$((FIX_FAILURE + 1)) ;;
      esac
      ;;
    check.violation)
      [ -n "$RULE_ID" ] || RULE_ID="unknown"
      printf '%s\t%s\n' "$RULE_ID" "$AUTO_FIXABLE" >> "$RULES_TSV"
      if [ "$AUTO_FIXABLE" != "true" ]; then
        printf '%s\t%s\t%s\n' "$GENERATED_AT" "$RULE_ID" "$MESSAGE" >> "$FAILURES_TSV"
      fi
      ;;
  esac
done < "$RUNS_FILE"

awk -F '\t' '{
  total[$1]++
  if ($2 == "true") fixable[$1]++
  else non_fixable[$1]++
}
END {
  for (rule in total) {
    printf "%s\t%d\t%d\t%d\n", rule, total[rule], fixable[rule] + 0, non_fixable[rule] + 0
  }
}' "$RULES_TSV" | sort > "${RULES_TSV}.summary"
mv "${RULES_TSV}.summary" "$RULES_TSV"

RULE_COUNT="$(wc -l < "$RULES_TSV" | tr -d ' ')"

printf '{\n' > "$REPORT_JSON"
printf '  "generated_at": "%s",\n' "$(harness_json_escape "$NOW")" >> "$REPORT_JSON"
printf '  "project_root": "%s",\n' "$(harness_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
printf '  "status": "ok",\n' >> "$REPORT_JSON"
printf '  "total_events": %s,\n' "$TOTAL_EVENTS" >> "$REPORT_JSON"
printf '  "check_runs": %s,\n' "$CHECK_RUNS" >> "$REPORT_JSON"
printf '  "check_pass": %s,\n' "$CHECK_PASS" >> "$REPORT_JSON"
printf '  "check_fixable": %s,\n' "$CHECK_FIXABLE" >> "$REPORT_JSON"
printf '  "check_blocked": %s,\n' "$CHECK_BLOCKED" >> "$REPORT_JSON"
printf '  "check_hard_failure": %s,\n' "$CHECK_HARD_FAILURE" >> "$REPORT_JSON"
printf '  "fix_runs": %s,\n' "$FIX_RUNS" >> "$REPORT_JSON"
printf '  "fix_success": %s,\n' "$FIX_SUCCESS" >> "$REPORT_JSON"
printf '  "fix_failure": %s,\n' "$FIX_FAILURE" >> "$REPORT_JSON"
printf '  "last_event_at": "%s",\n' "$(harness_json_escape "$LAST_EVENT_AT")" >> "$REPORT_JSON"
printf '  "drift_rules": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r RULE_ID TOTAL FIXABLE NON_FIXABLE; do
  [ -n "$RULE_ID" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"rule_id":"%s","total":%s,"fixable":%s,"non_fixable":%s}' \
    "$(harness_json_escape "$RULE_ID")" \
    "$TOTAL" \
    "$FIXABLE" \
    "$NON_FIXABLE" >> "$REPORT_JSON"
done < "$RULES_TSV"
printf '\n  ],\n' >> "$REPORT_JSON"
printf '  "unique_rule_count": %s\n' "$RULE_COUNT" >> "$REPORT_JSON"
printf '}\n' >> "$REPORT_JSON"

{
  echo "# Harness Report"
  echo ""
  echo "- project_root: \`$PROJECT_ROOT\`"
  echo "- total_events: \`$TOTAL_EVENTS\`"
  echo "- check_runs: \`$CHECK_RUNS\`"
  echo "- check_pass: \`$CHECK_PASS\`"
  echo "- check_fixable: \`$CHECK_FIXABLE\`"
  echo "- check_blocked: \`$CHECK_BLOCKED\`"
  echo "- check_hard_failure: \`$CHECK_HARD_FAILURE\`"
  echo "- fix_runs: \`$FIX_RUNS\`"
  echo "- fix_success: \`$FIX_SUCCESS\`"
  echo "- fix_failure: \`$FIX_FAILURE\`"
  echo "- last_event_at: \`$LAST_EVENT_AT\`"
  echo ""
  echo "## Drift Rules"
  echo ""
  echo "| Rule | Total | Fixable | Non-fixable |"
  echo "|------|-------|---------|-------------|"
  while IFS="$(printf '\t')" read -r RULE_ID TOTAL FIXABLE NON_FIXABLE; do
    [ -n "$RULE_ID" ] || continue
    echo "| $RULE_ID | $TOTAL | $FIXABLE | $NON_FIXABLE |"
  done < "$RULES_TSV"
} > "$REPORT_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_JSON"
else
  cat "$REPORT_MD"
fi
