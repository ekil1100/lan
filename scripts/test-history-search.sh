#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

BINARY="./zig-out/bin/lan"

# Search for known system message keyword
out="$($BINARY history search "Lan" 2>&1)"
echo "$out" | python3 -c "import sys,json; d=json.load(sys.stdin); assert len(d)>0, 'no matches'" 2>/dev/null || {
  echo "[history-search-test] FAIL reason=no_matches_for_known_keyword"
  echo "$out"
  exit 1
}

# Search for nonexistent keyword should return empty array
empty="$($BINARY history search "ZZZZNOTFOUND999" 2>&1)"
echo "$empty" | python3 -c "import sys,json; d=json.load(sys.stdin); assert len(d)==0, f'expected empty got {len(d)}'" 2>/dev/null || {
  echo "[history-search-test] FAIL reason=non_empty_for_missing_keyword"
  echo "$empty"
  exit 1
}

echo "[history-search-test] PASS reason=search-filter-covered"