#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
need_value() { [ "$#" -ge 2 ] && [ -n "${2:-}" ] || { echo "comment-resolve: $1 requires a value" >&2; exit 2; }; }
resolved="true"; expected=""; positional=()
while [ $# -gt 0 ]; do
  case "$1" in
    --unresolve|--reopen) resolved="false"; shift ;;
    --expected-mutation-revision|--expected-comment-revision) need_value "$@"; expected="$2"; shift 2 ;;
    --base-url) need_value "$@"; BASE_URL_FLAG="$2"; shift 2 ;;
    --*) echo "comment-resolve: unexpected option: $1" >&2; exit 2 ;;
    *) positional+=("$1"); shift ;;
  esac
done
id="${positional[0]:-}"; target="${positional[1]:-}"; cid="${positional[2]:-}"
[ "${#positional[@]}" -eq 3 ] && [ -n "$id" ] && [ -n "$target" ] && [ -n "$cid" ] || { echo "comment-resolve: need <id> <label|current> <commentId> [--unresolve|--reopen]" >&2; exit 2; }
require_int "comment-resolve <id>" "$id"
require_int "comment-resolve <commentId>" "$cid"
payload="{\"resolved\":$resolved}"
if [ "$target" = "current" ]; then
  [ -n "$expected" ] || { echo "comment-resolve current: require --expected-mutation-revision" >&2; exit 2; }
  require_int "--expected-mutation-revision" "$expected"
  [ "$expected" -gt 0 ] || { echo "--expected-mutation-revision: must be positive" >&2; exit 2; }
  payload="$(printf '%s' "$payload" | jq --argjson expectedMutationRevision "$expected" '.expectedMutationRevision=$expectedMutationRevision')"
  req POST "/docs/$id/current/comments/$cid/resolve" "$payload"
else
  [ -z "$expected" ] || { echo "comment-resolve: --expected-mutation-revision is for current Comments" >&2; exit 2; }
  req POST "/docs/$id/versions/$(jq -rn --arg v "$target" '$v|@uri')/comments/$cid/resolve" "$payload"
fi
echo
