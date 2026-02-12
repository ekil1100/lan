#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Test config reload (will use existing config)
out="$($BINARY config reload 2>&1 || true)"

# Should either succeed or fail gracefully
if echo "$out" | grep -q "reloaded successfully"; then
  echo "[config-reload-test] PASS reason=reload-success"
elif echo "$out" | grep -q "Config reload failed"; then
  echo "[config-reload-test] PASS reason=reload-failed-gracefully"
else
  echo "[config-reload-test] FAIL reason=unexpected-output"
  echo "$out"
  exit 1
fi