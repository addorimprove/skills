# Setup

## Login

Bundled scripts authenticate with an `mdnp_…` API key.

Check current login state:

```bash
bash "$SKILL_DIR/scripts/whoami.sh"
```

If the script prints `Not logged in`, ask the **user** to create an API key at
https://addorimprove.com/settings/account and export it:

```bash
export MD_PROMPT_API_KEY=mdnp_...
```

The agent cannot create the key. When `MD_PROMPT_API_KEY` is unset, scripts fall
back to `apiKey` in `~/.config/prompt/config.json`.

## Target environment

Scripts default to production:

```text
https://addorimprove.com
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
  If `jq` is missing, install it (`brew install jq`).

Every bundled script prints JSON to stdout.
