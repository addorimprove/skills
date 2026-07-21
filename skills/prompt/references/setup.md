# Setup

## Login

Bundled scripts and the published CLI share one stored `mdnp_…` key.

Check current login state:

```bash
bash "$SKILL_DIR/scripts/whoami.sh"
```

If the script prints `Not logged in`, ask the **user** to run:

```bash
npx @addorimprove/prompt login
```

Login is an interactive browser PKCE flow and cannot be completed by the agent.
It stores the key at `~/.config/prompt/config.json`.

`MD_PROMPT_API_KEY` overrides the stored key.

## CLI compatibility

Files-format workflows require a `@addorimprove/prompt` CLI release with `bundle`,
`stage-files`, `restore-files`, and `--files` upload flags. The skill
`stage-files.sh` helper is self-contained, but the CLI-equivalent staging command
requires a matching CLI release. Check before using those commands:

```bash
npx @addorimprove/prompt version --json
```

If the installed CLI is older than the files-workflow release, ask the user to run:

```bash
npx @addorimprove/prompt upgrade
```

or use the repo-local development CLI instructions when working from this repo.

## Target environment

Scripts default to production:

```text
https://markdown-notes-ten.vercel.app
```

Override with either:

```bash
export MD_PROMPT_BASE_URL=http://localhost:3000
```

or a script flag:

```bash
bash "$SKILL_DIR/scripts/view.sh" --base-url http://localhost:3000 <id>
```

## Running scripts

Run scripts by absolute path from the installed skill directory:

```bash
bash "$SKILL_DIR/scripts/view.sh" <id>
```

Requirements:

- `curl` is required.
- `jq` is required for the bundled scripts. They use it to read credentials,
  construct request JSON, URL-encode path/query values, and shape responses.
  If `jq` is missing, install it (`brew install jq`) or use the CLI instead.

Every bundled script prints JSON to stdout.
