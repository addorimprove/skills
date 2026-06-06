#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
resolved="true"; positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --unresolve) resolved="false"; shift ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; label="${positional[1]:-}"; cid="${positional[2]:-}"
[ -n "$id" ] && [ -n "$label" ] && [ -n "$cid" ] || { echo "comment-resolve: need <id> <label> <commentId> [--unresolve]" >&2; exit 2; }
req POST "/docs/$id/versions/$(jq -rn --arg v "$label" '$v|@uri')/comments/$cid/resolve" "{\"resolved\":$resolved}"
echo
