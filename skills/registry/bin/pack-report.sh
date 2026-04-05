#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$REGISTRY_DIR/lib/registry-common.sh"

TARGET=""
AGENT="claude"
JSON_OUTPUT="no"

for arg in "$@"; do
  case "$arg" in
    --target=*)
      TARGET="${arg#--target=}"
      ;;
    --agent=*)
      AGENT="${arg#--agent=}"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh pack-report.sh [--agent=claude|codex] [--target=/path/to/.claude] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

TARGET_ROOT="$(registry_target_root "$TARGET" "$AGENT")"
TARGET_SKILLS="$(registry_target_skills_dir "$TARGET" "$AGENT")"
SHARED_DIR="$(registry_shared_dir "$TARGET_ROOT")"
RUNS_FILE="$(registry_runs_file "$TARGET_ROOT")"
REPORT_JSON="$(registry_report_json "$TARGET_ROOT")"
REPORT_MD="$(registry_report_md "$TARGET_ROOT")"
NOW="$(registry_now_iso)"

mkdir -p "$SHARED_DIR"

emit_no_activity_report() {
  printf '{\n' > "$REPORT_JSON"
  printf '  "generated_at": "%s",\n' "$(registry_json_escape "$NOW")" >> "$REPORT_JSON"
  printf '  "target_root": "%s",\n' "$(registry_json_escape "$TARGET_ROOT")" >> "$REPORT_JSON"
  printf '  "target_skills": "%s",\n' "$(registry_json_escape "$TARGET_SKILLS")" >> "$REPORT_JSON"
  printf '  "status": "no_pack_activity",\n' >> "$REPORT_JSON"
  printf '  "summary": "No pack install or update activity found for this target."\n' >> "$REPORT_JSON"
  printf '}\n' >> "$REPORT_JSON"

  {
    echo "# Pack Report"
    echo ""
    echo "- target_root: \`$TARGET_ROOT\`"
    echo "- target_skills: \`$TARGET_SKILLS\`"
    echo "- status: \`no_pack_activity\`"
    echo "- summary: No pack install or update activity found for this target."
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

EVENTS_TSV="$(mktemp "${TMPDIR:-/tmp}/pack-report-events.XXXXXX")"
PACKS_TSV="$(mktemp "${TMPDIR:-/tmp}/pack-report-packs.XXXXXX")"
REASONS_TSV="$(mktemp "${TMPDIR:-/tmp}/pack-report-reasons.XXXXXX")"
FAILURES_TSV="$(mktemp "${TMPDIR:-/tmp}/pack-report-failures.XXXXXX")"
trap 'rm -f "$EVENTS_TSV" "$PACKS_TSV" "$REASONS_TSV" "$FAILURES_TSV"' EXIT HUP INT TERM

TOTAL_EVENTS=0
SUCCESS_EVENTS=0
FAILURE_EVENTS=0
INSTALL_SUCCESS=0
INSTALL_FAILURE=0
UPDATE_SUCCESS=0
UPDATE_FAILURE=0
LAST_EVENT_AT=""

while IFS= read -r LINE; do
  [ -n "$LINE" ] || continue
  GENERATED_AT="$(registry_json_field_from_line "$LINE" "generated_at")"
  ACTION="$(registry_json_field_from_line "$LINE" "action")"
  PACK_NAME="$(registry_json_field_from_line "$LINE" "pack")"
  STATUS="$(registry_json_field_from_line "$LINE" "status")"
  REASON="$(registry_json_field_from_line "$LINE" "reason")"
  MESSAGE="$(registry_json_field_from_line "$LINE" "message")"

  [ -n "$PACK_NAME" ] || PACK_NAME="unknown"
  [ -n "$ACTION" ] || ACTION="unknown"
  [ -n "$STATUS" ] || STATUS="unknown"

  TOTAL_EVENTS=$((TOTAL_EVENTS + 1))
  LAST_EVENT_AT="$GENERATED_AT"
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$PACK_NAME" "$ACTION" "$STATUS" "$REASON" "$GENERATED_AT" "$MESSAGE" >> "$EVENTS_TSV"

  case "$STATUS" in
    success) SUCCESS_EVENTS=$((SUCCESS_EVENTS + 1)) ;;
    failure) FAILURE_EVENTS=$((FAILURE_EVENTS + 1)) ;;
  esac

  case "$ACTION:$STATUS" in
    install:success) INSTALL_SUCCESS=$((INSTALL_SUCCESS + 1)) ;;
    install:failure) INSTALL_FAILURE=$((INSTALL_FAILURE + 1)) ;;
    update:success) UPDATE_SUCCESS=$((UPDATE_SUCCESS + 1)) ;;
    update:failure) UPDATE_FAILURE=$((UPDATE_FAILURE + 1)) ;;
  esac

  if [ "$STATUS" = "failure" ]; then
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$GENERATED_AT" "$PACK_NAME" "$ACTION" "$REASON" "$MESSAGE" >> "$FAILURES_TSV"
  fi
done < "$RUNS_FILE"

awk -F '\t' '{
  total[$1]++
  if ($3 == "success") success[$1]++
  if ($3 == "failure") failure[$1]++
}
END {
  for (pack in total) {
    printf "%s\t%d\t%d\t%d\n", pack, total[pack], success[pack] + 0, failure[pack] + 0
  }
}' "$EVENTS_TSV" | sort > "$PACKS_TSV"

awk -F '\t' '$3 == "failure" && $4 != "" && $4 != "unknown" { count[$4]++ }
END {
  for (reason in count) {
    printf "%s\t%d\n", reason, count[reason]
  }
}' "$EVENTS_TSV" | sort > "$REASONS_TSV"

UNIQUE_PACKS="$(wc -l < "$PACKS_TSV" | tr -d ' ')"

printf '{\n' > "$REPORT_JSON"
printf '  "generated_at": "%s",\n' "$(registry_json_escape "$NOW")" >> "$REPORT_JSON"
printf '  "target_root": "%s",\n' "$(registry_json_escape "$TARGET_ROOT")" >> "$REPORT_JSON"
printf '  "target_skills": "%s",\n' "$(registry_json_escape "$TARGET_SKILLS")" >> "$REPORT_JSON"
printf '  "status": "ok",\n' >> "$REPORT_JSON"
printf '  "total_events": %s,\n' "$TOTAL_EVENTS" >> "$REPORT_JSON"
printf '  "success_events": %s,\n' "$SUCCESS_EVENTS" >> "$REPORT_JSON"
printf '  "failure_events": %s,\n' "$FAILURE_EVENTS" >> "$REPORT_JSON"
printf '  "install_success": %s,\n' "$INSTALL_SUCCESS" >> "$REPORT_JSON"
printf '  "install_failure": %s,\n' "$INSTALL_FAILURE" >> "$REPORT_JSON"
printf '  "update_success": %s,\n' "$UPDATE_SUCCESS" >> "$REPORT_JSON"
printf '  "update_failure": %s,\n' "$UPDATE_FAILURE" >> "$REPORT_JSON"
printf '  "unique_packs": %s,\n' "$UNIQUE_PACKS" >> "$REPORT_JSON"
printf '  "last_event_at": "%s",\n' "$(registry_json_escape "$LAST_EVENT_AT")" >> "$REPORT_JSON"
printf '  "failure_reasons": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r REASON COUNT; do
  [ -n "$REASON" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"reason":"%s","count":%s}' \
    "$(registry_json_escape "$REASON")" \
    "$COUNT" >> "$REPORT_JSON"
done < "$REASONS_TSV"
printf '\n  ],\n' >> "$REPORT_JSON"
printf '  "packs": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r PACK_NAME EVENTS SUCCESS FAILURE; do
  [ -n "$PACK_NAME" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"pack":"%s","events":%s,"success":%s,"failure":%s}' \
    "$(registry_json_escape "$PACK_NAME")" \
    "$EVENTS" "$SUCCESS" "$FAILURE" >> "$REPORT_JSON"
done < "$PACKS_TSV"
printf '\n  ],\n' >> "$REPORT_JSON"
printf '  "recent_failures": [\n' >> "$REPORT_JSON"
FIRST="yes"
while IFS="$(printf '\t')" read -r GENERATED_AT PACK_NAME ACTION REASON MESSAGE; do
  [ -n "$GENERATED_AT" ] || continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"generated_at":"%s","pack":"%s","action":"%s","reason":"%s","message":"%s"}' \
    "$(registry_json_escape "$GENERATED_AT")" \
    "$(registry_json_escape "$PACK_NAME")" \
    "$(registry_json_escape "$ACTION")" \
    "$(registry_json_escape "$REASON")" \
    "$(registry_json_escape "$MESSAGE")" >> "$REPORT_JSON"
done <<EOF
$(tail -n 5 "$FAILURES_TSV")
EOF
printf '\n  ]\n}\n' >> "$REPORT_JSON"

{
  echo "# Pack Report"
  echo ""
  echo "- target_root: \`$TARGET_ROOT\`"
  echo "- target_skills: \`$TARGET_SKILLS\`"
  echo "- total_events: \`$TOTAL_EVENTS\`"
  echo "- success_events: \`$SUCCESS_EVENTS\`"
  echo "- failure_events: \`$FAILURE_EVENTS\`"
  echo "- install_success: \`$INSTALL_SUCCESS\`"
  echo "- install_failure: \`$INSTALL_FAILURE\`"
  echo "- update_success: \`$UPDATE_SUCCESS\`"
  echo "- update_failure: \`$UPDATE_FAILURE\`"
  echo "- unique_packs: \`$UNIQUE_PACKS\`"
  echo "- last_event_at: \`$LAST_EVENT_AT\`"
  echo ""
  echo "## Packs"
  echo ""
  echo "| Pack | Events | Success | Failure |"
  echo "|------|--------|---------|---------|"
  while IFS="$(printf '\t')" read -r PACK_NAME EVENTS SUCCESS FAILURE; do
    [ -n "$PACK_NAME" ] || continue
    echo "| $PACK_NAME | $EVENTS | $SUCCESS | $FAILURE |"
  done < "$PACKS_TSV"
  echo ""
  echo "## Failure Reasons"
  echo ""
  if [ ! -s "$REASONS_TSV" ]; then
    echo "- none"
  else
    while IFS="$(printf '\t')" read -r REASON COUNT; do
      [ -n "$REASON" ] || continue
      echo "- $REASON: \`$COUNT\`"
    done < "$REASONS_TSV"
  fi
} > "$REPORT_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_JSON"
else
  cat "$REPORT_MD"
fi
