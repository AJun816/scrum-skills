#!/bin/sh
# Scrum Skills - PreToolUse Hook: Bash (sh version)
# Block dangerous commands, check review mark on git commit
# For manual users who copy skills/ directory

set -e

# Read stdin (JSON from Claude Code)
# Note: JSON may contain escaped quotes \" in values
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')
# Use sed to extract command value, handling escaped quotes
COMMAND=$(echo "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*[,}].*//' | sed 's/\\"/"/g' | head -1)

[ "$TOOL_NAME" != "Bash" ] && exit 0
[ -z "$COMMAND" ] && exit 0

# ---- Block dangerous commands ----
if echo "$COMMAND" | grep -qE '\bgit\s+push\b.*(-f|--force)\b'; then
  echo "❌ Blocked: force push / 已阻止: 强制推送" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE '\bgit\s+reset\s+--hard\b'; then
  echo "❌ Blocked: reset --hard / 已阻止: 硬重置" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qE '\brm\s+-rf?\s+[/~]'; then
  echo "❌ Blocked: dangerous rm / 已阻止: 危险删除" >&2
  exit 2
fi

if echo "$COMMAND" | grep -qiE '\bDROP\s+(DATABASE|TABLE)\b'; then
  echo "❌ Blocked: DROP command / 已阻止: DROP命令" >&2
  exit 2
fi

# ---- Check git commit review mark ----
if echo "$COMMAND" | grep -qE '\bgit\s+commit\b'; then
  # Extract message after -m flag (handles both "msg" and 'msg')
  COMMIT_MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*['"'"'"]\([^'"'"'"]*\).*/\1/p')
  # Fallback: try without quotes
  if [ -z "$COMMIT_MSG" ]; then
    COMMIT_MSG=$(echo "$COMMAND" | sed -n 's/.*-m[[:space:]]*\([^[:space:]]*\).*/\1/p')
  fi
  if [ -n "$COMMIT_MSG" ]; then
    # Allow [skip-review]
    if echo "$COMMIT_MSG" | grep -q '\[skip-review\]'; then
      exit 0
    fi
    # Check review mark
    if ! echo "$COMMIT_MSG" | grep -q 'Reviewed-by:.*8-code-reviewer'; then
      echo "❌ Missing review mark / 缺少审查标记: Reviewed-by: 8-code-reviewer ✅" >&2
      exit 2
    fi
  fi
fi

exit 0
