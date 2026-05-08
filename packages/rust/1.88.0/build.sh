#!/usr/bin/env bash
set -euo pipefail

curl -OL "https://static.rust-lang.org/dist/rust-1.88.0-x86_64-unknown-linux-gnu.tar.gz"
tar xzf rust-1.88.0-x86_64-unknown-linux-gnu.tar.gz
rm rust-1.88.0-x86_64-unknown-linux-gnu.tar.gz

source ./environment

mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"

# Pre-warm crates.io for common DS libs (LeetCode-like).
precache_dir="$PWD/.piston-precache"
rm -rf "$precache_dir"
mkdir -p "$precache_dir/src"

cat > "$precache_dir/Cargo.toml" <<'EOF'
[package]
name = "piston-precache"
version = "0.1.0"
edition = "2024"

[dependencies]
rand = "0.8"
regex = "1"
itertools = "0.14"
EOF

cat > "$precache_dir/src/main.rs" <<'EOF'
fn main() {}
EOF

(cd "$precache_dir" && cargo fetch)
rm -rf "$precache_dir"

