#!/usr/bin/env bash
# Runs every offline unit test (mock-curl, no network).
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fails=0
for t in lib_test.sh req_test.sh read_test.sh write_test.sh comment_test.sh validation_test.sh; do
  echo "== $t =="
  if ! bash "$HERE/$t"; then fails=$((fails + 1)); fi
done
if [ "$fails" -ne 0 ]; then echo "$fails test file(s) failed" >&2; exit 1; fi
echo "ALL OFFLINE TESTS PASSED"
