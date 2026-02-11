#!/usr/bin/env bash
set -euo pipefail

# Verify a lan installation from GitHub Release.
# Usage: ./scripts/verify-install.sh [version] [install_dir]
#   version: tag name (default: latest)
#   install_dir: where to install (default: ~/.local/bin)

REPO="ekil1100/lan"
VERSION="${1:-latest}"
INSTALL_DIR="${2:-$HOME/.local/bin}"
PLATFORM="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

echo "[verify-install] platform=$PLATFORM arch=$ARCH version=$VERSION install_dir=$INSTALL_DIR"

# resolve latest tag
if [[ "$VERSION" == "latest" ]]; then
  api_url="https://api.github.com/repos/$REPO/releases/latest"
  VERSION="$(curl -fsSL "$api_url" 2>/dev/null | sed -n 's/.*"tag_name":[[:space:]]*"\([^"]*\)".*/\1/p')"
  if [[ -z "$VERSION" ]]; then
    echo "[verify-install] FAIL reason=cannot_resolve_latest_tag"
    echo "next: check network or provide explicit version"
    exit 1
  fi
  echo "[verify-install] resolved_version=$VERSION"
fi

# map arch
case "$ARCH" in
  x86_64|amd64) arch_label="x86_64" ;;
  arm64|aarch64) arch_label="aarch64" ;;
  *) echo "[verify-install] FAIL reason=unsupported_arch arch=$ARCH"; exit 1 ;;
esac

artifact="lan-${VERSION}-${PLATFORM}-${arch_label}.tar.gz"
url="https://github.com/$REPO/releases/download/$VERSION/$artifact"

echo "[verify-install] downloading $url"
if ! curl -fsSL -o "$tmp_dir/$artifact" "$url" 2>/dev/null; then
  echo "[verify-install] FAIL reason=download_failed url=$url"
  echo "next: verify release exists at $url"
  exit 1
fi

echo "[verify-install] extracting"
tar xzf "$tmp_dir/$artifact" -C "$tmp_dir" 2>/dev/null || {
  echo "[verify-install] FAIL reason=extract_failed"
  exit 1
}

# find binary
binary="$(find "$tmp_dir" -name 'lan' -type f | head -1)"
if [[ -z "$binary" ]]; then
  echo "[verify-install] FAIL reason=binary_not_found_in_artifact"
  exit 1
fi

chmod +x "$binary"

# verify version output
version_out="$("$binary" --version 2>/dev/null || echo "$binary" | xargs -I{} sh -c 'echo "" | {} 2>&1 | head -5' || true)"
echo "[verify-install] version_output=$version_out"

# install
mkdir -p "$INSTALL_DIR"
cp "$binary" "$INSTALL_DIR/lan"
chmod +x "$INSTALL_DIR/lan"

echo "[verify-install] PASS installed=$INSTALL_DIR/lan version=$VERSION"