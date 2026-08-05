# Snapshot labels

Labels exist only when **Versioning is On**.

- Bootstrap: `1-1`
- Iterate from `1-1`: `1-2`, then `1-3`
- Branch from `1-2`: `1-2.1-1`
- Iterate on that branch: `1-2.1-2`
- Another branch from the same parent: `1-2.2-1`

Use iterate to continue one line and branch to fork from a snapshot. A parent
with an existing iterate child is no longer an iterate tip.

**Versioning Off has no labels, snapshots, iterate, or branch.** Use
`currentRevision` only for content CAS; do not present `current-<revision>` as a
label or snapshot identity.
