---
name: prompt
description: Use when the user wants to fetch, search, read, create, or iterate prompts/documents, their versions, or comments in the markdown-notes app (addorimprove / app.photosharingapp.com). Driven by the published `prompt` CLI (npx @addorimprove/prompt).
---

# Prompt

Read and write prompts (documents), versions, and comments in the markdown-notes
app through the published **`prompt` CLI**. Always invoke it as
`npx @addorimprove/prompt <command>` (there is no bare `prompt` command unless the
user globally installed it).

## Setup

- **Auth.** Commands use a stored `mdnp_…` key. If any command prints
  `Not logged in`, ask the **user** to run `npx @addorimprove/prompt login` —
  it's an interactive browser (PKCE) login you can't perform yourself. It saves
  the key to `~/.config/prompt/config.json`. `MD_PROMPT_API_KEY` env overrides
  the file if set.
- **Target.** Defaults to prod (`https://app.photosharingapp.com`). Override with
  `--base-url <url>` or `MD_PROMPT_BASE_URL` (e.g. `http://localhost:3000`).
- **Where to run.** From the project root (or any dir) — but **not** from a
  checkout's own `cli/` folder (npx then fails with `prompt: command not found`).
- **Parse output with `--json`.** Every read/write command below takes `--json`
  and prints structured JSON; prefer it over the human format when acting on
  results. (Requires CLI ≥ 0.1.2 for `whoami --json`.)

## Non-interactive rules (you are not at a TTY)

- **Always pass `-f <file>`** to `new` / `iterate` / `branch`. Without it the CLI
  opens `$EDITOR` and hangs. Write the body to a temp file first, then pass it.
- **Always pass `-y`** to writes. Without it the CLI waits on a stdin `[y/N]`
  prompt you can't answer. (Get the user's go-ahead in chat first — see Guardrail.)

## Version label model

- `1-1` is the bootstrap version. `iterate` makes the next version on the same line
  (`1-1` → `1-2` → `1-3`). `branch` forks a new line from a version by appending a
  dot-segment: the first branch off `1-2` is `1-2.1-1`, the second is `1-2.2-1` (so a
  branch off `1-1` is `1-1.1-1`).

## Commands

| Goal | Command |
|------|---------|
| Who am I | `npx @addorimprove/prompt whoami --json` → `{ id, name, email }` |
| List / search docs | `npx @addorimprove/prompt ls [-q <query>] --json` → `[{ id, name, openCommentCount, … }]` |
| Doc tree + latest content | `npx @addorimprove/prompt view <id> --json` → `{ id, name, versions:[{label,commentCount}], latest:{label,content} }` |
| Doc tree only | `npx @addorimprove/prompt view <id> --tree` |
| One version's content | `npx @addorimprove/prompt view <id> <label> --json` → `{ label, content, format, … }` |
| A version's comments | `npx @addorimprove/prompt comments <id> <label> --json` (pre-sorted) |
| Create a doc | `npx @addorimprove/prompt new --name "<name>" -f <file> [--format mdx\|html] -y --json` → `{ id, label:"1-1" }` |
| Add on same line | `npx @addorimprove/prompt iterate <id> [--parent <label>] -f <file> [--format] -y --json` → `{ label }` |
| Fork a new line | `npx @addorimprove/prompt branch <id> <parentLabel> -f <file> [--format] -y --json` → `{ label }` |
| Change visibility | `npx @addorimprove/prompt visibility <id> <label> public\|private -y --json` → `{ label, isPublic, publicSlug, publicUrl }` |

- `iterate` defaults `--parent` to the doc's latest label if omitted.
- `--format` is `mdx` (default) or `html`.
- Build a shareable link from the `whoami` id: `$MD_PROMPT_BASE_URL/<id>/<docId>/<label>`.
- When a version is made public, the API also returns a short link of the form `/public/{slug}` (5 base62 characters). The CLI prints this as a `Short link:` line after the success line. Slugs are minted once on first publish and persist forever — even if the version is later made private and re-published, the same slug works again.

## Workflow recipes

**Use a prompt:** `npx @addorimprove/prompt ls -q <term> --json` → pick the id →
`npx @addorimprove/prompt view <id> --json` → use `latest.content`.

**Improve from feedback:** `npx @addorimprove/prompt view <id> --json` to find the
version with the highest `commentCount` →
`npx @addorimprove/prompt comments <id> <label> --json` (already sorted) → write an
improved body to a file addressing the unresolved comments →
`npx @addorimprove/prompt iterate <id> --parent <label> -f draft.md -y --json`.

**New prompt:** write the body to a file →
`npx @addorimprove/prompt new --name "<name>" -f draft.md -y --json`.

## Errors

Commands print a message and set a non-zero exit code:

| Exit / status | Meaning | Usual cause |
|---------------|---------|-------------|
| `Not logged in` (4) | No/invalid key | Tell the user to run `npx @addorimprove/prompt login` |
| 400 | Validation | Missing/invalid field, or bad `--format` |
| 404 | Not found / not yours | Wrong `id`/`label`, or it belongs to another user (every call is key-scoped) |
| 409 | Label conflict | `--parent` already has that next version |

- Branch labels use a dot segment: a branch off `1-2` is `1-2.1-1`, **not** `1-2-1`.
- `--parent` / `<parentLabel>` must be an existing label on that doc.

## Guardrail

Confirm with the user before any write (`new` / `iterate` / `branch` / `visibility`) —
describe what you'll create or change, then run with `-y`. Comments are read-only
through this CLI.
