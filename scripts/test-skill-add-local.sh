#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_skill_add_test_$(date +%s)"
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/src-ok" "$tmp_dir/src-bad" "$tmp_dir/home"

cat > "$tmp_dir/src-ok/manifest.json" <<'JSON'
{
  "name": "demo-skill",
  "version": "1.0.0",
  "entry": "run.sh",
  "tools": ["read"],
  "permissions": ["workspace.read"]
}
JSON

cat > "$tmp_dir/src-bad/manifest.json" <<'JSON'
{
  "name": "",
  "version": "1.0.0"
}
JSON

ok_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill add "$tmp_dir/src-ok" 2>&1 || true)"
echo "$ok_out" | grep -q "Skill installed:" || { echo "[skill-add] FAIL reason=install-success-missing"; echo "$ok_out"; exit 1; }

echo "$ok_out" | grep -q "name=demo-skill" || { echo "[skill-add] FAIL reason=name-missing"; echo "$ok_out"; exit 1; }
echo "$ok_out" | grep -q "perms=\[" || { echo "[skill-add] FAIL reason=permissions-hint-missing"; echo "$ok_out"; exit 1; }

list_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$list_out" | grep -q "name=demo-skill" || { echo "[skill-add] FAIL reason=list-missing-installed"; echo "$list_out"; exit 1; }
echo "$list_out" | grep -q "perms=\[" || { echo "[skill-add] FAIL reason=list-permissions-missing"; echo "$list_out"; exit 1; }

bad_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill add "$tmp_dir/src-bad" 2>&1 || true)"
echo "$bad_out" | grep -q "Skill install failed" || { echo "[skill-add] FAIL reason=invalid-manifest-not-failed"; echo "$bad_out"; exit 1; }
echo "$bad_out" | grep -q "next:" || { echo "[skill-add] FAIL reason=next-step-missing"; echo "$bad_out"; exit 1; }

echo "[skill-add] PASS reason=local-install-and-validation-ok"
