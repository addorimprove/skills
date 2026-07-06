#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: branch-files.sh <id> (<parentLabel>|--parent <label>) --files <dir> [prompt CLI flags...]

Requires <id>, a parent label, and --files so the command uses an explicit files-format parent.
USAGE
}

args=("$@")
positional=0
has_parent=0
has_files=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --parent=*) has_parent=1 ;;
    --parent)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      has_parent=1
      shift
      ;;
    --files=*) has_files=1 ;;
    --files)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      has_files=1
      shift
      ;;
    --*) ;;
    *) positional=$((positional + 1)) ;;
  esac
  shift
done

if [ "$positional" -lt 1 ] || { [ "$positional" -lt 2 ] && [ "$has_parent" -ne 1 ]; } || [ "$has_files" -ne 1 ]; then
  usage
  exit 2
fi

exec npx @addorimprove/prompt branch "${args[@]}"
