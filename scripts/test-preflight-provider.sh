#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Without LAN_PROVIDER_URL — should still PASS (no WARN)
out="$(LAN_PROVIDER_URL="" ./scripts/preflight.sh "$tmp/install" 2>&1 || true)"
echo "$out" | grep -q "\[preflight\] PASS" || { echo "[preflight-provider-test] FAIL reason=no-url-should-pass"; echo "$out"; exit 1; }

# With unreachable provider — should PASS with WARN
out2="$(LAN_PROVIDER_URL="http://192.0.2.1:1" ./scripts/preflight.sh "$tmp/install2" 2>&1 || true)"
echo "$out2" | grep -q "\[preflight\] PASS" || { echo "[preflight-provider-test] FAIL reason=unreachable-should-still-pass"; echo "$out2"; exit 1; }
echo "$out2" | grep -q "WARN\|provider_unreachable" || { echo "[preflight-provider-test] FAIL reason=warn-missing"; echo "$out2"; exit 1; }

echo "[preflight-provider-test] PASS reason=provider-integration-covered"