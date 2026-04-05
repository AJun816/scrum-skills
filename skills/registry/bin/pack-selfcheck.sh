#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

fail() {
  echo "PACK SELF-CHECK FAILED: $1" >&2
  exit 1
}

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pack-selfcheck.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

sh "$SCRIPT_DIR/pack-doctor.sh" >/dev/null || fail "pack-doctor should pass"
sh "$SCRIPT_DIR/pack-list.sh" > "$TMP_DIR/list.txt" || fail "pack-list should run"
grep -F "gstack" "$TMP_DIR/list.txt" >/dev/null 2>&1 || fail "pack-list missing gstack"
grep -F "find-community" "$TMP_DIR/list.txt" >/dev/null 2>&1 || fail "pack-list missing find-community"

TARGET_ROOT="$TMP_DIR/.codex"
sh "$SCRIPT_DIR/pack-install.sh" find-community --target="$TARGET_ROOT" >/dev/null || fail "pack-install failed"
[ -f "$TARGET_ROOT/skills/find-community/pack.json" ] || fail "installed pack manifest missing"

sh "$SCRIPT_DIR/pack-update.sh" find-community --target="$TARGET_ROOT" >/dev/null || fail "pack-update single failed"
sh "$SCRIPT_DIR/pack-update.sh" --all --target="$TARGET_ROOT" >/dev/null || fail "pack-update all failed"
[ -f "$TARGET_ROOT/skills/gstack/pack.json" ] || fail "gstack pack missing after update --all"

echo "PACK SELF-CHECK OK"
