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
2. Get user approval.
3. Run:
   ```bash
   bash "$SKILL_DIR/scripts/new.sh" --name "<name>" -f <file> [--format mdx|html|plain]
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

## Files-format folder workflows

Use the CLI when local folders are involved. These workflows preview the file tree
and default local writes under `.prompt/`.

Create a files prompt from a folder:

```bash
npx @addorimprove/prompt new --name "Spec" --files ./spec
```

Update a files prompt from a changed folder:

```bash
npx @addorimprove/prompt iterate <id> --parent <label> --files ./spec
```

Branch a files prompt from a folder:

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
