#!/bin/sh

set -e

PROJECT_ROOT="$(pwd)"
ACTION="$1"
TASK_ID="$2"

usage() {
  echo "Usage:"
  echo "  sh .harness/bin/harness-worktree.sh create TASK_ID"
  echo "  sh .harness/bin/harness-worktree.sh remove TASK_ID"
  echo "  sh .harness/bin/harness-worktree.sh list"
  exit 1
}

[ -z "$ACTION" ] && usage

[ -d "$PROJECT_ROOT/.git" ] || {
  echo "Not a git repository: $PROJECT_ROOT" >&2
  exit 1
}

WORKTREE_ROOT="$PROJECT_ROOT/.worktrees"
mkdir -p "$WORKTREE_ROOT"

case "$ACTION" in
  create)
    [ -z "$TASK_ID" ] && usage
    BRANCH_NAME="task/$TASK_ID"
    WORKTREE_PATH="$WORKTREE_ROOT/$TASK_ID"
    if [ -e "$WORKTREE_PATH" ]; then
      echo "Worktree already exists: $WORKTREE_PATH" >&2
      exit 1
    fi
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
      echo "Branch already exists: $BRANCH_NAME" >&2
      exit 1
    fi
    git branch "$BRANCH_NAME" HEAD
    if ! git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"; then
      git branch -D "$BRANCH_NAME" >/dev/null 2>&1 || true
      exit 1
    fi
    echo "Created worktree: $WORKTREE_PATH (branch $BRANCH_NAME)"
    ;;
  remove)
    [ -z "$TASK_ID" ] && usage
    BRANCH_NAME="task/$TASK_ID"
    WORKTREE_PATH="$WORKTREE_ROOT/$TASK_ID"
    [ -d "$WORKTREE_PATH" ] || {
      echo "Worktree not found: $WORKTREE_PATH" >&2
      exit 1
    }
    if ! git worktree remove "$WORKTREE_PATH" >/dev/null 2>&1; then
      rm -rf "$WORKTREE_PATH"
      git worktree prune >/dev/null 2>&1 || true
      git branch -D "$BRANCH_NAME" >/dev/null 2>&1 || true
    fi
    echo "Removed worktree: $WORKTREE_PATH"
    ;;
  list)
    git worktree list
    ;;
  *)
    usage
    ;;
esac
