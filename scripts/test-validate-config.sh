#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

# Bad: missing required fields
echo '{}' > "$tmp/bad.json"
bad_out="$(./scripts/validate-config.sh "$tmp/bad.json" 2>&1 || true)"
echo "$bad_out" | grep -q "\[validate-config\] FAIL" || { echo "[validate-config-test] FAIL reason=bad-not-fail"; echo "$bad_out"; exit 1; }

# Good: has required fields
cat > "$tmp/good.json" <<'EOF'
{"provider":{"url":"https://api.openai.com","model":"gpt-4","api_key":"sk-test"}}
EOF
good_out="$(./scripts/validate-config.sh "$tmp/good.json" 2>&1 || true)"
echo "$good_out" | grep -q "\[validate-config\] PASS" || { echo "[validate-config-test] FAIL reason=good-not-pass"; echo "$good_out"; exit 1; }

# Missing file
miss_out="$(./scripts/validate-config.sh "$tmp/nonexist.json" 2>&1 || true)"
echo "$miss_out" | grep -q "\[validate-config\] FAIL" || { echo "[validate-config-test] FAIL reason=missing-not-fail"; exit 1; }

echo "[validate-config-test] PASS reason=config-validation-covered"