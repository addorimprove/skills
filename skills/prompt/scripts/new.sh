#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"
need_value() { [ "$#" -ge 2 ] && [ -n "${2:-}" ] || { echo "new: $1 requires a value" >&2; exit 2; }; }
name=""; file=""; format=""; kind=""; versioning=""; folder=""; project=""
while [ $# -gt 0 ]; do
  case "$1" in
    --name) need_value "$@"; name="$2"; shift 2 ;;
    -f|--file) need_value "$@"; file="$2"; shift 2 ;;
    --kind) need_value "$@"; kind="$2"; shift 2 ;;
    --format) need_value "$@"; format="$2"; shift 2 ;;
    --versioning) need_value "$@"; versioning="$2"; shift 2 ;;
    --folder) need_value "$@"; folder="$2"; shift 2 ;;
    --project) need_value "$@"; project="$2"; shift 2 ;;
    --base-url) need_value "$@"; BASE_URL_FLAG="$2"; shift 2 ;;
    *) echo "new: unexpected arg: $1" >&2; exit 2 ;;
  esac
done
[ -n "$name" ] || { echo "new: missing --name" >&2; exit 2; }
[ -n "$file" ] && [ -f "$file" ] || { echo "new: missing -f <file>" >&2; exit 2; }
case "$kind" in ''|markdown|mdx|html|plain|files) ;; *) echo "--kind: must be markdown|mdx|html|plain|files" >&2; exit 2 ;; esac
case "$format" in ''|mdx|html|plain|files) ;; *) echo "--format: must be mdx|html|plain|files" >&2; exit 2 ;; esac
case "$versioning" in ''|on|off) ;; *) echo "--versioning: must be on|off" >&2; exit 2 ;; esac
if [ -n "$kind" ] && [ -n "$format" ] && [ "$kind" != "$format" ]; then
  echo "--kind and compatibility alias --format must describe the same Document kind" >&2
  exit 2
fi
if [ -n "$folder" ] && [ -n "$project" ] && [ "$folder" != "$project" ]; then
  echo "--folder and deprecated --project must name the same Folder" >&2
  exit 2
fi
placement="${folder:-$project}"
if [ -n "$placement" ] && [ "$placement" != "root" ]; then
  require_int "--folder" "$placement"
  [ "$placement" -gt 0 ] || { echo "--folder: must be a positive integer or root" >&2; exit 2; }
fi
body="$(jq -n --arg name "$name" --rawfile content "$file" '{name:$name, content:$content}')"
[ -n "$kind" ] && body="$(printf '%s' "$body" | jq --arg kind "$kind" '.contentKind=$kind')"
[ -n "$format" ] && body="$(printf '%s' "$body" | jq --arg format "$format" '.format=$format')"
[ -n "$versioning" ] && body="$(printf '%s' "$body" | jq --arg versioning "$versioning" '.versioning=$versioning')"
if [ "$placement" = "root" ]; then
  body="$(printf '%s' "$body" | jq '.folderId=null')"
elif [ -n "$placement" ]; then
  body="$(printf '%s' "$body" | jq --argjson folderId "$placement" '.folderId=$folderId')"
fi
req POST "/docs" "$body"
echo
