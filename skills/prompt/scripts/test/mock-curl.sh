#!/usr/bin/env bash
# Fake curl for offline tests. Records its args to $MOCK_CURL_ARGS_FILE,
# prints $MOCK_CURL_BODY then a newline then $MOCK_CURL_STATUS (mirrors the
# real `curl -w '\n%{http_code}'` contract lib.sh relies on).
set -uo pipefail
if [ -n "${MOCK_CURL_ARGS_FILE:-}" ]; then
  printf '%s\n' "$*" > "$MOCK_CURL_ARGS_FILE"
fi
printf '%s\n%s' "${MOCK_CURL_BODY:-}" "${MOCK_CURL_STATUS:-200}"
