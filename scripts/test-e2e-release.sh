#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_e2e_release_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/install"

# Step 1: package
echo "[e2e-release] step=package"
pkg_out="$(make package-release 2>&1)"
artifact="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"
if [[ -z "$artifact" || ! -f "$artifact" ]]; then
  echo "[e2e-release] FAIL step=package reason=artifact_missing"
  echo "$pkg_out"
  exit 1
fi
echo "[e2e-release] PASS step=package artifact=$artifact"

# Step 2: install
echo "[e2e-release] step=install"
install_out="$(./scripts/install.sh "$artifact" "$tmp_dir/install" 2>&1 || true)"
binary="$tmp_dir/install/lan"
if [[ ! -x "$binary" ]]; then
  echo "[e2e-release] FAIL step=install reason=binary_not_executable"
  echo "$install_out"
  exit 1
fi
echo "[e2e-release] PASS step=install binary=$binary"

# Step 3: post-install health
echo "[e2e-release] step=health"
health_out="$(./scripts/post-install-health.sh "$binary" 2>&1 || true)"
if echo "$health_out" | grep -q "\[post-install-health\] PASS"; then
  echo "[e2e-release] PASS step=health"
else
  echo "[e2e-release] FAIL step=health"
  echo "$health_out"
  exit 1
fi

echo "[e2e-release] PASS all_steps_passed"