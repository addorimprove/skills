# Version labels

- `1-1` is the bootstrap version.
- `iterate` makes the next version on the same line:
  - `1-1` → `1-2` → `1-3`
- `branch` forks a new line from a version by appending a dot segment:
  - first branch off `1-2`: `1-2.1-1`
  - second branch off `1-2`: `1-2.2-1`
  - first branch off `1-1`: `1-1.1-1`

Use `iterate` for a normal improvement to the current line. Use `branch` for an
alternative direction that should preserve the parent line unchanged.
