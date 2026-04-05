#!/bin/sh

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

fail() {
  echo "PACK SELF-CHECK FAILED: $1" >&2
  exit 1
}

assert_contains() {
  FILE="$1"
  PATTERN="$2"
  grep -F "$PATTERN" "$FILE" >/dev/null 2>&1 || fail "pattern not found: $PATTERN"
}

TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/pack-selfcheck.XXXXXX")"
trap 'rm -rf "$TMP_DIR"' EXIT HUP INT TERM

sh "$SCRIPT_DIR/pack-doctor.sh" >/dev/null || fail "pack-doctor should pass"
sh "$SCRIPT_DIR/pack-list.sh" > "$TMP_DIR/list.txt" || fail "pack-list should run"
assert_contains "$TMP_DIR/list.txt" "gstack"
assert_contains "$TMP_DIR/list.txt" "find-community"

EMPTY_TARGET="$TMP_DIR/.claude-empty"
sh "$SCRIPT_DIR/pack-report.sh" --target="$EMPTY_TARGET" --json > "$TMP_DIR/report-empty.json" || fail "pack-report empty should succeed"
assert_contains "$TMP_DIR/report-empty.json" '"status": "no_pack_activity"'

TARGET_ROOT="$TMP_DIR/.codex"
sh "$SCRIPT_DIR/pack-install.sh" find-community --target="$TARGET_ROOT" >/dev/null || fail "pack-install failed"
[ -f "$TARGET_ROOT/skills/find-community/pack.json" ] || fail "installed pack manifest missing"

if sh "$SCRIPT_DIR/pack-install.sh" find-community --target="$TARGET_ROOT" >/dev/null 2>&1; then
  fail "pack-install should fail when pack already exists without --force"
fi

sh "$SCRIPT_DIR/pack-update.sh" find-community --target="$TARGET_ROOT" >/dev/null || fail "pack-update single failed"
sh "$SCRIPT_DIR/pack-report.sh" --target="$TARGET_ROOT" --json > "$TMP_DIR/report.json" || fail "pack-report should run"
assert_contains "$TMP_DIR/report.json" '"total_events": 3'
assert_contains "$TMP_DIR/report.json" '"install_success": 1'
assert_contains "$TMP_DIR/report.json" '"install_failure": 1'
assert_contains "$TMP_DIR/report.json" '"update_success": 1'
assert_contains "$TMP_DIR/report.json" '"reason":"pack_already_exists"'
assert_contains "$TMP_DIR/report.json" '"pack":"find-community"'

ALL_TARGET="$TMP_DIR/.claude"
sh "$SCRIPT_DIR/pack-update.sh" --all --target="$ALL_TARGET" >/dev/null || fail "pack-update all failed"
[ -f "$ALL_TARGET/skills/gstack/pack.json" ] || fail "gstack pack missing after update --all"

echo "PACK SELF-CHECK OK"
