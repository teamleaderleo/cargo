# Design questions before a Cargo implementation

A no-fetch implementation needs explicit answers to all of these:

1. **Selection proof** — what proves a local patch completely replaces every package Cargo might need from the git source?
2. **Version matching** — may Cargo skip the source when the patch version does not satisfy the dependency requirement?
3. **Repository multiplicity** — what if one git repository provides multiple workspace packages and only one is patched?
4. **Revision selectors** — how do `branch`, `tag`, and `rev` affect the patch key and replacement proof?
5. **Transitive graph** — what if another dependency still needs an unpatched package from the same source?
6. **Lockfile compatibility** — can an existing lock entry identify enough source metadata to avoid a fetch, and what happens without a lockfile?
7. **Unused patches** — Cargo currently loads the source before it can determine that a patch is unused. How is that diagnostic preserved?
8. **Configuration scope** — is an exact override allowed only from local `.cargo/config.toml`, or also from publishable manifests?
9. **Offline/frozen modes** — should the new rule be general, or a fallback only when source access is impossible?
10. **Identity and checksums** — does the replacement retain the original source identity in the lockfile or become an ordinary path source?

## Plausible direction

A new, explicitly named configuration mechanism is safer than changing `[patch]` implicitly. For example, a local-only exact override could declare that a dependency source ID and package name are replaced before resolution, reject ambiguity, and fail if another package from the original source is needed.

That mechanism should be designed separately from the current issue's proposed implementation. The existing `[patch]` contract and tests should remain unchanged until Cargo accepts a new semantic rule.