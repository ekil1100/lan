#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="$(./zig-out/bin/lan --version | sed -n 's/^lan version=\([^ ]*\).*/\1/p')"
[[ -n "$VERSION" ]] || { echo "[package] FAIL reason=version-missing"; exit 1; }

OS_RAW="$(uname -s)"
ARCH_RAW="$(uname -m)"
case "$OS_RAW" in
  Darwin) OS="macos" ;;
  Linux) OS="linux" ;;
  *) OS="unknown" ;;
esac
case "$ARCH_RAW" in
  arm64|aarch64) ARCH="arm64" ;;
  x86_64|amd64) ARCH="amd64" ;;
  *) ARCH="$ARCH_RAW" ;;
esac

DIST_DIR="dist"
PKG_NAME="lan-${VERSION}-${OS}-${ARCH}"
PKG_DIR="${DIST_DIR}/${PKG_NAME}"
PKG_TGZ="${DIST_DIR}/${PKG_NAME}.tar.gz"

rm -rf "$PKG_DIR" "$PKG_TGZ"
mkdir -p "$PKG_DIR"

cp ./zig-out/bin/lan "$PKG_DIR/"
cp ./README.md "$PKG_DIR/"

tar -czf "$PKG_TGZ" -C "$DIST_DIR" "$PKG_NAME"

sha_cmd=""
if command -v shasum >/dev/null 2>&1; then
  sha_cmd="shasum -a 256"
elif command -v sha256sum >/dev/null 2>&1; then
  sha_cmd="sha256sum"
else
  echo "[package] FAIL reason=no-sha-tool"
  exit 1
fi

checksum_file="${PKG_TGZ}.sha256"
manifest_file="${DIST_DIR}/${PKG_NAME}.manifest"

checksum="$($sha_cmd "$PKG_TGZ" | awk '{print $1}')"
echo "$checksum  $(basename "$PKG_TGZ")" > "$checksum_file"

cat > "$manifest_file" <<EOF
name=$PKG_NAME
artifact=$(basename "$PKG_TGZ")
checksum_sha256=$checksum
os=$OS
arch=$ARCH
version=$VERSION
contains=lan,README.md
EOF

echo "[package] PASS artifact=${PKG_TGZ} checksum=${checksum_file} manifest=${manifest_file}"