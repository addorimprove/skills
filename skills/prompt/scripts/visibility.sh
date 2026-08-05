#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
need_value() { [ "$#" -ge 2 ] && [ -n "${2:-}" ] || { echo "visibility: $1 requires a value" >&2; exit 2; }; }
positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --base-url) need_value "$@"; BASE_URL_FLAG="$2"; shift 2 ;;
    --*) echo "visibility: unexpected option: $1" >&2; exit 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; target="${positional[1]:-}"; visibility="${positional[2]:-}"
[ "${#positional[@]}" -ge 2 ] && [ "${#positional[@]}" -le 3 ] && [ -n "$id" ] && [ -n "$target" ] || { echo "visibility: need <id> <label> public|private or <id> current [public|private]" >&2; exit 2; }
require_int "visibility <id>" "$id"
if [ "$target" = "current" ] && [ -z "$visibility" ]; then
  req GET "/docs/$id/current/publication"
  echo
  exit 0
fi
case "$visibility" in
  public) is_public="true" ;;
  private) is_public="false" ;;
  *) echo "visibility: state must be public|private" >&2; exit 2 ;;
esac
if [ "$target" = "current" ]; then
  req PATCH "/docs/$id/current/publication" "{\"isPublic\":$is_public}"
else
  req PATCH "/docs/$id/versions/$(jq -rn --arg v "$target" '$v|@uri')" "{\"isPublic\":$is_public}"
fi
echo
