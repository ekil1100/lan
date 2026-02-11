#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_skill_update_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/src-v1" "$tmp_dir/src-v2" "$tmp_dir/src-no-target" "$tmp_dir/home"

cat > "$tmp_dir/src-v1/manifest.json" <<'JSON'
{
  "name": "demo-skill",
  "version": "1.0.0",
  "entry": "run.sh",
  "tools": ["read"],
  "permissions": ["workspace.read"]
}
JSON

cat > "$tmp_dir/src-v2/manifest.json" <<'JSON'
{
  "name": "demo-skill",
  "version": "1.1.0",
  "entry": "run.sh",
  "tools": ["read"],
  "permissions": ["workspace.read"]
}
JSON

cat > "$tmp_dir/src-no-target/manifest.json" <<'JSON'
{
  "name": "ghost-skill",
  "version": "1.0.1",
  "entry": "run.sh",
  "tools": ["read"],
  "permissions": ["workspace.read"]
}
JSON

HOME="$tmp_dir/home" ./zig-out/bin/lan skill add "$tmp_dir/src-v1" >/dev/null 2>&1 || {
  echo "[skill-update] FAIL reason=setup-add-failed"
  exit 1
}

before="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$before" | grep -q "version=1.0.0" || { echo "[skill-update] FAIL reason=before-version-missing"; echo "$before"; exit 1; }

upd="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill update "$tmp_dir/src-v2" 2>&1 || true)"
echo "$upd" | grep -q "Skill updated" || { echo "[skill-update] FAIL reason=update-failed"; echo "$upd"; exit 1; }

after="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$after" | grep -q "version=1.1.0" || { echo "[skill-update] FAIL reason=after-version-not-updated"; echo "$after"; exit 1; }

nf="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill update "$tmp_dir/src-no-target" 2>&1 || true)"
echo "$nf" | grep -q "Skill update failed" || { echo "[skill-update] FAIL reason=no-target-not-failed"; echo "$nf"; exit 1; }
echo "$nf" | grep -q "next:" || { echo "[skill-update] FAIL reason=no-target-next-missing"; echo "$nf"; exit 1; }

echo "[skill-update] PASS reason=version-change-and-next-step-ok"
