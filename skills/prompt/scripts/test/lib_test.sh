#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=assert.sh
. "$HERE/assert.sh"
# shellcheck source=../lib.sh
. "$HERE/../lib.sh"

# Isolated fake config home, no real config leaks in.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
export XDG_CONFIG_HOME="$TMP/cfg"
mkdir -p "$XDG_CONFIG_HOME/prompt"

# 1. Default base URL when nothing set.
unset MD_PROMPT_BASE_URL MD_PROMPT_API_KEY
assert_eq "https://addorimprove.com" "$(resolve_base_url "")" "default base url"

# 2. Config baseUrl beats default.
printf '{"apiKey":"mdnp_cfg","baseUrl":"http://cfg.example"}' > "$XDG_CONFIG_HOME/prompt/config.json"
assert_eq "http://cfg.example" "$(resolve_base_url "")" "config base url"
assert_eq "mdnp_cfg" "$(resolve_api_key)" "config api key"

# 3. Env beats config; flag beats env.
export MD_PROMPT_BASE_URL="http://env.example"
assert_eq "http://env.example" "$(resolve_base_url "")" "env base url"
assert_eq "http://flag.example" "$(resolve_base_url "http://flag.example")" "flag base url"
export MD_PROMPT_API_KEY="mdnp_env"
assert_eq "mdnp_env" "$(resolve_api_key)" "env api key"

# 4. No key anywhere -> empty.
unset MD_PROMPT_API_KEY
rm -f "$XDG_CONFIG_HOME/prompt/config.json"
assert_eq "" "$(resolve_api_key)" "no api key"

finish
