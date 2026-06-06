#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
id=""; label=""
while [ $# -gt 0 ]; do
  case "$1" in
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) if [ -z "$id" ]; then id="$1"; elif [ -z "$label" ]; then label="$1"; fi; shift ;;
  esac
done
[ -n "$id" ] && [ -n "$label" ] || { echo "comments: need <id> <label>" >&2; exit 2; }
req GET "/docs/$id/versions/$(jq -rn --arg v "$label" '$v|@uri')/comments" | jq '.comments'
