# Comments

Comments are private discussion. They are never included in public output.
Agent-authored Comments appear with an **AI** badge. Get approval before adding,
replying, resolving, or reopening.

## Two targets

### Snapshot Comments — Versioning On

A snapshot Comment belongs to one exact immutable label/snapshot. Existing
commands and behavior remain unchanged:

```bash
bash "$SKILL_DIR/scripts/comments.sh" <documentId> <label>
bash "$SKILL_DIR/scripts/comment-add.sh" <documentId> <label> --body "<text>"
bash "$SKILL_DIR/scripts/comment-reply.sh" <documentId> <label> <commentId> --body "<text>"
bash "$SKILL_DIR/scripts/comment-resolve.sh" <documentId> <label> <commentId>
bash "$SKILL_DIR/scripts/comment-resolve.sh" <documentId> <label> <commentId> --unresolve
```

For a unified snapshot, a whole-File Comment identifies the logical File:

```bash
bash "$SKILL_DIR/scripts/comment-add.sh" <id> <label> \
  --path <logicalPath> --body "<text>"
```

A unified text-range Comment also supplies exact File-local offsets:

```bash
bash "$SKILL_DIR/scripts/comment-add.sh" <id> <label> \
  --path <logicalPath> --start <inclusiveOffset> --end <exclusiveOffset> \
  --quote "<exact snapshot source>" [--context "<surrounding text>"] \
  --body "<text>"
```

Legacy single-source snapshot `--quote` without `--path` remains supported.
Quotes match raw source, not rendered text. HTML legacy snapshots allow
whole-Document Comments only.

### Live-current Comments — Versioning Off

A live Comment belongs to the current Document/File, never a synthetic label or
snapshot. List all threads or one logical File:

```bash
bash "$SKILL_DIR/scripts/comments.sh" <documentId> current
bash "$SKILL_DIR/scripts/comments.sh" <documentId> current --path <logicalPath>
```

Add a whole-File thread using the revision that was actually read:

```bash
bash "$SKILL_DIR/scripts/comment-add.sh" <id> current \
  --path <logicalPath> \
  --observed-revision <currentRevision> \
  --body "<text>"
```

Add a text-range thread:

```bash
bash "$SKILL_DIR/scripts/comment-add.sh" <id> current \
  --path <logicalPath> \
  --observed-revision <currentRevision> \
  --start <inclusiveOffset> --end <exclusiveOffset> \
  --quote "<exact current source>" [--context "<surrounding text>"] \
  --body "<text>"
```

`--start` and `--end` must be supplied together. Binary Files support File-level
threads only; omit range and quote.

Replies and resolution use the thread's latest `mutationRevision`, not the
Document content revision:

```bash
bash "$SKILL_DIR/scripts/comment-reply.sh" <id> current <threadId> \
  --expected-mutation-revision <threadRevision> --body "<text>"

bash "$SKILL_DIR/scripts/comment-resolve.sh" <id> current <threadId> \
  --expected-mutation-revision <threadRevision>

bash "$SKILL_DIR/scripts/comment-resolve.sh" <id> current <threadId> \
  --expected-mutation-revision <threadRevision> --reopen
```

`--expected-comment-revision` is accepted as a compatibility alias for
`--expected-mutation-revision`. `--unresolve` remains the snapshot compatibility
spelling; canonical language is reopen.

## Conflict and anchoring rules

- `stale_comment` means current content or the thread changed. Do not guess or
  increment repeatedly; relist/refresh and reconcile before asking for approval
  to retry.
- On current content saves, attached text anchors are retained when exact,
  re-anchored only when unambiguous, marked `detached` when not recoverable, and
  marked `target-deleted` when their File was removed.
- Detached and target-deleted threads stay visible. Never silently delete or
  attach them to an ambiguous match.
- An explicit validated File rename can transfer a thread before re-anchoring.
- Replies have no independent content anchor.
