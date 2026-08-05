#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
need_value() { [ "$#" -ge 2 ] && [ -n "${2:-}" ] || { echo "comments: $1 requires a value" >&2; exit 2; }; }
id=""; target=""; path=""
while [ $# -gt 0 ]; do
  case "$1" in
    --path) need_value "$@"; path="$2"; shift 2 ;;
    --base-url) need_value "$@"; BASE_URL_FLAG="$2"; shift 2 ;;
    --*) echo "comments: unexpected option: $1" >&2; exit 2 ;;
    *) if [ -z "$id" ]; then id="$1"; elif [ -z "$target" ]; then target="$1"; else echo "comments: unexpected arg: $1" >&2; exit 2; fi; shift ;;
  esac
done
[ -n "$id" ] && [ -n "$target" ] || { echo "comments: need <id> <label|current> [--path <logicalPath>]" >&2; exit 2; }
require_int "comments <id>" "$id"
if [ "$target" = "current" ]; then
  suffix=""
  [ -n "$path" ] && suffix="?logicalPath=$(jq -rn --arg v "$path" '$v|@uri')"
  req GET "/docs/$id/current/comments$suffix" | jq '.comments'
else
  [ -z "$path" ] || { echo "comments: --path filtering is for current Comments" >&2; exit 2; }
  req GET "/docs/$id/versions/$(jq -rn --arg v "$target" '$v|@uri')/comments" | jq '.comments'
fi
