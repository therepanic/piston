#!/usr/bin/env bash
set -euo pipefail

curl -LO https://go.dev/dl/go1.23.0.linux-amd64.tar.gz
tar -xzf go1.23.0.linux-amd64.tar.gz
rm go1.23.0.linux-amd64.tar.gz

export PATH="$PWD/go/bin:$PATH"
export GOPATH="$PWD/gopath"
export GOMODCACHE="$GOPATH/pkg/mod"
export GOCACHE="$PWD/gocache"
export GO111MODULE=on
# Avoid Go 1.23 auto-downloading toolchains into module cache
export GOTOOLCHAIN=local

mkdir -p "$GOMODCACHE" "$GOCACHE"

precache_dir="$PWD/.piston-precache"
rm -rf "$precache_dir"
mkdir -p "$precache_dir"

cat > "$precache_dir/go.mod" <<'EOF'
module piston-precache

go 1.23

require (
    github.com/emirpasic/gods v1.18.1
    github.com/emirpasic/gods/v2 v2.0.0-alpha
)
EOF

(
  cd "$precache_dir"
  go mod download
)

# Ship go.mod + go.sum for run-time (submission has no network; go needs checksums).
cp "$precache_dir/go.mod" ./go.piston.mod
cp "$precache_dir/go.sum" ./go.piston.sum

rm -rf "$precache_dir"

# Remove download cache to prevent tar "file changed as we read it" errors.
# Keep extracted modules in $GOMODCACHE (e.g. github.com/emirpasic/gods*).
rm -rf "$GOMODCACHE/cache/download" "$GOMODCACHE/cache/vcs"
