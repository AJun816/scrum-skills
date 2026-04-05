#!/bin/sh

harness_now_iso() {
  date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S"
}

harness_json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

harness_project_name() {
  basename "$1"
}

harness_state_dir() {
  printf '%s/.harness/state\n' "$1"
}

harness_shared_dir() {
  printf '%s/.cache/shared\n' "$1"
}

harness_runs_file() {
  printf '%s/harness-runs.jsonl\n' "$(harness_state_dir "$1")"
}

harness_report_json() {
  printf '%s/harness-report.json\n' "$(harness_shared_dir "$1")"
}

harness_report_md() {
  printf '%s/harness-report.md\n' "$(harness_shared_dir "$1")"
}

harness_append_event() {
  PROJECT_ROOT="$1"
  EVENT_NAME="$2"
  STATUS="$3"
  MODE="$4"
  EXIT_CODE="$5"
  RULE_ID="$6"
  AUTO_FIXABLE="$7"
  MESSAGE="$8"
  PATH_VALUE="$9"
  RUNS_FILE="$(harness_runs_file "$PROJECT_ROOT")"

  mkdir -p "$(harness_state_dir "$PROJECT_ROOT")"
  printf '{"generated_at":"%s","event":"%s","status":"%s","mode":"%s","exit_code":"%s","rule_id":"%s","auto_fixable":"%s","message":"%s","path":"%s"}\n' \
    "$(harness_json_escape "$(harness_now_iso)")" \
    "$(harness_json_escape "$EVENT_NAME")" \
    "$(harness_json_escape "$STATUS")" \
    "$(harness_json_escape "$MODE")" \
    "$(harness_json_escape "$EXIT_CODE")" \
    "$(harness_json_escape "$RULE_ID")" \
    "$(harness_json_escape "$AUTO_FIXABLE")" \
    "$(harness_json_escape "$MESSAGE")" \
    "$(harness_json_escape "$PATH_VALUE")" >> "$RUNS_FILE"
}

harness_git_commit() {
  if [ -d "$1/.git" ]; then
    (cd "$1" && git rev-parse --short HEAD 2>/dev/null) || echo "unknown"
  else
    echo "unknown"
  fi
}

harness_detect_backend() {
  ROOT="$1"

  if [ -f "$ROOT/pom.xml" ]; then
    if grep -qi "spring-boot" "$ROOT/pom.xml" 2>/dev/null; then
      echo "Spring Boot"
    else
      echo "Java"
    fi
    return
  fi

  if [ -f "$ROOT/go.mod" ]; then
    echo "Go"
    return
  fi

  if [ -f "$ROOT/pyproject.toml" ] || [ -f "$ROOT/requirements.txt" ]; then
    if grep -qi "fastapi" "$ROOT/pyproject.toml" "$ROOT/requirements.txt" 2>/dev/null; then
      echo "FastAPI"
    elif grep -qi "django" "$ROOT/pyproject.toml" "$ROOT/requirements.txt" 2>/dev/null; then
      echo "Django"
    else
      echo "Python"
    fi
    return
  fi

  if [ -f "$ROOT/package.json" ]; then
    if grep -qi '"nest"' "$ROOT/package.json" 2>/dev/null; then
      echo "NestJS"
    elif grep -qi '"express"' "$ROOT/package.json" 2>/dev/null; then
      echo "Express"
    else
      echo "Node.js"
    fi
    return
  fi

  echo "unknown"
}

harness_detect_frontend() {
  ROOT="$1"

  if [ -f "$ROOT/package.json" ]; then
    if grep -qi '"vue"' "$ROOT/package.json" 2>/dev/null; then
      echo "Vue"
      return
    fi
    if grep -qi '"next"' "$ROOT/package.json" 2>/dev/null; then
      echo "Next.js"
      return
    fi
    if grep -qi '"react"' "$ROOT/package.json" 2>/dev/null; then
      echo "React"
      return
    fi
    if grep -qi '"svelte"' "$ROOT/package.json" 2>/dev/null; then
      echo "Svelte"
      return
    fi
  fi

  echo "unknown"
}

harness_detect_database() {
  ROOT="$1"

  if grep -Rqi "clickhouse" "$ROOT" \
    --include='*.yml' \
    --include='*.yaml' \
    --include='*.properties' \
    --include='docker-compose*.yml' 2>/dev/null; then
    echo "MySQL + ClickHouse"
    return
  fi

  if grep -Rqi "mysql" "$ROOT" \
    --include='*.yml' \
    --include='*.yaml' \
    --include='*.properties' \
    --include='docker-compose*.yml' 2>/dev/null; then
    echo "MySQL"
    return
  fi

  if grep -Rqi "postgres" "$ROOT" \
    --include='*.yml' \
    --include='*.yaml' \
    --include='*.properties' \
    --include='docker-compose*.yml' 2>/dev/null; then
    echo "PostgreSQL"
    return
  fi

  echo "unknown"
}

harness_detect_build() {
  ROOT="$1"

  if [ -f "$ROOT/pom.xml" ]; then
    echo "Maven"
    return
  fi
  if [ -f "$ROOT/build.gradle" ] || [ -f "$ROOT/build.gradle.kts" ]; then
    echo "Gradle"
    return
  fi
  if [ -f "$ROOT/go.mod" ]; then
    echo "Go Modules"
    return
  fi
  if [ -f "$ROOT/package.json" ]; then
    echo "npm"
    return
  fi
  if [ -f "$ROOT/pyproject.toml" ]; then
    echo "pyproject"
    return
  fi

  echo "unknown"
}

harness_detect_architecture() {
  ROOT="$1"

  if find "$ROOT" -type d \( \
    -name domain -o \
    -name application -o \
    -name infrastructure -o \
    -name interfaces \
  \) 2>/dev/null | grep -q .; then
    echo "ddd"
    return
  fi

  if find "$ROOT" -type d \( -name src -o -name app -o -name web \) 2>/dev/null | grep -q .; then
    echo "layered"
    return
  fi

  echo "unknown"
}

harness_detect_modules() {
  ROOT="$1"
  OUTPUT=""

  if [ -d "$ROOT/skills" ]; then
    OUTPUT=$(find "$ROOT/skills" -mindepth 1 -maxdepth 1 -type d ! -name ".cache" -exec basename {} \; 2>/dev/null | sort | sed -n '1,12p')
  elif [ -d "$ROOT/web/src" ]; then
    OUTPUT=$(find "$ROOT/web/src" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | sed -n '1,12p')
  elif [ -d "$ROOT/src" ]; then
    OUTPUT=$(find "$ROOT/src" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort | sed -n '1,12p')
  fi

  if [ -z "$OUTPUT" ]; then
    printf '["core"]'
    return
  fi

  JSON='['
  FIRST='yes'
  while IFS= read -r ITEM; do
    [ -z "$ITEM" ] && continue
    ESCAPED=$(harness_json_escape "$ITEM")
    if [ "$FIRST" = "yes" ]; then
      JSON="${JSON}\"${ESCAPED}\""
      FIRST='no'
    else
      JSON="${JSON}, \"${ESCAPED}\""
    fi
  done <<EOF
$OUTPUT
EOF

  printf '%s]\n' "$JSON"
}

harness_is_frontend_file() {
  echo "$1" | grep -qiE '\.(js|jsx|ts|tsx|vue)$'
}

harness_is_frontend_boundary_file() {
  case "$1" in
    src/views/*|src/components/*|src/pages/*|web/src/views/*|web/src/components/*|web/src/pages/*)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}

harness_is_java_application_file() {
  echo "$1" | grep -q '/application/' && echo "$1" | grep -q '\.java$'
}
