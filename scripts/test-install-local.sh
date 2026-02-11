#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_install_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[install-test] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg_path="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\(.*\)$/\1/p')"

ok_out="$(./scripts/install.sh "$pkg_path" "$tmp_dir/bin" 2>&1 || true)"
echo "$ok_out" | grep -q "Install success:" || { echo "[install-test] FAIL reason=install-success-missing"; echo "$ok_out"; exit 1; }
[[ -x "$tmp_dir/bin/lan" ]] || { echo "[install-test] FAIL reason=installed-binary-missing"; exit 1; }

ver_out="$($tmp_dir/bin/lan --version 2>&1 || true)"
echo "$ver_out" | grep -q "^lan version=" || { echo "[install-test] FAIL reason=installed-version-check-failed"; echo "$ver_out"; exit 1; }

bad_out="$(./scripts/install.sh "$tmp_dir/no-such.tar.gz" "$tmp_dir/bin2" 2>&1 || true)"
echo "$bad_out" | grep -q "Install failed:" || { echo "[install-test] FAIL reason=missing-package-not-failed"; echo "$bad_out"; exit 1; }
echo "$bad_out" | grep -q "next:" || { echo "[install-test] FAIL reason=next-step-missing"; echo "$bad_out"; exit 1; }

echo "[install-test] PASS reason=local-tarball-install-ok"
