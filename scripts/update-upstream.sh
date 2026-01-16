#!/usr/bin/env bash
set -euo pipefail

UPSTREAM="https://github.com/Nomadcxx/sysc-greet.git"

LATEST_TAG=$(
  git ls-remote --tags --sort="v:refname" "$UPSTREAM" |
  awk -F/ '{print $3}' |
  grep -E '^v?[0-9]' |
  grep -v '\^{}$' |
  tail -n1
)

VERSION="${LATEST_TAG#v}"

echo "$VERSION"
