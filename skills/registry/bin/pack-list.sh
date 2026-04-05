#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
# shellcheck disable=SC1091
. "$REGISTRY_DIR/lib/registry-common.sh"

printf '%-22s %-16s %-18s %-18s %-12s\n' "PACK" "KIND" "HOSTS" "DEPENDENCIES" "MODE"

registry_pack_dirs | while IFS= read -r PACK_DIR; do
  PACK_NAME="$(basename "$PACK_DIR")"
  PACK_MANIFEST="$PACK_DIR/pack.json"
  [ -f "$PACK_MANIFEST" ] || continue
  KIND="$(registry_json_string "$PACK_MANIFEST" "kind")"
  HOSTS="$(registry_json_array "$PACK_MANIFEST" "hosts")"
  DEPS="$(registry_json_array "$PACK_MANIFEST" "dependencies")"
  MODE="$(registry_json_string "$PACK_MANIFEST" "default_mode")"
  printf '%-22s %-16s %-18s %-18s %-12s\n' "$PACK_NAME" "$KIND" "${HOSTS:-none}" "${DEPS:-none}" "${MODE:-unknown}"
done
