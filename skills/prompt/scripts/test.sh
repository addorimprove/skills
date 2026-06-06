#!/usr/bin/env bash
# End-to-end smoke test against a DEV server only. NEVER run against prod.
# Requires a logged-in dev credential or MD_PROMPT_API_KEY set for the dev API.
# Usage: MD_PROMPT_BASE_URL=http://localhost:3000 bash scripts/test.sh
set -euo pipefail
S="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
base="${MD_PROMPT_BASE_URL:-}"
case "$base" in
  ""|*addorimprove.com*) echo "Refusing to run: set MD_PROMPT_BASE_URL to a dev URL (not prod)." >&2; exit 1 ;;
esac

echo "whoami:";    bash "$S/whoami.sh" | jq -e '.id' >/dev/null
tmp="$(mktemp)"; printf '# smoke %s\nbody\n' "$$" > "$tmp"
echo "new:";       id="$(bash "$S/new.sh" --name "smoke $$" -f "$tmp" | jq -r '.id')"; echo "  id=$id"
echo "view:";      bash "$S/view.sh" "$id" | jq -e '.latest.label' >/dev/null
printf '# smoke %s v2\n' "$$" > "$tmp"
echo "iterate:";   lbl="$(bash "$S/iterate.sh" "$id" -f "$tmp" | jq -r '.label')"; echo "  label=$lbl"
echo "comment:";   cid="$(bash "$S/comment-add.sh" "$id" "$lbl" --body "smoke comment" | jq -r '.id')"; echo "  cid=$cid"
echo "comments:";  bash "$S/comments.sh" "$id" "$lbl" | jq -e 'length >= 1' >/dev/null
echo "resolve:";   bash "$S/comment-resolve.sh" "$id" "$lbl" "$cid" | jq -e '.resolved == true' >/dev/null
echo "visibility:";bash "$S/visibility.sh" "$id" "$lbl" public | jq -e '.isPublic == true' >/dev/null
rm -f "$tmp"
echo "DEV SMOKE PASSED (doc $id)"
