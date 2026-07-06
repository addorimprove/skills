---
name: prompt
description: Use when the user wants to add, improve, fix, or get a prompt — or otherwise fetch, search, read, create, iterate, branch, publish, restore files, or comment on prompts/documents in the markdown-notes app (addorimprove.com). Prefer bundled scripts for API reads/writes; use the published `prompt` CLI for login, version/upgrade, and local files workflows.
compatibility: "Requires @addorimprove/prompt CLI with files workflow support: bundle, restore-files, and --files upload flags. Check with `npx @addorimprove/prompt version --json`; if too old, run `npx @addorimprove/prompt upgrade` or use the repo-local development CLI."
---

# Prompt

Work with prompts/documents, versions, visibility, and comments in the
markdown-notes app.

## Routing

- **Default path:** use bundled scripts in `scripts/` for document reads/writes.
- **CLI-only commands:** use `npx @addorimprove/prompt` for `login`, `version`,
  `upgrade`, `bundle`, `restore-bundle`, `restore-files`, and folder-based
  `--files` upload workflows.
- **Write safety rule:** get the user's go-ahead in chat before any write.

## Quick start

1. Set `SKILL_DIR` to this installed skill directory.
2. Check login state with:
   ```bash
   bash "$SKILL_DIR/scripts/whoami.sh"
   ```
3. If not logged in, ask the user to run:
   ```bash
   npx @addorimprove/prompt login
   ```
4. Pick the command from `references/commands.md`.
5. For writes, follow `references/write-safety.md` before running the command.

## Reference map

Read only the file needed for the task:

- `references/setup.md` — login, target environment, script execution rules.
- `references/commands.md` — bundled script inventory and CLI-only utilities.
- `references/write-safety.md` — write approvals, upload/download previews, JSON output.
- `references/workflows.md` — common list/read/create/improve recipes.
- `references/comments.md` — comment anchoring, replies, resolve behavior.
- `references/version-labels.md` — version and branch label model.
- `references/best-practices-applied.md` — skill packaging decisions.

## Gotchas

- Scripts print JSON and do not prompt. Treat write scripts as immediate actions.
- Document/version bodies come from `-f <file>`; create a temp file first. Comment bodies use `--body`.
- Use `--format plain` for code/logs where markdown rendering would be wrong; use `--format files` or CLI `--files <dir>` for ordered file/folder prompt bundles.
- Local restore/download writes default under `.prompt/`; do not write elsewhere unless the user explicitly supplies `--output <dir>`.
- Folder-style previews are omitted under `--json` so scripts can parse the JSON output.
- `restore-bundle` and `restore-files` preview files, ask for confirmation, and refuse to overwrite existing files unless `--force` is used.
