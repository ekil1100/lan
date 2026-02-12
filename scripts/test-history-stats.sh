#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Test stats output
out="$($BINARY history stats 2>&1)"
echo "$out" | grep -q '"total":' || { echo "[history-stats-test] FAIL reason=total-missing"; exit 1; }
echo "$out" | grep -q '"system":' || { echo "[history-stats-test] FAIL reason=system-missing"; exit 1; }
echo "$out" | grep -q '"user":' || { echo "[history-stats-test] FAIL reason=user-missing"; exit 1; }
echo "$out" | grep -q '"assistant":' || { echo "[history-stats-test] FAIL reason=assistant-missing"; exit 1; }
echo "$out" | grep -q '"file_bytes":' || { echo "[history-stats-test] FAIL reason=file_bytes-missing"; exit 1; }

# Validate JSON
python3 -c "import json; json.loads('$out')" 2>/dev/null || { echo "[history-stats-test] FAIL reason=invalid-json"; exit 1; }

echo "[history-stats-test] PASS reason=all-fields-present"