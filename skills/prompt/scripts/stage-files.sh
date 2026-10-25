#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat >&2 <<'USAGE'
Usage: stage-files.sh --id <staging-id> [--name <doc-name>] [--force] <file>...

Stages selected text files under ./prompt/<staging-id>/files/ and writes
./prompt/<staging-id>/bundle.md in canonical files-format. This script only
prepares and previews a local upload payload; it never uploads.

Run from the project root so file arguments are relative paths to preserve in
the staged bundle. Use --force to replace an existing staged bundle/files.
USAGE
}

stage_id=""
name=""
force=0
selected=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    --id)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      stage_id="$2"
      shift 2
      ;;
    --id=*) stage_id="${1#--id=}"; shift ;;
    --name)
      if [ "$#" -lt 2 ] || [ -z "${2:-}" ]; then usage; exit 2; fi
      name="$2"
      shift 2
      ;;
    --name=*) name="${1#--name=}"; shift ;;
    --force) force=1; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; while [ "$#" -gt 0 ]; do selected+=("$1"); shift; done ;;
    --*) echo "stage-files: unexpected arg: $1" >&2; usage; exit 2 ;;
    *) selected+=("$1"); shift ;;
  esac
done

fail() { echo "stage-files: $*" >&2; exit 2; }

[ -n "$stage_id" ] || fail "missing --id <staging-id>"
if [[ ! "$stage_id" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  fail "unsafe staging id: $stage_id"
fi
[ "${#selected[@]}" -gt 0 ] || fail "select at least one file"

root="$(pwd -P)"
stage_rel="./prompt/$stage_id"
stage_dir="$root/prompt/$stage_id"
files_dir="$stage_dir/files"
bundle="$stage_dir/bundle.md"

check_safe_dir_if_exists() {
  local path="$1" label="$2"
  [ ! -L "$path" ] || fail "refusing to write through symlink: $label"
  if [ -e "$path" ] && [ ! -d "$path" ]; then
    fail "staging path component is not a directory: $label"
  fi
}

check_safe_file_if_exists() {
  local path="$1" label="$2"
  [ ! -L "$path" ] || fail "refusing to overwrite symlink: $label"
  if [ -e "$path" ] && [ ! -f "$path" ]; then
    fail "staging bundle path is not a regular file: $label"
  fi
}

normalize_selected_path() {
  local raw="$1"
  case "$raw" in
    /*) fail "file paths must be relative to the current project: $raw" ;;
    *$'\n'*|*$'\r'*) fail "file path contains a newline: $raw" ;;
  esac
  local rel="$raw"
  while [[ "$rel" == ./* ]]; do rel="${rel#./}"; done
  case "$rel" in
    ''|.|..|../*|*/../*|*/..|*/./*|*/.|*//*|*\\*|/*) fail "unsafe file path: $raw" ;;
    *'-->'*) fail "file path cannot contain -->: $raw" ;;
  esac
  printf '%s' "$rel"
}

rels=()
for raw in "${selected[@]}"; do
  rel="$(normalize_selected_path "$raw")"
  if [ "${#rels[@]}" -gt 0 ]; then
    for existing in "${rels[@]}"; do
      [ "$existing" = "$rel" ] && fail "duplicate file selected: $rel"
    done
  fi
  src="$root/$rel"
  [ -f "$src" ] || fail "not a regular file: $rel"
  [ ! -L "$src" ] || fail "refusing to stage symlink: $rel"
  if ! LC_ALL=C tr -d '\000' < "$src" | cmp -s - "$src"; then
    fail "refusing to stage binary file: $rel"
  fi
  case "$(cd "$(dirname "$src")" && pwd -P)/$(basename "$src")" in
    "$root"/*) ;;
    *) fail "refusing to stage file outside project: $rel" ;;
  esac
  rels+=("$rel")
done

check_safe_dir_if_exists "$root/prompt" "./prompt"
check_safe_dir_if_exists "$stage_dir" "$stage_rel"
check_safe_dir_if_exists "$files_dir" "$stage_rel/files"
check_safe_file_if_exists "$bundle" "$stage_rel/bundle.md"

if [ -e "$bundle" ] && [ "$force" -ne 1 ]; then
  fail "refusing to overwrite existing bundle: $stage_rel/bundle.md (use --force)"
fi
if [ -d "$files_dir" ] && [ "$force" -ne 1 ] && [ -n "$(find "$files_dir" -mindepth 1 -print -quit)" ]; then
  fail "refusing to merge into existing staged files dir: $stage_rel/files (use --force)"
fi
for rel in "${rels[@]}"; do
  dest="$files_dir/$rel"
  if [ -e "$dest" ] && [ "$force" -ne 1 ]; then
    fail "refusing to overwrite existing staged file: $stage_rel/files/$rel (use --force)"
  fi
done

if [ "$force" -eq 1 ]; then
  rm -rf "$files_dir"
fi
mkdir -p "$files_dir"
for rel in "${rels[@]}"; do
  mkdir -p "$(dirname "$files_dir/$rel")"
  cp "$root/$rel" "$files_dir/$rel"
done

fence_for_file() {
  awk '
    match($0, /^~+/) { if (RLENGTH > max) max = RLENGTH }
    END {
      n = max + 1
      if (n < 4) n = 4
      for (i = 0; i < n; i++) printf "~"
    }
  ' "$1"
}

quote_yaml_string() {
  case "$1" in
    ''|*[!abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._/-]*) printf '%s' "$1" | jq -Rs . ;;
    *) printf '%s' "$1" ;;
  esac
}

shell_quote() {
  printf "'"
  printf '%s' "$1" | sed "s/'/'\\\\''/g"
  printf "'"
}

shell_quote_args() {
  local arg
  for arg in "$@"; do
    printf ' %s' "$(shell_quote "$arg")"
  done
}

{
  printf '<!-- FILE-TREE -->\n'
  printf '```yaml\n'
  for rel in "${rels[@]}"; do
    printf -- '- %s\n' "$(quote_yaml_string "$rel")"
  done
  printf '```\n\n'

  i=0
  total="${#rels[@]}"
  for rel in "${rels[@]}"; do
    staged="$files_dir/$rel"
    fence="$(fence_for_file "$staged")"
    printf '<!-- FILE-CONTENT: %s -->\n' "$rel"
    printf '%s\n' "$fence"
    cat "$staged"
    printf '\n%s\n' "$fence"
    i=$((i + 1))
    [ "$i" -lt "$total" ] && printf '\n'
  done
} > "$bundle"

bundle_rel="$stage_rel/bundle.md"

printf 'Staged %s file(s) under %s/\n\n' "${#rels[@]}" "$stage_rel"
printf 'Selected files:\n'
for rel in "${rels[@]}"; do
  printf '  - %s\n' "$rel"
done
printf '\nBundle: %s\n\n' "$bundle_rel"
printf 'Bundle preview:\n'
head -n 40 "$bundle"
if [ "$(wc -l < "$bundle" | tr -d ' ')" -gt 40 ]; then
  printf '...\n'
fi
printf '\nUpload command after approval (skill script preferred):\n'
if [ -n "$name" ]; then
  printf '  bash "$SKILL_DIR/scripts/new.sh" --name %s -f %s --format files\n' "$(shell_quote "$name")" "$(shell_quote "$bundle_rel")"
else
  printf '  bash "$SKILL_DIR/scripts/new.sh" --name "<name>" -f %s --format files\n' "$(shell_quote "$bundle_rel")"
fi
printf '\nOther approved upload forms:\n'
printf '  bash "$SKILL_DIR/scripts/iterate.sh" <docId> --parent <label> -f %s --format files\n' "$(shell_quote "$bundle_rel")"
printf '  bash "$SKILL_DIR/scripts/branch.sh" <docId> <parentLabel> -f %s --format files\n' "$(shell_quote "$bundle_rel")"
printf '\nAsk: All good to upload %s?\n' "$bundle_rel"
