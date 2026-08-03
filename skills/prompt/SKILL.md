---
name: prompt
description: Use when the user wants to add, improve, fix, or get a prompt — or otherwise fetch, search, read, create, iterate, branch, publish, restore files, or comment on prompts/documents in the markdown-notes app (markdown-notes-ten.vercel.app). Prefer bundled scripts for API reads/writes; use the published `prompt` CLI for login, version/upgrade, and local files workflows.
compatibility: "Requires @addorimprove/prompt CLI with legacy bundle/folder support plus raw Project → Folder workflows: projects alias, --project alias, files create|ls|pull|push|delete|snapshot, and mode-aware versioning. Legacy folders/docs/--folder/documentId meanings remain unchanged. Check with `npx @addorimprove/prompt version --json`; if too old, run `npx @addorimprove/prompt upgrade` or use the repo-local development CLI."
---

# Prompt

Work with prompts/documents, versions, visibility, and comments in the
markdown-notes app.

## Routing

- **Default path:** use bundled scripts in `scripts/` for document reads/writes
  and folder organization reads/writes. For files-format uploads, stage selected
  files under `./prompt/{id}/` and upload `bundle.md` with `--format files` only
  after approval.
- **CLI commands:** use `npx @addorimprove/prompt` for `login`, `version`,
  `upgrade`, legacy `bundle`/`stage-files`/`restore-bundle`/`restore-files`, and raw complete-tree `files` workflows. `prompt folders` and `prompt docs` retain their v1 meanings (Projects and Folders respectively); `prompt projects` and `--project` are additive aliases only.
- **Write safety rule:** get the user's go-ahead in chat before any write; files
  uploads require staged preview before upload. For folder moves/deletes, confirm
  the source document or folder and destination folder/root first.

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
- `references/commands.md` — bundled script inventory, folder commands, and CLI utilities.
- `references/write-safety.md` — write approvals, upload/download previews, JSON output.
- `references/workflows.md` — common list/read/create/improve recipes.
- `references/comments.md` — comment anchoring, replies, resolve behavior.
- `references/version-labels.md` — version and branch label model.
- `references/best-practices-applied.md` — skill packaging decisions.

## Gotchas

- Scripts print JSON and do not prompt. Treat write scripts as immediate actions.
- Document/version bodies come from `-f <file>`; create a temp file first. Comment bodies use `--body`.
- Use `--format plain` for code/logs where markdown rendering would be wrong.
- Use `--format files` with `-f ./prompt/{id}/bundle.md` for staged files-format uploads. Direct CLI `--files <dir>` upload is for explicit/ad hoc folder uploads.
- Files upload staging writes under `./prompt/{id}/` and stays there after upload. Local restore/download writes default under `.prompt/`; do not write restored files elsewhere unless the user explicitly supplies `--output <dir>`.
- For canonical raw Folder trees (including binary), use `prompt files create --files <dir>` or `files push`; stage/validate the complete tree first. `files pull`/`export` materializes canonical `meta.yml` and streams raw bytes. Never route binary through Markdown bundle code. `files delete` is logical pruning and requires an explicit confirmation.
- Folder-style previews are omitted under `--json` so scripts can parse the JSON output.
- `restore-bundle` and `restore-files` preview files, ask for confirmation, and refuse to overwrite existing files unless `--force` is used.
