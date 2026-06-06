#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$HERE/.."
# shellcheck source=assert.sh
. "$HERE/assert.sh"

export CURL="$HERE/mock-curl.sh"
export MOCK_CURL_ARGS_FILE="$(mktemp)"
BODYFILE="$(mktemp)"; printf 'hello "world"\n' > "$BODYFILE"
trap 'rm -f "$MOCK_CURL_ARGS_FILE" "$BODYFILE"' EXIT
export MD_PROMPT_API_KEY="mdnp_test"
export MD_PROMPT_BASE_URL="http://api.test"

# new --name N -f file -> POST /docs with name+content, content escaped
out="$(MOCK_CURL_BODY='{"id":5,"label":"1-1"}' bash "$S/new.sh" --name "My Doc" -f "$BODYFILE")"
assert_eq "5" "$(printf '%s' "$out" | jq -r '.id')" "new id"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X POST" "new method"
assert_contains "$args" "/docs" "new path"
assert_contains "$args" 'My Doc' "new name forwarded"
assert_contains "$args" 'hello' "new content forwarded"

# iterate 5 --parent 1-1 -f file -> POST /docs/5/versions intent=iterate
# (pass --parent explicitly so iterate makes a single POST, not a GET-then-POST)
out="$(MOCK_CURL_BODY='{"label":"1-2"}' bash "$S/iterate.sh" 5 --parent 1-1 -f "$BODYFILE")"
assert_eq "1-2" "$(printf '%s' "$out" | jq -r '.label')" "iterate label"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/docs/5/versions" "iterate path"
assert_contains "$args" "iterate" "iterate intent"

# branch 5 1-2 -f file -> POST /docs/5/versions intent=branch parentLabel=1-2
out="$(MOCK_CURL_BODY='{"label":"1-2.1-1"}' bash "$S/branch.sh" 5 1-2 -f "$BODYFILE")"
assert_eq "1-2.1-1" "$(printf '%s' "$out" | jq -r '.label')" "branch label"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "branch" "branch intent"
assert_contains "$args" "1-2" "branch parent"

# visibility 5 1-1 public -> PATCH /docs/5/versions/1-1 isPublic=true
out="$(MOCK_CURL_BODY='{"label":"1-1","isPublic":true,"publicSlug":"Q4RCa"}' bash "$S/visibility.sh" 5 1-1 public)"
assert_eq "true" "$(printf '%s' "$out" | jq -r '.isPublic')" "visibility isPublic"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X PATCH" "visibility method"
assert_contains "$args" "/docs/5/versions/1-1" "visibility path"

finish
