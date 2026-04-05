#!/bin/sh

SKILLS_DIR="$(cd "$EVALS_DIR/.." && pwd)"
EVAL_PACKAGE_ROOT="$(cd "$SKILLS_DIR/.." && pwd)"
HARNESS_COMMON="$SKILLS_DIR/harness/bin/harness-common.sh"

if [ -f "$HARNESS_COMMON" ]; then
  # shellcheck disable=SC1090
  . "$HARNESS_COMMON"
fi

eval_now_iso() {
  if command -v harness_now_iso >/dev/null 2>&1; then
    harness_now_iso
  else
    date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S"
  fi
}

eval_now_epoch() {
  date +%s 2>/dev/null || echo "0"
}

eval_json_escape() {
  if command -v harness_json_escape >/dev/null 2>&1; then
    harness_json_escape "$1"
  else
    printf '%s' "$1" | awk '
      BEGIN { RS = "\0"; ORS = "" }
      {
        gsub(/\\/,"\\\\");
        gsub(/"/,"\\\"");
        gsub(/\r/,"\\r");
        gsub(/\n/,"\\n");
        gsub(/\t/,"\\t");
        print;
      }
    '
  fi
}

eval_project_root() {
  ROOT="$1"
  if [ -z "$ROOT" ]; then
    ROOT="$(pwd)"
  fi
  (cd "$ROOT" && pwd)
}

eval_shared_dir() {
  printf '%s/.cache/shared\n' "$1"
}

eval_runs_root() {
  printf '%s/evals/runs\n' "$(eval_shared_dir "$1")"
}

eval_comparisons_root() {
  printf '%s/evals/comparisons\n' "$(eval_shared_dir "$1")"
}

eval_report_json() {
  printf '%s/evals/eval-report.json\n' "$(eval_shared_dir "$1")"
}

eval_report_md() {
  printf '%s/evals/eval-report.md\n' "$(eval_shared_dir "$1")"
}

eval_builtin_cases_dir() {
  printf '%s/cases\n' "$EVALS_DIR"
}

eval_project_cases_dir() {
  printf '%s/.harness/evals\n' "$1"
}

eval_case_name_from_file() {
  basename "$1" .case.env
}

eval_find_case_file() {
  PROJECT_ROOT="$1"
  CASE_NAME="$2"

  for DIR in "$(eval_project_cases_dir "$PROJECT_ROOT")" "$(eval_builtin_cases_dir)"; do
    if [ -f "$DIR/$CASE_NAME.case.env" ]; then
      printf '%s\n' "$DIR/$CASE_NAME.case.env"
      return 0
    fi
  done

  return 1
}

eval_run_id_new() {
  TS="$(date -u +%Y%m%d%H%M%S 2>/dev/null || date +%Y%m%d%H%M%S)"
  printf 'eval-%s-%s\n' "$TS" "$$"
}

eval_load_case() {
  CASE_FILE="$1"
  PROJECT_ROOT="$2"

  unset EVAL_NAME EVAL_DESCRIPTION EVAL_COMMAND EVAL_CWD EVAL_EXPECT_EXIT
  unset EVAL_EXPECT_STDOUT_CONTAINS EVAL_EXPECT_STDERR_CONTAINS
  unset EVAL_EXPECT_STDOUT_REGEX EVAL_EXPECT_STDERR_REGEX
  unset EVAL_MIN_PASS_PERCENT EVAL_TAGS

  # shellcheck disable=SC1090
  . "$CASE_FILE"

  [ -n "${EVAL_NAME:-}" ] || EVAL_NAME="$(eval_case_name_from_file "$CASE_FILE")"
  [ -n "${EVAL_DESCRIPTION:-}" ] || EVAL_DESCRIPTION=""
  [ -n "${EVAL_COMMAND:-}" ] || {
    echo "Invalid eval case (missing EVAL_COMMAND): $CASE_FILE" >&2
    return 1
  }
  [ -n "${EVAL_CWD:-}" ] || EVAL_CWD="."
  [ -n "${EVAL_EXPECT_EXIT:-}" ] || EVAL_EXPECT_EXIT="0"
  [ -n "${EVAL_MIN_PASS_PERCENT:-}" ] || EVAL_MIN_PASS_PERCENT="100"
  [ -n "${EVAL_TAGS:-}" ] || EVAL_TAGS=""

  case "$EVAL_CWD" in
    /*) : ;;
    *) EVAL_CWD="$PROJECT_ROOT/$EVAL_CWD" ;;
  esac
}

eval_duration_seconds() {
  START="$1"
  END="$2"
  case "$START:$END" in
    ''|*:*[!0-9]*)
      echo ""
      return
      ;;
  esac
  echo $((END - START))
}
