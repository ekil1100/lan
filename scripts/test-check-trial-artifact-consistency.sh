#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp=".lan_trial_artifact_consistency_test_$(date +%s)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/snap-1"

cat > "$tmp/tracker.md" <<'EOF'
| Batch | Device ID | Owner | OS/Version | Arch | Lan Version | Package | Install Path | Status | Issue Severity | Issue Link/Note | Last Update |
|---|---|---|---|---|---|---|---|---|---|---|---|
| B1 | D1 | like | macOS | arm64 | v | p | ~/.local/bin | Running | - | - | now |
EOF

cat > "$tmp/summary.json" <<'EOF'
{"failed_items":"-","pending_items":"B1/D1(running)"}
EOF

touch "$tmp/snap-1/results.jsonl" "$tmp/snap-1/report-mapping.json"
ok="$(./scripts/check-trial-artifact-consistency.sh "$tmp/tracker.md" "$tmp/summary.json" "$tmp/snap-1" 2>&1 || true)"
echo "$ok" | grep -q "\[trial-artifact-check\] PASS" || { echo "[trial-artifact-check-test] FAIL reason=pass-missing"; echo "$ok"; exit 1; }

rm -f "$tmp/snap-1/report-mapping.json"
bad="$(./scripts/check-trial-artifact-consistency.sh "$tmp/tracker.md" "$tmp/summary.json" "$tmp/snap-1" 2>&1 || true)"
echo "$bad" | grep -q "\[trial-artifact-check\] FAIL" || { echo "[trial-artifact-check-test] FAIL reason=fail-missing"; echo "$bad"; exit 1; }
echo "$bad" | grep -q "next:" || { echo "[trial-artifact-check-test] FAIL reason=next-missing"; echo "$bad"; exit 1; }

echo "[trial-artifact-check-test] PASS reason=consistency-check-covered"