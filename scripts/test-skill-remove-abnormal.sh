#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

tmp_dir=".lan_skill_remove_abnormal_$(date +%s)"
trap 'chmod -R u+w "$tmp_dir" 2>/dev/null || true; rm -rf "$tmp_dir"' EXIT
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

# baseline consistency: add -> list -> remove -> list
HOME="$tmp_dir/home" ./zig-out/bin/lan skill add "$tmp_dir/src-ok" >/dev/null 2>&1 || {
  echo "[skill-remove-abnormal] FAIL reason=setup-add-failed"
  exit 1
}

list_before="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$list_before" | grep -q "name=demo-skill" || { echo "[skill-remove-abnormal] FAIL reason=list-before-missing"; exit 1; }

rm_ok="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill remove demo-skill 2>&1 || true)"
echo "$rm_ok" | grep -q "Skill removed" || { echo "[skill-remove-abnormal] FAIL reason=remove-baseline-failed"; echo "$rm_ok"; exit 1; }

list_after="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$list_after" | grep -q "No skills installed" || { echo "[skill-remove-abnormal] FAIL reason=list-after-not-empty"; exit 1; }

# abnormal 1: not found
not_found="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill remove no-such-skill 2>&1 || true)"
echo "$not_found" | grep -q "not found" || { echo "[skill-remove-abnormal] FAIL reason=not-found-unexplained"; echo "$not_found"; exit 1; }
echo "$not_found" | grep -q "next:" || { echo "[skill-remove-abnormal] FAIL reason=not-found-next-missing"; exit 1; }

# abnormal 2: invalid name
invalid_name="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill remove ../bad 2>&1 || true)"
echo "$invalid_name" | grep -q "invalid name" || { echo "[skill-remove-abnormal] FAIL reason=invalid-name-unexplained"; echo "$invalid_name"; exit 1; }
echo "$invalid_name" | grep -q "next:" || { echo "[skill-remove-abnormal] FAIL reason=invalid-name-next-missing"; exit 1; }

# abnormal 3: permission denied
HOME="$tmp_dir/home" ./zig-out/bin/lan skill add "$tmp_dir/src-ok" >/dev/null 2>&1 || {
  echo "[skill-remove-abnormal] FAIL reason=setup-add-for-permission-failed"
  exit 1
}
skills_root="$tmp_dir/home/.config/lan/skills"
chmod 555 "$skills_root"
perm_out="$(HOME="$tmp_dir/home" ./zig-out/bin/lan skill remove demo-skill 2>&1 || true)"
chmod 755 "$skills_root"

echo "$perm_out" | grep -Eq "permission denied|Skill remove failed" || { echo "[skill-remove-abnormal] FAIL reason=permission-path-unexplained"; echo "$perm_out"; exit 1; }
echo "$perm_out" | grep -q "next:" || { echo "[skill-remove-abnormal] FAIL reason=permission-next-missing"; echo "$perm_out"; exit 1; }

echo "[skill-remove-abnormal] PASS reason=not-found-invalid-name-permission-covered"
