# skills

Agent skills for the **addorimprove** app, installable via the
[skills](https://skills.sh) CLI. Currently contains the **`prompt`** skill —
reading and writing prompts (documents), versions, and comments, driven by
bundled API scripts, with the published `prompt` CLI (`npx @addorimprove/prompt`)
as a backup option.

## Install

```bash
npx skills add addorimprove/skills
```

Target a specific agent (e.g. Claude Code):

```bash
npx skills add addorimprove/skills -a claude-code
```

## What it does

Lets your agent fetch, search, read, create, iterate, and publish/unpublish
prompts/documents and their comments in the addorimprove app
(`addorimprove.com`). The full instructions live in
[`skills/prompt/SKILL.md`](skills/prompt/SKILL.md). Detailed setup, command,
write safety, workflow, comment, and version-label guidance is split into smaller
files under [`skills/prompt/references/`](skills/prompt/references/). The CLI
also includes `prompt stage-files --id <id> <file>...` as the CLI-equivalent
staging workflow and `prompt restore-bundle [bundle.md] --output <dir>
[--force] [-y]` for restoring Markdown bundles, with a folder-style preview,
confirmation before files are written, and default refusal to overwrite existing files.

## Auth

The skill scripts and `npx @addorimprove/prompt` use the same stored `mdnp_…` key.
Log in once with:

```bash
npx @addorimprove/prompt login
```

It's an interactive browser (PKCE) login and stores the key at
`~/.config/prompt/config.json`. Set `MD_PROMPT_API_KEY` to override the file, or
`MD_PROMPT_BASE_URL` / `--base-url` to point at a non-prod target.
