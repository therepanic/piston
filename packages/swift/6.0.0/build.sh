#!/usr/bin/env bash
set -euo pipefail

# Swift release toolchain URL changes by Ubuntu version. Override if needed.
: "${SWIFT_TARBALL_URL:=https://download.swift.org/swift-6.0-release/ubuntu2204/swift-6.0-RELEASE/swift-6.0-RELEASE-ubuntu22.04.tar.gz}"

curl -L "$SWIFT_TARBALL_URL" -o swift.tar.gz
tar xzf swift.tar.gz
rm swift.tar.gz

source ./environment
mkdir -p "$HOME"

# Pre-warm SwiftPM dependencies (LeetCode-like).
precache_dir="$PWD/.piston-precache"
rm -rf "$precache_dir"
mkdir -p "$precache_dir/Sources/code"

cat > "$precache_dir/Package.swift" <<'EOF'
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "code",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms.git", exact: "1.2.0"),
        .package(url: "https://github.com/apple/swift-collections.git", exact: "1.1.4"),
        .package(url: "https://github.com/apple/swift-numerics.git", exact: "1.0.2"),
    ],
    targets: [
        .executableTarget(
            name: "code",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
                .product(name: "Numerics", package: "swift-numerics"),
            ]
        ),
    ]
)
EOF

cat > "$precache_dir/Sources/code/main.swift" <<'EOF'
import Algorithms
import Collections
import Numerics

print("ok")
EOF

(cd "$precache_dir" && swift package resolve)
rm -rf "$precache_dir"

