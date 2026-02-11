#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
TARGET_DIR="${2:-$HOME/.local/bin}"

if [[ -z "$PKG_PATH" ]]; then
  echo "Install failed: missing package path"
  echo "next: run ./scripts/install.sh <local-tarball> [target-dir]"
  exit 1
fi

if [[ ! -f "$PKG_PATH" ]]; then
  echo "Install failed: package not found ($PKG_PATH)"
  echo "next: run ./scripts/package-release.sh then retry with the generated tarball path"
  exit 1
fi

tmp_dir=".lan_install_tmp_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

if ! tar -xzf "$PKG_PATH" -C "$tmp_dir"; then
  echo "Install failed: invalid tarball"
  echo "next: regenerate package via ./scripts/package-release.sh and retry"
  exit 1
fi

bin_path="$(find "$tmp_dir" -name lan -type f | head -n 1)"
if [[ -z "$bin_path" ]]; then
  echo "Install failed: binary lan not found in package"
  echo "next: ensure package includes lan binary and retry"
  exit 1
fi

if [[ -e "$TARGET_DIR" && ! -d "$TARGET_DIR" ]]; then
  echo "Install failed: target path is a file ($TARGET_DIR)"
  echo "next: choose a directory path, e.g. ~/.local/bin"
  exit 1
fi

if ! mkdir -p "$TARGET_DIR" 2>/dev/null; then
  echo "Install failed: cannot create target directory ($TARGET_DIR)"
  echo "next: check path permissions or use a writable directory"
  exit 1
fi

if [[ ! -w "$TARGET_DIR" ]]; then
  echo "Install failed: target directory not writable ($TARGET_DIR)"
  echo "next: grant write permission or use another install path"
  exit 1
fi

if [[ -d "$TARGET_DIR/lan" ]]; then
  echo "Install failed: conflict at $TARGET_DIR/lan (is directory)"
  echo "next: remove/rename that directory then retry install"
  exit 1
fi

cp "$bin_path" "$TARGET_DIR/lan"
chmod +x "$TARGET_DIR/lan"

echo "Install success: $TARGET_DIR/lan"
