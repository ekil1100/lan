#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

out="$($BINARY help 2>&1)"
for cmd in "skill list" "skill add" "skill remove" "history export" "history search" "history clear" "config init"; do
  echo "$out" | grep -q "$cmd" || { echo "[cli-help-test] FAIL reason=missing_cmd cmd='$cmd'"; exit 1; }
done
echo "$out" | grep -q "doctor" || { echo "[cli-help-test] FAIL reason=missing_doctor"; exit 1; }

echo "[cli-help-test] PASS reason=all-subcommands-listed"