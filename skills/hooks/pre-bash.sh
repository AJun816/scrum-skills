#!/bin/sh
# Scrum Skills - PreToolUse Hook: Bash
# Enforce ✅[Reviewed] prefix on every git commit (mandatory, no bypass)

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')
COMMAND=$(echo "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*[,}].*//' | sed 's/\\"/"/g' | head -1)

[ "$TOOL_NAME" != "Bash" ] && exit 0
[ -z "$COMMAND" ] && exit 0

# ---- Enforce review prefix on git commit ----
if echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
  COMMIT_MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*['"'"'"]\([^'"'"'"]*\).*/\1/p')
  if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*\([^[:space:]]*\).*/\1/p')
  fi
  if [ -n "$COMMIT_MSG" ]; then
    # Allow [skip-review] bypass
    if echo "$COMMIT_MSG" | grep -q '\[skip-review\]'; then
      exit 0
    fi
    if ! echo "$COMMIT_MSG" | grep -q '^✅\[Reviewed\]'; then
      echo "❌ Commit blocked / 提交被阻止" >&2
      echo "   Every commit must start with ✅[Reviewed] prefix" >&2
      echo "   每次提交必须以 ✅[Reviewed] 开头" >&2
      echo "   Format / 格式: ✅[Reviewed] your commit message" >&2
      echo "   Run @8-code-reviewer first / 请先执行 @8-code-reviewer 代码审查" >&2
      echo "   Or add [skip-review] to bypass / 或添加 [skip-review] 跳过" >&2
      exit 2
    fi
  fi
fi

exit 0
