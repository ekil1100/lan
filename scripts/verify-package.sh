#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
if [[ -z "$PKG_PATH" ]]; then
  echo "[verify-package] FAIL reason=missing-package"
  echo "next: run ./scripts/verify-package.sh <artifact.tar.gz>"
  exit 1
fi

if [[ ! -f "$PKG_PATH" ]]; then
  echo "[verify-package] FAIL reason=artifact-not-found path=$PKG_PATH"
  echo "next: run ./scripts/package-release.sh to generate artifact"
  exit 1
fi

checksum_file="${PKG_PATH}.sha256"
base_no_ext="${PKG_PATH%.tar.gz}"
manifest_file="${base_no_ext}.manifest"

if [[ ! -f "$checksum_file" ]]; then
  echo "[verify-package] FAIL reason=checksum-missing path=$checksum_file"
  echo "next: regenerate package to produce checksum"
  exit 1
fi
if [[ ! -f "$manifest_file" ]]; then
  echo "[verify-package] FAIL reason=manifest-missing path=$manifest_file"
  echo "next: regenerate package to produce manifest"
  exit 1
fi

expected="$(awk '/^checksum_sha256=/{sub(/^checksum_sha256=/,""); print}' "$manifest_file")"
if [[ -z "$expected" ]]; then
  echo "[verify-package] FAIL reason=manifest-checksum-empty"
  echo "next: regenerate package; manifest format invalid"
  exit 1
fi

actual=""
if command -v shasum >/dev/null 2>&1; then
  actual="$(shasum -a 256 "$PKG_PATH" | awk '{print $1}')"
elif command -v sha256sum >/dev/null 2>&1; then
  actual="$(sha256sum "$PKG_PATH" | awk '{print $1}')"
else
  echo "[verify-package] FAIL reason=no-sha-tool"
  echo "next: install shasum/sha256sum and retry"
  exit 1
fi

if [[ "$actual" != "$expected" ]]; then
  echo "[verify-package] FAIL reason=checksum-mismatch"
  echo "next: regenerate artifact and checksum, then retry"
  exit 1
fi

echo "[verify-package] PASS reason=checksum-and-manifest-verified"