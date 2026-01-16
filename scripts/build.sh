#!/usr/bin/env bash
set -euo pipefail

VERSION="$1"
ROOT="$(pwd)"
LAST_BUILT_FILE="$ROOT/.last-built-version"

LAST_BUILT="$(cat "$LAST_BUILT_FILE")"

if [ "$VERSION" = "$LAST_BUILT" ]; then
  echo "Upstream version $VERSION already built — exiting"
  exit 0
fi

echo "Building sysc-greet $VERSION"

# Update configs first
scripts/update-configs.sh

WORKDIR="$ROOT/build"
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

git clone --branch "v$VERSION" --depth 1 https://github.com/Nomadcxx/sysc-greet.git sysc-greet
cd sysc-greet

cp -r "$ROOT/debian" .
cp -r "$ROOT/config" .

DATE="$(date -R)"
sed \
  -e "s/@VERSION@/${VERSION}/" \
  -e "s/@DATE@/${DATE}/" \
  debian/changelog.in > debian/changelog

rm debian/changelog.in

dpkg-buildpackage -us -uc

echo "$VERSION" > "$LAST_BUILT_FILE"
