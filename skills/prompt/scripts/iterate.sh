#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
id=""; parent=""; file=""; format=""
while [ $# -gt 0 ]; do
  case "$1" in
    --parent) parent="$2"; shift 2 ;;
    -f|--file) file="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) if [ -z "$id" ]; then id="$1"; fi; shift ;;
  esac
done
[ -n "$id" ] || { echo "iterate: missing <id>" >&2; exit 2; }
require_int "iterate <id>" "$id"
[ -n "$file" ] && [ -f "$file" ] || { echo "iterate: missing -f <file>" >&2; exit 2; }
# Default parent to the doc's latest label.
if [ -z "$parent" ]; then
  parent="$(req GET "/docs/$id" | jq -r '.latest.label // empty')"
  [ -n "$parent" ] || { echo "iterate: doc has no versions to iterate from" >&2; exit 1; }
fi
body="$(jq -n --arg parent "$parent" --rawfile content "$file" \
  '{intent:"iterate", parentLabel:$parent, content:$content}')"
[ -n "$format" ] && body="$(printf '%s' "$body" | jq --arg f "$format" '.format=$f')"
req POST "/docs/$id/versions" "$body"
echo
