#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
q=""
while [ $# -gt 0 ]; do
  case "$1" in
    -q|--query) q="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) echo "ls: unexpected arg: $1" >&2; exit 2 ;;
  esac
done
path="/docs"
[ -n "$q" ] && path="/docs?q=$(jq -rn --arg v "$q" '$v|@uri')"
req GET "$path" | jq '.docs'
