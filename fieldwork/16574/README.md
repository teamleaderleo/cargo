# Fieldwork: patched git sources still fetch the original repository

Upstream issue: https://github.com/rust-lang/cargo/issues/16574  
Inspected source: `614ec56f126eb6925f19ba538d6ecda2ef333a9c`  
External contact: **not authorized and not performed**

## In simple words

The reported behavior is real, but current Cargo tests show it is also part of today's general `[patch]` model: the existing `patch_git` test expects Cargo to print `UPDATING git repository ...` even when the selected crate comes from a local path patch.

A Cargo patch is not a textual replacement of the dependency declaration. It adds candidates to a source during resolution. Cargo still loads the original source so it can discover the original package set, versions, revisions, and whether the patch actually wins. Skipping the fetch generally changes semantics when the local patch has a mismatched version, package name, feature set, branch/revision relationship, or is unused.

## Upstream/process state

The issue is labeled `S-needs-design`, not `S-accepted`. Cargo's contribution guide states that only explicitly accepted issues are reviewed and encourages design discussion before implementation. That makes a broad production change inappropriate even on the fork until the desired replacement semantics are specified.

## Useful distinction

Four mechanisms or hypotheses should not be conflated:

1. `[patch.<source>]`: augments a source for dependency resolution and may still require loading the source;
2. source replacement (`[source] replace-with`): redirects an entire source but has different configuration and checksum/identity rules;
3. an exact dependency override: replace one manifest dependency before the original source is opened; Cargo has no settled contract for this broader request;
4. the historical single-patch plus exact-`=a.b.c` fast path: a narrower optimization that maintainer discussion says existed before PR #9847 separated lockfile-locked requirements from ordinary exact requirements.

## Prepared work

- `reproducer.sh` creates an unreachable git dependency plus a matching local path patch and records the attempted fetch.
- `candidate-test.patch` adds a deliberately failing test expressing the broad proposed no-fetch invariant.
- `exact-version-fast-path.patch` expresses the narrower exact-version/single-patch contract separately.
- `DESIGN.md` records the general design questions and the negative controls required before restoring the historical fast path.

## Execution plan

Fieldwork Round 005 executes the current `patch_git` positive control and the broad unreachable-source negative control. The exact-version fixture is retained as the next bounded probe because its result can justify a narrow regression-restoration lane without implying that every git patch should avoid source access.

## Stop condition

Do not implement source short-circuiting merely by detecting a same-name patch. That can silently select a patch Cargo would otherwise reject or leave unused. A broad change remains blocked.

A narrower implementation may proceed only if the exact-version probe and companion controls establish that one matching patch candidate is sufficient without weakening version, feature, workspace-package, or lockfile behavior.

## Evidence state

`source-and-test-reviewed`; broad failing test prepared; exact-version fast-path test prepared; production change **held for design and execution**. No upstream contact.
