#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REGISTRY_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$(cd "$REGISTRY_DIR/.." && pwd)"
REPO_ROOT="$(cd "$SKILLS_DIR/.." && pwd)"

registry_json_string() {
  FILE="$1"
  KEY="$2"
  grep -m 1 "\"$KEY\"" "$FILE" 2>/dev/null | sed "s/.*\"$KEY\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/"
}

registry_json_bool() {
  FILE="$1"
  KEY="$2"
  grep -m 1 "\"$KEY\"" "$FILE" 2>/dev/null | sed "s/.*\"$KEY\"[[:space:]]*:[[:space:]]*\\(true\\|false\\).*/\\1/"
}

registry_json_array() {
  FILE="$1"
  KEY="$2"
  grep -m 1 "\"$KEY\"" "$FILE" 2>/dev/null | sed "s/.*\"$KEY\"[[:space:]]*:[[:space:]]*\\[\\(.*\\)\\].*/\\1/" | tr -d '"' | tr ',' ' ' | xargs 2>/dev/null
}

registry_pack_dirs() {
  find "$SKILLS_DIR" -mindepth 1 -maxdepth 1 -type d | sort | while IFS= read -r DIR; do
    [ -f "$DIR/.source.json" ] || [ -f "$DIR/pack.json" ] || continue
    printf '%s\n' "$DIR"
  done
}

registry_pack_dir() {
  printf '%s/%s\n' "$SKILLS_DIR" "$1"
}

registry_pack_manifest() {
  printf '%s/pack.json\n' "$(registry_pack_dir "$1")"
}

registry_pack_source_manifest() {
  printf '%s/.source.json\n' "$(registry_pack_dir "$1")"
}

registry_pack_exists() {
  [ -d "$(registry_pack_dir "$1")" ] && [ -f "$(registry_pack_manifest "$1")" ]
}

registry_target_skills_dir() {
  TARGET="$1"
  AGENT="$2"

  if [ -n "$TARGET" ]; then
    case "$TARGET" in
      */skills)
        printf '%s\n' "$TARGET"
        return
        ;;
      *)
        printf '%s/skills\n' "$TARGET"
        return
        ;;
    esac
  fi

  if [ -z "$AGENT" ]; then
    AGENT="claude"
  fi
  AGENT="${AGENT#.}"
  printf '%s/.%s/skills\n' "${HOME:-$USERPROFILE}" "$AGENT"
}

registry_copy_pack() {
  PACK_NAME="$1"
  TARGET_SKILLS="$2"
  FORCE="$3"
  SRC_DIR="$(registry_pack_dir "$PACK_NAME")"
  DEST_DIR="$TARGET_SKILLS/$PACK_NAME"

  [ -d "$SRC_DIR" ] || {
    echo "Pack source not found: $SRC_DIR" >&2
    return 1
  }

  mkdir -p "$TARGET_SKILLS"

  if [ -e "$DEST_DIR" ]; then
    [ "$FORCE" = "yes" ] || {
      echo "Pack already exists at target: $DEST_DIR" >&2
      return 1
    }
    rm -rf "$DEST_DIR"
  fi

  cp -R "$SRC_DIR" "$DEST_DIR"
  echo "$DEST_DIR"
}

registry_doctor_pack() {
  PACK_DIR="$1"
  PACK_NAME="$(basename "$PACK_DIR")"
  PACK_MANIFEST="$PACK_DIR/pack.json"
  ISSUE_COUNT=0

  [ -f "$PACK_DIR/.source.json" ] || {
    echo "[error] $PACK_NAME :: missing .source.json"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  }

  [ -f "$PACK_MANIFEST" ] || {
    echo "[error] $PACK_NAME :: missing pack.json"
    return 1
  }

  for KEY in name kind hosts runtime capabilities workflow_integration docs security; do
    grep -q "\"$KEY\"" "$PACK_MANIFEST" 2>/dev/null || {
      echo "[error] $PACK_NAME :: missing key '$KEY' in pack.json"
      ISSUE_COUNT=$((ISSUE_COUNT + 1))
    }
  done

  MANIFEST_NAME="$(registry_json_string "$PACK_MANIFEST" "name")"
  [ "$MANIFEST_NAME" = "$PACK_NAME" ] || {
    echo "[error] $PACK_NAME :: pack.json name mismatch ($MANIFEST_NAME)"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  }

  DOC_PATH="$(registry_json_string "$PACK_MANIFEST" "zh_cn")"
  [ -n "$DOC_PATH" ] || {
    echo "[error] $PACK_NAME :: missing docs.zh_cn path"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  }

  [ -n "$DOC_PATH" ] && [ ! -f "$REPO_ROOT/$DOC_PATH" ] && {
    echo "[error] $PACK_NAME :: docs.zh_cn path not found ($DOC_PATH)"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  }

  HOSTS="$(registry_json_array "$PACK_MANIFEST" "hosts")"
  [ -n "$HOSTS" ] || {
    echo "[error] $PACK_NAME :: hosts must not be empty"
    ISSUE_COUNT=$((ISSUE_COUNT + 1))
  }

  if [ "$ISSUE_COUNT" -eq 0 ]; then
    echo "[ok] $PACK_NAME"
  fi

  [ "$ISSUE_COUNT" -eq 0 ]
}
