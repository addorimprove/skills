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
- CLI write commands such as `prompt bundle`, `prompt new --files`, `prompt iterate --files`, `prompt branch --files`, `prompt restore-bundle`, and `prompt restore-files`
- Any use of `prompt restore-bundle --force` or `prompt restore-files --force`

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

## Files-format preview-before-upload rule

For files-format uploads prepared by an agent, do not upload directly from a
loose folder by default. First stage the exact payload under `./prompt/{id}/` in
the current project working directory:

```text
./prompt/{id}/
  files/
  bundle.md
```

Before any upload, show the user:

- selected file list
- `./prompt/{id}/bundle.md` path
- short bundle preview or summary
- exact upload command using `-f ./prompt/{id}/bundle.md --format files`

Then ask exactly:

```text
All good to upload ./prompt/{id}/bundle.md?
```

Only upload after approval. Leave `./prompt/{id}/` in place after upload. Do not
create `manifest.json` by default.

## Upload/download previews

The CLI shows folder-style file previews before file transfer actions:

- `prompt restore-bundle ...` and `prompt restore-files ...` show `Files to download:` and ask
  for confirmation before writing files. Without `--output`, they write under `.prompt/`.
  They reject paths outside the output folder such as `/tmp/file` or `../file`, and refuse
  to overwrite existing files by default. Use `--force` and/or `-y` only after explicit user approval.
- Do not write restored files outside `.prompt/` unless the user explicitly specifies `--output <dir>`.
- Staged files uploads use the local `./prompt/{id}/bundle.md` preview first, then
  `new.sh`, `iterate.sh`, or `branch.sh` with `-f <bundle> --format files` after approval.
  Prefer `stage-files.sh`; `prompt stage-files` is the CLI-equivalent staging command.
- `prompt new -f`, `prompt iterate -f`, `prompt branch -f`, and the folder-based
  `--files <dir>` variants show `Files to upload:` before sending file content.

Previews are omitted under `--json` so scripts can parse the JSON output.

## Format choice

- `mdx` means Markdown in this app; JSX and expressions are unsupported.
- `html` stores sanitized HTML.
- `plain` renders source verbatim in a `<pre>` and is best for code, logs, or any
  content where Markdown interpretation would be wrong.
- `files` stores an ordered file/folder bundle. Prefer staged
  `./prompt/{id}/bundle.md` plus `--format files` for agent-prepared uploads;
  use CLI `--files <dir>` only for explicit/ad hoc folder uploads.

Plain is opt-in only. Auto-detection chooses `files` for canonical `FILE-TREE` bundles and otherwise chooses `mdx` or `html`.
