# Best practices applied

Sources consulted:

- Pi `docs/skills.md`
- `skills` npm CLI README skill creation guidance
- Existing API skill best-practices note in `restate-procure/skills/api`

Applied decisions:

- Keep `SKILL.md` short and focused on activation, routing, quick start, and a
  reference map.
- Keep the main file short by moving detailed setup, command lists, write safety
  rules, workflows, comments, and version-label details into separate reference
  files.
- Keep tools and instructions separate: API calls stay in `scripts/`, while usage
  guidance stays in `references/`.
- Preserve explicit write safety in the root file because it is a high-value
  behavior the agent must see immediately.
- Prefer bundled scripts for normal API reads/writes to avoid an `npx` round trip.
- The published CLI is retired; auth uses a Settings API key and binary Files
  go through the hosted MCP server.
