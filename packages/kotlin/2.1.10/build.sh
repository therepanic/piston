#!/usr/bin/env bash
set -euo pipefail

# Bundle a JDK (Kotlin 2.x requires a modern Java runtime).
# Uses Adoptium API to avoid pinning exact build numbers.
curl -L "https://api.adoptium.net/v3/binary/latest/21/ga/linux/x64/jdk/hotspot/normal/eclipse" -o jdk.tar.gz
tar xzf jdk.tar.gz --strip-components=1
rm jdk.tar.gz

# Download and extract Kotlin compiler
curl -L "https://github.com/JetBrains/kotlin/releases/download/v2.1.10/kotlin-compiler-2.1.10.zip" -o kotlin.zip
unzip kotlin.zip >/dev/null
rm kotlin.zip
cp -r kotlinc/* .
rm -rf kotlinc
