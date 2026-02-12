#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

out="$(./scripts/lan-doctor.sh "$tmp/install" "$HOME/.config/lan/config.json" 2>&1 || true)"
echo "$out" | grep -q "\[doctor\] SUMMARY" || { echo "[doctor-test] FAIL reason=summary-missing"; echo "$out"; exit 1; }
echo "$out" | grep -q "\[doctor\] PASS\|\[doctor\] FAIL" || { echo "[doctor-test] FAIL reason=verdict-missing"; echo "$out"; exit 1; }

echo "[doctor-test] PASS reason=doctor-diagnostics-covered"