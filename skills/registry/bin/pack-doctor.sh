#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$REGISTRY_DIR/lib/registry-common.sh"

FAILED=0
PACK_LIST_FILE="$(mktemp "${TMPDIR:-/tmp}/pack-doctor.XXXXXX")"
trap 'rm -f "$PACK_LIST_FILE"' EXIT HUP INT TERM

registry_pack_dirs > "$PACK_LIST_FILE"

while IFS= read -r PACK_DIR; do
  registry_doctor_pack "$PACK_DIR" || FAILED=1
done < "$PACK_LIST_FILE"

[ "$FAILED" -eq 0 ] || exit 1
