# prompt

An [agent skill](https://skills.sh) for reading and writing prompts (documents),
versions, and comments in the **addorimprove** app, driven by the published
`prompt` CLI (`npx @addorimprove/prompt`).

## Install

```bash
npx skills add addorimprove/prompt
```

Target a specific agent (e.g. Claude Code):

```bash
npx skills add addorimprove/prompt -a claude-code
```

## What it does

Lets your agent fetch, search, read, create, and iterate prompts/documents and
their comments in the addorimprove app (`app.photosharingapp.com`) through the
`prompt` CLI. The full instructions live in
[`skills/prompt/SKILL.md`](skills/prompt/SKILL.md).

## Auth

The skill drives `npx @addorimprove/prompt`, which uses a stored `mdnp_…` key.
Log in once with:

```bash
npx @addorimprove/prompt login
```

It's an interactive browser (PKCE) login and stores the key at
`~/.config/prompt/config.json`. Set `MD_PROMPT_API_KEY` to override the file, or
`MD_PROMPT_BASE_URL` / `--base-url` to point at a non-prod target.
