#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$REGISTRY_DIR/lib/registry-common.sh"

PACK_NAME=""
TARGET=""
AGENT="claude"
FORCE="no"
ERROR_FILE="$(mktemp "${TMPDIR:-/tmp}/pack-install.XXXXXX")"
trap 'rm -f "$ERROR_FILE"' EXIT HUP INT TERM

for arg in "$@"; do
  case "$arg" in
    --target=*)
      TARGET="${arg#--target=}"
      ;;
    --agent=*)
      AGENT="${arg#--agent=}"
      ;;
    --force)
      FORCE="yes"
      ;;
    --help|-h)
      echo "Usage: sh pack-install.sh PACK_NAME [--agent=claude|codex] [--target=/path/to/.claude] [--force]"
      exit 0
      ;;
    *)
      [ -z "$PACK_NAME" ] || {
        echo "Unknown option: $arg" >&2
        exit 1
      }
      PACK_NAME="$arg"
      ;;
  esac
done

TARGET_ROOT="$(registry_target_root "$TARGET" "$AGENT")"
TARGET_SKILLS="$(registry_target_skills_dir "$TARGET" "$AGENT")"

log_failure() {
  REASON="$1"
  MESSAGE="$2"
  registry_append_event "$TARGET_ROOT" "install" "${PACK_NAME:-unknown}" "failure" "$REASON" "$AGENT" "$TARGET_SKILLS" "$MESSAGE" "single"
  echo "$MESSAGE" >&2
  exit 1
}

[ -n "$PACK_NAME" ] || log_failure "missing_pack_name" "Missing PACK_NAME"
registry_pack_exists "$PACK_NAME" || log_failure "unknown_pack" "Unknown pack: $PACK_NAME"

if DEST="$(registry_copy_pack "$PACK_NAME" "$TARGET_SKILLS" "$FORCE" 2>"$ERROR_FILE")"; then
  SUCCESS_REASON="installed"
  [ "$FORCE" = "yes" ] && SUCCESS_REASON="installed_force"
  registry_append_event "$TARGET_ROOT" "install" "$PACK_NAME" "success" "$SUCCESS_REASON" "$AGENT" "$TARGET_SKILLS" "Installed pack: $PACK_NAME -> $DEST" "single"
else
  MESSAGE="$(tr '\n' ' ' < "$ERROR_FILE" | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//')"
  [ -n "$MESSAGE" ] || MESSAGE="pack install failed"
  FAILURE_REASON="copy_failed"
  case "$MESSAGE" in
    Pack\ already\ exists\ at\ target:*) FAILURE_REASON="pack_already_exists" ;;
    Pack\ source\ not\ found:*) FAILURE_REASON="pack_source_missing" ;;
  esac
  log_failure "$FAILURE_REASON" "$MESSAGE"
fi

echo "Installed pack: $PACK_NAME -> $DEST"
