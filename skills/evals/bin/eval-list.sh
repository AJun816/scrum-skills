#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
EVALS_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$EVALS_DIR/lib/eval-common.sh"

PROJECT_ROOT="$(pwd)"
JSON_OUTPUT="no"
SEEN_FILE="$(mktemp "${TMPDIR:-/tmp}/eval-list-seen.XXXXXX")"
trap 'rm -f "$SEEN_FILE"' EXIT HUP INT TERM

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh eval-list.sh [--project-root=PATH] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(eval_project_root "$PROJECT_ROOT")"
LIST_FILE="$(mktemp "${TMPDIR:-/tmp}/eval-list.XXXXXX")"
trap 'rm -f "$SEEN_FILE" "$LIST_FILE"' EXIT HUP INT TERM

append_dir_cases() {
  CASE_DIR="$1"
  CASE_SOURCE="$2"
  [ -d "$CASE_DIR" ] || return 0

  find "$CASE_DIR" -mindepth 1 -maxdepth 1 -type f -name '*.case.env' | sort | while IFS= read -r CASE_FILE; do
    CASE_NAME="$(eval_case_name_from_file "$CASE_FILE")"
    grep -Fx "$CASE_NAME" "$SEEN_FILE" >/dev/null 2>&1 && continue
    eval_load_case "$CASE_FILE" "$PROJECT_ROOT" || exit 1
    printf '%s\t%s\t%s\t%s\n' "$EVAL_NAME" "$CASE_SOURCE" "$CASE_FILE" "$EVAL_DESCRIPTION" >> "$LIST_FILE"
    printf '%s\n' "$CASE_NAME" >> "$SEEN_FILE"
  done
}

append_dir_cases "$(eval_project_cases_dir "$PROJECT_ROOT")" "project"
append_dir_cases "$(eval_builtin_cases_dir)" "builtin"

if [ "$JSON_OUTPUT" = "yes" ]; then
  printf '{\n  "project_root": "%s",\n  "cases": [\n' "$(eval_json_escape "$PROJECT_ROOT")"
  FIRST="yes"
  while IFS="$(printf '\t')" read -r CASE_NAME CASE_SOURCE CASE_FILE CASE_DESCRIPTION; do
    [ -z "$CASE_NAME" ] && continue
    if [ "$FIRST" = "yes" ]; then
      FIRST="no"
    else
      printf ',\n'
    fi
    printf '    {"name":"%s","source":"%s","file":"%s","description":"%s"}' \
      "$(eval_json_escape "$CASE_NAME")" \
      "$(eval_json_escape "$CASE_SOURCE")" \
      "$(eval_json_escape "$CASE_FILE")" \
      "$(eval_json_escape "$CASE_DESCRIPTION")"
  done < "$LIST_FILE"
  printf '\n  ]\n}\n'
  exit 0
fi

printf '%-24s %-10s %s\n' "CASE" "SOURCE" "DESCRIPTION"
while IFS="$(printf '\t')" read -r CASE_NAME CASE_SOURCE CASE_FILE CASE_DESCRIPTION; do
  [ -z "$CASE_NAME" ] && continue
  printf '%-24s %-10s %s\n' "$CASE_NAME" "$CASE_SOURCE" "$CASE_DESCRIPTION"
done < "$LIST_FILE"
