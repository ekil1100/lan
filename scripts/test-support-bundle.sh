#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_support_bundle_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/config" "$tmp_dir/logs" "$tmp_dir/out"

cat > "$tmp_dir/config/settings.yml" <<EOF
api_key: abcdef
proxy: direct
password = hello
EOF

cat > "$tmp_dir/logs/history.log" <<EOF
line1
line2
EOF

out="$(./scripts/support-bundle.sh "$tmp_dir/out" "$tmp_dir/config" "$tmp_dir/logs/history.log" 2>&1 || true)"
echo "$out" | grep -q "\[support-bundle\] PASS output=" || { echo "[support-bundle-test] FAIL reason=script-failed"; echo "$out"; exit 1; }

bundle="$(echo "$out" | sed -n 's/^\[support-bundle\] PASS output=\(.*\)$/\1/p')"
[[ -f "$bundle" ]] || { echo "[support-bundle-test] FAIL reason=bundle-missing"; exit 1; }

name="$(basename "$bundle")"
echo "$name" | grep -Eq '^lan-support-[a-z0-9._-]+-[0-9]{8}-[0-9]{6}\.tar\.gz$' || { echo "[support-bundle-test] FAIL reason=name-format-invalid"; echo "$name"; exit 1; }

extract="$tmp_dir/extract"
mkdir -p "$extract"
tar -xzf "$bundle" -C "$extract"

grep -q "version=" "$extract/version.txt" || { echo "[support-bundle-test] FAIL reason=version-missing"; exit 1; }
grep -q "\*\*\*REDACTED\*\*\*" "$extract/config-summary.txt" || { echo "[support-bundle-test] FAIL reason=redaction-missing"; exit 1; }
grep -q "line2" "$extract/recent.log" || { echo "[support-bundle-test] FAIL reason=log-missing"; exit 1; }

echo "[support-bundle-test] PASS reason=bundle-contains-required-artifacts"