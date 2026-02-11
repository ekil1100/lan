#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_preflight_test_$(date +%s)"
trap 'chmod -R u+w "$tmp_dir" 2>/dev/null || true; rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

# pass path
ok_out="$(SHELL=/bin/bash ./scripts/preflight.sh "$tmp_dir/bin" 2>&1 || true)"
echo "$ok_out" | grep -q "\[preflight\] PASS" || { echo "[preflight-test] FAIL reason=pass-case-failed"; echo "$ok_out"; exit 1; }

# fail path: target is file
file_target="$tmp_dir/file-target"
echo x > "$file_target"
bad_out="$(SHELL=/bin/bash ./scripts/preflight.sh "$file_target" 2>&1 || true)"
echo "$bad_out" | grep -q "\[preflight\] FAIL" || { echo "[preflight-test] FAIL reason=fail-case-missing"; echo "$bad_out"; exit 1; }
echo "$bad_out" | grep -q "next:" || { echo "[preflight-test] FAIL reason=next-step-missing"; echo "$bad_out"; exit 1; }

echo "[preflight-test] PASS reason=preflight-pass-fail-covered"
