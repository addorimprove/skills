#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$HERE/.."
# shellcheck source=assert.sh
. "$HERE/assert.sh"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

PROJECT="$TMPDIR/project"
mkdir -p "$PROJECT/src"
printf '# Spec\n' > "$PROJECT/README.md"
printf 'export {};\n' > "$PROJECT/src/index.ts"
stage_out="$(cd "$PROJECT" && bash "$S/stage-files.sh" --id new-spec --name "Spec Doc" README.md src/index.ts)"
assert_contains "$stage_out" "Staged 2 file(s) under ./prompt/new-spec/" "stage-files summary"
assert_contains "$stage_out" "Bundle: ./prompt/new-spec/bundle.md" "stage-files bundle path"
assert_contains "$stage_out" "bash \"\$SKILL_DIR/scripts/new.sh\" --name 'Spec Doc' -f './prompt/new-spec/bundle.md' --format files" "stage-files upload command"
assert_contains "$stage_out" "bash \"\$SKILL_DIR/scripts/iterate.sh\" <docId> --parent <label> -f './prompt/new-spec/bundle.md' --format files" "stage-files quoted iterate command"
assert_not_contains "$stage_out" "npx @addorimprove/prompt" "stage-files has no CLI equivalent"
assert_contains "$stage_out" "All good to upload ./prompt/new-spec/bundle.md?" "stage-files approval prompt"
assert_contains "$(cat "$PROJECT/prompt/new-spec/files/README.md")" "# Spec" "stage-files copied README"
bundle="$(cat "$PROJECT/prompt/new-spec/bundle.md")"
assert_contains "$bundle" "<!-- FILE-TREE -->" "stage-files bundle tree marker"
assert_contains "$bundle" "- README.md" "stage-files bundle lists README"
assert_contains "$bundle" "<!-- FILE-CONTENT: src/index.ts -->" "stage-files bundle content marker"
if [ -e "$PROJECT/prompt/new-spec/manifest.json" ]; then
  printf 'FAIL stage-files does not create manifest\n' >&2
  ASSERT_FAILS=$((ASSERT_FAILS + 1))
else
  printf 'ok   stage-files does not create manifest\n'
fi

err="$(cd "$PROJECT" && bash "$S/stage-files.sh" --id '$(echo injected)' README.md 2>&1 >/dev/null)"; rc=$?
assert_status 2 "$rc" "stage-files rejects unsafe id"
assert_contains "$err" "unsafe staging id" "stage-files unsafe id message"

OUTSIDE="$TMPDIR/outside-stage"
mkdir -p "$OUTSIDE" "$PROJECT/prompt"
ln -s "$OUTSIDE" "$PROJECT/prompt/new-link"
err="$(cd "$PROJECT" && bash "$S/stage-files.sh" --id new-link README.md 2>&1 >/dev/null)"; rc=$?
assert_status 2 "$rc" "stage-files rejects symlink staging dir"
assert_contains "$err" "refusing to write through symlink" "stage-files symlink staging message"
if [ -e "$OUTSIDE/bundle.md" ] || [ -e "$OUTSIDE/files/README.md" ]; then
  printf 'FAIL stage-files does not write through symlink\n' >&2
  ASSERT_FAILS=$((ASSERT_FAILS + 1))
else
  printf 'ok   stage-files does not write through symlink\n'
fi

err="$(cd "$PROJECT" && bash "$S/stage-files.sh" --id new-spec README.md 2>&1 >/dev/null)"; rc=$?
assert_status 2 "$rc" "stage-files refuses existing bundle"
assert_contains "$err" "refusing to overwrite existing bundle" "stage-files overwrite message"
printf '# Changed\n' > "$PROJECT/README.md"
(cd "$PROJECT" && bash "$S/stage-files.sh" --id new-spec --force README.md >/dev/null)
assert_contains "$(cat "$PROJECT/prompt/new-spec/files/README.md")" "# Changed" "stage-files force updates staged file"
if [ -e "$PROJECT/prompt/new-spec/files/src/index.ts" ]; then
  printf 'FAIL stage-files force removes stale files\n' >&2
  ASSERT_FAILS=$((ASSERT_FAILS + 1))
else
  printf 'ok   stage-files force removes stale files\n'
fi

finish
