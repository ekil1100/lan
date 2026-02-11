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

echo "[package] PASS artifact=${PKG_TGZ}"