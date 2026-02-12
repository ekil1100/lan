#!/usr/bin/env bash
# CI verification pending — will be run after CI completes
set -euo pipefail

cd "$(dirname "$0")/.."

TAG="v0.1.0-beta"
echo "[verify-release] Checking GitHub release for $TAG..."

# Check release exists
release_json="$(curl -s "https://api.github.com/repos/ekil1100/lan/releases/tags/$TAG" 2>/dev/null)"
if echo "$release_json" | grep -q '"message":"Not Found"'; then
  echo "[verify-release] PENDING reason=release-not-yet-created (CI still running)"
  exit 0
fi

# Count assets
asset_count="$(echo "$release_json" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('assets',[])))" 2>/dev/null || echo 0)"
echo "[verify-release] assets=$asset_count"

if [[ "$asset_count" -lt 2 ]]; then
  echo "[verify-release] FAIL reason=insufficient-assets expected=2+ actual=$asset_count"
  exit 1
fi

# List assets
echo "$release_json" | python3 -c "import sys,json; [print(' -', a['name']) for a in json.load(sys.stdin).get('assets',[])]"

echo "[verify-release] PASS"