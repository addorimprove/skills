# Write safety rules

## Human approval before writes

Get the user's go-ahead in chat before any write:

- `new.sh`
- `iterate.sh`
- `branch.sh`
- `visibility.sh`
- `comment-add.sh`
- `comment-reply.sh`
- `comment-resolve.sh`
- CLI write commands such as `prompt restore-bundle`
- Any use of `prompt restore-bundle --force`

Bundled scripts do not prompt. They act immediately.

## Write bodies

Document/version bodies (`new.sh`, `iterate.sh`, `branch.sh`) always come from `-f <file>`. Comment bodies use `--body <text>`.

Recommended document/version flow:

1. Write the proposed body to a temp file.
2. Tell the user what will be written.
3. After approval, pass the file to the script.

Example:

```bash
tmp="$(mktemp)"
printf '%s\n' "# Draft" > "$tmp"
bash "$SKILL_DIR/scripts/new.sh" --name "Draft" -f "$tmp"
```

## Upload/download previews

The CLI shows folder-style file previews before file transfer actions:

- `prompt restore-bundle ... --output <dir>` shows `Files to download:` and asks
  for confirmation before writing files. It rejects paths outside the output
  folder such as `/tmp/file` or `../file`, and refuses to overwrite existing
  files by default. Use `--force` and/or `-y` only after explicit user approval.
- `prompt new -f`, `prompt iterate -f`, and `prompt branch -f` show
  `Files to upload:` before sending file content.

Previews are omitted under `--json` so scripts can parse the JSON output.

## Format choice

- `mdx` means Markdown in this app; JSX and expressions are unsupported.
- `html` stores sanitized HTML.
- `plain` renders source verbatim in a `<pre>` and is best for code, logs, or any
  content where Markdown interpretation would be wrong.

Plain is opt-in only. Auto-detection only chooses `mdx` or `html`.
