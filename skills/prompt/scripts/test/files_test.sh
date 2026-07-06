#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
S="$HERE/.."
# shellcheck source=assert.sh
. "$HERE/assert.sh"

TMPDIR="$(mktemp -d)"
CALLS="$TMPDIR/npx.calls"
mkdir -p "$TMPDIR/bin"
cat > "$TMPDIR/bin/npx" <<'MOCK_NPX'
#!/usr/bin/env bash
printf 'npx' > "$MOCK_NPX_CALLS"
for arg in "$@"; do printf '\t%s' "$arg" >> "$MOCK_NPX_CALLS"; done
printf '\n' >> "$MOCK_NPX_CALLS"
MOCK_NPX
chmod +x "$TMPDIR/bin/npx"
export PATH="$TMPDIR/bin:$PATH"
export MOCK_NPX_CALLS="$CALLS"
trap 'rm -rf "$TMPDIR"' EXIT

run_ok() {
  : > "$CALLS"
  if ! bash "$1" "${@:2}" >/dev/null 2>"$TMPDIR/stderr"; then
    printf 'FAIL %s unexpectedly failed\n' "$1" >&2
    cat "$TMPDIR/stderr" >&2
    ASSERT_FAILS=$((ASSERT_FAILS + 1))
  fi
}

run_fail() {
  : > "$CALLS"
  if bash "$1" "${@:2}" >/dev/null 2>"$TMPDIR/stderr"; then
    printf 'FAIL %s unexpectedly succeeded\n' "$1" >&2
    ASSERT_FAILS=$((ASSERT_FAILS + 1))
  else
    printf 'ok   %s failed as expected\n' "$(basename "$1")"
  fi
}

run_ok "$S/new-files.sh" --name Spec --files ./spec -y
assert_eq $'npx\t@addorimprove/prompt\tnew\t--name\tSpec\t--files\t./spec\t-y' "$(cat "$CALLS")" "new-files delegates"
assert_not_contains "$(cat "$CALLS")" "--force" "new-files does not add force"

run_ok "$S/iterate-files.sh" 7 --parent 1-1 --files ./spec -y
assert_eq $'npx\t@addorimprove/prompt\titerate\t7\t--parent\t1-1\t--files\t./spec\t-y' "$(cat "$CALLS")" "iterate-files delegates"
assert_not_contains "$(cat "$CALLS")" "--force" "iterate-files does not add force"

run_ok "$S/branch-files.sh" 7 --parent 1-1 --files ./spec -y
assert_eq $'npx\t@addorimprove/prompt\tbranch\t7\t--parent\t1-1\t--files\t./spec\t-y' "$(cat "$CALLS")" "branch-files delegates with --parent"

run_ok "$S/branch-files.sh" 7 1-1 --files ./spec -y
assert_eq $'npx\t@addorimprove/prompt\tbranch\t7\t1-1\t--files\t./spec\t-y' "$(cat "$CALLS")" "branch-files delegates with positional parent"

run_ok "$S/restore-files.sh" 7 --version 1-1 -y
assert_eq $'npx\t@addorimprove/prompt\trestore-files\t7\t--version\t1-1\t-y' "$(cat "$CALLS")" "restore-files delegates"
assert_not_contains "$(cat "$CALLS")" "--force" "restore-files does not add force"

run_ok "$S/restore-files.sh" 7 -y
assert_eq $'npx\t@addorimprove/prompt\trestore-files\t7\t-y' "$(cat "$CALLS")" "restore-files does not require output"

run_fail "$S/new-files.sh" --name Spec -y
assert_contains "$(cat "$TMPDIR/stderr")" "--files" "new-files missing files message"
assert_eq "" "$(cat "$CALLS")" "new-files missing files does not call npx"

run_fail "$S/iterate-files.sh" 7 --parent 1-1 -y
assert_contains "$(cat "$TMPDIR/stderr")" "--files" "iterate-files missing files message"
assert_eq "" "$(cat "$CALLS")" "iterate-files missing files does not call npx"

run_fail "$S/branch-files.sh" 7 --parent 1-1 -y
assert_contains "$(cat "$TMPDIR/stderr")" "--files" "branch-files missing files message"
assert_eq "" "$(cat "$CALLS")" "branch-files missing files does not call npx"

finish
