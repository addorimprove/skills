#!/usr/bin/env bash
# Minimal assert helpers for offline script tests.
ASSERT_FAILS=0

assert_eq() { # expected actual [label]
  if [ "$1" != "$2" ]; then
    printf 'FAIL %s\n  expected: %q\n  actual:   %q\n' "${3:-assert_eq}" "$1" "$2" >&2
    ASSERT_FAILS=$((ASSERT_FAILS + 1))
  else
    printf 'ok   %s\n' "${3:-assert_eq}"
  fi
}

assert_contains() { # haystack needle [label]
  case "$1" in
    *"$2"*) printf 'ok   %s\n' "${3:-assert_contains}" ;;
    *) printf 'FAIL %s\n  %q does not contain %q\n' "${3:-assert_contains}" "$1" "$2" >&2
       ASSERT_FAILS=$((ASSERT_FAILS + 1)) ;;
  esac
}

assert_status() { # expected actual [label]
  assert_eq "$1" "$2" "${3:-exit status}"
}

finish() {
  if [ "$ASSERT_FAILS" -ne 0 ]; then
    printf '\n%d assertion(s) failed\n' "$ASSERT_FAILS" >&2
    exit 1
  fi
  printf '\nall assertions passed\n'
}
