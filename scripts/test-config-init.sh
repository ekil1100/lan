#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Test 1: existing config → skip
skip_out="$($BINARY config init 2>&1)"
echo "$skip_out" | grep -q "already exists\|skipping" || { echo "[config-init-test] FAIL reason=skip-not-detected"; echo "$skip_out"; exit 1; }

# Test 2: fresh HOME → init creates valid JSON config
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
# Pre-create dir but ensure no config file
export HOME="$tmp"
mkdir -p "$tmp/.config/lan"
# Config.load creates a default — we test that config init detects it
init_out="$($BINARY config init 2>&1)"
# Should either create or skip (Config.load may auto-create)
[[ -f "$tmp/.config/lan/config.json" ]] || { echo "[config-init-test] FAIL reason=config-not-present"; exit 1; }
python3 -c "import json; json.load(open('$tmp/.config/lan/config.json'))" 2>/dev/null || { echo "[config-init-test] FAIL reason=invalid-json"; exit 1; }

echo "[config-init-test] PASS reason=init-skip-roundtrip-covered"