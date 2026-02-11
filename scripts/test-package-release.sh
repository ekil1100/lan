#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$out" | grep -q "\[package\] PASS artifact=" || { echo "[package-test] FAIL reason=package-step-failed"; echo "$out"; exit 1; }

artifact="$(echo "$out" | sed -n 's/^\[package\] PASS artifact=\(.*\)$/\1/p')"
[[ -f "$artifact" ]] || { echo "[package-test] FAIL reason=artifact-not-found path=$artifact"; exit 1; }

tmp_dir=".lan_pkg_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

tar -xzf "$artifact" -C "$tmp_dir"

found_bin="$(find "$tmp_dir" -name lan -type f | head -n 1)"
found_readme="$(find "$tmp_dir" -name README.md -type f | head -n 1)"
[[ -n "$found_bin" ]] || { echo "[package-test] FAIL reason=bin-missing"; exit 1; }
[[ -n "$found_readme" ]] || { echo "[package-test] FAIL reason=readme-missing"; exit 1; }

base="$(basename "$artifact")"
echo "$base" | grep -Eq '^lan-[0-9]+\.[0-9]+\.[0-9]+-(macos|linux)-[^.]+\.tar\.gz$' || {
  echo "[package-test] FAIL reason=filename-format-invalid name=$base"
  exit 1
}

echo "[package-test] PASS reason=artifact-validated"