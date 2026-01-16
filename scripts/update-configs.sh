#!/usr/bin/env bash
set -euo pipefail

UPSTREAM="https://github.com/Nomadcxx/sysc-greet.git"
TMP="$(mktemp -d)"

git clone --depth 1 "$UPSTREAM" "$TMP"

rm -rf config
cp -av "$TMP/config" ./config

rm -rf "$TMP"

echo "sysc-greet configs updated from upstream"
