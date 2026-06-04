#!/usr/bin/env bash
set -euo pipefail

# Swift release archives use `ubuntu1804` in the directory name and `ubuntu18.04` in the file name.
: "${SWIFT_TARBALL_URL:=https://download.swift.org/swift-5.9.2-release/ubuntu1804/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-ubuntu18.04.tar.gz}"

curl -L "$SWIFT_TARBALL_URL" -o swift.tar.gz
tar xzf swift.tar.gz --strip-components=1
rm swift.tar.gz

source ./environment
export HOME="$PWD/home"
export XDG_CACHE_HOME="$HOME/.cache"
mkdir -p "$HOME" "$XDG_CACHE_HOME"

# Vendor SwiftPM dependencies into the package so runtime builds work without network access.
deps_dir="$PWD/vendor"
rm -rf "$deps_dir"
mkdir -p "$deps_dir"

git clone --depth 1 --branch 1.2.0 https://github.com/apple/swift-algorithms.git "$deps_dir/swift-algorithms"
git clone --depth 1 --branch 1.1.4 https://github.com/apple/swift-collections.git "$deps_dir/swift-collections"
git clone --depth 1 --branch 1.0.2 https://github.com/apple/swift-numerics.git "$deps_dir/swift-numerics"
