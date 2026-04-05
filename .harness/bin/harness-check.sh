#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/harness-common.sh"

PROJECT_ROOT="$(pwd)"
MODE="all"
FILES_ARG=""
JSON_OUTPUT="no"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --files=*)
      FILES_ARG="${arg#--files=}"
      ;;
    --staged)
      MODE="staged"
      ;;
    --changed-files)
      MODE="changed"
      ;;
    --all)
      MODE="all"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      echo "Usage: sh harness-check.sh [--project-root=PATH] [--files=a,b] [--staged|--changed-files|--all] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
HARNESS_DIR="$PROJECT_ROOT/.harness"
STATE_DIR="$HARNESS_DIR/state"
REPORT_FILE="$STATE_DIR/last-report.json"
TIMESTAMP="$(harness_now_iso)"
BASELINE_FILE="$STATE_DIR/drift-baseline.json"

mkdir -p "$STATE_DIR"

VIOLATIONS=""
VIOLATION_COUNT=0
HAS_NON_FIXABLE="no"
HARD_FAILURE="no"

add_violation() {
  SEVERITY="$1"
  RULE_ID="$2"
  FILE_PATH="$3"
  MESSAGE="$4"
  AUTO_FIXABLE="$5"

  if [ "$MODE" = "all" ] && [ -z "$FILES_ARG" ] && [ -f "$BASELINE_FILE" ]; then
    if grep -F "\"rule_id\":\"$RULE_ID\",\"path\":\"$FILE_PATH\"" "$BASELINE_FILE" >/dev/null 2>&1; then
      return
    fi
  fi

  if [ -n "$VIOLATIONS" ]; then
    VIOLATIONS="$VIOLATIONS
"
  fi
  VIOLATIONS="${VIOLATIONS}${SEVERITY}|${RULE_ID}|${FILE_PATH}|${MESSAGE}|${AUTO_FIXABLE}"
  VIOLATION_COUNT=$((VIOLATION_COUNT + 1))

  if [ "$AUTO_FIXABLE" != "true" ]; then
    HAS_NON_FIXABLE="yes"
  fi
}

REQUIRED_FILES="
.harness/bin/harness-init.sh
.harness/bin/harness-check.sh
.harness/bin/harness-fix.sh
.harness/bin/harness-gate.sh
.harness/bin/harness-repo-map.sh
.harness/bin/harness-repo-index.sh
.harness/architecture/contract.yaml
.harness/architecture/dependency-rules.yaml
.harness/rules/backend.yaml
.harness/rules/frontend.yaml
.harness/rules/tests.yaml
.harness/project-profile.json
PROJECT_CONFIG.md
.cache/shared/repo-index.json
"

for required in $REQUIRED_FILES; do
  if [ ! -f "$PROJECT_ROOT/$required" ]; then
    if [ "$required" = ".harness/bin/harness-init.sh" ]; then
      HARD_FAILURE="yes"
      add_violation "error" "missing-harness-init" "$required" "Harness 初始化脚本缺失，无法自动修复" "false"
    else
      add_violation "error" "missing-required-artifact" "$required" "缺少 Harness 必需产物" "true"
    fi
  fi
done

if [ -d "$PROJECT_ROOT/.git" ]; then
  HOOKS_PATH=$(cd "$PROJECT_ROOT" && git config --get core.hooksPath 2>/dev/null || true)
  if [ "$HOOKS_PATH" != ".harness/git-hooks" ]; then
    add_violation "error" "git-hooks-path" ".git/config" "core.hooksPath 必须指向 .harness/git-hooks" "true"
  fi
fi

collect_files() {
  if [ -n "$FILES_ARG" ]; then
    printf '%s' "$FILES_ARG" | tr ',' '\n' | while IFS= read -r raw_path; do
      [ -z "$raw_path" ] && continue
      case "$raw_path" in
        "$PROJECT_ROOT"/*)
          printf '%s\n' "${raw_path#"$PROJECT_ROOT"/}"
          ;;
        *)
          printf '%s\n' "$raw_path"
          ;;
      esac
    done
    return
  fi

  if [ ! -d "$PROJECT_ROOT/.git" ]; then
    find "$PROJECT_ROOT" -type f 2>/dev/null | sed "s|$PROJECT_ROOT/||"
    return
  fi

  case "$MODE" in
    staged)
      (cd "$PROJECT_ROOT" && git diff --cached --name-only --diff-filter=ACMR 2>/dev/null) || true
      ;;
    changed)
      (
        cd "$PROJECT_ROOT" && {
          git diff --name-only --diff-filter=ACMR HEAD 2>/dev/null
          git ls-files --others --exclude-standard 2>/dev/null
        }
      ) | sort -u
      ;;
    *)
      (cd "$PROJECT_ROOT" && git ls-files 2>/dev/null) || true
      ;;
  esac
}

FILES_TO_CHECK="$(collect_files)"

while IFS= read -r relative_path; do
  [ -z "$relative_path" ] && continue
  FILE="$PROJECT_ROOT/$relative_path"
  [ ! -f "$FILE" ] && continue

  BASENAME=$(basename "$FILE")
  if echo "$BASENAME" | grep -q '_Refactored\.'; then
    add_violation "error" "no-refactored-suffix" "$relative_path" "禁止提交 *_Refactored.* 临时文件" "false"
  fi

  LINE_COUNT=$(wc -l < "$FILE" 2>/dev/null | tr -d ' ')
  if [ -n "$LINE_COUNT" ] && [ "$LINE_COUNT" -gt 800 ]; then
    add_violation "error" "file-size-limit" "$relative_path" "文件超过 800 行" "false"
  fi

  if harness_is_frontend_boundary_file "$relative_path" && grep -qE 'import[[:space:]]+axios[[:space:]]+from' "$FILE" 2>/dev/null; then
    add_violation "error" "frontend-no-direct-axios" "$relative_path" "前端视图层不得直接 import axios" "false"
  fi

  if harness_is_frontend_file "$relative_path" && grep -qE 'import\.meta\.env\.[A-Z0-9_]*(API_KEY|TOKEN|SECRET)' "$FILE" 2>/dev/null; then
    add_violation "error" "frontend-no-secret-env" "$relative_path" "前端不得直接读取 API Key / Token / Secret 环境变量" "false"
  fi

  if harness_is_java_application_file "$relative_path" && grep -qE '^import .*\.infrastructure\.' "$FILE" 2>/dev/null; then
    add_violation "error" "application-no-infrastructure-import" "$relative_path" "Java application 层不得直接 import infrastructure 包" "false"
  fi
done <<EOF
$FILES_TO_CHECK
EOF

EXIT_CODE=0
if [ "$HARD_FAILURE" = "yes" ]; then
  EXIT_CODE=4
elif [ "$VIOLATION_COUNT" -gt 0 ] && [ "$HAS_NON_FIXABLE" = "yes" ]; then
  EXIT_CODE=3
elif [ "$VIOLATION_COUNT" -gt 0 ]; then
  EXIT_CODE=2
fi

printf '{\n' > "$REPORT_FILE"
printf '  "generated_at": "%s",\n' "$TIMESTAMP" >> "$REPORT_FILE"
printf '  "project_root": "%s",\n' "$(harness_json_escape "$PROJECT_ROOT")" >> "$REPORT_FILE"
printf '  "checked_files_mode": "%s",\n' "$MODE" >> "$REPORT_FILE"
printf '  "exit_code": %s,\n' "$EXIT_CODE" >> "$REPORT_FILE"
printf '  "checked_files_count": %s,\n' "$(printf '%s\n' "$FILES_TO_CHECK" | sed '/^$/d' | wc -l | tr -d ' ')" >> "$REPORT_FILE"
printf '  "violations": [\n' >> "$REPORT_FILE"

FIRST="yes"
printf '%s\n' "$VIOLATIONS" | while IFS='|' read -r severity rule_id path message auto_fixable; do
  [ -z "$rule_id" ] && continue
  if [ "$FIRST" = "yes" ]; then
    FIRST="no"
  else
    printf ',\n' >> "$REPORT_FILE"
  fi
  printf '    {"severity":"%s","rule_id":"%s","path":"%s","message":"%s","auto_fixable":%s}' \
    "$(harness_json_escape "$severity")" \
    "$(harness_json_escape "$rule_id")" \
    "$(harness_json_escape "$path")" \
    "$(harness_json_escape "$message")" \
    "$auto_fixable" >> "$REPORT_FILE"
done

printf '\n  ]\n' >> "$REPORT_FILE"
printf '}\n' >> "$REPORT_FILE"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_FILE"
  exit "$EXIT_CODE"
fi

if [ "$EXIT_CODE" -eq 0 ]; then
  echo "Harness check passed."
  exit 0
fi

echo "Harness check failed (exit=$EXIT_CODE):" >&2
printf '%s\n' "$VIOLATIONS" | while IFS='|' read -r severity rule_id path message auto_fixable; do
  [ -z "$rule_id" ] && continue
  echo "  - [$severity][$rule_id] $path :: $message (auto_fixable=$auto_fixable)" >&2
done

exit "$EXIT_CODE"
