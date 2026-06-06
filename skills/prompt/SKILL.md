---
name: prompt
description: Use when the user wants to add, improve, fix, or get a prompt — or otherwise fetch, search, read, create, or iterate prompts/documents and their versions, or read/add/reply/resolve comments in the markdown-notes app (addorimprove.com). Triggers on phrasings like "add prompt", "improve prompt", "fix prompt", "get prompt". Driven by bundled scripts (preferred) with the published `prompt` CLI as fallback.
---

# Prompt

Read and write prompts (documents), versions, and comments in the markdown-notes
app. **Prefer the bundled scripts in this skill's `scripts/` directory** — they
call the REST API directly (curl + jq) with no `npx` round-trip. The published
`npx @addorimprove/prompt` CLI remains a **fallback**, and is the **only** way to
`login` (and to self-update via `version`/`upgrade`).

Run scripts by absolute path, e.g.:
`bash ~/.claude/skills/prompt/scripts/view.sh <id>`
(Use the path where this skill is installed; from a repo checkout it is
`skills/prompt/scripts/…`.) `curl` is required. `jq` is preferred (used to read
the credential and slice JSON) but not strictly necessary — if it's missing,
install it (`brew install jq`) or read the raw API JSON the scripts print and
parse it yourself.

## Setup

- **Auth.** Scripts and CLI share one stored `mdnp_…` key. Check state with
  `scripts/whoami.sh` (prints `{ id, name, email }`). If anything prints
  `Not logged in`, ask the **user** to run `npx @addorimprove/prompt login` — an
  interactive browser (PKCE) login you can't perform yourself. It saves the key to
  `~/.config/prompt/config.json`. `MD_PROMPT_API_KEY` overrides the file if set.
- **Target.** Defaults to prod (`https://addorimprove.com`). Override with
  `MD_PROMPT_BASE_URL` (e.g. `http://localhost:3000`) or a `--base-url <url>` flag
  on any script.
- **Output is JSON.** Every script prints the API's JSON payload to stdout; pipe to
  `jq` as needed.

## Guardrail

Get the user's go-ahead in chat before any **write** (new / iterate / branch /
visibility / comment writes). The scripts do not prompt — they act immediately.

## Version label model

- `1-1` is the bootstrap version. `iterate` makes the next version on the same line
  (`1-1` → `1-2` → `1-3`). `branch` forks a new line from a version by appending a
  dot-segment: the first branch off `1-2` is `1-2.1-1`, the second is `1-2.2-1` (so a
  branch off `1-1` is `1-1.1-1`).

## Scripts (preferred)

| Goal | Script |
|------|--------|
| Who am I | `whoami.sh` → `{ id, name, email }` |
| What was I working on | `recent.sh [-n <limit>]` → activity array (most-recent-first, one row per doc; `action` ∈ visit/create/iterate/branch/publish/unpublish/comment; each has a ready-to-open `url`) |
| List / search docs | `ls.sh [-q <query>]` → docs array (`{ id, name, openCommentCount, … }`) |
| Doc tree + latest content | `view.sh <id>` → `{ id, name, versions:[…], latest:{label,content} }` |
| One version's content | `view.sh <id> <label>` → `{ label, content, format, … }` |
| A version's comments | `comments.sh <id> <label>` → comments array (pre-sorted) |
| Add a comment | `comment-add.sh <id> <label> --body "<text>" [--quote "<text>"]` → `{ id }` |
| Reply to a comment | `comment-reply.sh <id> <label> <commentId> --body "<text>"` → `{ id }` |
| Resolve / un-resolve | `comment-resolve.sh <id> <label> <commentId> [--unresolve]` → `{ id, resolved }` |
| Create a doc | `new.sh --name "<name>" -f <file> [--format mdx\|html\|plain]` → `{ id, label:"1-1" }` |
| Add on same line | `iterate.sh <id> [--parent <label>] -f <file> [--format]` → `{ label }` |
| Fork a new line | `branch.sh <id> <parentLabel> -f <file> [--format]` → `{ label }` |
| Change visibility | `visibility.sh <id> <label> public\|private` → `{ label, isPublic, publicSlug, publicUrl }` |

- **Write bodies always come from `-f <file>`** — write the content to a temp file
  first, then pass it. Scripts never open `$EDITOR` and never need a `-y` confirm.
- `iterate` defaults `--parent` to the doc's latest label if omitted.
- `--format` is `mdx` (default), `html`, or `plain`. `plain` renders source verbatim
  in a `<pre>` (HTML-escaped, monospace, whitespace preserved) — use it for code
  snippets, logs, or anything where markdown/HTML interpretation would be wrong.
  Plain is opt-in only; auto-detection only ever picks `mdx` or `html`.
- Build a shareable link from the `whoami` id:
  `$MD_PROMPT_BASE_URL/<id>/<docId>/<label>`.
- When a version is made public, the response includes a short link `/public/{slug}`
  (5 base62 chars). Slugs are minted once on first publish and persist forever — even
  if later made private and re-published, the same slug works again.

### Commenting

You can **add review comments as an AI agent**. Comments you post are the owner's
own comments, shown in the web UI with an **AI** badge; resolving a thread is
attributed too (`resolved by AI` vs `resolved by you`).

- `comment-add.sh` posts a top-level comment. Omit `--quote` for a whole-document
  comment. Pass `--quote "<text>"` to anchor it to a span — the quote must match the
  **raw version source verbatim**, including any markdown/HTML syntax (it is *not*
  matched against rendered text); the first occurrence wins. A quote not found in the
  source is a 400. Anchored comments are **not** supported on `html` versions
  (whole-document only).
- `comment-reply.sh` posts into an existing thread; you can only reply to a
  top-level comment, not to another reply.
- `comment-resolve.sh` sets resolved state (idempotent); `--unresolve` re-opens.
  Only top-level comments can be resolved.

## Workflow recipes

**Use a prompt:** `ls.sh -q <term>` → pick the id → `view.sh <id>` → use
`latest.content`.

**Improve from feedback:** `view.sh <id>` to find the version with the highest
`commentCount` → `comments.sh <id> <label>` (already sorted) → write an improved
body to a temp file addressing the unresolved comments →
`iterate.sh <id> --parent <label> -f draft.md`.

## CLI fallback

If a script is unavailable or you need `login`, use the published CLI:
`npx @addorimprove/prompt <command> --json`. Same auth, same API. The CLI's
write commands additionally need `-f <file>` (to avoid opening `$EDITOR`) and `-y`
(to skip its stdin confirm prompt). Self-update with
`npx @addorimprove/prompt upgrade`; check freshness with
`npx @addorimprove/prompt version --json`. After updating the CLI/skill, refresh
this skill doc with `npx skills add addorimprove/skills`.
