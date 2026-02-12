#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Test that multi-provider config is valid JSON
json="docs/config/config.multi-provider.json"
python3 -c "import json; d=json.load(open('$json')); assert 'providers' in d; assert len(d['providers']) >= 1" 2>/dev/null || {
  echo "[multi-provider-test] FAIL reason=invalid-json-or-missing-providers"
  exit 1
}

# Test backward compatibility: single provider config should still work
single="docs/config/config.template.json"
python3 -c "import json; json.load(open('$single'))" 2>/dev/null || {
  echo "[multi-provider-test] FAIL reason=single-provider-config-invalid"
  exit 1
}

# Verify providers array has required fields
python3 -c "
import json,sys
with open('$json') as f:
    d=json.load(f)
for p in d['providers']:
    assert 'name' in p, 'missing name'
    assert 'url' in p, 'missing url'
    assert 'api_key' in p, 'missing api_key'
    assert 'model' in p, 'missing model'
print('providers_fields_ok')
" 2>/dev/null || { echo "[multi-provider-test] FAIL reason=missing-provider-fields"; exit 1; }

echo "[multi-provider-test] PASS reason=multi-provider-config-valid"