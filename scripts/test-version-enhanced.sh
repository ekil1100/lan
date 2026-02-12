#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Test lan version (human)
out1="$($BINARY version 2>&1)"
echo "$out1" | grep -q "version=" || { echo "[version-test] FAIL reason=version-missing-human"; exit 1; }
echo "$out1" | grep -q "commit=" || { echo "[version-test] FAIL reason=commit-missing-human"; exit 1; }
echo "$out1" | grep -q "build_time=" || { echo "[version-test] FAIL reason=build_time-missing-human"; exit 1; }

# Test lan version --json
out2="$($BINARY version --json 2>&1)"
echo "$out2" | grep -q '"version":' || { echo "[version-test] FAIL reason=version-missing-json"; exit 1; }
echo "$out2" | grep -q '"commit":' || { echo "[version-test] FAIL reason=commit-missing-json"; exit 1; }
echo "$out2" | grep -q '"build_time":' || { echo "[version-test] FAIL reason=build_time-missing-json"; exit 1; }

# Validate JSON
python3 -c "import json; json.loads('$out2')" 2>/dev/null || { echo "[version-test] FAIL reason=invalid-json"; exit 1; }

echo "[version-test] PASS reason=version-formats-covered"