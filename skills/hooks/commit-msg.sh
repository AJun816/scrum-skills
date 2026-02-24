#!/bin/sh
# Scrum Skills - Git commit-msg Hook (sh version)
# Checks for review mark in commit messages
# Installed to .git/hooks/commit-msg
#
# Format: Reviewed-by: 8-code-reviewer ✅ (YYYY-MM-DD HH:MM)
# Skip:   [skip-review] in commit message

MSG_FILE="$1"

if [ -z "$MSG_FILE" ] || [ ! -f "$MSG_FILE" ]; then
  echo "commit-msg hook: no message file" >&2
  exit 1
fi

COMMIT_MSG=$(cat "$MSG_FILE")

# Allow [skip-review]
if echo "$COMMIT_MSG" | grep -q '\[skip-review\]'; then
  exit 0
fi

# Check for review mark
if ! echo "$COMMIT_MSG" | grep -q 'Reviewed-by:.*8-code-reviewer'; then
  echo "" >&2
  echo "❌ Commit blocked / 提交被阻止" >&2
  echo "" >&2
  echo "Missing review mark / 缺少审查标记:" >&2
  echo "  Reviewed-by: 8-code-reviewer ✅ (YYYY-MM-DD HH:MM)" >&2
  echo "" >&2
  echo "To skip: add [skip-review] to commit message" >&2
  echo "跳过审查: 在提交信息中添加 [skip-review]" >&2
  echo "" >&2
  exit 1
fi

exit 0
