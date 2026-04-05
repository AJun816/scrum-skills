#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNTIME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$(cd "$RUNTIME_DIR/.." && pwd)"
HARNESS_COMMON="$SKILLS_DIR/harness/bin/harness-common.sh"

if [ -f "$HARNESS_COMMON" ]; then
  # shellcheck disable=SC1090
  . "$HARNESS_COMMON"
fi

workflow_now_iso() {
  if command -v harness_now_iso >/dev/null 2>&1; then
    harness_now_iso
  else
    date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S"
  fi
}

workflow_json_escape() {
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
}

workflow_shell_quote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}

workflow_project_root() {
  ROOT="$1"
  if [ -z "$ROOT" ]; then
    ROOT="$(pwd)"
  fi
  (cd "$ROOT" && pwd)
}

workflow_shared_dir() {
  printf '%s/.cache/shared\n' "$1"
}

workflow_runtime_root() {
  printf '%s/workflow-runtime\n' "$(workflow_shared_dir "$1")"
}

workflow_steps_root() {
  printf '%s/steps\n' "$(workflow_runtime_root "$1")"
}

workflow_state_file() {
  printf '%s/workflow-state.json\n' "$(workflow_shared_dir "$1")"
}

workflow_events_file() {
  printf '%s/workflow-runs.jsonl\n' "$(workflow_shared_dir "$1")"
}

workflow_meta_file() {
  printf '%s/meta.env\n' "$(workflow_runtime_root "$1")"
}

workflow_request_file() {
  printf '%s/request.txt\n' "$(workflow_runtime_root "$1")"
}

workflow_reset_files() {
  PROJECT_ROOT="$1"
  rm -rf "$(workflow_runtime_root "$PROJECT_ROOT")"
  rm -f "$(workflow_state_file "$PROJECT_ROOT")"
  rm -f "$(workflow_events_file "$PROJECT_ROOT")"
}

workflow_ensure_layout() {
  PROJECT_ROOT="$1"
  mkdir -p "$(workflow_shared_dir "$PROJECT_ROOT")"
  mkdir -p "$(workflow_runtime_root "$PROJECT_ROOT")"
  mkdir -p "$(workflow_steps_root "$PROJECT_ROOT")"
}

workflow_id_new() {
  TS="$(date -u +%Y%m%d%H%M%S 2>/dev/null || date +%Y%m%d%H%M%S)"
  printf 'wf-%s-%s\n' "$TS" "$$"
}

workflow_supported_mode() {
  case "$1" in
    imperial|agile)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

workflow_detect_host() {
  case "$SKILLS_DIR" in
    */.claude/skills|*/.claude/skills/*)
      echo "claude"
      return
      ;;
    */.codex/skills|*/.codex/skills/*)
      echo "codex"
      return
      ;;
  esac

  if [ -n "$CODEX_HOME" ]; then
    echo "codex"
    return
  fi

  if [ -n "$CLAUDE_CONFIG_DIR" ]; then
    echo "claude"
    return
  fi

  echo "unknown"
}

workflow_step_specs() {
  MODE="$1"
  case "$MODE" in
    imperial)
      cat <<'EOF'
01|taizi-triage|0-taizi|太子分拣
02|zhongshu-plan|0-zhongshu-province|中书省规划
03|menxia-review-plan|0-menxia-province|门下省审核（规划）
04|shangshu-dispatch|0-shangshu-province|尚书省派发
05|menxia-review-code|0-menxia-province|门下省代码审核
06|zhongshu-report|0-zhongshu-province|中书省回奏
07|emperor-review|0-emperor|皇上御览
EOF
      ;;
    agile)
      cat <<'EOF'
01|scrum-analyze|0-scrum-master|Scrum 分析
02|scrum-plan|0-scrum-master|Scrum 规划
03|scrum-execute|0-scrum-master|Scrum 执行
04|scrum-review|0-scrum-master|Scrum 审核
EOF
      ;;
    *)
      return 1
      ;;
  esac
}

workflow_rejection_target() {
  MODE="$1"
  STEP_NAME="$2"
  case "${MODE}:${STEP_NAME}" in
    imperial:menxia-review-plan) echo "zhongshu-plan" ;;
    imperial:menxia-review-code) echo "shangshu-dispatch" ;;
    imperial:emperor-review) echo "zhongshu-plan" ;;
    agile:scrum-review) echo "scrum-execute" ;;
    *) echo "" ;;
  esac
}

workflow_step_requires_harness() {
  case "$1:$2" in
    imperial:shangshu-dispatch|agile:scrum-execute)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

workflow_harness_check_bin() {
  printf '%s/.harness/bin/harness-check.sh\n' "$1"
}

workflow_harness_fix_bin() {
  printf '%s/.harness/bin/harness-fix.sh\n' "$1"
}

workflow_harness_cycle() {
  PROJECT_ROOT="$1"
  CHECK_BIN="$(workflow_harness_check_bin "$PROJECT_ROOT")"
  FIX_BIN="$(workflow_harness_fix_bin "$PROJECT_ROOT")"
  ATTEMPT=1

  [ -f "$CHECK_BIN" ] && [ -f "$FIX_BIN" ] || return 4

  while [ "$ATTEMPT" -le 4 ]; do
    if sh "$CHECK_BIN" --project-root="$PROJECT_ROOT" --changed-files --json >/dev/null 2>&1; then
      workflow_append_event "$PROJECT_ROOT" "harness.check.pass" "harness check passed" ""
      return 0
    else
      CHECK_STATUS="$?"
    fi

    case "$CHECK_STATUS" in
      2)
        workflow_append_event "$PROJECT_ROOT" "harness.check.fixable" "harness check requires auto-fix" ""
        [ "$ATTEMPT" -lt 4 ] || return 2
        if sh "$FIX_BIN" --project-root="$PROJECT_ROOT" --changed-files >/dev/null 2>&1; then
          workflow_append_event "$PROJECT_ROOT" "harness.fix.pass" "harness auto-fix applied" ""
        else
          FIX_STATUS="$?"
          workflow_append_event "$PROJECT_ROOT" "harness.fix.fail" "harness auto-fix failed" ""
          return "$FIX_STATUS"
        fi
        ATTEMPT=$((ATTEMPT + 1))
        ;;
      3|4)
        workflow_append_event "$PROJECT_ROOT" "harness.check.fail" "harness gate blocked workflow" ""
        return "$CHECK_STATUS"
        ;;
      *)
        workflow_append_event "$PROJECT_ROOT" "harness.check.error" "unexpected harness status" ""
        return 3
        ;;
    esac
  done

  return 2
}

workflow_load_meta() {
  META_FILE="$(workflow_meta_file "$1")"
  [ -f "$META_FILE" ] || return 1
  unset WORKFLOW_ID WORKFLOW_MODE WORKFLOW_HOST WORKFLOW_STATUS WORKFLOW_CURRENT_STEP
  unset WORKFLOW_NEXT_STEP WORKFLOW_STARTED_AT WORKFLOW_UPDATED_AT
  # shellcheck disable=SC1090
  . "$META_FILE"
}

workflow_save_meta() {
  PROJECT_ROOT="$1"
  cat > "$(workflow_meta_file "$PROJECT_ROOT")" <<EOF
WORKFLOW_ID=$(workflow_shell_quote "$WORKFLOW_ID")
WORKFLOW_MODE=$(workflow_shell_quote "$WORKFLOW_MODE")
WORKFLOW_HOST=$(workflow_shell_quote "$WORKFLOW_HOST")
WORKFLOW_STATUS=$(workflow_shell_quote "$WORKFLOW_STATUS")
WORKFLOW_CURRENT_STEP=$(workflow_shell_quote "$WORKFLOW_CURRENT_STEP")
WORKFLOW_NEXT_STEP=$(workflow_shell_quote "$WORKFLOW_NEXT_STEP")
WORKFLOW_STARTED_AT=$(workflow_shell_quote "$WORKFLOW_STARTED_AT")
WORKFLOW_UPDATED_AT=$(workflow_shell_quote "$WORKFLOW_UPDATED_AT")
EOF
}

workflow_step_dir() {
  PROJECT_ROOT="$1"
  STEP_NAME="$2"
  find "$(workflow_steps_root "$PROJECT_ROOT")" -mindepth 1 -maxdepth 1 -type d -name "*-${STEP_NAME}" | sort | head -n 1
}

workflow_step_meta_file() {
  printf '%s/meta.env\n' "$1"
}

workflow_step_message_file() {
  printf '%s/message.txt\n' "$1"
}

workflow_load_step_dir() {
  STEP_DIR="$1"
  [ -d "$STEP_DIR" ] || return 1
  unset STEP_INDEX STEP_NAME STEP_SKILL STEP_LABEL STEP_STATUS STEP_REJECTION_COUNT
  unset STEP_STARTED_AT STEP_COMPLETED_AT
  # shellcheck disable=SC1090
  . "$(workflow_step_meta_file "$STEP_DIR")"
  if [ -f "$(workflow_step_message_file "$STEP_DIR")" ]; then
    STEP_MESSAGE="$(cat "$(workflow_step_message_file "$STEP_DIR")")"
  else
    STEP_MESSAGE=""
  fi
}

workflow_save_step_dir() {
  STEP_DIR="$1"
  cat > "$(workflow_step_meta_file "$STEP_DIR")" <<EOF
STEP_INDEX=$(workflow_shell_quote "$STEP_INDEX")
STEP_NAME=$(workflow_shell_quote "$STEP_NAME")
STEP_SKILL=$(workflow_shell_quote "$STEP_SKILL")
STEP_LABEL=$(workflow_shell_quote "$STEP_LABEL")
STEP_STATUS=$(workflow_shell_quote "$STEP_STATUS")
STEP_REJECTION_COUNT=$(workflow_shell_quote "$STEP_REJECTION_COUNT")
STEP_STARTED_AT=$(workflow_shell_quote "$STEP_STARTED_AT")
STEP_COMPLETED_AT=$(workflow_shell_quote "$STEP_COMPLETED_AT")
EOF
  printf '%s' "$STEP_MESSAGE" > "$(workflow_step_message_file "$STEP_DIR")"
}

workflow_create_steps() {
  PROJECT_ROOT="$1"
  MODE="$2"
  NOW="$(workflow_now_iso)"
  FIRST_STEP=""

  workflow_step_specs "$MODE" | while IFS='|' read -r STEP_INDEX STEP_NAME STEP_SKILL STEP_LABEL; do
    [ -z "$STEP_NAME" ] && continue
    STEP_DIR="$(workflow_steps_root "$PROJECT_ROOT")/${STEP_INDEX}-${STEP_NAME}"
    mkdir -p "$STEP_DIR"
    STEP_REJECTION_COUNT="0"
    STEP_COMPLETED_AT=""
    STEP_MESSAGE=""
    if [ -z "$FIRST_STEP" ]; then
      FIRST_STEP="$STEP_NAME"
      STEP_STATUS="in_progress"
      STEP_STARTED_AT="$NOW"
      printf '%s' "$STEP_NAME" > "$(workflow_runtime_root "$PROJECT_ROOT")/.first-step"
    else
      STEP_STATUS="pending"
      STEP_STARTED_AT=""
    fi
    workflow_save_step_dir "$STEP_DIR"
  done
}

workflow_first_step() {
  PROJECT_ROOT="$1"
  FIRST_FILE="$(workflow_runtime_root "$PROJECT_ROOT")/.first-step"
  if [ -f "$FIRST_FILE" ]; then
    cat "$FIRST_FILE"
    return
  fi
  find "$(workflow_steps_root "$PROJECT_ROOT")" -mindepth 1 -maxdepth 1 -type d | sort | head -n 1 | sed 's#.*/[0-9][0-9]-##'
}

workflow_next_step() {
  PROJECT_ROOT="$1"
  CURRENT="$2"
  FOUND="no"
  for STEP_DIR in "$(workflow_steps_root "$PROJECT_ROOT")"/*; do
    [ ! -d "$STEP_DIR" ] && continue
    workflow_load_step_dir "$STEP_DIR" || continue
    if [ "$FOUND" = "yes" ]; then
      echo "$STEP_NAME"
      return
    fi
    if [ "$STEP_NAME" = "$CURRENT" ]; then
      FOUND="yes"
    fi
  done
}

workflow_append_event() {
  PROJECT_ROOT="$1"
  EVENT_TYPE="$2"
  MESSAGE="$3"
  STEP_NAME="$4"

  workflow_load_meta "$PROJECT_ROOT" || return 1
  NOW="$(workflow_now_iso)"
  cat >> "$(workflow_events_file "$PROJECT_ROOT")" <<EOF
{"timestamp":"$(workflow_json_escape "$NOW")","workflow_id":"$(workflow_json_escape "$WORKFLOW_ID")","mode":"$(workflow_json_escape "$WORKFLOW_MODE")","host":"$(workflow_json_escape "$WORKFLOW_HOST")","status":"$(workflow_json_escape "$WORKFLOW_STATUS")","event":"$(workflow_json_escape "$EVENT_TYPE")","current_step":"$(workflow_json_escape "$STEP_NAME")","message":"$(workflow_json_escape "$MESSAGE")"}
EOF
}

workflow_render_state() {
  PROJECT_ROOT="$1"
  workflow_load_meta "$PROJECT_ROOT" || return 1
  REQUEST_CONTENT=""
  if [ -f "$(workflow_request_file "$PROJECT_ROOT")" ]; then
    REQUEST_CONTENT="$(cat "$(workflow_request_file "$PROJECT_ROOT")")"
  fi

  STATE_FILE="$(workflow_state_file "$PROJECT_ROOT")"
  {
    printf '{\n'
    printf '  "workflow_id": "%s",\n' "$(workflow_json_escape "$WORKFLOW_ID")"
    printf '  "mode": "%s",\n' "$(workflow_json_escape "$WORKFLOW_MODE")"
    printf '  "host": "%s",\n' "$(workflow_json_escape "$WORKFLOW_HOST")"
    printf '  "status": "%s",\n' "$(workflow_json_escape "$WORKFLOW_STATUS")"
    printf '  "current_step": "%s",\n' "$(workflow_json_escape "$WORKFLOW_CURRENT_STEP")"
    printf '  "next_step": "%s",\n' "$(workflow_json_escape "$WORKFLOW_NEXT_STEP")"
    printf '  "started_at": "%s",\n' "$(workflow_json_escape "$WORKFLOW_STARTED_AT")"
    printf '  "updated_at": "%s",\n' "$(workflow_json_escape "$WORKFLOW_UPDATED_AT")"
    printf '  "user_request": "%s",\n' "$(workflow_json_escape "$REQUEST_CONTENT")"
    printf '  "steps": [\n'
    STEP_FIRST="yes"
    for STEP_DIR in "$(workflow_steps_root "$PROJECT_ROOT")"/*; do
      [ ! -d "$STEP_DIR" ] && continue
      workflow_load_step_dir "$STEP_DIR" || continue
      if [ "$STEP_FIRST" = "yes" ]; then
        STEP_FIRST="no"
      else
        printf ',\n'
      fi
      printf '    {"index":"%s","step":"%s","skill":"%s","label":"%s","status":"%s","rejection_count":%s,"started_at":"%s","completed_at":"%s","message":"%s","outputs":[]}' \
        "$(workflow_json_escape "$STEP_INDEX")" \
        "$(workflow_json_escape "$STEP_NAME")" \
        "$(workflow_json_escape "$STEP_SKILL")" \
        "$(workflow_json_escape "$STEP_LABEL")" \
        "$(workflow_json_escape "$STEP_STATUS")" \
        "$(workflow_json_escape "$STEP_REJECTION_COUNT")" \
        "$(workflow_json_escape "$STEP_STARTED_AT")" \
        "$(workflow_json_escape "$STEP_COMPLETED_AT")" \
        "$(workflow_json_escape "$STEP_MESSAGE")"
    done
    printf '\n  ],\n'
    printf '  "shared_documents": {\n'
    printf '    "workflow_events": ".cache/shared/workflow-runs.jsonl"'
    if [ -f "$PROJECT_ROOT/.cache/shared/repo-map.md" ]; then
      printf ',\n    "repo_map": ".cache/shared/repo-map.md"'
    fi
    if [ -f "$PROJECT_ROOT/.cache/shared/repo-index.json" ]; then
      printf ',\n    "repo_index": ".cache/shared/repo-index.json"'
    fi
    if [ -f "$PROJECT_ROOT/PROJECT_CONFIG.md" ]; then
      printf ',\n    "project_config": "PROJECT_CONFIG.md"'
    fi
    printf '\n  },\n'
    printf '  "harness": {\n'
    if [ -f "$PROJECT_ROOT/.harness/project-profile.json" ]; then
      printf '    "project_profile": ".harness/project-profile.json"'
      if [ -f "$PROJECT_ROOT/.harness/state/last-report.json" ]; then
        printf ',\n    "last_report": ".harness/state/last-report.json"'
      fi
      printf '\n'
    fi
    printf '  }\n'
    printf '}\n'
  } > "$STATE_FILE"
}
