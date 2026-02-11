#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Clear history
out="$($BINARY history clear 2>&1)"
echo "$out" | grep -q "History cleared" || { echo "[history-clear-test] FAIL reason=clear-message-missing"; echo "$out"; exit 1; }

# Export after clear should return empty array
export_out="$($BINARY history export 2>&1)"
count="$(echo "$export_out" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))")"
[[ "$count" == "0" ]] || { echo "[history-clear-test] FAIL reason=not_empty_after_clear count=$count"; exit 1; }

echo "[history-clear-test] PASS reason=clear-and-verify-covered"