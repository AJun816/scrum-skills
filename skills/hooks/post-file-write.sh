#!/bin/sh
# Scrum Skills - PostToolUse Hook: Write/Edit (sh version)
# Warn on code smells (console.log, TODO, deep nesting)
# Post hooks can only warn (exit 0), cannot block

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')

[ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ] && exit 0

CONTENT=$(echo "$INPUT" | grep -o '"content"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"content"[[:space:]]*:[[:space:]]*"//;s/"$//')
if [ -z "$CONTENT" ]; then
  CONTENT=$(echo "$INPUT" | grep -o '"new_string"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"new_string"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$CONTENT" ] && exit 0

WARNINGS=""

if echo "$CONTENT" | grep -qE '\bconsole\.(log|debug|info)\b'; then
  WARNINGS="${WARNINGS}\n  - console.log detected"
fi

if echo "$CONTENT" | grep -qiE '//\s*(TODO|FIXME|HACK|XXX)\b'; then
  WARNINGS="${WARNINGS}\n  - TODO/FIXME comment found"
fi

if [ -n "$WARNINGS" ]; then
  printf "⚠️ Code quality warnings / 代码质量警告:%b\n" "$WARNINGS" >&2
fi

exit 0
