#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_skill_remove_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/src-ok" "$tmp_dir/home"

cat > "$tmp_dir/src-ok/manifest.json" <<'JSON'
{
  "name": "demo-skill",
  "version": "1.0.0",
  "entry": "run.sh",
  "tools": ["read"],
  "permissions": ["workspace.read"]
}
JSON

HOME="$tmp_dir/home" ./zig-out/bin/lan skill add "$tmp_dir/src-ok" >/dev/null 2>&1 || {
  echo "[skill-remove] FAIL reason=setup-add-failed"
  exit 1
}

rm_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill remove demo-skill 2>&1 || true)"
echo "$rm_out" | grep -q "Skill removed: name=demo-skill" || { echo "[skill-remove] FAIL reason=remove-failed"; echo "$rm_out"; exit 1; }

list_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$list_out" | grep -q "No skills installed" || { echo "[skill-remove] FAIL reason=list-not-empty-after-remove"; echo "$list_out"; exit 1; }

nf_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill remove no-such-skill 2>&1 || true)"
echo "$nf_out" | grep -q "Skill remove failed: not found" || { echo "[skill-remove] FAIL reason=not-found-unexplained"; echo "$nf_out"; exit 1; }
echo "$nf_out" | grep -q "next:" || { echo "[skill-remove] FAIL reason=next-step-missing"; echo "$nf_out"; exit 1; }

echo "[skill-remove] PASS reason=remove-and-list-consistency-ok"
