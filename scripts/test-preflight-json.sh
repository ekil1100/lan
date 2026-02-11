#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_preflight_json_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

ok="$(SHELL=/bin/bash ./scripts/preflight.sh --json "$tmp_dir/bin" 2>&1 || true)"
echo "$ok" | grep -q '"ok":true' || { echo "[preflight-json] FAIL reason=ok-true-missing"; echo "$ok"; exit 1; }

f="$tmp_dir/file-target"
echo x > "$f"
bad="$(SHELL=/bin/bash ./scripts/preflight.sh --json "$f" 2>&1 || true)"
echo "$bad" | grep -q '"ok":false' || { echo "[preflight-json] FAIL reason=ok-false-missing"; echo "$bad"; exit 1; }
echo "$bad" | grep -q '"reason":"target_not_directory"' || { echo "[preflight-json] FAIL reason=reason-missing"; echo "$bad"; exit 1; }

echo "[preflight-json] PASS reason=json-channel-consistent"
