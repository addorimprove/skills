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

# whoami -> GET /
out="$(MOCK_CURL_BODY='{"id":"u1","name":"A","email":"a@b.c"}' bash "$S/whoami.sh")"
assert_eq "u1" "$(printf '%s' "$out" | jq -r '.id')" "whoami id"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "http://api.test/api/v1/me " "whoami path"

# recent -n 2 -> GET /activity?limit=2, unwrap activity array
out="$(MOCK_CURL_BODY='{"activity":[{"documentId":1},{"documentId":2}]}' bash "$S/recent.sh" -n 2)"
assert_eq "2" "$(printf '%s' "$out" | jq 'length')" "recent length"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/activity?limit=2" "recent query"

# ls -q foo -> GET /docs?q=foo, unwrap docs array
out="$(MOCK_CURL_BODY='{"docs":[{"id":7}]}' bash "$S/ls.sh" -q foo)"
assert_eq "7" "$(printf '%s' "$out" | jq -r '.[0].id')" "ls id"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/docs?q=foo" "ls query"

# view 7 -> GET /docs/7
out="$(MOCK_CURL_BODY='{"id":7,"name":"D"}' bash "$S/view.sh" 7)"
assert_eq "7" "$(printf '%s' "$out" | jq -r '.id')" "view doc id"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/docs/7" "view doc path"

# view 7 1-2 -> GET /docs/7/versions/1-2
out="$(MOCK_CURL_BODY='{"label":"1-2"}' bash "$S/view.sh" 7 1-2)"
assert_eq "1-2" "$(printf '%s' "$out" | jq -r '.label')" "view version label"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/docs/7/versions/1-2" "view version path"

# comments 7 1-2 -> GET .../comments, unwrap comments array
out="$(MOCK_CURL_BODY='{"comments":[{"id":3}]}' bash "$S/comments.sh" 7 1-2)"
assert_eq "3" "$(printf '%s' "$out" | jq -r '.[0].id')" "comments id"
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/docs/7/versions/1-2/comments" "comments path"

finish
