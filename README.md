# skills

Agent skills for the **addorimprove** app, installable via the
[skills](https://skills.sh) CLI. Currently contains the **`prompt`** skill —
reading and writing prompts (documents), versions, and comments, driven by
bundled API scripts.

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
files under [`skills/prompt/references/`](skills/prompt/references/).

## Auth

Create an `mdnp_…` API key at
[addorimprove.com/settings/account](https://addorimprove.com/settings/account)
and export it:

```bash
export MD_PROMPT_API_KEY=mdnp_...
```

The scripts also read `apiKey` from `~/.config/prompt/config.json` when the env
var is unset. Set `MD_PROMPT_BASE_URL` / `--base-url` to point at a non-prod
target. Agents that support MCP can use the hosted server at
`https://addorimprove.com/api/mcp` instead.
