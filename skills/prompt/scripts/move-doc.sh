#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

usage() { echo "usage: move-doc.sh <docId> --folder <folderId|root>" >&2; }

doc="${1:-}"
require_int "docId" "$doc"
[ "$doc" -gt 0 ] || { echo "docId: must be a positive integer" >&2; exit 2; }
shift || true
folder=""
while [ $# -gt 0 ]; do
  case "$1" in
    --folder) folder="$2"; shift 2 ;;
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) echo "move-doc: unexpected arg: $1" >&2; usage; exit 2 ;;
  esac
done
[ -n "$folder" ] || { echo "move-doc: missing --folder" >&2; usage; exit 2; }
if [ "$folder" = "root" ]; then
  body='{"folderId":null}'
else
  require_int "--folder" "$folder"
  [ "$folder" -gt 0 ] || { echo "--folder: must be a positive integer or root" >&2; exit 2; }
  body="$(jq -n --argjson folderId "$folder" '{folderId:$folderId}')"
fi
req PATCH "/docs/$doc" "$body"
echo
