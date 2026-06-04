#!/usr/bin/env bash
set -euo pipefail

# Swift 5.9.2 is the latest 5.9 patch release and still targets Ubuntu 18.04.
: "${SWIFT_TARBALL_URL:=https://download.swift.org/swift-5.9.2-release/ubuntu18.04/swift-5.9.2-RELEASE/swift-5.9.2-RELEASE-ubuntu18.04.tar.gz}"

curl -L "$SWIFT_TARBALL_URL" -o swift.tar.gz
tar xzf swift.tar.gz --strip-components=1
rm swift.tar.gz

source ./environment
mkdir -p "$HOME"

# Pre-warm SwiftPM dependencies used in OpenLeetCode-style solutions.
precache_dir="$PWD/.piston-precache"
rm -rf "$precache_dir"
mkdir -p "$precache_dir/Sources/code"

cat > "$precache_dir/Package.swift" <<'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "code",
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
