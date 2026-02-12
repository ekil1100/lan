#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Test missing name
out1="$($BINARY skill info 2>&1 || true)"
echo "$out1" | grep -q "missing name" || { echo "[skill-info-test] FAIL reason=missing-name-check"; exit 1; }
echo "$out1" | grep -q "next:" || { echo "[skill-info-test] FAIL reason=missing-next-step"; exit 1; }

# Test not found
out2="$($BINARY skill info nonexistent-skill-xyz 2>&1 || true)"
echo "$out2" | grep -q "not found" || { echo "[skill-info-test] FAIL reason=not-found-check"; exit 1; }

# Test valid skill (use hello-world if available, otherwise skip)
if $BINARY skill list 2>&1 | grep -q "hello-world"; then
  out3="$($BINARY skill info hello-world 2>&1)"
  echo "$out3" | grep -q "name=" || { echo "[skill-info-test] FAIL reason=name-missing"; exit 1; }
  echo "$out3" | grep -q "version=" || { echo "[skill-info-test] FAIL reason=version-missing"; exit 1; }
  echo "$out3" | grep -q "path=" || { echo "[skill-info-test] FAIL reason=path-missing"; exit 1; }
fi

echo "[skill-info-test] PASS reason=skill-info-covered"