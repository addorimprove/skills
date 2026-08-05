#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
need_value() { [ "$#" -ge 2 ] && [ -n "${2:-}" ] || { echo "comment-add: $1 requires a value" >&2; exit 2; }; }
body_text=""; quote=""; path=""; observed=""; start=""; end=""; context=""; positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --body) need_value "$@"; body_text="$2"; shift 2 ;;
    --quote) need_value "$@"; quote="$2"; shift 2 ;;
    --path) need_value "$@"; path="$2"; shift 2 ;;
    --observed-revision) need_value "$@"; observed="$2"; shift 2 ;;
    --start) need_value "$@"; start="$2"; shift 2 ;;
    --end) need_value "$@"; end="$2"; shift 2 ;;
    --context) need_value "$@"; context="$2"; shift 2 ;;
    --base-url) need_value "$@"; BASE_URL_FLAG="$2"; shift 2 ;;
    --*) echo "comment-add: unexpected option: $1" >&2; exit 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; target="${positional[1]:-}"
[ "${#positional[@]}" -eq 2 ] && [ -n "$id" ] && [ -n "$target" ] && [ -n "$body_text" ] || { echo "comment-add: need <id> <label|current> --body <text>" >&2; exit 2; }
require_int "comment-add <id>" "$id"
if [ -n "$start" ] || [ -n "$end" ]; then
  [ -n "$start" ] && [ -n "$end" ] || { echo "comment-add: --start and --end must be used together" >&2; exit 2; }
  require_int "--start" "$start"; require_int "--end" "$end"
  [ "$end" -gt "$start" ] || { echo "comment-add: --end must be greater than --start" >&2; exit 2; }
  [ -n "$path" ] || { echo "comment-add: File-local offsets require --path" >&2; exit 2; }
fi
[ -z "$context" ] || [ -n "$path" ] || { echo "comment-add: --context requires --path" >&2; exit 2; }
[ -z "$quote" ] || [ -z "$path" ] || [ -n "$start" ] || { echo "comment-add: a File-local --quote requires --start and --end" >&2; exit 2; }
payload="$(jq -n --arg body "$body_text" '{body:$body}')"
[ -n "$quote" ] && payload="$(printf '%s' "$payload" | jq --arg quote "$quote" '.quote=$quote')"
[ -n "$path" ] && payload="$(printf '%s' "$payload" | jq --arg logicalPath "$path" '.logicalPath=$logicalPath')"
[ -n "$context" ] && payload="$(printf '%s' "$payload" | jq --arg context "$context" '.context=$context')"
[ -z "$start" ] || payload="$(printf '%s' "$payload" | jq --argjson start "$start" --argjson end "$end" '.start=$start | .end=$end')"
if [ "$target" = "current" ]; then
  [ -n "$path" ] && [ -n "$observed" ] || { echo "comment-add current: require --path and --observed-revision" >&2; exit 2; }
  require_int "--observed-revision" "$observed"
  [ "$observed" -gt 0 ] || { echo "--observed-revision: must be positive" >&2; exit 2; }
  payload="$(printf '%s' "$payload" | jq --argjson observedRevision "$observed" '.observedRevision=$observedRevision')"
  req POST "/docs/$id/current/comments" "$payload"
else
  [ -z "$observed" ] || { echo "comment-add: --observed-revision requires target current" >&2; exit 2; }
  req POST "/docs/$id/versions/$(jq -rn --arg v "$target" '$v|@uri')/comments" "$payload"
fi
echo
