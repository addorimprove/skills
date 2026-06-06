#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
body_text=""; positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --body) body_text="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; label="${positional[1]:-}"; cid="${positional[2]:-}"
[ -n "$id" ] && [ -n "$label" ] && [ -n "$cid" ] && [ -n "$body_text" ] || { echo "comment-reply: need <id> <label> <commentId> --body <text>" >&2; exit 2; }
payload="$(jq -n --arg b "$body_text" '{body:$b}')"
req POST "/docs/$id/versions/$(jq -rn --arg v "$label" '$v|@uri')/comments/$cid/replies" "$payload"
echo
