#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVALS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$EVALS_DIR/lib/eval-common.sh"

PROJECT_ROOT="$(pwd)"
CURRENT=""
BASELINE=""
JSON_OUTPUT="no"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --current=*)
      CURRENT="${arg#--current=}"
      ;;
    --baseline=*)
      BASELINE="${arg#--baseline=}"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh eval-compare.sh --current=RUN_OR_PATH --baseline=RUN_OR_PATH [--project-root=PATH] [--json]"
      exit 0
      ;;
    *)
      if [ -z "$CURRENT" ]; then
        CURRENT="$arg"
      elif [ -z "$BASELINE" ]; then
        BASELINE="$arg"
      else
        echo "Unknown option: $arg" >&2
        exit 1
      fi
      ;;
  esac
done

PROJECT_ROOT="$(eval_project_root "$PROJECT_ROOT")"

[ -n "$CURRENT" ] || {
  echo "Missing --current" >&2
  exit 1
}
[ -n "$BASELINE" ] || {
  echo "Missing --baseline" >&2
  exit 1
}

resolve_summary_tsv() {
  ARG="$1"
  if [ -f "$ARG" ]; then
    printf '%s\n' "$ARG"
    return 0
  fi
  if [ -f "$ARG/summary.tsv" ]; then
    printf '%s/summary.tsv\n' "$ARG"
    return 0
  fi
  if [ -f "$(eval_runs_root "$PROJECT_ROOT")/$ARG/summary.tsv" ]; then
    printf '%s/%s/summary.tsv\n' "$(eval_runs_root "$PROJECT_ROOT")" "$ARG"
    return 0
  fi
  return 1
}

CURRENT_TSV="$(resolve_summary_tsv "$CURRENT")" || {
  echo "Unable to resolve current summary: $CURRENT" >&2
  exit 1
}
BASELINE_TSV="$(resolve_summary_tsv "$BASELINE")" || {
  echo "Unable to resolve baseline summary: $BASELINE" >&2
  exit 1
}

OUTPUT_ROOT="$(eval_comparisons_root "$PROJECT_ROOT")/compare-$(date -u +%Y%m%d%H%M%S 2>/dev/null || date +%Y%m%d%H%M%S)-$$"
mkdir -p "$OUTPUT_ROOT"
COMPARISON_TSV="$OUTPUT_ROOT/comparison.tsv"
COMPARISON_JSON="$OUTPUT_ROOT/comparison.json"
COMPARISON_MD="$OUTPUT_ROOT/comparison.md"

printf 'case\tstatus\tcurrent_pass_percent\tbaseline_pass_percent\tpass_delta\tcurrent_avg_duration\tbaseline_avg_duration\tduration_delta\n' > "$COMPARISON_TSV"

compare_case() {
  CASE_NAME="$1"
  CURRENT_ROW="$2"
  BASELINE_ROW="$3"

  CURRENT_PASS="$(printf '%s' "$CURRENT_ROW" | awk -F '\t' '{print $6}')"
  CURRENT_DURATION="$(printf '%s' "$CURRENT_ROW" | awk -F '\t' '{print $7}')"
  BASELINE_PASS="$(printf '%s' "$BASELINE_ROW" | awk -F '\t' '{print $6}')"
  BASELINE_DURATION="$(printf '%s' "$BASELINE_ROW" | awk -F '\t' '{print $7}')"

  [ -n "$CURRENT_PASS" ] || CURRENT_PASS="0"
  [ -n "$BASELINE_PASS" ] || BASELINE_PASS="0"
  [ -n "$CURRENT_DURATION" ] || CURRENT_DURATION="0"
  [ -n "$BASELINE_DURATION" ] || BASELINE_DURATION="0"

  PASS_DELTA=$((CURRENT_PASS - BASELINE_PASS))
  DURATION_DELTA=$((CURRENT_DURATION - BASELINE_DURATION))
  STATUS="same"

  if [ "$PASS_DELTA" -gt 0 ]; then
    STATUS="improved"
  elif [ "$PASS_DELTA" -lt 0 ]; then
    STATUS="regressed"
  elif [ "$DURATION_DELTA" -lt 0 ]; then
    STATUS="faster"
  elif [ "$DURATION_DELTA" -gt 0 ]; then
    STATUS="slower"
  fi

  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$CASE_NAME" "$STATUS" "$CURRENT_PASS" "$BASELINE_PASS" "$PASS_DELTA" \
    "$CURRENT_DURATION" "$BASELINE_DURATION" "$DURATION_DELTA" >> "$COMPARISON_TSV"
}

tail -n +2 "$CURRENT_TSV" | while IFS="$(printf '\t')" read -r CASE_NAME STATUS TRIALS PASSED FAILED PASS_PERCENT AVG_DURATION MIN_PASS DESCRIPTION SOURCE; do
  [ -z "$CASE_NAME" ] && continue
  CURRENT_ROW="$(printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s' "$CASE_NAME" "$STATUS" "$TRIALS" "$PASSED" "$FAILED" "$PASS_PERCENT" "$AVG_DURATION" "$MIN_PASS" "$DESCRIPTION" "$SOURCE")"
  BASELINE_ROW="$(grep -F "$(printf '%s\t' "$CASE_NAME")" "$BASELINE_TSV" || true)"
  if [ -z "$BASELINE_ROW" ]; then
    printf '%s\tnew\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$CASE_NAME" "$PASS_PERCENT" "0" "$PASS_PERCENT" "$AVG_DURATION" "0" "$AVG_DURATION" >> "$COMPARISON_TSV"
  else
    compare_case "$CASE_NAME" "$CURRENT_ROW" "$BASELINE_ROW"
  fi
done

tail -n +2 "$BASELINE_TSV" | while IFS="$(printf '\t')" read -r CASE_NAME STATUS TRIALS PASSED FAILED PASS_PERCENT AVG_DURATION MIN_PASS DESCRIPTION SOURCE; do
  [ -z "$CASE_NAME" ] && continue
  if ! grep -F "$(printf '%s\t' "$CASE_NAME")" "$CURRENT_TSV" >/dev/null 2>&1; then
    printf '%s\tremoved\t0\t%s\t-%s\t0\t%s\t-%s\n' \
      "$CASE_NAME" "$PASS_PERCENT" "$PASS_PERCENT" "$AVG_DURATION" "$AVG_DURATION" >> "$COMPARISON_TSV"
  fi
done

TOTAL_CASES="$(tail -n +2 "$COMPARISON_TSV" | sed '/^$/d' | wc -l | tr -d ' ')"
REGRESSIONS="$(grep -c "$(printf '\tregressed\t')" "$COMPARISON_TSV" 2>/dev/null || true)"
IMPROVEMENTS="$(grep -c "$(printf '\timproved\t')" "$COMPARISON_TSV" 2>/dev/null || true)"

printf '{\n' > "$COMPARISON_JSON"
printf '  "generated_at": "%s",\n' "$(eval_json_escape "$(eval_now_iso)")" >> "$COMPARISON_JSON"
printf '  "project_root": "%s",\n' "$(eval_json_escape "$PROJECT_ROOT")" >> "$COMPARISON_JSON"
printf '  "current": "%s",\n' "$(eval_json_escape "$CURRENT_TSV")" >> "$COMPARISON_JSON"
printf '  "baseline": "%s",\n' "$(eval_json_escape "$BASELINE_TSV")" >> "$COMPARISON_JSON"
printf '  "total_cases": %s,\n' "$TOTAL_CASES" >> "$COMPARISON_JSON"
printf '  "improvements": %s,\n' "$IMPROVEMENTS" >> "$COMPARISON_JSON"
printf '  "regressions": %s,\n' "$REGRESSIONS" >> "$COMPARISON_JSON"
printf '  "cases": [\n' >> "$COMPARISON_JSON"
FIRST="yes"
tail -n +2 "$COMPARISON_TSV" | while IFS="$(printf '\t')" read -r CASE_NAME STATUS CURRENT_PASS BASELINE_PASS PASS_DELTA CURRENT_DURATION BASELINE_DURATION DURATION_DELTA; do
  [ -z "$CASE_NAME" ] && continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$COMPARISON_JSON"
  fi
  printf '    {"case":"%s","status":"%s","current_pass_percent":%s,"baseline_pass_percent":%s,"pass_delta":%s,"current_avg_duration":%s,"baseline_avg_duration":%s,"duration_delta":%s}' \
    "$(eval_json_escape "$CASE_NAME")" \
    "$(eval_json_escape "$STATUS")" \
    "$CURRENT_PASS" "$BASELINE_PASS" "$PASS_DELTA" "$CURRENT_DURATION" "$BASELINE_DURATION" "$DURATION_DELTA" >> "$COMPARISON_JSON"
done
printf '\n  ]\n}\n' >> "$COMPARISON_JSON"

{
  echo "# Eval Comparison"
  echo ""
  echo "- current: \`$CURRENT_TSV\`"
  echo "- baseline: \`$BASELINE_TSV\`"
  echo "- total_cases: \`$TOTAL_CASES\`"
  echo "- improvements: \`$IMPROVEMENTS\`"
  echo "- regressions: \`$REGRESSIONS\`"
  echo ""
  echo "| Case | Status | Pass Delta | Duration Delta(s) |"
  echo "|------|--------|------------|-------------------|"
  tail -n +2 "$COMPARISON_TSV" | while IFS="$(printf '\t')" read -r CASE_NAME STATUS CURRENT_PASS BASELINE_PASS PASS_DELTA CURRENT_DURATION BASELINE_DURATION DURATION_DELTA; do
    [ -z "$CASE_NAME" ] && continue
    echo "| $CASE_NAME | $STATUS | $PASS_DELTA | $DURATION_DELTA |"
  done
} > "$COMPARISON_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$COMPARISON_JSON"
else
  cat "$COMPARISON_MD"
fi

[ "$REGRESSIONS" -eq 0 ]
