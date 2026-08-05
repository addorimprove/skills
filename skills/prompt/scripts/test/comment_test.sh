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

# unified snapshot File-local anchor carries path, offsets, quote, and context
out="$(MOCK_CURL_BODY='{"id":14}' bash "$S/comment-add.sh" 7 1-1 --body anchored --path index.md --start 2 --end 6 --quote text --context before)"
assert_eq "14" "$(printf '%s' "$out" | jq -r '.id')" "snapshot File-local add id"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" '"logicalPath": "index.md"' "snapshot logical path"
assert_contains "$args" '"start": 2' "snapshot start"
assert_contains "$args" '"end": 6' "snapshot end"
assert_contains "$args" '"context": "before"' "snapshot context"

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

# live-current list is a distinct resource and can filter by logical File path
out="$(MOCK_CURL_BODY='{"comments":[]}' bash "$S/comments.sh" 7 current --path 'docs/index.md')"
assert_eq "0" "$(printf '%s' "$out" | jq 'length')" "current comments list"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/docs/7/current/comments?logicalPath=docs%2Findex.md" "current list path"

# live-current creation carries observed content revision and logical path
out="$(MOCK_CURL_BODY='{"id":21,"mutationRevision":1}' bash "$S/comment-add.sh" 7 current --path index.md --observed-revision 4 --body 'live note')"
assert_eq "21" "$(printf '%s' "$out" | jq -r '.id')" "current add id"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/docs/7/current/comments" "current add path"
assert_contains "$args" '"observedRevision": 4' "current add observed revision"
assert_contains "$args" '"logicalPath": "index.md"' "current add logical path"

# live-current reply and reopen carry thread mutation CAS
out="$(MOCK_CURL_BODY='{"id":22,"threadMutationRevision":3}' bash "$S/comment-reply.sh" 7 current 21 --expected-mutation-revision 2 --body reply)"
assert_eq "3" "$(printf '%s' "$out" | jq -r '.threadMutationRevision')" "current reply next thread revision"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/docs/7/current/comments/21/replies" "current reply path"
assert_contains "$args" '"expectedMutationRevision": 2' "current reply CAS"

out="$(MOCK_CURL_BODY='{"id":21,"resolved":false,"mutationRevision":4}' bash "$S/comment-resolve.sh" 7 current 21 --reopen --expected-mutation-revision 3)"
assert_eq "false" "$(printf '%s' "$out" | jq -r '.resolved')" "current reopen"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/docs/7/current/comments/21/resolve" "current reopen path"
assert_contains "$args" '"expectedMutationRevision": 3' "current reopen CAS"

finish
