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
