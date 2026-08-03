# Fieldwork: patched git sources still fetch the original repository

Upstream issue: https://github.com/rust-lang/cargo/issues/16574  
Inspected source: `614ec56f126eb6925f19ba538d6ecda2ef333a9c`  
External contact: **not authorized and not performed**

## In simple words

The reported behavior is real, but current Cargo tests show it is also part of today's `[patch]` model: the existing `patch_git` test expects Cargo to print `UPDATING git repository ...` even when the selected crate comes from a local path patch.

A Cargo patch is not a textual replacement of the dependency declaration. It adds candidates to a source during resolution. Cargo still loads the original source so it can discover the original package set, versions, revisions, and whether the patch actually wins. Skipping the fetch therefore changes semantics when the local patch has a mismatched version, package name, feature set, branch/revision relationship, or is unused.

## Upstream/process state

The issue is labeled `S-needs-design`, not `S-accepted`. Cargo's contribution guide states that only explicitly accepted issues are reviewed and encourages design discussion before implementation. That makes a production change inappropriate even on the fork until the desired replacement semantics are specified.

## Useful distinction

Three mechanisms should not be conflated:

1. `[patch.<source>]`: augments a source for dependency resolution and may still require loading the source;
2. source replacement (`[source] replace-with`): redirects an entire source but has different configuration and checksum/identity rules;
3. an exact dependency override: the requested behavior—replace one manifest dependency before the original source is opened—does not currently have a settled Cargo contract.

## Prepared work

- `reproducer.sh` creates an unreachable git dependency plus a matching local path patch and records the attempted fetch.
- `candidate-test.patch` adds a deliberately failing test expressing the proposed no-fetch invariant.
- `DESIGN.md` lists the decisions required before production code can be responsibly changed.

## Stop condition

Do not implement source short-circuiting merely by detecting a same-name patch. That can silently select a patch Cargo would otherwise reject or leave unused. Resume implementation only after a rule defines when a patch is an exact replacement and how lockfiles, multiple packages per git repository, branch/rev/tag constraints, transitive dependencies, and unused-patch diagnostics behave.

## Evidence state

`source-and-test-reviewed`; `failing-test-prepared`; production change **held for design**. No test was executed in this environment.