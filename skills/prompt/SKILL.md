---
name: prompt
description: Use when the user wants to fetch, search, read, create, or iterate prompts/documents and their versions, or to read/add/reply/resolve comments in the markdown-notes app (addorimprove.com). Driven by the published `prompt` CLI (npx @addorimprove/prompt).
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
- **Target.** Defaults to prod (`https://addorimprove.com`). Override with
  `--base-url <url>` or `MD_PROMPT_BASE_URL` (e.g. `http://localhost:3000`).
- **Where to run.** From the project root (or any dir) — but **not** from a
  checkout's own `cli/` folder (npx then fails with `prompt: command not found`).
- **Parse output with `--json`.** Every read/write command below takes `--json`
  and prints structured JSON; prefer it over the human format when acting on
  results. (Requires CLI ≥ 0.1.2 for `whoami --json`.)

## Non-interactive rules (you are not at a TTY)

- **Always pass `-f <file>`** to `new` / `iterate` / `branch`. Without it the CLI
  opens `$EDITOR` and hangs. Write the body to a temp file first, then pass it.
- **Always pass `-y`** to `new` / `iterate` / `branch` / `visibility` writes. Without
  it the CLI waits on a stdin `[y/N]` prompt you can't answer. (Get the user's
  go-ahead in chat first — see Guardrail.) The `comment add` / `reply` / `resolve`
  writes never prompt, so they don't need `-y`.

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
| A version's comments | `npx @addorimprove/prompt comment list <id> <label> --json` (pre-sorted; `comments <id> <label>` is an alias) |
| Add a comment | `npx @addorimprove/prompt comment add <id> <label> --body "<text>" [--quote "<text>"] --json` → `{ id }` |
| Reply to a comment | `npx @addorimprove/prompt comment reply <id> <label> <commentId> --body "<text>" --json` → `{ id }` |
| Resolve / un-resolve | `npx @addorimprove/prompt comment resolve <id> <label> <commentId> [--unresolve] --json` → `{ id, resolved }` |
| Create a doc | `npx @addorimprove/prompt new --name "<name>" -f <file> [--format mdx\|html\|plain] -y --json` → `{ id, label:"1-1" }` |
| Add on same line | `npx @addorimprove/prompt iterate <id> [--parent <label>] -f <file> [--format] -y --json` → `{ label }` |
| Fork a new line | `npx @addorimprove/prompt branch <id> <parentLabel> -f <file> [--format] -y --json` → `{ label }` |
| Change visibility | `npx @addorimprove/prompt visibility <id> <label> public\|private -y --json` → `{ label, isPublic, publicSlug, publicUrl }` |

- `iterate` defaults `--parent` to the doc's latest label if omitted.
- `--format` is `mdx` (default), `html`, or `plain`. `plain` renders source verbatim in a `<pre>` (HTML-escaped, monospace, whitespace preserved) — use it for code snippets, logs, or anything where markdown/HTML interpretation would be wrong. Plain is opt-in only; auto-detection only ever picks `mdx` or `html`.
- Build a shareable link from the `whoami` id: `$MD_PROMPT_BASE_URL/<id>/<docId>/<label>`.
- When a version is made public, the API also returns a short link of the form `/public/{slug}` (5 base62 characters). The CLI prints this as a `Short link:` line after the success line. Slugs are minted once on first publish and persist forever — even if the version is later made private and re-published, the same slug works again.

### Commenting (CLI ≥ 0.6.0)

You can **add review comments as an AI agent**. Comments you post are the owner's
own comments, shown in the web UI with an **AI** badge so the owner can tell them
apart; resolving a thread is attributed too (`resolved by AI` vs `resolved by you`).

- **`comment add`** posts a top-level comment. Omit `--quote` for a whole-document
  comment. Pass `--quote "<text>"` to anchor it to a span — the quote must match the
  **raw version source verbatim**, including any markdown/HTML syntax (it is *not*
  matched against rendered text); the first occurrence wins. A quote not found in the
  source is a 400. Anchored comments are **not** supported on `html` versions
  (whole-document only) — anchoring an html version is a 400.
- **`comment reply`** posts into an existing thread; you can only reply to a
  top-level comment, not to another reply.
- **`comment resolve`** sets resolved state explicitly (idempotent); `--unresolve`
  re-opens. Only top-level comments can be resolved.
- These comment writes **do not prompt** for confirmation and don't need `-f`/`-y` —
  pass everything as flags (see the Guardrail note about getting the user's go-ahead).

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

**Review a version (add comments):** `npx @addorimprove/prompt view <id> <label> --json`
to read the raw `content` → for each issue, `comment add <id> <label> --body "<note>"
--quote "<exact raw substring>"` (omit `--quote` for an overall note) → optionally
`comment reply` into a thread, or `comment resolve <id> <label> <commentId>` once
addressed. Use `comment list <id> <label> --json` to see existing threads
(`authorKind`, `resolved`, `resolvedBy`, `snippet`, `replies`) before commenting.

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
describe what you'll create or change, then run with `-y`. The `comment add` /
`reply` / `resolve` writes don't take `-y` (they never prompt), but the same rule
applies: get the user's go-ahead before posting or resolving comments on their behalf.
