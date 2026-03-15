#!/bin/sh
# Scrum Skills - PreToolUse Hook: Write/Edit
# Block if file exceeds 800 lines

set -e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | grep -o '"tool_name"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"tool_name"[[:space:]]*:[[:space:]]*"//;s/"//')

[ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ] && exit 0

FILE_PATH=$(echo "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//;s/"//')
[ -z "$FILE_PATH" ] && exit 0

# ---- File size check (code files only, Write only) ----
CODE_EXTENSIONS='js|ts|jsx|tsx|vue|java|py|go|rs|rb|php|cs|cpp|c|h|kt|swift|css|html'

is_code_file() {
  echo "$1" | grep -qiE "\.($CODE_EXTENSIONS)$"
}

# ---- aider 强制检查（代码文件必须通过 aider 修改） ----
if is_code_file "$FILE_PATH"; then
  # 允许绕过：AIDER_BYPASS=true 环境变量（紧急情况，需在 commit message 中说明）
  if [ "$AIDER_BYPASS" = "true" ]; then
    echo "⚠️ aider bypass enabled for: $FILE_PATH — 请在 commit message 中说明原因" >&2
  elif [ "$AIDER_ACTIVE" != "true" ]; then
    echo "⛔ 代码文件必须通过 aider 修改: $FILE_PATH" >&2
    echo "💡 请使用 aider --no-git --message '...' $FILE_PATH" >&2
    echo "💡 紧急情况可设置 AIDER_BYPASS=true 绕过（需在 commit message 中说明原因）" >&2
    exit 2
  fi
fi

# ---- File size check (code files only, Write only) ----
if is_code_file "$FILE_PATH" && [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | sed -n 's/.*"content"[[:space:]]*:[[:space:]]*"//p' | sed 's/"[[:space:]]*[,}].*//' | sed 's/\\"/"/g' | head -1)
  if [ -n "$CONTENT" ]; then
    LINE_COUNT=$(echo "$CONTENT" | tr '\\n' '\n' | wc -l)
    if [ "$LINE_COUNT" -gt 800 ]; then
      echo "❌ File exceeds 800 lines ($LINE_COUNT) / 文件超过800行" >&2
      exit 2
    fi
    if [ "$LINE_COUNT" -gt 600 ]; then
      echo "⚠️ Warning: file has $LINE_COUNT lines (>600) / 警告: 文件已有${LINE_COUNT}行" >&2
    fi
  fi
fi

exit 0
