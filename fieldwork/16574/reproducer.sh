#!/usr/bin/env bash
set -euo pipefail

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
cd "$work"
mkdir -p app/src app/foo-dep/src app/.cargo

cat > app/Cargo.toml <<'TOML'
[package]
name = "cargo-patch-test"
version = "0.0.1"
edition = "2024"

[dependencies.foo-dep]
git = "ssh://unreachable.invalid/foo-dep.git"
TOML

cat > app/.cargo/config.toml <<'TOML'
[patch."ssh://unreachable.invalid/foo-dep.git"]
foo-dep = { path = "../foo-dep" }
TOML

cat > app/src/lib.rs <<'RS'
pub fn local() -> bool { foo_dep::local() }
RS

cat > app/foo-dep/Cargo.toml <<'TOML'
[package]
name = "foo-dep"
version = "0.1.0"
edition = "2024"
TOML

cat > app/foo-dep/src/lib.rs <<'RS'
pub fn local() -> bool { true }
RS

cd app
printf 'Expected current behavior: Cargo attempts the unreachable git source before resolution.\n'
cargo update -vv
