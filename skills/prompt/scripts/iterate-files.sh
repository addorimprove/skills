#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: iterate-files.sh <id> --parent <label> --files <dir> [prompt CLI flags...]

Requires <id>, --parent, and --files so the command uses an explicit files-format parent.
USAGE
}

args=("$@")
has_id=0
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
    *)
      if [ "$has_id" -eq 0 ]; then has_id=1; fi
      ;;
  esac
  shift
done

if [ "$has_id" -ne 1 ] || [ "$has_parent" -ne 1 ] || [ "$has_files" -ne 1 ]; then
  usage
  exit 2
fi

exec npx @addorimprove/prompt iterate "${args[@]}"
