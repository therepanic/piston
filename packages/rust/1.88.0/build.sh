#!/usr/bin/env bash
set -euo pipefail

curl -OL "https://static.rust-lang.org/dist/rust-1.88.0-x86_64-unknown-linux-gnu.tar.gz"
tar xzf rust-1.88.0-x86_64-unknown-linux-gnu.tar.gz
rm rust-1.88.0-x86_64-unknown-linux-gnu.tar.gz

install_dir="$PWD/rust"
rm -rf "$install_dir"
./rust-1.88.0-x86_64-unknown-linux-gnu/install.sh --prefix="$install_dir" --without=rust-docs
rm -rf ./rust-1.88.0-x86_64-unknown-linux-gnu

source ./environment

mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"

# Pre-vendor crates.io deps for offline compilation inside nsjail (no network).
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

(cd "$precache_dir" && cargo generate-lockfile)

# Copy lockfile + vendor sources into the package.
cp "$precache_dir/Cargo.lock" "$PISTON_RUST_LOCK"
rm -rf "$PISTON_RUST_VENDOR"
mkdir -p "$PISTON_RUST_VENDOR"
(cd "$precache_dir" && cargo vendor "$PISTON_RUST_VENDOR" >/dev/null)

# Ensure cargo never tries to hit the network at runtime.
mkdir -p "$CARGO_HOME"
cat > "$CARGO_HOME/config.toml" <<EOF
[net]
offline = true

[source.crates-io]
replace-with = "vendored-sources"

[source.vendored-sources]
directory = "$PISTON_RUST_VENDOR"
EOF

rm -rf "$precache_dir"

