#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_release_notes_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir"

out="$tmp_dir/release-notes.md"

# missing params should fail with hint
miss_out="$(./scripts/release-notes.sh HEAD~5..HEAD "$out" 2>&1 || true)"
echo "$miss_out" | grep -q "\[release-notes\] FAIL reason=missing_required_metadata" || { echo "[release-notes-test] FAIL reason=missing-metadata-not-detected"; echo "$miss_out"; exit 1; }
echo "$miss_out" | grep -q "next:" || { echo "[release-notes-test] FAIL reason=missing-metadata-next-missing"; echo "$miss_out"; exit 1; }

# generate with valid params
cmd_out="$(./scripts/release-notes.sh HEAD~5..HEAD "$out" "v0.1.0" "2026-02-11" "abc1234" 2>&1 || true)"
echo "$cmd_out" | grep -q "\[release-notes\] PASS output=" || { echo "[release-notes-test] FAIL reason=generator-failed"; echo "$cmd_out"; exit 1; }

[[ -f "$out" ]] || { echo "[release-notes-test] FAIL reason=output-missing"; exit 1; }
grep -qF "**Version**: v0.1.0" "$out" || { echo "[release-notes-test] FAIL reason=version-missing"; cat "$out"; exit 1; }
grep -qF "**Date**: 2026-02-11" "$out" || { echo "[release-notes-test] FAIL reason=date-missing"; cat "$out"; exit 1; }
grep -qF "**Commit**: abc1234" "$out" || { echo "[release-notes-test] FAIL reason=commit-missing"; cat "$out"; exit 1; }

# auto-categorization: at least one section should exist (we have feat/docs/ci commits in recent history)
has_section=0
for s in "Features" "Fixes" "Documentation" "CI / Build" "Other"; do
  grep -q "## .*${s}" "$out" && has_section=1
done
[[ "$has_section" -eq 1 ]] || { echo "[release-notes-test] FAIL reason=no-categorized-sections"; cat "$out"; exit 1; }

echo "[release-notes-test] PASS reason=auto-categorized"