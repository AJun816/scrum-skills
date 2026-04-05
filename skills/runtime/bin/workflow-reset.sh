#!/bin/sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
exec sh "$SCRIPT_DIR/workflow.sh" reset "$@"
