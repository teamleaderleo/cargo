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

## Current maintainer model

Cargo loads both original and patched sources because `[patch]` adds candidates rather than textually replacing a dependency. The original source may still win when the patch version does not satisfy the requirement or when activated features are unavailable from the patch. For git sources, skipping the original source generally would therefore be a compatibility change.

A committed lockfile remains a supported way to avoid rediscovery. Maintainer discussion also identifies a historical narrower fast path: when there is exactly one patch and the dependency has an exact `=a.b.c` requirement, Cargo can determine that a matching patch candidate is sufficient without querying the original source. PR #9847 separated a genuinely lockfile-locked requirement from an ordinary exact requirement, apparently disabling that optimization around Cargo 1.57.

## Bounded implementation question

Before inventing a new override mechanism, test whether restoring the **single-patch plus ordinary exact-version** fast path is still semantically valid on current Cargo:

- exactly one patch candidate exists for the dependency;
- its package name and version satisfy the exact requirement;
- required features are available from that candidate;
- no other package from the same source is needed for this dependency query;
- lockfile and source identity behavior remain unchanged from the historical contract.

Required negative controls:

- non-exact version ranges still query the original source;
- an exact version mismatch still queries the original source;
- a feature mismatch still permits the original source to win;
- multiple patch candidates do not take the fast path;
- another required package from the same git workspace remains fetchable;
- existing committed-lockfile behavior is unchanged.

This is narrower than the issue's general expectation and should be treated as a regression-restoration hypothesis, not as acceptance of no-fetch semantics for every git patch.

## Broader plausible direction

If the exact-version fast path is insufficient, a new, explicitly named configuration mechanism is safer than changing `[patch]` implicitly. A local-only exact override could declare that a dependency source ID and package name are replaced before resolution, reject ambiguity, and fail if another package from the original source is needed.

That mechanism should be designed separately from the current issue's proposed implementation. The existing general `[patch]` contract and tests should remain unchanged until Cargo accepts a new semantic rule.
