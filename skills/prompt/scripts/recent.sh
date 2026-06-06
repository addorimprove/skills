#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
limit=""
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--limit) limit="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) echo "recent: unexpected arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$limit" ] && require_int "recent --limit" "$limit"
path="/activity"
[ -n "$limit" ] && path="/activity?limit=$limit"
req GET "$path" | jq '.activity'
