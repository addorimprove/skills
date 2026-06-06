#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=assert.sh
. "$HERE/assert.sh"
# shellcheck source=../lib.sh
. "$HERE/../lib.sh"

export CURL="$HERE/mock-curl.sh"
export MOCK_CURL_ARGS_FILE="$(mktemp)"
trap 'rm -f "$MOCK_CURL_ARGS_FILE"' EXIT
export MD_PROMPT_API_KEY="mdnp_test"
export MD_PROMPT_BASE_URL="http://api.test"

# 1. Success: body returned, args carry method/key/url.
MOCK_CURL_STATUS=200 MOCK_CURL_BODY='{"id":"u1"}' out="$(req GET "")"
assert_eq '{"id":"u1"}' "$out" "200 returns body"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X GET" "method in args"
assert_contains "$args" "x-api-key: mdnp_test" "key header in args"
assert_contains "$args" "http://api.test/api/v1/me" "url in args"

# 2. Body present -> content-type + -d.
MOCK_CURL_STATUS=200 MOCK_CURL_BODY='{"label":"1-1"}' req POST "/docs" '{"name":"x"}' >/dev/null
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "content-type: application/json" "json content-type"
assert_contains "$args" '{"name":"x"}' "body forwarded"

# 3. 401 -> not-logged-in message, status 4.
err="$(MOCK_CURL_STATUS=401 MOCK_CURL_BODY='{"error":{"message":"nope"}}' req GET "" 2>&1)"; rc=$?
assert_status 4 "$rc" "401 exit code"
assert_contains "$err" "Not logged in" "401 message"

# 4. 400 -> server message, status 1.
err="$(MOCK_CURL_STATUS=400 MOCK_CURL_BODY='{"error":{"message":"bad body"}}' req POST "/docs" '{}' 2>&1)"; rc=$?
assert_status 1 "$rc" "400 exit code"
assert_contains "$err" "bad body" "400 message"

# 5. 404 -> not found.
err="$(MOCK_CURL_STATUS=404 MOCK_CURL_BODY='{}' req GET "/docs/9" 2>&1)"; rc=$?
assert_status 1 "$rc" "404 exit code"
assert_contains "$err" "Not found" "404 message"

# 6. No key -> not logged in, status 4, no curl call.
unset MD_PROMPT_API_KEY
err="$(XDG_CONFIG_HOME="$(mktemp -d)" req GET "" 2>&1)"; rc=$?
assert_status 4 "$rc" "missing key exit code"
assert_contains "$err" "Not logged in" "missing key message"

finish
