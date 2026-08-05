# Workflows

## Find and read a Document

```bash
bash "$SKILL_DIR/scripts/ls.sh" -q "<term>"
bash "$SKILL_DIR/scripts/view.sh" <documentId>
bash "$SKILL_DIR/scripts/view.sh" <documentId> <snapshotLabel>
```

A Versioning-Off Document has current state/revision, not a snapshot label.

## Organize Folders and Documents

Folders are only organizational containers.

```bash
bash "$SKILL_DIR/scripts/folders.sh"
bash "$SKILL_DIR/scripts/folders.sh" ls --parent <folderId>
```

After approval:

```bash
bash "$SKILL_DIR/scripts/folders.sh" create "Ideas"
bash "$SKILL_DIR/scripts/folders.sh" create "Drafts" --parent <folderId>
bash "$SKILL_DIR/scripts/move-doc.sh" <documentId> --folder <folderId>
bash "$SKILL_DIR/scripts/move-doc.sh" <documentId> --folder root
bash "$SKILL_DIR/scripts/folders.sh" delete <emptyFolderId>
```

Before a move, confirm the source Document id/name and destination Folder
id/path or root. Before deletion, confirm the Folder id/path and deletion intent.
Moving changes placement only; it does not create content or update a snapshot.

## Create a Document

1. Choose one kind: Markdown, MDX, HTML, Plain, or Files.
2. Choose Versioning On/Off; On is the default and mode is immutable.
3. Confirm root or the exact destination Folder.
4. Put the proposed source in a file and show it to the user.
5. Obtain approval, then run:

```bash
bash "$SKILL_DIR/scripts/new.sh" \
  --name "<name>" \
  --kind markdown|mdx|html|plain|files \
  [--versioning on|off] \
  [--folder <folderId|root>] \
  -f <source-file>
```

Versioning-On responses have a snapshot label/id. Versioning-Off responses have
`currentRevision` and must not have a label or snapshot id.

Legacy `--format mdx|html|plain|files` and deprecated `--project` remain usable,
but canonical workflows use `--kind` and `--folder`.

## Create or update a Files Document safely

### Selected text Files prepared by an agent

Stage under the current project's `./prompt/{id}/`:

```text
./prompt/{id}/
  files/
  bundle.md
```

```bash
bash "$SKILL_DIR/scripts/stage-files.sh" --id <id> [--name "<name>"] [--force] <file>...
```

Show the selected File list, bundle path, short preview/summary, and exact upload
command. Ask exactly:

```text
All good to upload ./prompt/{id}/bundle.md?
```

Only after approval:

```bash
bash "$SKILL_DIR/scripts/new.sh" --name "<name>" --kind files \
  [--versioning on|off] [--folder <folderId|root>] \
  -f ./prompt/{id}/bundle.md
```

Leave staging in place. Do not create `manifest.json` by default.

### Complete trees or binary Files

Markdown bundles are text-only. For binary content, empty Directories, or an
entire canonical tree, preview the complete Directory and use raw multipart:

```bash
npx @addorimprove/prompt new --name "<name>" --kind files \
  --files <directory> [--versioning on|off] [--folder <folderId|root>]
```

Versioning Off current replacement is CAS-guarded:

```bash
npx @addorimprove/prompt files push <documentId> \
  --files <directory> --expected-revision <loadedRevision>
```

Never retry a stale save by silently substituting a newer revision. Retain the
local staged work, refresh, reconcile, preview again, and obtain approval.

Logical pruning requires another explicit approval:

```bash
npx @addorimprove/prompt files delete <documentId> \
  --files <pruned-directory> --expected-revision <loadedRevision>
```

## Versioning-On iteration and branching

Only Versioning On has labels, iterate, and branch:

```bash
bash "$SKILL_DIR/scripts/iterate.sh" <id> --parent <label> -f <file>
bash "$SKILL_DIR/scripts/branch.sh" <id> <parentLabel> -f <file>
```

Read snapshot Comments before improving:

```bash
bash "$SKILL_DIR/scripts/comments.sh" <id> <label>
```

Versioning Off must not use these commands.

## Snapshot versus live-current Comments

Snapshot Comments stay attached to an exact label/snapshot. Live-current
Comments target a logical File and use revision CAS. Follow
`references/comments.md`; obtain approval before add, reply, resolve, or reopen.

## Publish or unpublish

### Frozen snapshot publication (Versioning On)

```bash
bash "$SKILL_DIR/scripts/visibility.sh" <id> <label> public
bash "$SKILL_DIR/scripts/visibility.sh" <id> <label> private
```

### Stable live publication (Versioning Off)

Read state:

```bash
bash "$SKILL_DIR/scripts/visibility.sh" <id> current
```

After approval:

```bash
bash "$SKILL_DIR/scripts/visibility.sh" <id> current public
bash "$SKILL_DIR/scripts/visibility.sh" <id> current private
```

The first live publish mints one stable slug. Unpublish reserves it; republish
reuses it. The link always resolves the latest committed current state and never
includes Comments or Scratchpad.

## Restore Files locally

Restore defaults under `.prompt/` and refuses overwrite:

```bash
npx @addorimprove/prompt restore-files <id> --version <label>
npx @addorimprove/prompt restore-bundle [bundle.md]
```

Use `--output` or `--force` only after explicit destination/overwrite approval.
