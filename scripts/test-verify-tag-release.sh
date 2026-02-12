#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

out="$(./scripts/verify-tag-release.sh v0.0.0-test 2>&1)"
echo "$out" | grep -q "\[verify-tag-release\] PASS" || { echo "[verify-tag-release-test] FAIL reason=not-pass"; echo "$out"; exit 1; }
echo "$out" | grep -q "artifact=" || { echo "[verify-tag-release-test] FAIL reason=no-artifact"; exit 1; }

echo "[verify-tag-release-test] PASS reason=tag-verification-covered"