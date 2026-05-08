#!/usr/bin/env bash
set -euo pipefail

: "${JAVA_TARBALL_URL:=https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse}"

curl -L "$JAVA_TARBALL_URL" -o java.tar.gz
tar xzf java.tar.gz --strip-components=1
rm java.tar.gz

