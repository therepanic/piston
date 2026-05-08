#!/bin/bash
set -euo pipefail

PREFIX=$(realpath $(dirname $0))

mkdir -p build
cd build

# Ruby 3.2.x builds cleanly with OpenSSL 3 on modern Ubuntu.
curl -L "https://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.6.tar.gz" -o ruby.tar.gz
tar xzf ruby.tar.gz --strip-components=1
rm ruby.tar.gz

./configure --prefix "$PREFIX"
make -j"$(nproc)"
make install -j"$(nproc)"

cd ..
rm -rf build

bin/gem install algorithms

