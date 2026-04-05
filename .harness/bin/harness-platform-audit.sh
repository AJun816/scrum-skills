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
      echo "Usage: sh harness-platform-audit.sh [--project-root=PATH] [--json]"
      exit 0
      ;;
    *)
      echo "Unknown option: $arg" >&2
      exit 1
      ;;
  esac
done

PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
SHARED_DIR="$PROJECT_ROOT/.cache/shared"
REPORT_JSON="$SHARED_DIR/platform-audit.json"
REPORT_MD="$SHARED_DIR/platform-audit.md"
LOCAL_CHECKS_FILE="$(mktemp "${TMPDIR:-/tmp}/platform-audit-local.XXXXXX")"
REMOTES_FILE="$(mktemp "${TMPDIR:-/tmp}/platform-audit-remotes.XXXXXX")"
trap 'rm -f "$LOCAL_CHECKS_FILE" "$REMOTES_FILE"' EXIT HUP INT TERM

mkdir -p "$SHARED_DIR"

record_local_check() {
  printf '%s\t%s\t%s\n' "$1" "$2" "$3" >> "$LOCAL_CHECKS_FILE"
}

record_remote() {
  printf '%s\t%s\t%s\t%s\t%s\t%s\n' "$1" "$2" "$3" "$4" "$5" "$6" >> "$REMOTES_FILE"
}

git_current_branch() {
  if [ -d "$PROJECT_ROOT/.git" ]; then
    (
      cd "$PROJECT_ROOT" &&
      git symbolic-ref --quiet --short HEAD 2>/dev/null ||
      git rev-parse --abbrev-ref HEAD 2>/dev/null ||
      echo "unknown"
    ) | awk 'NR == 1 {print; exit}'
  else
    echo "unknown"
  fi
}

git_hooks_path() {
  if [ -d "$PROJECT_ROOT/.git" ]; then
    (cd "$PROJECT_ROOT" && git config --get core.hooksPath 2>/dev/null) || true
  fi
}

platform_from_remote_url() {
  case "$1" in
    *github.com*) echo "github" ;;
    *gitee.com*) echo "gitee" ;;
    *) echo "unknown" ;;
  esac
}

platform_checklist() {
  case "$1" in
    github) echo "skills/config/github-ruleset-checklist.md" ;;
    gitee) echo "skills/config/gitee-ruleset-checklist.md" ;;
    *) echo "" ;;
  esac
}

platform_native_ci_status() {
  case "$1" in
    github)
      [ -f "$PROJECT_ROOT/.github/workflows/harness-gate.yml" ] && echo "present" || echo "missing"
      ;;
    gitee)
      if [ -d "$PROJECT_ROOT/.gitee" ]; then
        echo "check-local-config"
      else
        echo "manual"
      fi
      ;;
    *)
      echo "manual"
      ;;
  esac
}

CURRENT_BRANCH="$(git_current_branch)"
HOOKS_PATH="$(git_hooks_path)"

if [ -d "$PROJECT_ROOT/.git" ]; then
  record_local_check "git-repository" "pass" "Git repository detected"
else
  record_local_check "git-repository" "fail" "Not a Git repository"
fi

if [ -d "$PROJECT_ROOT/.harness" ]; then
  record_local_check "harness-directory" "pass" ".harness directory detected"
else
  record_local_check "harness-directory" "fail" "Missing .harness directory"
fi

if [ -f "$PROJECT_ROOT/.harness/bin/harness-gate.sh" ]; then
  record_local_check "harness-gate" "pass" "Versioned harness gate present"
else
  record_local_check "harness-gate" "fail" "Missing .harness/bin/harness-gate.sh"
fi

if [ -f "$PROJECT_ROOT/.harness/git-hooks/pre-commit" ] && \
   [ -f "$PROJECT_ROOT/.harness/git-hooks/commit-msg" ] && \
   [ -f "$PROJECT_ROOT/.harness/git-hooks/pre-push" ]; then
  record_local_check "versioned-hooks" "pass" "pre-commit / commit-msg / pre-push present"
else
  record_local_check "versioned-hooks" "fail" "Missing one or more versioned Git hooks"
fi

if [ "$HOOKS_PATH" = ".harness/git-hooks" ]; then
  record_local_check "hooks-path" "pass" "core.hooksPath wired to .harness/git-hooks"
else
  record_local_check "hooks-path" "fail" "core.hooksPath is '${HOOKS_PATH:-unset}'"
fi

if [ -d "$PROJECT_ROOT/.harness/overrides" ]; then
  record_local_check "overrides-directory" "pass" "Audit override directory present"
else
  record_local_check "overrides-directory" "fail" "Missing .harness/overrides"
fi

if [ -f "$PROJECT_ROOT/.github/workflows/harness-gate.yml" ]; then
  record_local_check "github-workflow" "pass" "Harness Gate GitHub workflow present"
else
  record_local_check "github-workflow" "warn" "Missing .github/workflows/harness-gate.yml"
fi

if [ -d "$PROJECT_ROOT/.git" ]; then
  git -C "$PROJECT_ROOT" remote -v 2>/dev/null | awk '$3 == "(fetch)" {print $1 "\t" $2}' | sort -u | while IFS="$(printf '\t')" read -r REMOTE_NAME REMOTE_URL; do
    [ -n "$REMOTE_NAME" ] || continue
    PLATFORM="$(platform_from_remote_url "$REMOTE_URL")"
    CHECKLIST="$(platform_checklist "$PLATFORM")"
    CI_STATUS="$(platform_native_ci_status "$PLATFORM")"
    if [ -n "$CHECKLIST" ]; then
      CHECKLIST_STATUS="present"
      [ -f "$PROJECT_ROOT/$CHECKLIST" ] || CHECKLIST_STATUS="missing"
    else
      CHECKLIST_STATUS="n/a"
    fi
    record_remote \
      "$REMOTE_NAME" \
      "$REMOTE_URL" \
      "$PLATFORM" \
      "$CHECKLIST" \
      "$CHECKLIST_STATUS" \
      "$CI_STATUS"
  done
fi

LOCAL_FAILS="$(awk -F '\t' '$2 == "fail" {count++} END {print count+0}' "$LOCAL_CHECKS_FILE")"
REMOTE_COUNT="$(wc -l < "$REMOTES_FILE" | tr -d ' ')"

OVERALL_STATUS="local_ready"
SUMMARY_MESSAGE="Local harness enforcement is wired. Remote platform rules still need manual verification."
if [ "$LOCAL_FAILS" -gt 0 ]; then
  OVERALL_STATUS="local_fail"
  SUMMARY_MESSAGE="Local harness prerequisites are incomplete."
elif [ "${REMOTE_COUNT:-0}" -gt 0 ]; then
  OVERALL_STATUS="needs_remote_verification"
fi

printf '{\n' > "$REPORT_JSON"
printf '  "generated_at": "%s",\n' "$(harness_now_iso)" >> "$REPORT_JSON"
printf '  "project_root": "%s",\n' "$(harness_json_escape "$PROJECT_ROOT")" >> "$REPORT_JSON"
printf '  "current_branch": "%s",\n' "$(harness_json_escape "$CURRENT_BRANCH")" >> "$REPORT_JSON"
printf '  "hooks_path": "%s",\n' "$(harness_json_escape "${HOOKS_PATH:-}")" >> "$REPORT_JSON"
printf '  "overall_status": "%s",\n' "$(harness_json_escape "$OVERALL_STATUS")" >> "$REPORT_JSON"
printf '  "summary": "%s",\n' "$(harness_json_escape "$SUMMARY_MESSAGE")" >> "$REPORT_JSON"
printf '  "local_checks": [\n' >> "$REPORT_JSON"
LOCAL_FIRST="yes"
while IFS="$(printf '\t')" read -r CHECK_ID CHECK_STATUS CHECK_MESSAGE; do
  [ -n "$CHECK_ID" ] || continue
  if [ "$LOCAL_FIRST" = "yes" ]; then
    LOCAL_FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"id":"%s","status":"%s","message":"%s"}' \
    "$(harness_json_escape "$CHECK_ID")" \
    "$(harness_json_escape "$CHECK_STATUS")" \
    "$(harness_json_escape "$CHECK_MESSAGE")" >> "$REPORT_JSON"
done < "$LOCAL_CHECKS_FILE"
printf '\n  ],\n' >> "$REPORT_JSON"
printf '  "remotes": [\n' >> "$REPORT_JSON"
REMOTE_FIRST="yes"
while IFS="$(printf '\t')" read -r REMOTE_NAME REMOTE_URL PLATFORM CHECKLIST CHECKLIST_STATUS CI_STATUS; do
  [ -n "$REMOTE_NAME" ] || continue
  if [ "$REMOTE_FIRST" = "yes" ]; then
    REMOTE_FIRST="no"
  else
    printf ',\n' >> "$REPORT_JSON"
  fi
  printf '    {"name":"%s","url":"%s","platform":"%s","checklist":"%s","checklist_status":"%s","native_ci_status":"%s","remote_enforcement":"manual_verification_required"}' \
    "$(harness_json_escape "$REMOTE_NAME")" \
    "$(harness_json_escape "$REMOTE_URL")" \
    "$(harness_json_escape "$PLATFORM")" \
    "$(harness_json_escape "$CHECKLIST")" \
    "$(harness_json_escape "$CHECKLIST_STATUS")" \
    "$(harness_json_escape "$CI_STATUS")" >> "$REPORT_JSON"
done < "$REMOTES_FILE"
printf '\n  ]\n}\n' >> "$REPORT_JSON"

{
  echo "# Platform Audit"
  echo ""
  echo "- current_branch: \`$CURRENT_BRANCH\`"
  echo "- hooks_path: \`${HOOKS_PATH:-unset}\`"
  echo "- overall_status: \`$OVERALL_STATUS\`"
  echo "- summary: $SUMMARY_MESSAGE"
  echo ""
  echo "## Local Checks"
  echo ""
  while IFS="$(printf '\t')" read -r CHECK_ID CHECK_STATUS CHECK_MESSAGE; do
    [ -n "$CHECK_ID" ] || continue
    echo "- $CHECK_ID: \`$CHECK_STATUS\`"
    echo "  $CHECK_MESSAGE"
  done < "$LOCAL_CHECKS_FILE"
  echo ""
  echo "## Remote Platforms"
  echo ""
  if [ ! -s "$REMOTES_FILE" ]; then
    echo "- No Git remotes detected."
  else
    while IFS="$(printf '\t')" read -r REMOTE_NAME REMOTE_URL PLATFORM CHECKLIST CHECKLIST_STATUS CI_STATUS; do
      [ -n "$REMOTE_NAME" ] || continue
      echo "- $REMOTE_NAME ($PLATFORM)"
      echo "  url: \`$REMOTE_URL\`"
      echo "  checklist: \`${CHECKLIST:-none}\` ($CHECKLIST_STATUS)"
      echo "  native_ci_status: \`$CI_STATUS\`"
      echo "  remote_enforcement: manual_verification_required"
    done < "$REMOTES_FILE"
  fi
} > "$REPORT_MD"

if [ "$JSON_OUTPUT" = "yes" ]; then
  cat "$REPORT_JSON"
else
  cat "$REPORT_MD"
fi

[ "$LOCAL_FAILS" -eq 0 ] || exit 2
