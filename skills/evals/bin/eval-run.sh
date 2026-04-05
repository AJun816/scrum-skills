#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVALS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$EVALS_DIR/lib/eval-common.sh"

PROJECT_ROOT="$(pwd)"
TRIALS="1"
RUN_ALL="no"
JSON_OUTPUT="no"
RUN_ROOT=""
CASE_NAMES=""

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --trials=*)
      TRIALS="${arg#--trials=}"
      ;;
    --output-dir=*)
      RUN_ROOT="${arg#--output-dir=}"
      ;;
    --all)
      RUN_ALL="yes"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh eval-run.sh [CASE_NAME ... | --all] [--project-root=PATH] [--trials=N] [--output-dir=PATH] [--json]"
      exit 0
      ;;
    *)
      CASE_NAMES="$CASE_NAMES
$arg"
      ;;
  esac
done

PROJECT_ROOT="$(eval_project_root "$PROJECT_ROOT")"

case "$TRIALS" in
  ''|*[!0-9]*|0)
    echo "Invalid --trials value: $TRIALS" >&2
    exit 1
    ;;
esac

if [ "$RUN_ALL" != "yes" ] && [ -z "$(printf '%s' "$CASE_NAMES" | sed '/^$/d')" ]; then
  echo "Missing CASE_NAME or --all" >&2
  exit 1
fi

resolve_run_root() {
  if [ -n "$RUN_ROOT" ]; then
    case "$RUN_ROOT" in
      /*) printf '%s\n' "$RUN_ROOT" ;;
      *) printf '%s/%s\n' "$PROJECT_ROOT" "$RUN_ROOT" ;;
    esac
    return
  fi
  printf '%s/%s\n' "$(eval_runs_root "$PROJECT_ROOT")" "$(eval_run_id_new)"
}

collect_case_files() {
  CASE_LIST_FILE="$1"
  SEEN_FILE="$2"

  append_case_file() {
    CASE_FILE="$1"
    CASE_NAME="$(eval_case_name_from_file "$CASE_FILE")"
    grep -Fx "$CASE_NAME" "$SEEN_FILE" >/dev/null 2>&1 && return 0
    printf '%s\n' "$CASE_FILE" >> "$CASE_LIST_FILE"
    printf '%s\n' "$CASE_NAME" >> "$SEEN_FILE"
  }

  if [ "$RUN_ALL" = "yes" ]; then
    for CASE_DIR in "$(eval_project_cases_dir "$PROJECT_ROOT")"; do
      [ -d "$CASE_DIR" ] || continue
      find "$CASE_DIR" -mindepth 1 -maxdepth 1 -type f -name '*.case.env' | sort | while IFS= read -r CASE_FILE; do
        append_case_file "$CASE_FILE"
      done
    done

    if [ "$PROJECT_ROOT" = "$EVAL_PACKAGE_ROOT" ]; then
      for CASE_DIR in "$(eval_builtin_cases_dir)"; do
        [ -d "$CASE_DIR" ] || continue
        find "$CASE_DIR" -mindepth 1 -maxdepth 1 -type f -name '*.case.env' | sort | while IFS= read -r CASE_FILE; do
          append_case_file "$CASE_FILE"
        done
      done
    fi
    return
  fi

  while IFS= read -r CASE_NAME; do
    [ -z "$CASE_NAME" ] && continue
    CASE_FILE="$(eval_find_case_file "$PROJECT_ROOT" "$CASE_NAME")" || {
      echo "Unknown eval case: $CASE_NAME" >&2
      exit 1
    }
    append_case_file "$CASE_FILE"
  done <<EOF
$CASE_NAMES
EOF
}

append_failed_check() {
  FAILURES_FILE="$1"
  CHECK_NAME="$2"
  CHECK_VALUE="$3"
  printf '%s\t%s\n' "$CHECK_NAME" "$CHECK_VALUE" >> "$FAILURES_FILE"
}

validate_contains() {
  TARGET_FILE="$1"
  EXPECTED_LINES="$2"
  CHECK_NAME="$3"
  FAILURES_FILE="$4"
  FAILED="no"

  while IFS= read -r PATTERN; do
    [ -z "$PATTERN" ] && continue
    if ! grep -F "$PATTERN" "$TARGET_FILE" >/dev/null 2>&1; then
      append_failed_check "$FAILURES_FILE" "$CHECK_NAME" "$PATTERN"
      FAILED="yes"
    fi
  done <<EOF
$EXPECTED_LINES
EOF

  [ "$FAILED" = "no" ]
}

validate_regex() {
  TARGET_FILE="$1"
  EXPECTED_LINES="$2"
  CHECK_NAME="$3"
  FAILURES_FILE="$4"
  FAILED="no"

  while IFS= read -r PATTERN; do
    [ -z "$PATTERN" ] && continue
    if ! grep -E "$PATTERN" "$TARGET_FILE" >/dev/null 2>&1; then
      append_failed_check "$FAILURES_FILE" "$CHECK_NAME" "$PATTERN"
      FAILED="yes"
    fi
  done <<EOF
$EXPECTED_LINES
EOF

  [ "$FAILED" = "no" ]
}

write_trial_grade_json() {
  TRIAL_DIR="$1"
  PASSED="$2"
  EXIT_CODE="$3"
  EXPECTED_EXIT="$4"
  DURATION_SECONDS="$5"
  FAILURES_FILE="$6"

  GRADE_JSON="$TRIAL_DIR/grade.json"
  printf '{\n' > "$GRADE_JSON"
  printf '  "passed": %s,\n' "$PASSED" >> "$GRADE_JSON"
  printf '  "exit_code": %s,\n' "$EXIT_CODE" >> "$GRADE_JSON"
  printf '  "expected_exit_code": %s,\n' "$EXPECTED_EXIT" >> "$GRADE_JSON"
  printf '  "duration_seconds": %s,\n' "$DURATION_SECONDS" >> "$GRADE_JSON"
  printf '  "failed_checks": [\n' >> "$GRADE_JSON"
  FIRST="yes"
  while IFS="$(printf '\t')" read -r CHECK_NAME CHECK_VALUE; do
    [ -z "$CHECK_NAME" ] && continue
    if [ "$FIRST" = "yes" ]; then
      FIRST="no"
    else
      printf ',\n' >> "$GRADE_JSON"
    fi
    printf '    {"check":"%s","value":"%s"}' \
      "$(eval_json_escape "$CHECK_NAME")" \
      "$(eval_json_escape "$CHECK_VALUE")" >> "$GRADE_JSON"
  done < "$FAILURES_FILE"
  printf '\n  ]\n}\n' >> "$GRADE_JSON"
}

write_run_outputs() {
  RUN_ID="$1"
  RUN_ROOT="$2"
  CASE_SUMMARY_LIST="$3"
  SUMMARY_TSV="$RUN_ROOT/summary.tsv"
  SUMMARY_JSON="$RUN_ROOT/summary.json"
  SUMMARY_MD="$RUN_ROOT/summary.md"
  GENERATED_AT="$(eval_now_iso)"
  TOTAL_CASES="0"
  PASSED_CASES="0"
  FAILED_CASES="0"

  printf 'case\tstatus\ttrials\tpassed\tfailed\tpass_percent\tavg_duration_seconds\tmin_pass_percent\tdescription\tsource\n' > "$SUMMARY_TSV"

  while IFS= read -r CASE_SUMMARY_FILE; do
    [ -f "$CASE_SUMMARY_FILE" ] || continue
    # shellcheck disable=SC1090
    . "$CASE_SUMMARY_FILE"
    TOTAL_CASES=$((TOTAL_CASES + 1))
    if [ "$CASE_STATUS" = "pass" ]; then
      PASSED_CASES=$((PASSED_CASES + 1))
    else
      FAILED_CASES=$((FAILED_CASES + 1))
    fi
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$CASE_NAME" "$CASE_STATUS" "$CASE_TRIALS" "$CASE_PASSED" "$CASE_FAILED" \
      "$CASE_PASS_PERCENT" "$CASE_AVG_DURATION" "$CASE_MIN_PASS_PERCENT" \
      "$CASE_DESCRIPTION" "$CASE_SOURCE" >> "$SUMMARY_TSV"
  done < "$CASE_SUMMARY_LIST"

  printf '{\n' > "$SUMMARY_JSON"
  printf '  "run_id": "%s",\n' "$(eval_json_escape "$RUN_ID")" >> "$SUMMARY_JSON"
  printf '  "generated_at": "%s",\n' "$(eval_json_escape "$GENERATED_AT")" >> "$SUMMARY_JSON"
  printf '  "project_root": "%s",\n' "$(eval_json_escape "$PROJECT_ROOT")" >> "$SUMMARY_JSON"
  printf '  "trials_per_case": %s,\n' "$TRIALS" >> "$SUMMARY_JSON"
  printf '  "total_cases": %s,\n' "$TOTAL_CASES" >> "$SUMMARY_JSON"
  printf '  "passed_cases": %s,\n' "$PASSED_CASES" >> "$SUMMARY_JSON"
  printf '  "failed_cases": %s,\n' "$FAILED_CASES" >> "$SUMMARY_JSON"
  printf '  "cases": [\n' >> "$SUMMARY_JSON"
  FIRST="yes"
  while IFS= read -r CASE_SUMMARY_FILE; do
    [ -f "$CASE_SUMMARY_FILE" ] || continue
    # shellcheck disable=SC1090
    . "$CASE_SUMMARY_FILE"
    if [ "$FIRST" = "yes" ]; then
      FIRST="no"
    else
      printf ',\n' >> "$SUMMARY_JSON"
    fi
    printf '    {"case":"%s","status":"%s","trials":%s,"passed":%s,"failed":%s,"pass_percent":%s,"avg_duration_seconds":%s,"min_pass_percent":%s,"description":"%s","source":"%s"}' \
      "$(eval_json_escape "$CASE_NAME")" \
      "$(eval_json_escape "$CASE_STATUS")" \
      "$CASE_TRIALS" \
      "$CASE_PASSED" \
      "$CASE_FAILED" \
      "$CASE_PASS_PERCENT" \
      "$CASE_AVG_DURATION" \
      "$CASE_MIN_PASS_PERCENT" \
      "$(eval_json_escape "$CASE_DESCRIPTION")" \
      "$(eval_json_escape "$CASE_SOURCE")" >> "$SUMMARY_JSON"
  done < "$CASE_SUMMARY_LIST"
  printf '\n  ]\n}\n' >> "$SUMMARY_JSON"

  {
    echo "# Eval Run Summary"
    echo ""
    echo "- run_id: \`$RUN_ID\`"
    echo "- generated_at: \`$GENERATED_AT\`"
    echo "- project_root: \`$PROJECT_ROOT\`"
    echo "- trials_per_case: \`$TRIALS\`"
    echo "- total_cases: \`$TOTAL_CASES\`"
    echo "- passed_cases: \`$PASSED_CASES\`"
    echo "- failed_cases: \`$FAILED_CASES\`"
    echo ""
    echo "| Case | Status | Trials | Pass Rate | Avg Duration(s) |"
    echo "|------|--------|--------|-----------|-----------------|"
    while IFS= read -r CASE_SUMMARY_FILE; do
      [ -f "$CASE_SUMMARY_FILE" ] || continue
      # shellcheck disable=SC1090
      . "$CASE_SUMMARY_FILE"
      echo "| $CASE_NAME | $CASE_STATUS | $CASE_TRIALS | $CASE_PASS_PERCENT% | $CASE_AVG_DURATION |"
    done < "$CASE_SUMMARY_LIST"
  } > "$SUMMARY_MD"

  if [ "$JSON_OUTPUT" = "yes" ]; then
    cat "$SUMMARY_JSON"
  else
    cat "$SUMMARY_MD"
  fi

  [ "$FAILED_CASES" -eq 0 ]
}

RUN_ROOT="$(resolve_run_root)"
RUN_ID="$(basename "$RUN_ROOT")"
CASE_LIST_FILE="$(mktemp "${TMPDIR:-/tmp}/eval-run-cases.XXXXXX")"
SEEN_FILE="$(mktemp "${TMPDIR:-/tmp}/eval-run-seen.XXXXXX")"
CASE_SUMMARY_LIST="$(mktemp "${TMPDIR:-/tmp}/eval-run-summaries.XXXXXX")"
trap 'rm -f "$CASE_LIST_FILE" "$SEEN_FILE" "$CASE_SUMMARY_LIST"' EXIT HUP INT TERM

mkdir -p "$RUN_ROOT"
collect_case_files "$CASE_LIST_FILE" "$SEEN_FILE"

if [ ! -s "$CASE_LIST_FILE" ]; then
  echo "No eval cases found. Add .harness/evals/*.case.env or run from the scrum-skills package root for built-in cases." >&2
  exit 1
fi

printf 'RUN_ID=%s\n' "$RUN_ID" > "$RUN_ROOT/run.env"
printf 'PROJECT_ROOT=%s\n' "$PROJECT_ROOT" >> "$RUN_ROOT/run.env"
printf 'GENERATED_AT=%s\n' "$(eval_now_iso)" >> "$RUN_ROOT/run.env"
printf 'TRIALS=%s\n' "$TRIALS" >> "$RUN_ROOT/run.env"

while IFS= read -r CASE_FILE; do
  [ -f "$CASE_FILE" ] || continue
  eval_load_case "$CASE_FILE" "$PROJECT_ROOT"

  case "$CASE_FILE" in
    "$(eval_project_cases_dir "$PROJECT_ROOT")"/*) CASE_SOURCE="project" ;;
    *) CASE_SOURCE="builtin" ;;
  esac

  CASE_DIR="$RUN_ROOT/$EVAL_NAME"
  mkdir -p "$CASE_DIR"

  CASE_PASSED="0"
  CASE_FAILED="0"
  CASE_TOTAL_DURATION="0"
  TRIAL_INDEX="1"

  while [ "$TRIAL_INDEX" -le "$TRIALS" ]; do
    TRIAL_NAME="$(printf 'trial-%02d' "$TRIAL_INDEX")"
    TRIAL_DIR="$CASE_DIR/$TRIAL_NAME"
    TRIAL_STDOUT="$TRIAL_DIR/stdout.txt"
    TRIAL_STDERR="$TRIAL_DIR/stderr.txt"
    FAILURES_FILE="$TRIAL_DIR/failed-checks.tsv"
    mkdir -p "$TRIAL_DIR"
    : > "$FAILURES_FILE"

    STARTED_AT="$(eval_now_iso)"
    START_EPOCH="$(eval_now_epoch)"
    set +e
    (
      cd "$EVAL_CWD"
      sh -c "$EVAL_COMMAND"
    ) >"$TRIAL_STDOUT" 2>"$TRIAL_STDERR"
    EXIT_CODE="$?"
    set -e
    COMPLETED_AT="$(eval_now_iso)"
    END_EPOCH="$(eval_now_epoch)"
    DURATION_SECONDS="$(eval_duration_seconds "$START_EPOCH" "$END_EPOCH")"
    [ -n "$DURATION_SECONDS" ] || DURATION_SECONDS="0"

    TRIAL_PASSED="true"
    if [ "$EXIT_CODE" != "$EVAL_EXPECT_EXIT" ]; then
      append_failed_check "$FAILURES_FILE" "exit_code" "$EXIT_CODE"
      TRIAL_PASSED="false"
    fi

    validate_contains "$TRIAL_STDOUT" "${EVAL_EXPECT_STDOUT_CONTAINS:-}" "stdout_contains" "$FAILURES_FILE" || TRIAL_PASSED="false"
    validate_contains "$TRIAL_STDERR" "${EVAL_EXPECT_STDERR_CONTAINS:-}" "stderr_contains" "$FAILURES_FILE" || TRIAL_PASSED="false"
    validate_regex "$TRIAL_STDOUT" "${EVAL_EXPECT_STDOUT_REGEX:-}" "stdout_regex" "$FAILURES_FILE" || TRIAL_PASSED="false"
    validate_regex "$TRIAL_STDERR" "${EVAL_EXPECT_STDERR_REGEX:-}" "stderr_regex" "$FAILURES_FILE" || TRIAL_PASSED="false"

    write_trial_grade_json "$TRIAL_DIR" "$TRIAL_PASSED" "$EXIT_CODE" "$EVAL_EXPECT_EXIT" "$DURATION_SECONDS" "$FAILURES_FILE"

    {
      echo "CASE_NAME=$EVAL_NAME"
      echo "TRIAL_NAME=$TRIAL_NAME"
      echo "STARTED_AT=$STARTED_AT"
      echo "COMPLETED_AT=$COMPLETED_AT"
      echo "DURATION_SECONDS=$DURATION_SECONDS"
      echo "EXIT_CODE=$EXIT_CODE"
      echo "PASSED=$TRIAL_PASSED"
      echo "COMMAND=$(printf '%s' "$EVAL_COMMAND" | tr '\n' ' ')"
    } > "$TRIAL_DIR/result.env"

    if [ "$TRIAL_PASSED" = "true" ]; then
      CASE_PASSED=$((CASE_PASSED + 1))
    else
      CASE_FAILED=$((CASE_FAILED + 1))
    fi
    CASE_TOTAL_DURATION=$((CASE_TOTAL_DURATION + DURATION_SECONDS))
    TRIAL_INDEX=$((TRIAL_INDEX + 1))
  done

  CASE_PASS_PERCENT=$((CASE_PASSED * 100 / TRIALS))
  CASE_AVG_DURATION=$((CASE_TOTAL_DURATION / TRIALS))
  if [ "$CASE_PASS_PERCENT" -ge "$EVAL_MIN_PASS_PERCENT" ]; then
    CASE_STATUS="pass"
  else
    CASE_STATUS="fail"
  fi

  CASE_SUMMARY_FILE="$CASE_DIR/case-summary.env"
  {
    echo "CASE_NAME='$EVAL_NAME'"
    echo "CASE_STATUS='$CASE_STATUS'"
    echo "CASE_TRIALS='$TRIALS'"
    echo "CASE_PASSED='$CASE_PASSED'"
    echo "CASE_FAILED='$CASE_FAILED'"
    echo "CASE_PASS_PERCENT='$CASE_PASS_PERCENT'"
    echo "CASE_AVG_DURATION='$CASE_AVG_DURATION'"
    echo "CASE_MIN_PASS_PERCENT='$EVAL_MIN_PASS_PERCENT'"
    echo "CASE_DESCRIPTION='$(printf '%s' "$EVAL_DESCRIPTION" | sed "s/'/'\\\\''/g")'"
    echo "CASE_SOURCE='$CASE_SOURCE'"
  } > "$CASE_SUMMARY_FILE"
  printf '%s\n' "$CASE_SUMMARY_FILE" >> "$CASE_SUMMARY_LIST"
done < "$CASE_LIST_FILE"

write_run_outputs "$RUN_ID" "$RUN_ROOT" "$CASE_SUMMARY_LIST"
