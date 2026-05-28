#!/bin/bash
set -euo pipefail

PREFIX=$(realpath "$(dirname "$0")")

mkdir -p build/mono build/mono-basic
cd build

curl "https://download.mono-project.com/sources/mono/mono-6.12.0.182.tar.xz" -o mono.tar.xz
curl -L "https://github.com/mono/mono-basic/archive/refs/tags/4.7.tar.gz" -o mono-basic.tar.gz
tar xf mono.tar.xz --strip-components=1 -C mono
tar xf mono-basic.tar.gz --strip-components=1 -C mono-basic

# Compiling Mono
cd mono

./configure --prefix "$PREFIX"

make -j"$(nproc)"
make install -j"$(nproc)"

export PATH="$PREFIX/bin:$PATH"  # To be able to use mono commands

if ! command -v mono >/dev/null 2>&1; then
    echo "Mono runtime was not installed into the package" >&2
    exit 1
fi

# Compiling mono-basic
cd ../mono-basic
./configure --prefix="$PREFIX"

make -j"$(nproc)" PLATFORM="linux"  # Avoids conflict with the $PLATFORM variable we have
make install -j"$(nproc)" PLATFORM="linux"

# Some Mono builds do not expose compiler launchers in bin/.
# Add stable wrappers if the managed compiler exes exist.
mkdir -p "$PREFIX/bin"

if [ ! -x "$PREFIX/bin/mono-csc" ] && [ -f "$PREFIX/lib/mono/4.5/csc.exe" ]; then
cat > "$PREFIX/bin/mono-csc" <<EOF
#!/bin/sh
exec "$PREFIX/bin/mono" "$PREFIX/lib/mono/4.5/csc.exe" "\$@"
EOF
chmod +x "$PREFIX/bin/mono-csc"
fi

if [ ! -x "$PREFIX/bin/mcs" ] && [ -f "$PREFIX/lib/mono/4.5/mcs.exe" ]; then
cat > "$PREFIX/bin/mcs" <<EOF
#!/bin/sh
exec "$PREFIX/bin/mono" "$PREFIX/lib/mono/4.5/mcs.exe" "\$@"
EOF
chmod +x "$PREFIX/bin/mcs"
fi

if [ ! -x "$PREFIX/bin/vbnc" ] && [ -f "$PREFIX/lib/mono/4.5/vbnc.exe" ]; then
cat > "$PREFIX/bin/vbnc" <<EOF
#!/bin/sh
exec "$PREFIX/bin/mono" "$PREFIX/lib/mono/4.5/vbnc.exe" "\$@"
EOF
chmod +x "$PREFIX/bin/vbnc"
fi

# Fail the package build if no usable compiler was installed.
if ! command -v mono-csc >/dev/null 2>&1 \
  && ! command -v mcs >/dev/null 2>&1 \
  && [ ! -f "$PREFIX/lib/mono/4.5/csc.exe" ] \
  && [ ! -f "$PREFIX/lib/mono/4.5/mcs.exe" ]; then
    echo "Mono C# compiler was not installed into the package" >&2
    exit 1
fi

# Remove redundant files
cd ../../
rm -rf build
