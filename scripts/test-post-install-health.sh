#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_post_install_health_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

# ensure binary exists for success path
zig build >/dev/null
ok_out="$(./scripts/post-install-health.sh ./zig-out/bin/lan 2>&1 || true)"
echo "$ok_out" | grep -q "\[post-install-health\] PASS summary=all_checks_passed" || {
  echo "[post-install-health-test] FAIL reason=pass-summary-missing"
  echo "$ok_out"
  exit 1
}

# failure path 1: missing binary should include next
bad_out="$(./scripts/post-install-health.sh "$tmp_dir/missing-lan" 2>&1 || true)"
echo "$bad_out" | grep -q "\[post-install-health\] FAIL case=binary" || {
  echo "[post-install-health-test] FAIL reason=fail-case-missing"
  echo "$bad_out"
  exit 1
}
echo "$bad_out" | grep -q "next:" || {
  echo "[post-install-health-test] FAIL reason=next-missing"
  echo "$bad_out"
  exit 1
}

# failure path 2: wrong version prefix expectation
bad_ver="$(EXPECT_VERSION_PREFIX='not-a-real-prefix' ./scripts/post-install-health.sh ./zig-out/bin/lan 2>&1 || true)"
echo "$bad_ver" | grep -q "\[post-install-health\] FAIL case=version-readable" || {
  echo "[post-install-health-test] FAIL reason=version-fail-case-missing"
  echo "$bad_ver"
  exit 1
}
echo "$bad_ver" | grep -q "next:" || {
  echo "[post-install-health-test] FAIL reason=version-next-missing"
  echo "$bad_ver"
  exit 1
}

echo "[post-install-health-test] PASS reason=health-check-covered-with-fail-branches"