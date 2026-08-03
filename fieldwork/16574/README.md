# Fieldwork: patched git sources still fetch the original repository

Upstream issue: https://github.com/rust-lang/cargo/issues/16574  
Inspected source: `614ec56f126eb6925f19ba538d6ecda2ef333a9c`  
External contact: **not authorized and not performed**

## In simple words

The reported behavior is real, but current Cargo tests show it is also part of today's general `[patch]` model: the existing `patch_git` test expects Cargo to print `UPDATING git repository ...` even when the selected crate comes from a local path patch.

A Cargo patch is not a textual replacement of the dependency declaration. It adds candidates to a source during resolution. Cargo still loads the original source so it can discover the original package set, versions, revisions, and whether the patch actually wins. Skipping the fetch generally changes semantics when the local patch has a mismatched version, package name, feature set, branch/revision relationship, or is unused.

## Executed contracts

Fieldwork run `30839352175`, job `91772318148`, established the broad current contract:

- current `patch::patch_git` passed;
- a matching path patch plus unreachable original git source still printed `Updating git repository`;
- Cargo reached the original-source product path and exited 101 after connection refusal.

Fieldwork run `30842332925`, job `91782183881`, tested the narrower historical hypothesis with exactly one matching path patch and an ordinary exact requirement `=0.1.0`:

- the exact-version fast path was **absent**;
- Cargo still reached the original git source and failed there;
- no production source change was made.

The runner lacked `rg`, so source-map collection used the script's fallback path. The product result and retained state are valid; this was not classified as a clean full Cargo gate.

## Upstream/process state

The issue is labeled `S-needs-design`, not `S-accepted`. Cargo's contribution guide states that only explicitly accepted issues are reviewed and encourages design discussion before implementation. That makes a broad production change inappropriate even on the fork until the desired replacement semantics are specified.

## Useful distinction

Four mechanisms or hypotheses should not be conflated:

1. `[patch.<source>]`: augments a source for dependency resolution and may still require loading the source;
2. source replacement (`[source] replace-with`): redirects an entire source but has different configuration and checksum/identity rules;
3. an exact dependency override: replace one manifest dependency before the original source is opened; Cargo has no settled contract for this broader request;
4. the historical single-patch plus exact-`=a.b.c` fast path: a narrower optimization discussed by maintainers, but absent on the tested current head.

## Retained work

- `reproducer.sh` creates an unreachable git dependency plus a matching local path patch and records the attempted fetch.
- `candidate-test.patch` expresses the rejected broad no-fetch invariant.
- `exact-version-fast-path.patch` expresses the narrower exact-version/single-patch contract.
- `DESIGN.md` records version mismatch, feature mismatch, multiple-patch, workspace-package, and lockfile controls.
- `EXACT-VERSION-RESULT.md` records the executed narrow result and identities.

## Stop condition

Do not implement source short-circuiting merely by detecting a same-name or exact-version patch. Both broad and exact-version fixtures still reach the original source on the tested head, and a shortcut can silently select a patch Cargo would otherwise reject or leave unused.

Any production lane now requires an accepted semantic design that explains candidate completeness, lockfile behavior, source identity, feature resolution, and failure behavior when the original source is unavailable.

## Evidence state

`target-executed-focused`; broad no-fetch contract negative; exact-version fast path absent; production change **held for accepted design**. No upstream contact.
