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

# Make swift-algorithms use the vendored numerics package so SwiftPM does not see
# the same package identity both as a URL dependency and a local path dependency.
sed -i 's#\.package(url: "https://github.com/apple/swift-numerics.git", from: "1\.0\.0")#.package(path: "'"$deps_dir"'/swift-numerics")#' \
    "$deps_dir/swift-algorithms/Package.swift"

# Prebuild a reusable SwiftPM workspace so runtime compiles only rebuild user code.
template_dir="$PWD/template-swiftpm"
rm -rf "$template_dir"
mkdir -p "$template_dir/Sources/code"

cat > "$template_dir/Package.swift" <<EOF
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "code",
    dependencies: [
        .package(path: "${deps_dir}/swift-algorithms"),
        .package(path: "${deps_dir}/swift-collections"),
    ],
    targets: [
        .executableTarget(
            name: "code",
            dependencies: [
                .product(name: "Algorithms", package: "swift-algorithms"),
                .product(name: "Collections", package: "swift-collections"),
            ]
        ),
    ]
)
EOF

cat > "$template_dir/Sources/code/main.swift" <<'EOF'
import Algorithms
import Collections

print("ok")
EOF

(cd "$template_dir" && swift build -c release)

# Drop transient compiler caches and normalize permissions so the installed package is copyable in isolate.
find "$template_dir/.build" -type d \( -name ModuleCache -o -name Modules \) -prune -exec rm -rf {} +
chmod -R a+rX "$template_dir" "$deps_dir"
