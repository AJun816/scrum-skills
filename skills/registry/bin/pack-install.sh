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

[ -n "$PACK_NAME" ] || {
  echo "Missing PACK_NAME" >&2
  exit 1
}

registry_pack_exists "$PACK_NAME" || {
  echo "Unknown pack: $PACK_NAME" >&2
  exit 1
}

TARGET_SKILLS="$(registry_target_skills_dir "$TARGET" "$AGENT")"
DEST="$(registry_copy_pack "$PACK_NAME" "$TARGET_SKILLS" "$FORCE")"
echo "Installed pack: $PACK_NAME -> $DEST"
