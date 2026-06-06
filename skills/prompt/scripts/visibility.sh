#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; label="${positional[1]:-}"; vis="${positional[2]:-}"
[ -n "$id" ] && [ -n "$label" ] && [ -n "$vis" ] || { echo "visibility: need <id> <label> public|private" >&2; exit 2; }
require_int "visibility <id>" "$id"
case "$vis" in
  public) ispublic="true" ;;
  private) ispublic="false" ;;
  *) echo "visibility: third arg must be public|private" >&2; exit 2 ;;
esac
req PATCH "/docs/$id/versions/$(jq -rn --arg v "$label" '$v|@uri')" "{\"isPublic\":$ispublic}"
echo
