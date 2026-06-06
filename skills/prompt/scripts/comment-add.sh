#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
body_text=""; quote=""; positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --body) body_text="$2"; shift 2 ;;
    --quote) quote="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; label="${positional[1]:-}"
[ -n "$id" ] && [ -n "$label" ] && [ -n "$body_text" ] || { echo "comment-add: need <id> <label> --body <text>" >&2; exit 2; }
if [ -n "$quote" ]; then
  payload="$(jq -n --arg b "$body_text" --arg q "$quote" '{body:$b, quote:$q}')"
else
  payload="$(jq -n --arg b "$body_text" '{body:$b}')"
fi
req POST "/docs/$id/versions/$(jq -rn --arg v "$label" '$v|@uri')/comments" "$payload"
echo
