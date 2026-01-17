#!/usr/bin/env bash
set -euo pipefail

echo "### RUNNING scripts/build.sh from COMMIT:"
git rev-parse HEAD
sed -n '1,200p' "$0"
echo "### END build.sh dump"

VERSION="$1"
ROOT="$(pwd)"
WORKDIR="$ROOT/build"
LAST_BUILT_FILE="$ROOT/.last-built-version"

# CI-safe default
LAST_BUILT="none"
if [[ -f "$LAST_BUILT_FILE" ]]; then
  LAST_BUILT="$(cat "$LAST_BUILT_FILE")"
fi

if [[ "$VERSION" == "$LAST_BUILT" ]]; then
  echo "Upstream version $VERSION already built — exiting"
  exit 0
fi

echo "==> Building sysc-greet $VERSION"

# Update bundled configs
scripts/update-configs.sh

rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "==> Cloning sysc-greet"
git clone --branch "v$VERSION" --depth 1 \
  https://github.com/Nomadcxx/sysc-greet.git sysc-greet

cd sysc-greet

echo "==> Injecting debian/ and config/"
cp -r "$ROOT/debian" .
cp -r "$ROOT/config" .

DATE="$(date -R)"
sed \
  -e "s/@VERSION@/${VERSION}/" \
  -e "s/@DATE@/${DATE}/" \
  debian/changelog.in > debian/changelog
rm debian/changelog.in

echo "==> Building Debian packages"
dpkg-buildpackage -us -uc

echo "==> Artifacts already in build/ — skipping move"
ls -lh "$WORKDIR"/*.deb "$WORKDIR"/*.changes "$WORKDIR"/*.buildinfo

echo "$VERSION" > "$LAST_BUILT_FILE"

echo "==> Build artifacts:"
ls -lh "$WORKDIR"
