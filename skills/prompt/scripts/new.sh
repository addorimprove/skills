#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
name=""; file=""; format=""; folder=""
while [ $# -gt 0 ]; do
  case "$1" in
    --name) name="$2"; shift 2 ;;
    -f|--file) file="$2"; shift 2 ;;
    --format) format="$2"; shift 2 ;;
    --folder) folder="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) echo "new: unexpected arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$name" ] || { echo "new: missing --name" >&2; exit 2; }
[ -n "$file" ] && [ -f "$file" ] || { echo "new: missing -f <file>" >&2; exit 2; }
if [ -n "$folder" ]; then
  require_int "--folder" "$folder"
  [ "$folder" -gt 0 ] || { echo "--folder: must be a positive integer" >&2; exit 2; }
fi
body="$(jq -n --arg name "$name" --rawfile content "$file" \
  '{name:$name, content:$content}')"
[ -n "$format" ] && body="$(printf '%s' "$body" | jq --arg f "$format" '.format=$f')"
[ -n "$folder" ] && body="$(printf '%s' "$body" | jq --argjson folderId "$folder" '.folderId=$folderId')"
req POST "/docs" "$body"
echo
