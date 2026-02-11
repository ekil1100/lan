#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_install_conflict_test_$(date +%s)"
trap 'chmod -R u+w "$tmp_dir" 2>/dev/null || true; rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[install-conflict] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\(.*\)$/\1/p')"

# conflict 1: target path is a file
file_target="$tmp_dir/target-file"
echo x > "$file_target"
out1="$(./scripts/install.sh "$pkg" "$file_target" 2>&1 || true)"
echo "$out1" | grep -q "Install failed: target path is a file" || { echo "[install-conflict] FAIL reason=file-conflict-not-detected"; echo "$out1"; exit 1; }
echo "$out1" | grep -q "next:" || { echo "[install-conflict] FAIL reason=file-conflict-next-missing"; exit 1; }

# conflict 2: lan already a directory
dir_target="$tmp_dir/bin"
mkdir -p "$dir_target/lan"
out2="$(./scripts/install.sh "$pkg" "$dir_target" 2>&1 || true)"
echo "$out2" | grep -q "conflict" || { echo "[install-conflict] FAIL reason=lan-dir-conflict-not-detected"; echo "$out2"; exit 1; }
echo "$out2" | grep -q "next:" || { echo "[install-conflict] FAIL reason=lan-dir-next-missing"; exit 1; }

# conflict 3: permission denied (best effort)
ro_target="$tmp_dir/readonly"
mkdir -p "$ro_target"
chmod 555 "$ro_target"
out3="$(./scripts/install.sh "$pkg" "$ro_target" 2>&1 || true)"
chmod 755 "$ro_target"
echo "$out3" | grep -Eq "not writable|cannot create target directory|Install failed" || { echo "[install-conflict] FAIL reason=permission-path-unexplained"; echo "$out3"; exit 1; }
echo "$out3" | grep -q "next:" || { echo "[install-conflict] FAIL reason=permission-next-missing"; exit 1; }

echo "[install-conflict] PASS reason=file-dir-permission-conflicts-covered"
