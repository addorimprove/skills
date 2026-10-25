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

Markdown bundles are text-only. Upload binary content, empty Directories, or an
entire canonical tree through the hosted MCP server (`https://addorimprove.com/api/mcp`) or the web app.
