#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_upgrade_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin" "$tmp_dir/config"

# Seed config that must be preserved
cat > "$tmp_dir/config/config.json" <<'JSON'
{"provider":"kimi","note":"keep-me"}
JSON

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
echo "$pkg_out" | grep -q "\[package\] PASS artifact=" || { echo "[upgrade-test] FAIL reason=package-failed"; echo "$pkg_out"; exit 1; }
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\(.*\)$/\1/p')"

# First install as baseline
./scripts/install.sh "$pkg" "$tmp_dir/bin" >/dev/null 2>&1 || { echo "[upgrade-test] FAIL reason=baseline-install-failed"; exit 1; }

up_out="$(./scripts/upgrade.sh "$pkg" "$tmp_dir/bin" "$tmp_dir/config" 2>&1 || true)"
echo "$up_out" | grep -q "Upgrade success:" || { echo "[upgrade-test] FAIL reason=upgrade-failed"; echo "$up_out"; exit 1; }
echo "$up_out" | grep -q "version_before:" || { echo "[upgrade-test] FAIL reason=version-before-missing"; echo "$up_out"; exit 1; }
echo "$up_out" | grep -q "version_after:" || { echo "[upgrade-test] FAIL reason=version-after-missing"; echo "$up_out"; exit 1; }

# Config preserved
[[ -f "$tmp_dir/config/config.json" ]] || { echo "[upgrade-test] FAIL reason=config-missing"; exit 1; }
grep -q "keep-me" "$tmp_dir/config/config.json" || { echo "[upgrade-test] FAIL reason=config-not-preserved"; exit 1; }

# Error path + next step
bad_out="$(./scripts/upgrade.sh "$tmp_dir/nope.tgz" "$tmp_dir/bin" "$tmp_dir/config" 2>&1 || true)"
echo "$bad_out" | grep -q "Upgrade failed:" || { echo "[upgrade-test] FAIL reason=bad-path-not-failed"; echo "$bad_out"; exit 1; }
echo "$bad_out" | grep -q "next:" || { echo "[upgrade-test] FAIL reason=next-step-missing"; echo "$bad_out"; exit 1; }

echo "[upgrade-test] PASS reason=upgrade-config-version-observable"
