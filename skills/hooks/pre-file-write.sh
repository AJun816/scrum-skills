#!/bin/sh
# Scrum Skills - PreToolUse Hook: Write/Edit (sh version)
# Block if file exceeds 800 lines, scan for sensitive info
# For manual users who copy skills/ directory

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')

[ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ] && exit 0

FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"//')
[ -z "$FILE_PATH" ] && exit 0

# ---- Block .env file writes ----
if echo "$FILE_PATH" | grep -qE '\.env(\.local|\.prod|\.production)?$'; then
  echo "❌ Blocked: writing to env file / 已阻止: 写入环境变量文件" >&2
  exit 2
fi

# ---- Security scan (basic patterns) ----
# Extract content, handling escaped quotes in JSON
CONTENT=$(echo "$INPUT" | sed -n 's/.*"content"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*[,}].*//' | sed 's/\\"/"/g' | head -1)
if [ -z "$CONTENT" ]; then
  CONTENT=$(echo "$INPUT" | sed -n 's/.*"new_string"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*[,}].*//' | sed 's/\\"/"/g' | head -1)
fi

if echo "$CONTENT" | grep -qiE '(password|passwd|pwd)\s*[:=]\s*['"'"'"][^'"'"'"]{4,}'; then
  echo "❌ Blocked: password detected / 已阻止: 检测到密码" >&2
  exit 2
fi

if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}'; then
  echo "❌ Blocked: AWS key detected / 已阻止: 检测到AWS密钥" >&2
  exit 2
fi

if echo "$CONTENT" | grep -qE -- '-----BEGIN[[:space:]]+(RSA[[:space:]]+)?PRIVATE[[:space:]]+KEY-----'; then
  echo "❌ Blocked: private key detected / 已阻止: 检测到私钥" >&2
  exit 2
fi

# ---- File size check (code files only) ----
is_code_file() {
  echo "$1" | grep -qiE '\.(js|ts|jsx|tsx|vue|java|py|go|rs|rb|php|cs|cpp|c|h|kt|swift)$'
}

if is_code_file "$FILE_PATH" && [ "$TOOL_NAME" = "Write" ]; then
  LINE_COUNT=$(echo "$CONTENT" | tr '\\n' '\n' | wc -l)
  if [ "$LINE_COUNT" -gt 800 ]; then
    echo "❌ File exceeds 800 lines ($LINE_COUNT) / 文件超过800行" >&2
    exit 2
  fi
  if [ "$LINE_COUNT" -gt 600 ]; then
    echo "⚠️ Warning: file has $LINE_COUNT lines (>600) / 警告: 文件已有${LINE_COUNT}行" >&2
  fi
fi

exit 0
