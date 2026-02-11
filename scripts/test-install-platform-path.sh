#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_install_platform_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/home"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[install-platform] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"

# linux default path
linux_out="$(HOME="$tmp_dir/home" PLATFORM_OVERRIDE=Linux ./scripts/install.sh "$pkg" 2>&1 || true)"
echo "$linux_out" | grep -q "Install success: $tmp_dir/home/.local/bin/lan" || { echo "[install-platform] FAIL reason=linux-default-path-wrong"; echo "$linux_out"; exit 1; }

# macos default path
rm -f "$tmp_dir/home/bin/lan"
mac_out="$(HOME="$tmp_dir/home" PLATFORM_OVERRIDE=Darwin ./scripts/install.sh "$pkg" 2>&1 || true)"
echo "$mac_out" | grep -q "Install success: $tmp_dir/home/bin/lan" || { echo "[install-platform] FAIL reason=mac-default-path-wrong"; echo "$mac_out"; exit 1; }

# conflict + next-step still present
echo x > "$tmp_dir/target-file"
bad_out="$(HOME="$tmp_dir/home" ./scripts/install.sh "$pkg" "$tmp_dir/target-file" 2>&1 || true)"
echo "$bad_out" | grep -q "Install failed: target path is a file" || { echo "[install-platform] FAIL reason=conflict-check-missing"; echo "$bad_out"; exit 1; }
echo "$bad_out" | grep -q "next:" || { echo "[install-platform] FAIL reason=next-step-missing"; echo "$bad_out"; exit 1; }

echo "[install-platform] PASS reason=platform-default-and-conflict-check-ok"