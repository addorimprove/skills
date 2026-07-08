#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$HERE/.."
# shellcheck source=assert.sh
. "$HERE/assert.sh"

export CURL="$HERE/mock-curl.sh"
export MOCK_CURL_ARGS_FILE="$(mktemp)"
BODYFILE="$(mktemp)"; printf '# foldered\n' > "$BODYFILE"
trap 'rm -f "$MOCK_CURL_ARGS_FILE" "$BODYFILE"' EXIT
export MD_PROMPT_API_KEY="mdnp_test"
export MD_PROMPT_BASE_URL="http://api.test"

# new --folder sends folderId in POST /docs body
out="$(MOCK_CURL_BODY='{"id":5,"label":"1-1"}' bash "$S/new.sh" --name "Foldered" --folder 12 -f "$BODYFILE")"
assert_eq "5" "$(printf '%s' "$out" | jq -r '.id')" "new --folder id"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X POST" "new --folder method"
assert_contains "$args" "/docs" "new --folder path"
assert_contains "$args" '"folderId": 12' "new --folder body"

# folders ls root and nested
out="$(MOCK_CURL_BODY='{"folders":[],"documents":[],"folderOptions":[]}' bash "$S/folders.sh")"
assert_eq "0" "$(printf '%s' "$out" | jq -r '.folders | length')" "folders root parses"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X GET" "folders root method"
assert_contains "$args" "/folders" "folders root path"

out="$(MOCK_CURL_BODY='{"folders":[],"documents":[],"folderOptions":[]}' bash "$S/folders.sh" ls --parent 12)"
assert_eq "0" "$(printf '%s' "$out" | jq -r '.documents | length')" "folders nested parses"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "/folders?parentFolderId=12" "folders nested query"

# folders create/delete
out="$(MOCK_CURL_BODY='{"id":13,"name":"Drafts","parentFolderId": 12}' bash "$S/folders.sh" create Drafts --parent 12)"
assert_eq "13" "$(printf '%s' "$out" | jq -r '.id')" "folders create id"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X POST" "folders create method"
assert_contains "$args" "/folders" "folders create path"
assert_contains "$args" '"parentFolderId": 12' "folders create body"

MOCK_CURL_STATUS=204 MOCK_CURL_BODY='' bash "$S/folders.sh" delete 13 >/tmp/folder-delete-out.$$ 2>/tmp/folder-delete-err.$$
status=$?
assert_eq "0" "$status" "folders delete status"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X DELETE" "folders delete method"
assert_contains "$args" "/folders/13" "folders delete path"
rm -f /tmp/folder-delete-out.$$ /tmp/folder-delete-err.$$
unset MOCK_CURL_STATUS MOCK_CURL_BODY

# docs move to folder and root
out="$(MOCK_CURL_BODY='{"documentId":7,"fromFolderId":null,"toFolderId":12}' bash "$S/move-doc.sh" 7 --folder 12)"
assert_eq "12" "$(printf '%s' "$out" | jq -r '.toFolderId')" "move folder result"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" "-X PATCH" "move folder method"
assert_contains "$args" "/docs/7" "move folder path"
assert_contains "$args" '"folderId": 12' "move folder body"

out="$(MOCK_CURL_BODY='{"documentId":7,"fromFolderId":12,"toFolderId":null}' bash "$S/move-doc.sh" 7 --folder root)"
assert_eq "null" "$(printf '%s' "$out" | jq -r '.toFolderId')" "move root result"
args="$(cat "$MOCK_CURL_ARGS_FILE")"
assert_contains "$args" '"folderId":null' "move root body"

finish
