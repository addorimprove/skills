#!/usr/bin/env bash
# Shared helpers for the prompt skill scripts. Source this; do not execute.
# Resolution matches the @addorimprove/prompt CLI exactly.
#
# jq is PREFERRED but not strictly required. It is used here to read the stored
# credential and to slice/unwrap response JSON. If jq is missing you have two
# options: install it (`brew install jq`), or skip the jq-shaping scripts and
# call `req` directly — it prints the raw API JSON to stdout, which the agent
# (LLM) can parse on its own. curl is the only hard dependency.

prompt_config_path() {
  printf '%s/prompt/config.json' "${XDG_CONFIG_HOME:-$HOME/.config}"
}

resolve_api_key() {
  if [ -n "${MD_PROMPT_API_KEY:-}" ]; then
    printf '%s' "$MD_PROMPT_API_KEY"
    return 0
  fi
  local p
  p="$(prompt_config_path)"
  if [ -f "$p" ]; then
    jq -r '.apiKey // empty' "$p"
  fi
}

resolve_base_url() { # [flag]
  local flag="${1:-}"
  if [ -n "$flag" ]; then printf '%s' "$flag"; return 0; fi
  if [ -n "${MD_PROMPT_BASE_URL:-}" ]; then printf '%s' "$MD_PROMPT_BASE_URL"; return 0; fi
  local p b
  p="$(prompt_config_path)"
  if [ -f "$p" ]; then
    b="$(jq -r '.baseUrl // empty' "$p")"
    if [ -n "$b" ]; then printf '%s' "$b"; return 0; fi
  fi
  printf '%s' "https://addorimprove.com"
}

# req METHOD PATH [JSON_BODY]
# Sends an authenticated request to $BASE/api/v1/me$PATH. On 2xx prints the
# response body (empty for 204) and returns 0. On error prints a CLI-matched
# message to stderr and returns a non-zero status. Tests override curl via $CURL
# and the base-url flag via $BASE_URL_FLAG.
req() {
  local method="$1" path="$2" body="${3:-}"
  local key
  key="$(resolve_api_key)"
  if [ -z "$key" ]; then
    echo "Not logged in. Run 'npx @addorimprove/prompt login'." >&2
    return 4
  fi
  local base url
  base="$(resolve_base_url "${BASE_URL_FLAG:-}")"
  url="$base/api/v1/me$path"

  local args=(-sS -X "$method" -H "x-api-key: $key" -w '\n%{http_code}')
  if [ -n "$body" ]; then
    args+=(-H 'content-type: application/json' -d "$body")
  fi

  local out status resp
  if ! out="$("${CURL:-curl}" "${args[@]}" "$url")"; then
    echo "Request failed (network error)." >&2
    return 1
  fi
  status="${out##*$'\n'}"
  resp="${out%$'\n'*}"

  case "$status" in
    204) return 0 ;;
    2*) printf '%s' "$resp"; return 0 ;;
    401) echo "Not logged in. Run 'npx @addorimprove/prompt login'." >&2; return 4 ;;
    404) echo "Not found (or not yours)." >&2; return 1 ;;
    409) echo "Label conflict — $(printf '%s' "$resp" | jq -r '.error.message // empty')" >&2; return 1 ;;
    400) printf '%s\n' "$(printf '%s' "$resp" | jq -r '.error.message // empty')" >&2; return 1 ;;
    *)  echo "Request failed ($status): $(printf '%s' "$resp" | jq -r '.error.message // empty')" >&2; return 1 ;;
  esac
}
