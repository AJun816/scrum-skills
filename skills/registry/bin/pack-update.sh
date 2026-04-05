#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$REGISTRY_DIR/lib/registry-common.sh"

PACK_NAME=""
TARGET=""
AGENT="claude"
UPDATE_ALL="no"
ERROR_FILE="$(mktemp "${TMPDIR:-/tmp}/pack-update.XXXXXX")"
PACK_LIST_FILE="$(mktemp "${TMPDIR:-/tmp}/pack-update-list.XXXXXX")"
trap 'rm -f "$ERROR_FILE" "$PACK_LIST_FILE"' EXIT HUP INT TERM

for arg in "$@"; do
  case "$arg" in
    --target=*)
      TARGET="${arg#--target=}"
      ;;
    --agent=*)
      AGENT="${arg#--agent=}"
      ;;
    --all)
      UPDATE_ALL="yes"
      ;;
    --help|-h)
      echo "Usage: sh pack-update.sh PACK_NAME [--agent=claude|codex] [--target=/path/to/.claude] | --all"
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
  PACK_VALUE="$1"
  REASON="$2"
  MESSAGE="$3"
  SCOPE="$4"
  registry_append_event "$TARGET_ROOT" "update" "$PACK_VALUE" "failure" "$REASON" "$AGENT" "$TARGET_SKILLS" "$MESSAGE" "$SCOPE"
  echo "$MESSAGE" >&2
  exit 1
}

update_one_pack() {
  NAME="$1"
  SCOPE="$2"
  if DEST="$(registry_copy_pack "$NAME" "$TARGET_SKILLS" "yes" 2>"$ERROR_FILE")"; then
    registry_append_event "$TARGET_ROOT" "update" "$NAME" "success" "updated" "$AGENT" "$TARGET_SKILLS" "Updated pack: $NAME -> $DEST" "$SCOPE"
    echo "Updated pack: $NAME -> $DEST"
    return 0
  fi

  MESSAGE="$(tr '\n' ' ' < "$ERROR_FILE" | sed 's/[[:space:]][[:space:]]*/ /g; s/^ //; s/ $//')"
  [ -n "$MESSAGE" ] || MESSAGE="pack update failed"
  REASON="copy_failed"
  case "$MESSAGE" in
    Pack\ source\ not\ found:*) REASON="pack_source_missing" ;;
  esac
  log_failure "$NAME" "$REASON" "$MESSAGE" "$SCOPE"
}

if [ "$UPDATE_ALL" = "yes" ]; then
  registry_pack_dirs > "$PACK_LIST_FILE"
  while IFS= read -r PACK_DIR; do
    [ -f "$PACK_DIR/pack.json" ] || continue
    NAME="$(basename "$PACK_DIR")"
    update_one_pack "$NAME" "all"
  done < "$PACK_LIST_FILE"
  exit 0
fi

[ -n "$PACK_NAME" ] || log_failure "unknown" "missing_pack_name" "Missing PACK_NAME or --all" "single"
registry_pack_exists "$PACK_NAME" || log_failure "$PACK_NAME" "unknown_pack" "Unknown pack: $PACK_NAME" "single"

update_one_pack "$PACK_NAME" "single"
