#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

out="$(./zig-out/bin/lan --version 2>&1 || true)"

echo "$out" | grep -q "^lan version=" || { echo "[version] FAIL reason=version-prefix-missing"; echo "$out"; exit 1; }
echo "$out" | grep -q " commit=" || { echo "[version] FAIL reason=commit-missing"; echo "$out"; exit 1; }
echo "$out" | grep -q " build_time=" || { echo "[version] FAIL reason=build-time-missing"; echo "$out"; exit 1; }

echo "[version] PASS reason=version-metadata-present"
