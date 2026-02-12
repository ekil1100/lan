#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

INSTALL_DIR="${1:-$HOME/.local/bin}"
CONFIG="${2:-$HOME/.config/lan/config.json}"

total=0; pass=0; warn=0; fail=0

run_check() {
  local name="$1" cmd="$2" warn_ok="${3:-false}"
  total=$((total+1))
  local out
  out="$(eval "$cmd" 2>&1 || true)"
  if echo "$out" | grep -q "PASS"; then
    pass=$((pass+1))
    echo "[doctor] PASS check=$name"
  elif [[ "$warn_ok" == "true" ]]; then
    warn=$((warn+1))
    echo "[doctor] WARN check=$name"
  else
    fail=$((fail+1))
    echo "[doctor] FAIL check=$name"
  fi
}

echo "[doctor] Running diagnostics..."
echo ""

# 1) Preflight
run_check "preflight" "./scripts/preflight.sh '$INSTALL_DIR'"

# 2) Config validation
run_check "config" "./scripts/validate-config.sh '$CONFIG'"

# 3) Provider health (WARN-only)
if [[ -n "${LAN_PROVIDER_URL:-}" ]]; then
  run_check "provider" "./scripts/check-provider-health.sh '$LAN_PROVIDER_URL' 5" true
else
  total=$((total+1)); warn=$((warn+1))
  echo "[doctor] WARN check=provider reason=LAN_PROVIDER_URL_not_set"
fi

# 4) Build sanity
run_check "build" "zig build"

echo ""
echo "[doctor] SUMMARY total=$total pass=$pass warn=$warn fail=$fail"

if [[ "$fail" -gt 0 ]]; then
  echo "[doctor] FAIL"
  echo "next: fix failed checks above and rerun ./scripts/lan-doctor.sh"
  exit 1
fi

echo "[doctor] PASS (${warn} warning(s))"