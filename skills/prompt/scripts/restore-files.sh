#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: restore-files.sh <id> [--version <label>] [--output <dir>] [--force] [-y] [prompt CLI flags...]

Requires <id>. Without --output, the CLI default writes under .prompt/.
USAGE
}

args=("$@")
has_id=0
while [ "$#" -gt 0 ]; do
  case "$1" in
    --version|--output)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      shift
      ;;
    --version=*|--output=*) ;;
    --*) ;;
    *)
      if [ "$has_id" -eq 0 ]; then has_id=1; fi
      ;;
  esac
  shift
done

if [ "$has_id" -ne 1 ]; then
  usage
  exit 2
fi

exec npx @addorimprove/prompt restore-files "${args[@]}"
