#!/usr/bin/env bash

source ../../node/22.14.0/build.sh
source ./environment

bin/npm config set prefix "$PWD"

bin/npm install -g typescript@5.7.3 lodash@4.17.21 \
  @datastructures-js/binary-search-tree@5.4.0 \
  @datastructures-js/deque@1.0.8 \
  @datastructures-js/graph@5.3.1 \
  @datastructures-js/heap@4.3.7 \
  @datastructures-js/linked-list@6.1.4 \
  @datastructures-js/priority-queue@6.3.5 \
  @datastructures-js/queue@4.3.0 \
  @datastructures-js/set@4.2.2 \
  @datastructures-js/stack@3.1.6 \
  @datastructures-js/trie@4.2.3

