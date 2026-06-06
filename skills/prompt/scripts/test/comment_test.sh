#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$HERE/.."
# shellcheck source=assert.sh
. "$HERE/assert.sh"

export CURL="$HERE/mock-curl.sh"
export MOCK_CURL_ARGS_FILE="$(mktemp)"
trap 'rm -f "$MOCK_CURL_ARGS_FILE"' EXIT
export MD_PROMPT_API_KEY="mdnp_test"
export MD_PROMPT_BASE_URL="http://api.test"

# comment-add 7 1-1 --body "hi" -> POST .../comments
out="$(MOCK_CURL_BODY='{"id":11}' bash "$S/comment-add.sh" 7 1-1 --body "hi there")"
assert_eq "11" "$(printf '%s' "$out" | jq -r '.id')" "add id"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/docs/7/versions/1-1/comments" "add path"
assert_contains "$args" "hi there" "add body forwarded"

# comment-add with --quote
out="$(MOCK_CURL_BODY='{"id":12}' bash "$S/comment-add.sh" 7 1-1 --body "b" --quote "Q")"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "quote" "add quote key"

# comment-reply 7 1-1 11 --body "re" -> POST .../comments/11/replies
out="$(MOCK_CURL_BODY='{"id":13}' bash "$S/comment-reply.sh" 7 1-1 11 --body "re")"
assert_eq "13" "$(printf '%s' "$out" | jq -r '.id')" "reply id"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/comments/11/replies" "reply path"

# comment-resolve 7 1-1 11 -> POST .../resolve resolved=true
out="$(MOCK_CURL_BODY='{"id":11,"resolved":true}' bash "$S/comment-resolve.sh" 7 1-1 11)"
assert_eq "true" "$(printf '%s' "$out" | jq -r '.resolved')" "resolve resolved"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/comments/11/resolve" "resolve path"
assert_contains "$args" "true" "resolve true"

# comment-resolve --unresolve -> resolved=false
out="$(MOCK_CURL_BODY='{"id":11,"resolved":false}' bash "$S/comment-resolve.sh" 7 1-1 11 --unresolve)"
assert_eq "false" "$(printf '%s' "$out" | jq -r '.resolved')" "unresolve resolved"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "false" "resolve false"

finish
