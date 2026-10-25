# Commands

Use **Folder** for organization, **Document** for content, and **Files** only for
the ordered-tree Document kind. Get approval before every write.

## Bundled scripts (preferred JSON path)

Run `bash "$SKILL_DIR/scripts/<script>" ...`.

| Goal | Command |
|---|---|
| Account | `whoami.sh` |
| List/search Documents | `ls.sh [-q <query>]` |
| Recent Documents | `recent.sh [-n <limit>]` |
| Read Document/latest snapshot | `view.sh <documentId>` |
| Read exact snapshot | `view.sh <documentId> <label>` |
| List Folder contents | `folders.sh [ls] [--parent <folderId>]` |
| Create Folder | `folders.sh create "<name>" [--parent <folderId>]` |
| Delete empty Folder | `folders.sh delete <folderId>` |
| Move Document | `move-doc.sh <documentId> --folder <folderId|root>` |
| Create Document | `new.sh --name "<name>" --kind markdown|mdx|html|plain|files [--versioning on|off] [--folder <id|root>] -f <file>` |
| Iterate snapshot | `iterate.sh <documentId> [--parent <label>] -f <file> [--format ...]` |
| Branch snapshot | `branch.sh <documentId> <parentLabel> -f <file> [--format ...]` |
| Snapshot Comments | `comments.sh <documentId> <label>` |
| Live Comments | `comments.sh <documentId> current [--path <logicalPath>]` |
| Add snapshot Comment | `comment-add.sh <id> <label> --body "<text>" [--path <path> [--start <n> --end <n> --quote "<text>" --context "<text>"]]` |
| Add live Comment | `comment-add.sh <id> current --path <path> --observed-revision <n> --body "<text>" [--start <n> --end <n> --quote "<text>" --context "<text>"]` |
| Reply snapshot | `comment-reply.sh <id> <label> <commentId> --body "<text>"` |
| Reply live | `comment-reply.sh <id> current <commentId> --expected-mutation-revision <n> --body "<text>"` |
| Resolve/reopen snapshot | `comment-resolve.sh <id> <label> <commentId> [--unresolve]` |
| Resolve/reopen live | `comment-resolve.sh <id> current <commentId> --expected-mutation-revision <n> [--reopen]` |
| Snapshot publication | `visibility.sh <id> <label> public|private` |
| Read live publication | `visibility.sh <id> current` |
| Change live publication | `visibility.sh <id> current public|private` |

`new.sh` retains `--format` and deprecated `--project` aliases. Omitted
`--versioning` still means On. Explicit `--folder root` sends `folderId:null`.

## Files staging and raw uploads

### Agent-prepared text Files

Stage selected text Files first:

```bash
bash "$SKILL_DIR/scripts/stage-files.sh" --id <staging-id> [--name "<name>"] [--force] <file>...
```

This writes `./prompt/<staging-id>/files/` and `bundle.md` but does not upload.
After showing the exact tree and bundle and receiving approval, create with:

```bash
bash "$SKILL_DIR/scripts/new.sh" --name "<name>" --kind files \
  [--versioning on|off] [--folder <id|root>] \
  -f ./prompt/<staging-id>/bundle.md
```

Versioning-On updates may use the existing `iterate.sh` / `branch.sh`
`--format files` compatibility path. Versioning Off has no iterate or branch.

### Complete/binary Files trees

Use the repository CLI so multipart bytes, canonical metadata, explicit order,
and empty Directories are preserved:

```bash
npx @addorimprove/prompt new --name "<name>" --kind files \
  --files <directory> [--versioning on|off] [--folder <id|root>]

npx @addorimprove/prompt files create "<name>" --files <directory> \
  [--versioning on|off] [--folder <id|root>]
npx @addorimprove/prompt files ls <documentId> [--snapshot <snapshotId>]
npx @addorimprove/prompt files pull <documentId> [--snapshot <snapshotId>] [--output <dir>]
npx @addorimprove/prompt files push <documentId> --files <directory> --expected-revision <n>
npx @addorimprove/prompt files delete <documentId> --files <pruned-directory> --expected-revision <n>
npx @addorimprove/prompt files snapshot <documentId> --files <directory> --parent <label> --intent iterate|branch
```

`files delete` publishes a confirmed pruned current tree and is destructive.
`files snapshot`, iterate, and branch require Versioning On.

## Other CLI utilities

```bash
# create an API key at https://addorimprove.com/settings/account
npx @addorimprove/prompt version --json
npx @addorimprove/prompt upgrade
npx @addorimprove/prompt folders [ls] [--parent <id>]
npx @addorimprove/prompt docs [ls] [-q <query>]
npx @addorimprove/prompt docs move <documentId> --folder <id|root>
npx @addorimprove/prompt bundle <dir> [--output <file>]
npx @addorimprove/prompt restore-bundle [bundle.md] [--output <dir>] [--force]
npx @addorimprove/prompt restore-files <id> [--version <label>] [--output <dir>] [--force]
```

Compatibility aliases remain: `projects`, `--project`, `--format`, `ls`, and
legacy bundle/restore commands. Their routes, JSON fields, and IDs are unchanged.
