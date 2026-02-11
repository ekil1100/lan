#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

total=0; passed=0; failed=0
failures=""

check() {
  local gate="$1" item="$2" cmd="$3"
  total=$((total+1))
  if eval "$cmd" >/dev/null 2>&1; then
    passed=$((passed+1))
    echo "[beta-entry] PASS gate=$gate item=$item"
  else
    failed=$((failed+1))
    failures+="$gate/$item;"
    echo "[beta-entry] FAIL gate=$gate item=$item"
  fi
}

# A. 能力可用
check "capability" "build" "zig build"
check "capability" "smoke" "./scripts/smoke.sh"
check "capability" "release-notes" "./scripts/test-release-notes.sh"
check "capability" "support-bundle" "./scripts/test-support-bundle.sh"

# B. 回归门禁
check "regression" "r9-ops" "make r9-ops-readiness-regression"
check "regression" "ci-parity" "rg -q r9-ops-readiness-regression .github/workflows/ci.yml"

# C. 稳定性基线
check "stability" "zig-test" "zig build test"
check "stability" "troubleshooting-doc" "test -f docs/ops/troubleshooting.md"

# D. 发布支持
check "release-support" "install-verify-doc" "test -f docs/release/beta-candidate-install-verify.md"
check "release-support" "checklist-doc" "test -f docs/release/beta-entry-checklist.md"

rate=0
[[ "$total" -gt 0 ]] && rate=$((passed*100/total))

echo ""
echo "[beta-entry] SUMMARY total=$total passed=$passed failed=$failed pass_rate=${rate}%"
if [[ "$failed" -gt 0 ]]; then
  echo "[beta-entry] FAILED_ITEMS ${failures}"
  echo "next: fix failed items and rerun ./scripts/verify-beta-entry.sh"
  exit 1
fi
echo "[beta-entry] PASS all_gates_passed"