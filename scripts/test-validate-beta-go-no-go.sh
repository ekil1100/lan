#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_go_no_go_validate_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

bad="$tmp_dir/bad.md"
cat > "$bad" <<'EOF'
# Report
pass_rate: 80%
EOF
bad_out="$(./scripts/validate-beta-go-no-go.sh "$bad" 2>&1 || true)"
echo "$bad_out" | grep -q "\[go-no-go-validate\] FAIL" || { echo "[go-no-go-validate-test] FAIL reason=bad-case-not-fail"; echo "$bad_out"; exit 1; }
echo "$bad_out" | grep -q "next:" || { echo "[go-no-go-validate-test] FAIL reason=next-missing"; echo "$bad_out"; exit 1; }

good="$tmp_dir/good.md"
cat > "$good" <<'EOF'
pass_rate: 95%
failed_items: -
pending_items: B1/DEV-02(running)
Owner
Mitigation Action
Due Time
GO because trial is stable and no P0/P1 risk.
R-001 | P2 | network jitter | alice | tune retry threshold | 2026-02-13 12:00 CST | Open
EOF
good_out="$(./scripts/validate-beta-go-no-go.sh "$good" 2>&1 || true)"
echo "$good_out" | grep -q "\[go-no-go-validate\] PASS" || { echo "[go-no-go-validate-test] FAIL reason=good-case-not-pass"; echo "$good_out"; exit 1; }

echo "[go-no-go-validate-test] PASS reason=validator-covered"