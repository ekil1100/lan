#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Test: history export outputs valid JSON with role/content fields
out="$($BINARY history export 2>&1)"

# Must be valid JSON array
echo "$out" | python3 -c "import sys,json; d=json.load(sys.stdin); assert isinstance(d,list)" 2>/dev/null || {
  echo "[history-export-test] FAIL reason=invalid_json"
  echo "$out"
  exit 1
}

# Each entry must have role and content
echo "$out" | python3 -c "
import sys,json
d=json.load(sys.stdin)
for m in d:
    assert 'role' in m, f'missing role: {m}'
    assert 'content' in m, f'missing content: {m}'
" 2>/dev/null || {
  echo "[history-export-test] FAIL reason=missing_fields"
  exit 1
}

echo "[history-export-test] PASS reason=json-with-role-content"