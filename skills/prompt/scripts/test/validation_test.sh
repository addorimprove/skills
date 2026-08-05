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
export MOCK_CURL_BODY='{}'

# Non-numeric / traversal id must be rejected with exit 2 and must NOT call curl.
: > "$MOCK_CURL_ARGS_FILE"
err="$(bash "$S/view.sh" "../../keys/current" 2>&1)"; rc=$?
assert_status 2 "$rc" "view traversal id rejected"
assert_contains "$err" "must be a positive integer" "view id message"
assert_eq "" "$(cat "$MOCK_CURL_ARGS_FILE")" "view no curl call on bad id"

# A flag mistyped into the id slot is also rejected.
err="$(bash "$S/visibility.sh" "--oops" 1-1 public 2>&1)"; rc=$?
assert_status 2 "$rc" "visibility non-numeric id rejected"

# commentId validated too.
err="$(bash "$S/comment-resolve.sh" 7 1-1 "abc" 2>&1)"; rc=$?
assert_status 2 "$rc" "comment-resolve non-numeric cid rejected"

# recent limit validated.
err="$(bash "$S/recent.sh" -n "5&x=1" 2>&1)"; rc=$?
assert_status 2 "$rc" "recent non-numeric limit rejected"

# Changed scripts reject missing option values with controlled usage errors.
err="$(bash "$S/new.sh" --name 2>&1)"; rc=$?
assert_status 2 "$rc" "new missing option value rejected"
assert_contains "$err" "--name requires a value" "new missing value message"
assert_not_contains "$err" "unbound variable" "new no shell leak"

err="$(bash "$S/comment-add.sh" 7 current --body note --path 2>&1)"; rc=$?
assert_status 2 "$rc" "comment-add missing option value rejected"
assert_contains "$err" "--path requires a value" "comment-add missing value message"
assert_not_contains "$err" "unbound variable" "comment-add no shell leak"

# Valid numeric id still works (reaches curl).
: > "$MOCK_CURL_ARGS_FILE"
bash "$S/view.sh" 7 >/dev/null
assert_contains "$(cat "$MOCK_CURL_ARGS_FILE")" "/docs/7" "valid id still reaches curl"

finish
