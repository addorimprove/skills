#!/usr/bin/env bash
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$HERE/../.."
# shellcheck source=assert.sh
. "$HERE/assert.sh"

skill="$(cat "$ROOT/SKILL.md")"
commands="$(cat "$ROOT/references/commands.md")"
comments="$(cat "$ROOT/references/comments.md")"
safety="$(cat "$ROOT/references/write-safety.md")"
workflows="$(cat "$ROOT/references/workflows.md")"

assert_contains "$skill" "Folder:** optional, nestable organizational container" "Folder is organizational"
assert_contains "$skill" "Document:** content-bearing item" "Document is content-bearing"
assert_contains "$skill" "Markdown**, **MDX**, **HTML**, **Plain**, and **Files" "all five kinds documented"
assert_contains "$skill" "Versioning Off:** one CAS-guarded live current state" "Versioning Off model"
assert_contains "$skill" "no snapshots, labels" "Off has no snapshots or labels"
assert_contains "$comments" "Snapshot Comments — Versioning On" "snapshot Comments documented"
assert_contains "$comments" "Live-current Comments — Versioning Off" "live Comments documented"
assert_contains "$comments" "stale_comment" "live Comment conflict documented"
assert_contains "$commands" "--kind markdown|mdx|html|plain|files" "canonical kind command"
assert_contains "$commands" "--expected-mutation-revision" "thread CAS command"
assert_contains "$workflows" "stable slug" "live publication stable slug"
assert_contains "$safety" "Get the user's explicit go-ahead before every write" "approval contract"
assert_contains "$safety" "Never route binary through bundle text" "binary Files safety"
assert_contains "$safety" 'All good to upload ./prompt/{id}/bundle.md?' "exact upload approval question"
assert_contains "$skill" '`prompt projects` aliases organizational `prompt folders`' "projects compatibility alias"
assert_contains "$skill" '`--project <id|root>` aliases Document placement' "project flag compatibility alias"
assert_contains "$skill" '`--format mdx|html|plain|files`' "format compatibility alias"

finish
