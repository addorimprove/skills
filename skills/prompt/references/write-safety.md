# Write safety rules

## Approval is mandatory

Get the user's explicit go-ahead before every write, including:

- creating a Folder or Document;
- moving a Document or deleting a Folder;
- creating a snapshot, iterating, or branching;
- publishing or unpublishing a snapshot or live-current Document;
- adding, replying to, resolving, or reopening Comments;
- staging/bundling local Files, uploading, restoring, overwriting, or pruning;
- any `--force`, `-y`, logical delete, or destination outside `.prompt/`.

Bundled scripts act immediately and do not prompt. `-y` may be used only after
approval. JSON output suppresses CLI previews and never counts as user review.

## Document bodies

Document/snapshot bodies come from `-f <file>`; Comment bodies use `--body`.
Show the exact proposed source/summary, Document id/name, Document kind,
Versioning mode, and destination Folder/root before creation.

Canonical creation:

```bash
bash "$SKILL_DIR/scripts/new.sh" --name "<name>" \
  --kind markdown|mdx|html|plain|files \
  [--versioning on|off] [--folder <id|root>] -f <file>
```

Versioning defaults On and cannot be changed later. Verify a Versioning-Off
response has `currentRevision` and no label/snapshot identity.

## Folder moves and deletion

Before a move, confirm:

- source Document id and name;
- current Folder/root when known;
- destination Folder id/path or root.

Before Folder deletion, confirm Folder id/path and intent. Deletion succeeds only
for an empty Folder but is still destructive.

## Files preview before upload

### Agent-prepared text bundle

Stage exact selected Files under:

```text
./prompt/{id}/
  files/
  bundle.md
```

Show:

- selected File list;
- `./prompt/{id}/bundle.md` path;
- short bundle preview/summary;
- exact upload command.

Ask exactly:

```text
All good to upload ./prompt/{id}/bundle.md?
```

Only then upload. Keep the staging Directory after upload. Do not create
`manifest.json` by default.

### Complete/binary Files tree

Markdown bundles are not binary-safe and cannot represent the canonical raw
upload contract. For binary Files, explicit empty Directories, or a complete
ordered tree:

1. stage/validate the entire Directory;
2. show the complete tree, primary File, mode, and Folder/root destination;
3. obtain approval;
4. use `prompt new --kind files --files` or `prompt files create`.

Never route binary through bundle text. Raw upload checks each byte count and
checksum and never exposes R2 keys.

## Versioning-Off current writes

`files push` and logical `files delete` require the editor-loaded
`--expected-revision`. On `stale_revision`, retain the local work, refresh,
reconcile, preview again, and ask before retrying. Never substitute the server's
new revision automatically.

Current Comment creation requires the observed content revision. Reply,
resolve, and reopen require the latest thread `mutationRevision`. On
`stale_comment`, relist and reconcile; do not blind-retry.

## Publication

Confirm exact target and resulting behavior:

- snapshot target `<label>` freezes one immutable snapshot;
- target `current` is a stable live slug to latest committed Versioning-Off
  content;
- unpublish reserves either existing slug for reuse;
- Comments and Scratchpad remain private.

## Restore/download safety

Restore commands:

- default under `.prompt/`;
- preview every output File;
- reject absolute/traversal paths and symlink escapes;
- refuse overwrite unless `--force` is explicitly approved;
- write elsewhere only when the user explicitly supplies `--output <dir>`.

Local `bundle`, `stage-files`, restore, and overwrite are writes too; approval
still applies even though they do not mutate the remote app.

## Legacy aliases

`projects`, `--project`, `--format`, `--unresolve`, and legacy bundle workflows
remain supported. Approval and preview rules are identical when aliases are
used; compatibility names do not change durable IDs or JSON fields.
