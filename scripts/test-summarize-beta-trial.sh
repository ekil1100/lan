#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_beta_trial_summary_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

tracker="$tmp_dir/tracker.md"
cat > "$tracker" <<'EOF'
| Batch | Device ID | Owner | OS/Version | Arch | Lan Version | Package | Install Path | Status | Issue Severity | Issue Link/Note | Last Update |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B1 | DEV-01 | like | macOS | arm64 | v0.1.0 | pkg | ~/.local/bin | Pass | - | - | now |
| B1 | DEV-02 | like | macOS | arm64 | v0.1.0 | pkg | ~/.local/bin | Fail | P1 | issue-1 | now |
| B1 | DEV-03 | like | macOS | arm64 | v0.1.0 | pkg | ~/.local/bin | Running | - | - | now |
EOF

out="$(./scripts/summarize-beta-trial.sh "$tracker" "$tmp_dir/out" 2>&1 || true)"
echo "$out" | grep -q "\[beta-trial-summary\] FAIL" || { echo "[beta-trial-summary-test] FAIL reason=expected-fail-not-hit"; echo "$out"; exit 1; }
echo "$out" | grep -q "next:" || { echo "[beta-trial-summary-test] FAIL reason=next-missing"; echo "$out"; exit 1; }
json="$(echo "$out" | sed -n 's/^\[beta-trial-summary\] FAIL json=\([^ ]*\).*/\1/p')"
text="$(echo "$out" | sed -n 's/^\[beta-trial-summary\] FAIL .* text=\([^ ]*\) fail=.*/\1/p')"
[[ -f "$json" ]] || { echo "[beta-trial-summary-test] FAIL reason=json-missing"; exit 1; }
[[ -f "$text" ]] || { echo "[beta-trial-summary-test] FAIL reason=text-missing"; exit 1; }
grep -q '"pass_rate":' "$json" || { echo "[beta-trial-summary-test] FAIL reason=pass-rate-missing"; exit 1; }
grep -q 'failed_items:' "$text" || { echo "[beta-trial-summary-test] FAIL reason=failed-items-missing"; exit 1; }

# multi-batch input (directory) should aggregate and PASS
mkdir -p "$tmp_dir/multi"
cat > "$tmp_dir/multi/b1.md" <<'EOF'
| Batch | Device ID | Owner | OS/Version | Arch | Lan Version | Package | Install Path | Status | Issue Severity | Issue Link/Note | Last Update |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B1 | D1 | like | macOS | arm64 | v | p | ~/.local/bin | Pass | - | - | now |
EOF
cat > "$tmp_dir/multi/b2.md" <<'EOF'
| Batch | Device ID | Owner | OS/Version | Arch | Lan Version | Package | Install Path | Status | Issue Severity | Issue Link/Note | Last Update |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B2 | D2 | like | macOS | arm64 | v | p | ~/.local/bin | Running | - | - | now |
EOF
multi_out="$(./scripts/summarize-beta-trial.sh "$tmp_dir/multi" "$tmp_dir/out2" 2>&1 || true)"
echo "$multi_out" | grep -q "\[beta-trial-summary\] PASS" || { echo "[beta-trial-summary-test] FAIL reason=multi-pass-missing"; echo "$multi_out"; exit 1; }
multi_json="$(echo "$multi_out" | sed -n 's/^\[beta-trial-summary\] PASS json=\([^ ]*\).*/\1/p')"
grep -q '"batch_count":2' "$multi_json" || { echo "[beta-trial-summary-test] FAIL reason=batch-count-missing"; cat "$multi_json"; exit 1; }

echo "[beta-trial-summary-test] PASS reason=machine-human-summary-covered"