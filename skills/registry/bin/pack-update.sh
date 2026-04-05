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

TARGET_SKILLS="$(registry_target_skills_dir "$TARGET" "$AGENT")"

if [ "$UPDATE_ALL" = "yes" ]; then
  registry_pack_dirs | while IFS= read -r PACK_DIR; do
    [ -f "$PACK_DIR/pack.json" ] || continue
    NAME="$(basename "$PACK_DIR")"
    DEST="$(registry_copy_pack "$NAME" "$TARGET_SKILLS" "yes")"
    echo "Updated pack: $NAME -> $DEST"
  done
  exit 0
fi

[ -n "$PACK_NAME" ] || {
  echo "Missing PACK_NAME or --all" >&2
  exit 1
}

registry_pack_exists "$PACK_NAME" || {
  echo "Unknown pack: $PACK_NAME" >&2
  exit 1
}

DEST="$(registry_copy_pack "$PACK_NAME" "$TARGET_SKILLS" "yes")"
echo "Updated pack: $PACK_NAME -> $DEST"
