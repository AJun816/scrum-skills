#!/bin/sh
# Scrum Skills - Git commit-msg Hook
# Enforce ✅[Reviewed] prefix on every commit (mandatory)
# Prefer repository-local .harness/git-hooks via core.hooksPath

MSG_FILE="$1"

if [ -z "$MSG_FILE" ] || [ ! -f "$MSG_FILE" ]; then
  echo "commit-msg hook: no message file" >&2
  exit 1
fi

if [ -x ".harness/bin/harness-gate.sh" ]; then
  exec sh ./.harness/bin/harness-gate.sh commit-msg "$MSG_FILE"
fi

COMMIT_MSG=$(cat "$MSG_FILE")

if ! echo "$COMMIT_MSG" | grep -q '^✅\[Reviewed\]'; then
  echo "" >&2
  echo "❌ Commit blocked / 提交被阻止" >&2
  echo "" >&2
  echo "Every commit must start with ✅[Reviewed] prefix" >&2
  echo "每次提交必须以 ✅[Reviewed] 开头" >&2
  echo "" >&2
  echo "Format / 格式: ✅[Reviewed] your commit message" >&2
  echo "Run @8-code-reviewer first / 请先执行 @8-code-reviewer 代码审查" >&2
  echo "" >&2
  exit 1
fi

exit 0
