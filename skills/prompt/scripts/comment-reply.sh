#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
need_value() { [ "$#" -ge 2 ] && [ -n "${2:-}" ] || { echo "comment-reply: $1 requires a value" >&2; exit 2; }; }
body_text=""; expected=""; positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --body) need_value "$@"; body_text="$2"; shift 2 ;;
    --expected-mutation-revision|--expected-comment-revision) need_value "$@"; expected="$2"; shift 2 ;;
    --base-url) need_value "$@"; BASE_URL_FLAG="$2"; shift 2 ;;
    --*) echo "comment-reply: unexpected option: $1" >&2; exit 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; target="${positional[1]:-}"; cid="${positional[2]:-}"
[ "${#positional[@]}" -eq 3 ] && [ -n "$id" ] && [ -n "$target" ] && [ -n "$cid" ] && [ -n "$body_text" ] || { echo "comment-reply: need <id> <label|current> <commentId> --body <text>" >&2; exit 2; }
require_int "comment-reply <id>" "$id"
require_int "comment-reply <commentId>" "$cid"
payload="$(jq -n --arg body "$body_text" '{body:$body}')"
if [ "$target" = "current" ]; then
  [ -n "$expected" ] || { echo "comment-reply current: require --expected-mutation-revision" >&2; exit 2; }
  require_int "--expected-mutation-revision" "$expected"
  [ "$expected" -gt 0 ] || { echo "--expected-mutation-revision: must be positive" >&2; exit 2; }
  payload="$(printf '%s' "$payload" | jq --argjson expectedMutationRevision "$expected" '.expectedMutationRevision=$expectedMutationRevision')"
  req POST "/docs/$id/current/comments/$cid/replies" "$payload"
else
  [ -z "$expected" ] || { echo "comment-reply: --expected-mutation-revision is for current Comments" >&2; exit 2; }
  req POST "/docs/$id/versions/$(jq -rn --arg v "$target" '$v|@uri')/comments/$cid/replies" "$payload"
fi
echo
