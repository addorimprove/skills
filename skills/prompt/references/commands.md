# Commands

## Bundled scripts (preferred)

Run these with `bash "$SKILL_DIR/scripts/<script>" ...`.

| Goal | Script | Output |
|------|--------|--------|
| Who am I | `whoami.sh` | `{ id, name, email }` |
| Recent activity | `recent.sh [-n <limit>]` | activity array, most-recent-first |
| List / search docs | `ls.sh [-q <query>]` | docs array (`{ id, name, openCommentCount, … }`) |
| Doc tree + latest content | `view.sh <id>` | `{ id, name, versions:[…], latest:{label,content} }` |
| One version's content | `view.sh <id> <label>` | `{ label, content, format, … }` |
| Version comments | `comments.sh <id> <label>` | comments array, pre-sorted |
| Create a doc | `new.sh --name "<name>" -f <file> [--format mdx\|html\|plain]` | `{ id, label:"1-1" }` |
| Add version on same line | `iterate.sh <id> [--parent <label>] -f <file> [--format]` | `{ label }` |
| Fork a branch line | `branch.sh <id> <parentLabel> -f <file> [--format]` | `{ label }` |
| Change visibility | `visibility.sh <id> <label> public\|private` | `{ label, isPublic, publicSlug, publicUrl }` |
| Add a comment | `comment-add.sh <id> <label> --body "<text>" [--quote "<text>"]` | `{ id }` |
| Reply to a comment | `comment-reply.sh <id> <label> <commentId> --body "<text>"` | `{ id }` |
| Resolve / unresolve | `comment-resolve.sh <id> <label> <commentId> [--unresolve]` | `{ id, resolved }` |

## CLI-only utilities

Use the published CLI for browser login, npm updates, and Markdown bundle
restore:

| Goal | CLI |
|------|-----|
| Login | `npx @addorimprove/prompt login` |
| Check CLI version | `npx @addorimprove/prompt version --json` |
| Self-update CLI | `npx @addorimprove/prompt upgrade` |
| Restore Markdown bundle | `npx @addorimprove/prompt restore-bundle [bundle.md] --output <dir> [--force] [-y] [--json]` |

If you use the CLI for write commands (`new`, `iterate`, `branch`), pass
`-f <file>` to avoid opening `$EDITOR` and `-y` to skip the CLI confirmation
prompt.

`restore-bundle` requires `--output <dir>` and unpacks `<!-- FILE: path -->`
markers with `~~~~md` fences. It shows a folder-style preview and asks for
confirmation before writing files, rejects paths outside the output folder such
as `/tmp/file` or `../file`, refuses to overwrite existing files unless `--force`
is passed, and omits the preview under `--json`. Pass `-y` only after explicit
approval.
