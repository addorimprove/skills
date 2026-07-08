# Workflows

## Use an existing prompt

1. Search:
   ```bash
   bash "$SKILL_DIR/scripts/ls.sh" -q "<term>"
   ```
2. Pick the document id.
3. Read the latest content:
   ```bash
   bash "$SKILL_DIR/scripts/view.sh" <id>
   ```
4. Use `latest.content` from the JSON response.

## Read a specific version

```bash
bash "$SKILL_DIR/scripts/view.sh" <id> <label>
```

## Create a new prompt

1. Draft content in a temp file.
2. If creating inside a folder, list/confirm the destination folder id/path first.
3. Get user approval.
4. Run:
   ```bash
   bash "$SKILL_DIR/scripts/new.sh" --name "<name>" [--folder <folderId>] -f <file> [--format mdx|html|plain]
   ```

## Folder organization

List root folders and documents:

```bash
bash "$SKILL_DIR/scripts/folders.sh"
```

List a nested folder's contents:

```bash
bash "$SKILL_DIR/scripts/folders.sh" ls --parent 123
```

Create folders after approval:

```bash
bash "$SKILL_DIR/scripts/folders.sh" create "Ideas"
bash "$SKILL_DIR/scripts/folders.sh" create "Drafts" --parent 123
```

Create a new prompt/document in a folder:

```bash
bash "$SKILL_DIR/scripts/new.sh" --name "Spec" --folder 123 -f ./spec.md
```

Move an existing prompt/document after confirming the source document id/name and
destination folder id/path:

```bash
bash "$SKILL_DIR/scripts/move-doc.sh" 456 --folder 123
```

Move a document back to root:

```bash
bash "$SKILL_DIR/scripts/move-doc.sh" 456 --folder root
```

Delete an empty folder only after confirming the folder id/path and that deletion
is intended:

```bash
bash "$SKILL_DIR/scripts/folders.sh" delete 123
```

Safety notes:

- Folder delete is destructive but only succeeds when the folder is empty.
- Moving a document changes organization only; versions/content are unchanged.
- Before any folder write, preview the intended target and get user approval.
- For `move-doc.sh`, confirm source document id/name and destination folder id/path.
- For `folders.sh delete`, confirm folder id/path and deletion intent.

## Create or update a files-format prompt from selected files

Use this staged workflow when an agent prepares a files-format prompt/document.
The goal is to create the exact upload payload locally, show it to the user, and
upload only after explicit approval.

Staging lives in `./prompt/{id}/` in the current project working directory:

```text
./prompt/{id}/
  files/
  bundle.md
```

ID convention:

- Existing document/version workflows: use the server document id, for example
  `./prompt/49/`.
- New document workflows before a server id exists: use a local staging id, for
  example `./prompt/new-refactoring-guru-scraper/`.
- Staging ids must start with a letter or digit and contain only letters,
  digits, dots, underscores, and hyphens.
- After upload, leave the staging directory as-is. Optionally copy/rename it to
  the returned server doc id, but do not remove it.

Required files only:

- `files/` contains the selected files exactly as they will be bundled,
  preserving relative paths.
- `bundle.md` contains the exact files-format upload payload.
- Do not create `manifest.json` by default.

Canonical `bundle.md` structure:

````md
<!-- FILE-TREE -->
```yaml
- README.md
- pyproject.toml
- scrape_refactoring_guru.py
```

<!-- FILE-CONTENT: README.md -->
~~~~md
...
~~~~
````

Workflow:

1. Select the minimum files needed for the prompt/document.
2. Create `./prompt/{id}/files/` and copy selected files into it, preserving
   relative paths.
3. Generate `./prompt/{id}/bundle.md` in the canonical structure above.
   Prefer the local preview-only skill helper:
   ```bash
   bash "$SKILL_DIR/scripts/stage-files.sh" --id <id> [--name "<name>"] [--force] <file>...
   ```
   CLI equivalent for humans or non-skill contexts:
   ```bash
   npx @addorimprove/prompt stage-files --id <id> [--name "<name>"] [--force] <file>...
   ```
4. Show the user:
   - selected file list
   - bundle path
   - short bundle preview or summary
   - exact upload command
5. Ask exactly:
   ```text
   All good to upload ./prompt/{id}/bundle.md?
   ```
6. Upload only after approval.

New document upload:

```bash
bash "$SKILL_DIR/scripts/new.sh" \
  --name "<name>" \
  [--folder <folderId>] \
  -f ./prompt/{id}/bundle.md \
  --format files
```

Iterate an existing files-format document:

```bash
bash "$SKILL_DIR/scripts/iterate.sh" <id> --parent <label> \
  -f ./prompt/<id>/bundle.md \
  --format files
```

Branch an existing files-format document:

```bash
bash "$SKILL_DIR/scripts/branch.sh" <id> <parentLabel> \
  -f ./prompt/<id>/bundle.md \
  --format files
```

## Improve from feedback

1. Read the doc tree:
   ```bash
   bash "$SKILL_DIR/scripts/view.sh" <id>
   ```
2. Choose the version to improve, often the version with the highest unresolved
   or relevant `commentCount`.
3. Read comments:
   ```bash
   bash "$SKILL_DIR/scripts/comments.sh" <id> <label>
   ```
4. Draft improved content in a temp file.
5. Get user approval.
6. Iterate from the chosen parent:
   ```bash
   bash "$SKILL_DIR/scripts/iterate.sh" <id> --parent <label> -f <file>
   ```

If `--parent` is omitted, `iterate.sh` defaults to the document's latest label.

## Branch a new direction

Use `branch` when the new version should fork from an existing version rather
than continue the same line:

```bash
bash "$SKILL_DIR/scripts/branch.sh" <id> <parentLabel> -f <file>
```

## Direct files-format folder workflows (fallback)

Prefer the staged selected-files workflow above for agent-prepared uploads. Use
these direct folder commands only when the user explicitly wants to upload an
entire folder without a persistent `./prompt/{id}/bundle.md` staging preview.
The CLI previews the file tree before upload, and restore commands default local
writes under `.prompt/`.

Create a files prompt directly from a folder:

```bash
npx @addorimprove/prompt new --name "Spec" [--folder 123] --files ./spec
```

Update a files prompt directly from a changed folder:

```bash
npx @addorimprove/prompt iterate <id> --parent <label> --files ./spec
```

Branch a files prompt directly from a folder:

```bash
npx @addorimprove/prompt branch <id> --parent <label> --files ./spec
```

Restore a files version locally. Without `--output`, files are written to
`.prompt/<id>/<label>/`:

```bash
npx @addorimprove/prompt restore-files <id> --version <label>
```

Only restore outside `.prompt/` when the user explicitly asks for a destination:

```bash
npx @addorimprove/prompt restore-files <id> --version <label> --output ./spec
```

Use `--force` only after explicit overwrite approval.

## Publish or unpublish

After user approval:

```bash
bash "$SKILL_DIR/scripts/visibility.sh" <id> <label> public
bash "$SKILL_DIR/scripts/visibility.sh" <id> <label> private
```

When public, the response includes `/public/{slug}` when available. Slugs are
minted once on first publish and persist even after unpublish/re-publish.

## Build a shareable owner/doc/version URL

Use the `whoami` id:

```text
$MD_PROMPT_BASE_URL/<userId>/<docId>/<label>
```
