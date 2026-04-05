#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUNTIME_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$RUNTIME_DIR/lib/runtime-common.sh"

usage() {
  cat <<'EOF'
Usage:
  sh skills/runtime/bin/workflow.sh start --mode=imperial [--host=codex] [--project-root=PATH] --request="..."
  sh skills/runtime/bin/workflow.sh status [--project-root=PATH] [--json]
  sh skills/runtime/bin/workflow.sh resume [--project-root=PATH] [--message="..."]
  sh skills/runtime/bin/workflow.sh approve [--project-root=PATH] [--message="..."]
  sh skills/runtime/bin/workflow.sh reject --reason="..." [--project-root=PATH]
  sh skills/runtime/bin/workflow.sh abort [--project-root=PATH] [--message="..."]
  sh skills/runtime/bin/workflow.sh reset [--project-root=PATH]
EOF
}

step_activate() {
  PROJECT_ROOT="$1"
  STEP_NAME_ARG="$2"
  STEP_DIR="$(workflow_step_dir "$PROJECT_ROOT" "$STEP_NAME_ARG")"
  [ -d "$STEP_DIR" ] || {
    echo "Unknown step: $STEP_NAME_ARG" >&2
    exit 1
  }
  workflow_load_step_dir "$STEP_DIR"
  STEP_STATUS="in_progress"
  STEP_STARTED_AT="$(workflow_now_iso)"
  STEP_COMPLETED_AT=""
  workflow_save_step_dir "$STEP_DIR"
}

step_complete() {
  PROJECT_ROOT="$1"
  STEP_NAME_ARG="$2"
  FINAL_STATUS="$3"
  STEP_MESSAGE_ARG="$4"
  STEP_DIR="$(workflow_step_dir "$PROJECT_ROOT" "$STEP_NAME_ARG")"
  [ -d "$STEP_DIR" ] || {
    echo "Unknown step: $STEP_NAME_ARG" >&2
    exit 1
  }
  workflow_load_step_dir "$STEP_DIR"
  STEP_STATUS="$FINAL_STATUS"
  STEP_COMPLETED_AT="$(workflow_now_iso)"
  STEP_MESSAGE="$STEP_MESSAGE_ARG"
  workflow_save_step_dir "$STEP_DIR"
}

step_prepare_retry() {
  PROJECT_ROOT="$1"
  STEP_NAME_ARG="$2"
  STEP_MESSAGE_ARG="$3"
  STEP_DIR="$(workflow_step_dir "$PROJECT_ROOT" "$STEP_NAME_ARG")"
  [ -d "$STEP_DIR" ] || {
    echo "Unknown step: $STEP_NAME_ARG" >&2
    exit 1
  }
  workflow_load_step_dir "$STEP_DIR"
  STEP_STATUS="pending"
  STEP_STARTED_AT=""
  STEP_COMPLETED_AT=""
  STEP_MESSAGE="$STEP_MESSAGE_ARG"
  workflow_save_step_dir "$STEP_DIR"
}

status_table() {
  PROJECT_ROOT="$1"
  workflow_load_meta "$PROJECT_ROOT"
  echo ""
  echo "## 🔄 工作流进度"
  echo ""
  echo "workflow_id: $WORKFLOW_ID"
  echo "mode       : $WORKFLOW_MODE"
  echo "host       : $WORKFLOW_HOST"
  echo "status     : $WORKFLOW_STATUS"
  echo "current    : $WORKFLOW_CURRENT_STEP"
  [ -n "$WORKFLOW_NEXT_STEP" ] && echo "next       : $WORKFLOW_NEXT_STEP"
  echo ""
  printf '%-3s %-24s %-28s %-14s\n' "#" "步骤" "技能" "状态"
  for STEP_DIR in "$(workflow_steps_root "$PROJECT_ROOT")"/*; do
    [ ! -d "$STEP_DIR" ] && continue
    workflow_load_step_dir "$STEP_DIR" || continue
    printf '%-3s %-24s %-28s %-14s\n' "$STEP_INDEX" "$STEP_LABEL" "$STEP_SKILL" "$STEP_STATUS"
  done
  echo ""
  echo "state_file : .cache/shared/workflow-state.json"
}

COMMAND="$1"
[ -n "$COMMAND" ] || {
  usage
  exit 1
}
shift

PROJECT_ROOT="$(pwd)"
MODE="imperial"
HOST="auto"
REQUEST=""
MESSAGE=""
JSON_OUTPUT="no"

for arg in "$@"; do
  case "$arg" in
    --project-root=*)
      PROJECT_ROOT="${arg#--project-root=}"
      ;;
    --mode=*)
      MODE="${arg#--mode=}"
      ;;
    --host=*)
      HOST="${arg#--host=}"
      ;;
    --request=*)
      REQUEST="${arg#--request=}"
      ;;
    --message=*)
      MESSAGE="${arg#--message=}"
      ;;
    --reason=*)
      MESSAGE="${arg#--reason=}"
      ;;
    --json)
      JSON_OUTPUT="yes"
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      if [ -z "$REQUEST" ] && [ "$COMMAND" = "start" ]; then
        REQUEST="$arg"
      else
        echo "Unknown option: $arg" >&2
        exit 1
      fi
      ;;
  esac
done

PROJECT_ROOT="$(workflow_project_root "$PROJECT_ROOT")"

case "$COMMAND" in
  start)
    [ -n "$REQUEST" ] || {
      echo "Missing --request for workflow start" >&2
      exit 1
    }
    workflow_supported_mode "$MODE" || {
      echo "Unsupported mode: $MODE" >&2
      exit 1
    }
    if [ "$HOST" = "auto" ]; then
      HOST="$(workflow_detect_host)"
    fi
    workflow_ensure_layout "$PROJECT_ROOT"
    if workflow_load_meta "$PROJECT_ROOT" 2>/dev/null; then
      if [ "$WORKFLOW_STATUS" = "running" ] || [ "$WORKFLOW_STATUS" = "paused" ]; then
        echo "Active workflow already exists: $WORKFLOW_ID ($WORKFLOW_STATUS)" >&2
        exit 1
      fi
    fi
    rm -rf "$(workflow_steps_root "$PROJECT_ROOT")"
    mkdir -p "$(workflow_steps_root "$PROJECT_ROOT")"
    printf '%s' "$REQUEST" > "$(workflow_request_file "$PROJECT_ROOT")"
    workflow_create_steps "$PROJECT_ROOT" "$MODE"
    WORKFLOW_ID="$(workflow_id_new)"
    WORKFLOW_MODE="$MODE"
    WORKFLOW_HOST="$HOST"
    WORKFLOW_STATUS="running"
    WORKFLOW_CURRENT_STEP="$(workflow_first_step "$PROJECT_ROOT")"
    WORKFLOW_NEXT_STEP=""
    WORKFLOW_STARTED_AT="$(workflow_now_iso)"
    WORKFLOW_UPDATED_AT="$WORKFLOW_STARTED_AT"
    workflow_save_meta "$PROJECT_ROOT"
    workflow_render_state "$PROJECT_ROOT"
    workflow_append_event "$PROJECT_ROOT" "workflow.start" "workflow started" "$WORKFLOW_CURRENT_STEP"
    status_table "$PROJECT_ROOT"
    ;;
  status)
    workflow_load_meta "$PROJECT_ROOT" || {
      echo "No workflow state found." >&2
      exit 1
    }
    workflow_render_state "$PROJECT_ROOT"
    if [ "$JSON_OUTPUT" = "yes" ]; then
      cat "$(workflow_state_file "$PROJECT_ROOT")"
    else
      status_table "$PROJECT_ROOT"
    fi
    ;;
  resume)
    workflow_load_meta "$PROJECT_ROOT" || {
      echo "No workflow state found." >&2
      exit 1
    }
    [ "$WORKFLOW_STATUS" = "paused" ] || {
      echo "Workflow is not paused." >&2
      exit 1
    }
    TARGET_STEP="$WORKFLOW_NEXT_STEP"
    [ -n "$TARGET_STEP" ] || TARGET_STEP="$WORKFLOW_CURRENT_STEP"
    step_activate "$PROJECT_ROOT" "$TARGET_STEP"
    WORKFLOW_STATUS="running"
    WORKFLOW_CURRENT_STEP="$TARGET_STEP"
    WORKFLOW_NEXT_STEP=""
    WORKFLOW_UPDATED_AT="$(workflow_now_iso)"
    workflow_save_meta "$PROJECT_ROOT"
    workflow_render_state "$PROJECT_ROOT"
    workflow_append_event "$PROJECT_ROOT" "workflow.resume" "${MESSAGE:-workflow resumed}" "$TARGET_STEP"
    status_table "$PROJECT_ROOT"
    ;;
  approve)
    workflow_load_meta "$PROJECT_ROOT" || {
      echo "No workflow state found." >&2
      exit 1
    }
    [ "$WORKFLOW_STATUS" = "running" ] || {
      echo "Workflow is not running." >&2
      exit 1
    }
    CURRENT_STEP="$WORKFLOW_CURRENT_STEP"
    [ -n "$CURRENT_STEP" ] || {
      echo "No current step." >&2
      exit 1
    }
    if workflow_step_requires_harness "$WORKFLOW_MODE" "$CURRENT_STEP"; then
      if workflow_harness_cycle "$PROJECT_ROOT"; then
        :
      else
        HARNESS_STATUS="$?"
        case "$HARNESS_STATUS" in
          4)
            HARNESS_MESSAGE="Harness not initialized. Run sh skills/hooks/setup.sh --project-root=$PROJECT_ROOT"
            ;;
          2|3)
            HARNESS_MESSAGE="Harness gate blocked workflow. Inspect .harness/state/last-report.json"
            ;;
          *)
            HARNESS_MESSAGE="Unexpected harness failure. Inspect .harness/state/last-report.json"
            ;;
        esac
        step_complete "$PROJECT_ROOT" "$CURRENT_STEP" "error" "$HARNESS_MESSAGE"
        WORKFLOW_STATUS="paused"
        WORKFLOW_CURRENT_STEP="$CURRENT_STEP"
        WORKFLOW_NEXT_STEP="$CURRENT_STEP"
        WORKFLOW_UPDATED_AT="$(workflow_now_iso)"
        workflow_save_meta "$PROJECT_ROOT"
        workflow_render_state "$PROJECT_ROOT"
        workflow_append_event "$PROJECT_ROOT" "workflow.pause" "$HARNESS_MESSAGE" "$CURRENT_STEP"
        status_table "$PROJECT_ROOT"
        exit "$HARNESS_STATUS"
      fi
    fi
    step_complete "$PROJECT_ROOT" "$CURRENT_STEP" "completed" "${MESSAGE:-approved}"
    NEXT_STEP="$(workflow_next_step "$PROJECT_ROOT" "$CURRENT_STEP")"
    WORKFLOW_UPDATED_AT="$(workflow_now_iso)"
    if [ -n "$NEXT_STEP" ]; then
      step_activate "$PROJECT_ROOT" "$NEXT_STEP"
      WORKFLOW_CURRENT_STEP="$NEXT_STEP"
      WORKFLOW_NEXT_STEP=""
      WORKFLOW_STATUS="running"
    else
      WORKFLOW_CURRENT_STEP=""
      WORKFLOW_NEXT_STEP=""
      WORKFLOW_STATUS="completed"
    fi
    workflow_save_meta "$PROJECT_ROOT"
    workflow_render_state "$PROJECT_ROOT"
    workflow_append_event "$PROJECT_ROOT" "review.approve" "${MESSAGE:-approved}" "$CURRENT_STEP"
    status_table "$PROJECT_ROOT"
    ;;
  reject)
    workflow_load_meta "$PROJECT_ROOT" || {
      echo "No workflow state found." >&2
      exit 1
    }
    [ -n "$MESSAGE" ] || {
      echo "Missing --reason for reject" >&2
      exit 1
    }
    CURRENT_STEP="$WORKFLOW_CURRENT_STEP"
    [ -n "$CURRENT_STEP" ] || {
      echo "No current step." >&2
      exit 1
    }
    CURRENT_STEP_DIR="$(workflow_step_dir "$PROJECT_ROOT" "$CURRENT_STEP")"
    workflow_load_step_dir "$CURRENT_STEP_DIR"
    STEP_REJECTION_COUNT=$((STEP_REJECTION_COUNT + 1))
    STEP_MESSAGE="$MESSAGE"
    TARGET_STEP="$(workflow_rejection_target "$WORKFLOW_MODE" "$CURRENT_STEP")"
    WORKFLOW_UPDATED_AT="$(workflow_now_iso)"
    if [ "$STEP_REJECTION_COUNT" -ge 3 ]; then
      STEP_STATUS="force_passed"
      STEP_COMPLETED_AT="$(workflow_now_iso)"
      workflow_save_step_dir "$CURRENT_STEP_DIR"
      NEXT_STEP="$(workflow_next_step "$PROJECT_ROOT" "$CURRENT_STEP")"
      if [ -n "$NEXT_STEP" ]; then
        step_activate "$PROJECT_ROOT" "$NEXT_STEP"
        WORKFLOW_CURRENT_STEP="$NEXT_STEP"
        WORKFLOW_STATUS="running"
        WORKFLOW_NEXT_STEP=""
      else
        WORKFLOW_CURRENT_STEP=""
        WORKFLOW_STATUS="completed"
        WORKFLOW_NEXT_STEP=""
      fi
      workflow_save_meta "$PROJECT_ROOT"
      workflow_render_state "$PROJECT_ROOT"
      workflow_append_event "$PROJECT_ROOT" "review.force_pass" "$MESSAGE" "$CURRENT_STEP"
      status_table "$PROJECT_ROOT"
      exit 0
    fi
    STEP_STATUS="rejected"
    STEP_COMPLETED_AT=""
    workflow_save_step_dir "$CURRENT_STEP_DIR"
    if [ -n "$TARGET_STEP" ]; then
      step_prepare_retry "$PROJECT_ROOT" "$TARGET_STEP" "等待恢复后重新执行"
      WORKFLOW_CURRENT_STEP="$TARGET_STEP"
      WORKFLOW_NEXT_STEP="$TARGET_STEP"
    fi
    WORKFLOW_STATUS="paused"
    workflow_save_meta "$PROJECT_ROOT"
    workflow_render_state "$PROJECT_ROOT"
    workflow_append_event "$PROJECT_ROOT" "review.reject" "$MESSAGE" "$CURRENT_STEP"
    status_table "$PROJECT_ROOT"
    ;;
  abort)
    workflow_load_meta "$PROJECT_ROOT" || {
      echo "No workflow state found." >&2
      exit 1
    }
    WORKFLOW_STATUS="aborted"
    WORKFLOW_UPDATED_AT="$(workflow_now_iso)"
    workflow_save_meta "$PROJECT_ROOT"
    workflow_render_state "$PROJECT_ROOT"
    workflow_append_event "$PROJECT_ROOT" "workflow.abort" "${MESSAGE:-workflow aborted}" "$WORKFLOW_CURRENT_STEP"
    status_table "$PROJECT_ROOT"
    ;;
  reset)
    workflow_reset_files "$PROJECT_ROOT"
    echo "Workflow runtime state reset: $PROJECT_ROOT/.cache/shared"
    ;;
  *)
    usage
    exit 1
    ;;
esac
