#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_release_notes_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

out="$tmp_dir/release-notes.md"
cmd_out="$(./scripts/release-notes.sh HEAD~5..HEAD "$out" 2>&1 || true)"
echo "$cmd_out" | grep -q "\[release-notes\] PASS output=" || { echo "[release-notes-test] FAIL reason=generator-failed"; echo "$cmd_out"; exit 1; }

[[ -f "$out" ]] || { echo "[release-notes-test] FAIL reason=output-missing"; exit 1; }
grep -q "## New" "$out" || { echo "[release-notes-test] FAIL reason=new-section-missing"; exit 1; }
grep -q "## Fixes" "$out" || { echo "[release-notes-test] FAIL reason=fixes-section-missing"; exit 1; }
grep -q "## Known Issues" "$out" || { echo "[release-notes-test] FAIL reason=known-issues-section-missing"; exit 1; }
grep -q "## Commit Summary" "$out" || { echo "[release-notes-test] FAIL reason=commit-summary-missing"; exit 1; }

echo "[release-notes-test] PASS reason=stub-generated"
