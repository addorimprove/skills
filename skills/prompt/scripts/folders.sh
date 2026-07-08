#!/usr/bin/env bash
set -euo pipefail
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

usage() {
  cat >&2 <<'USAGE'
usage:
  folders.sh [ls] [--parent <folderId>]
  folders.sh create <name> [--parent <folderId>]
  folders.sh delete <folderId>
USAGE
}

require_positive() {
  require_int "$1" "$2"
  [ "$2" -gt 0 ] || { echo "$1: must be a positive integer" >&2; exit 2; }
}

sub="ls"
if [ $# -gt 0 ] && [[ "$1" != --* ]]; then
  sub="$1"
  shift
fi
case "$sub" in
  ls)
    parent=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --parent) parent="$2"; shift 2 ;;
        --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
        *) echo "folders: unexpected arg: $1" >&2; usage; exit 2 ;;
      esac
    done
    if [ -n "$parent" ]; then
      require_positive "--parent" "$parent"
      req GET "/folders?parentFolderId=$parent"
    else
      req GET "/folders"
    fi
    echo ;;
  create)
    name="${1:-}"
    [ -n "$name" ] || { echo "folders create: missing <name>" >&2; usage; exit 2; }
    shift || true
    parent=""
    while [ $# -gt 0 ]; do
      case "$1" in
        --parent) parent="$2"; shift 2 ;;
        --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
        *) echo "folders create: unexpected arg: $1" >&2; usage; exit 2 ;;
      esac
    done
    if [ -n "$parent" ]; then
      require_positive "--parent" "$parent"
      body="$(jq -n --arg name "$name" --argjson parentFolderId "$parent" '{name:$name,parentFolderId:$parentFolderId}')"
    else
      body="$(jq -n --arg name "$name" '{name:$name,parentFolderId:null}')"
    fi
    req POST "/folders" "$body"
    echo ;;
  delete)
    folder="${1:-}"
    require_positive "folderId" "$folder"
    shift || true
    while [ $# -gt 0 ]; do
      case "$1" in
        --base-url) BASE_URL_FLAG="$2"; shift 2 ;;
        *) echo "folders delete: unexpected arg: $1" >&2; usage; exit 2 ;;
      esac
    done
    req DELETE "/folders/$folder"
    echo ;;
  *)
    usage; exit 2 ;;
esac
