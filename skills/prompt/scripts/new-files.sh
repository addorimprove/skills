#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: new-files.sh --name <name> --files <dir> [prompt CLI flags...]

Requires --name and --files so the command stays in files-format workflow and never opens $EDITOR.
USAGE
}

args=("$@")
has_name=0
has_files=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --name=*) has_name=1 ;;
    --name)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      has_name=1
      shift
      ;;
    --files=*) has_files=1 ;;
    --files)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      has_files=1
      shift
      ;;
  esac
  shift
done

if [ "$has_name" -ne 1 ] || [ "$has_files" -ne 1 ]; then
  usage
  exit 2
fi

exec npx @addorimprove/prompt new --kind files "${args[@]}"
