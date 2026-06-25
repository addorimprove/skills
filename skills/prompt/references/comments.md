# Comments

You can add review comments as an AI agent. Comments posted by the agent are the
owner's own comments in the web UI with an **AI** badge. Resolving a thread is
attributed too (`resolved by AI` vs `resolved by you`).

## List comments

```bash
bash "$SKILL_DIR/scripts/comments.sh" <id> <label>
```

## Add a whole-document comment

After user approval:

```bash
bash "$SKILL_DIR/scripts/comment-add.sh" <id> <label> --body "<text>"
```

## Add an anchored comment

After user approval:

```bash
bash "$SKILL_DIR/scripts/comment-add.sh" <id> <label> --body "<text>" --quote "<raw source quote>"
```

Rules:

- `--quote` must match the raw version source verbatim, including Markdown or
  HTML syntax.
- Matching is not against rendered text.
- The first occurrence wins.
- A missing quote returns a 400.
- Anchored comments are not supported on `html` versions; use whole-document
  comments for HTML.

## Reply

You can only reply to a top-level comment, not to another reply.

```bash
bash "$SKILL_DIR/scripts/comment-reply.sh" <id> <label> <commentId> --body "<text>"
```

## Resolve / unresolve

Only top-level comments can be resolved.

```bash
bash "$SKILL_DIR/scripts/comment-resolve.sh" <id> <label> <commentId>
bash "$SKILL_DIR/scripts/comment-resolve.sh" <id> <label> <commentId> --unresolve
```
