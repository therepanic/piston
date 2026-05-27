#!/usr/bin/env bash
set -euo pipefail

: "${JAVA_TARBALL_URL:=https://api.adoptium.net/v3/binary/latest/25/ga/linux/x64/jdk/hotspot/normal/eclipse}"
: "${GSON_VERSION:=2.13.1}"

curl -L "$JAVA_TARBALL_URL" -o java.tar.gz
tar xzf java.tar.gz --strip-components=1
rm java.tar.gz

mkdir -p libs
curl -L "https://repo1.maven.org/maven2/com/google/code/gson/gson/${GSON_VERSION}/gson-${GSON_VERSION}.jar" \
  -o "libs/gson-${GSON_VERSION}.jar"

