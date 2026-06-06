#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
id=""; parent=""; file=""; format=""
positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    -f|--file) file="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; parent="${positional[1]:-}"
[ -n "$id" ] && [ -n "$parent" ] || { echo "branch: need <id> <parentLabel>" >&2; exit 2; }
[ -n "$file" ] && [ -f "$file" ] || { echo "branch: missing -f <file>" >&2; exit 2; }
body="$(jq -n --arg parent "$parent" --rawfile content "$file" \
  '{intent:"branch", parentLabel:$parent, content:$content}')"
[ -n "$format" ] && body="$(printf '%s' "$body" | jq --arg f "$format" '.format=$f')"
req POST "/docs/$id/versions" "$body"
echo
