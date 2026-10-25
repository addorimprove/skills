---
name: prompt
description: Use when the user wants to add, improve, fix, or get a prompt — or otherwise fetch, search, read, create, iterate, branch, publish, restore files, organize Folders, or comment on Documents in the addorimprove.com app. Prefer bundled scripts for API reads/writes; binary or complete Files trees go through the hosted MCP server or the web app.
compatibility: "Requires curl, jq, and an addorimprove.com API key (MD_PROMPT_API_KEY)."
---

# Prompt

Work with organizational **Folders** and content-bearing **Documents** in the
addorimprove.com app. A Document may be at root (no Folder) or inside a Folder.

## Product model

- **Folder:** optional, nestable organizational container. It has no content,
  Versioning, Comments, Scratchpad, or publication.
- **Document:** content-bearing item. `ls.sh` lists Documents and
  `new.sh` creates one.
- **Document kinds:** **Markdown**, **MDX**, **HTML**, **Plain**, and **Files**.
  Files is a Document kind containing an ordered File/Directory tree; it is not
  an organizational Folder.
- **Versioning On:** saves immutable snapshots; labels, iterate, branch,
  snapshot Comments, and frozen snapshot publication are available.
- **Versioning Off:** one CAS-guarded live current state; no snapshots, labels,
  iterate, or branch. Private live-current Comments and a stable live public
  slug remain available.

## Routing

- Prefer bundled scripts in `scripts/` for JSON reads and writes.
- For agent-prepared text Files, stage the exact selected payload under
  `./prompt/{id}/` and preview it before upload.
- For binary or complete canonical trees, use the hosted MCP server (`https://addorimprove.com/api/mcp`) or the web app;
  never pass binary through a Markdown bundle.

## Write safety

Get the user's explicit go-ahead before **every** remote or local write,
including creation, moves, deletion, iterate/branch, publication, Comments,
uploads, restore, overwrite, and pruning. Bundled scripts execute immediately.
Files uploads require an exact staged tree/bundle preview first. Read
`references/write-safety.md` before writing.

## Quick start

1. Set `SKILL_DIR` to this skill directory.
2. Check auth:
   ```bash
   bash "$SKILL_DIR/scripts/whoami.sh"
   ```
3. If not logged in, ask the user to create an API key at
   https://addorimprove.com/settings/account and set `MD_PROMPT_API_KEY`.
4. Choose a command from `references/commands.md`.
5. Get approval before any write.

## Reference map

- `references/setup.md` — login, target environment, script rules.
- `references/commands.md` — script command contracts.
- `references/workflows.md` — Folder, Document, Files, and publication flows.
- `references/comments.md` — snapshot versus live-current Comments and CAS.
- `references/write-safety.md` — approval and upload/restore safety.
- `references/version-labels.md` — Versioning-On snapshot labels.
- `references/best-practices-applied.md` — packaging decisions.

## Compatibility aliases

Keep these only for compatibility; do not use their retired language in normal
explanations:

- `prompt projects` aliases organizational `prompt folders`.
- `--project <id|root>` aliases Document placement `--folder <id|root>`.
- `--format mdx|html|plain|files` aliases the older content classifier where
  possible; canonical creation uses `--kind` and includes Markdown explicitly.
- Existing v1 routes and JSON fields such as `folderId`, `projectId`, and
  `documentId` retain their exact IDs and meanings.
- `prompt ls`, legacy bundle commands, snapshot labels, and snapshot Comment /
  visibility command shapes remain supported.

## Gotchas

- Versioning defaults **On**. Mode cannot be changed after creation.
- Versioning Off must never be represented by a fake label or snapshot id.
- Snapshot Comments target one exact snapshot. Live-current Comments target a
  logical File and require observed content/thread revisions.
- Unpublishing a live Document reserves its slug; republishing reuses it.
- Scripts print JSON and do not prompt; JSON output is not a substitute for
  showing the user the staged upload.
