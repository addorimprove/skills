# Commands

## Bundled scripts (preferred)

Run these with `bash "$SKILL_DIR/scripts/<script>" ...`. The `*-files.sh`
wrappers validate required files-workflow arguments before delegating to the CLI.

| Goal | Script | Output |
|------|--------|--------|
| Who am I | `whoami.sh` | `{ id, name, email }` |
| Recent activity | `recent.sh [-n <limit>]` | activity array, most-recent-first |
| List / search docs | `ls.sh [-q <query>]` | docs array (`{ id, name, openCommentCount, … }`) |
| Doc tree + latest content | `view.sh <id>` | `{ id, name, versions:[…], latest:{label,content} }` |
| One version's content | `view.sh <id> <label>` | `{ label, content, format, … }` |
| Version comments | `comments.sh <id> <label>` | comments array, pre-sorted |
| Create a doc | `new.sh --name "<name>" -f <file> [--format mdx\|html\|plain\|files]` | `{ id, label:"1-1" }` |
| Add version on same line | `iterate.sh <id> [--parent <label>] -f <file> [--format]` | `{ label }` |
| Fork a branch line | `branch.sh <id> <parentLabel> -f <file> [--format]` | `{ label }` |
| Create files doc from folder | `new-files.sh --name "<name>" --files <dir> [-y]` | CLI output |
| Iterate files doc from folder | `iterate-files.sh <id> --parent <label> --files <dir> [-y]` | CLI output |
| Branch files doc from folder | `branch-files.sh <id> --parent <label> --files <dir> [-y]` | CLI output |
| Restore files version | `restore-files.sh <id> [--version <label>] [--output <dir>] [--force] [-y]` | CLI output |
| Change visibility | `visibility.sh <id> <label> public\|private` | `{ label, isPublic, publicSlug, publicUrl }` |
| Add a comment | `comment-add.sh <id> <label> --body "<text>" [--quote "<text>"]` | `{ id }` |
| Reply to a comment | `comment-reply.sh <id> <label> <commentId> --body "<text>"` | `{ id }` |
| Resolve / unresolve | `comment-resolve.sh <id> <label> <commentId> [--unresolve]` | `{ id, resolved }` |

## CLI-only utilities

Use the published CLI for browser login, npm updates, local folder upload, and
files restore workflows:

| Goal | CLI |
|------|-----|
| Login | `npx @addorimprove/prompt login` |
| Check CLI version | `npx @addorimprove/prompt version --json` |
| Self-update CLI | `npx @addorimprove/prompt upgrade` |
| Build files bundle from folder | `npx @addorimprove/prompt bundle <dir> [--output .prompt/bundles/name.md] [-y] [--json]` |
| Create files doc from folder | `npx @addorimprove/prompt new --name "Spec" --files ./spec [-y] [--json]` |
| Iterate files doc from folder | `npx @addorimprove/prompt iterate <id> --parent <label> --files ./spec [-y] [--json]` |
| Branch files doc from folder | `npx @addorimprove/prompt branch <id> --parent <label> --files ./spec [-y] [--json]` |
| Restore local bundle | `npx @addorimprove/prompt restore-bundle [bundle.md] [--output <dir>] [--force] [-y] [--json]` |
| Restore files version | `npx @addorimprove/prompt restore-files <id> [--version <label>] [--output <dir>] [--force] [-y] [--json]` |

If you use the CLI for write commands (`new`, `iterate`, `branch`), pass
`-f <file>` to avoid opening `$EDITOR` and `-y` to skip the CLI confirmation
prompt.

Files-format bundles use `<!-- FILE-TREE -->` plus `<!-- FILE-CONTENT: path -->` sections. `restore-bundle` also keeps legacy `<!-- FILE: path -->` support. Restore commands default to `.prompt/` (`.prompt/bundles/<bundle>/` or `.prompt/<id>/<label>/`) unless `--output <dir>` is explicitly supplied. They show a folder-style preview and ask for confirmation before writing files, reject paths outside the output folder such as `/tmp/file` or `../file`, refuse to overwrite existing files unless `--force` is passed, and omit the preview under `--json`. Pass `-y` only after explicit approval.
