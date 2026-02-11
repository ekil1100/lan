#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

current_case=""
on_error() {
  local exit_code="$?"
  if [[ -n "$current_case" ]]; then
    echo "[r4-skill-suite] FAIL case=${current_case} exit=${exit_code}"
  else
    echo "[r4-skill-suite] FAIL case=<unknown> exit=${exit_code}"
  fi
  exit "$exit_code"
}
trap on_error ERR

# R4 batch-2 scope: T07/T08/T09/T10

# 1) manifest boundary validation (T07)
current_case="manifest-boundary"
zig test src/skill_manifest.zig --test-filter "skill manifest schema v1"

# 2) list command offline (empty index actionable hint)
current_case="skill-list-empty"
tmp_home=".lan_skill_list_suite_home_$(date +%s)"
trap 'rm -rf "$tmp_home"' EXIT
mkdir -p "$tmp_home"
list_out="$(HOME="$tmp_home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$list_out" | grep -q "No skills installed"
echo "$list_out" | grep -q "next:"

# 3) add path + permissions hint (T10 baseline)
current_case="skill-add-local"
./scripts/test-skill-add-local.sh

# 4) update path + version diff + permissions hint (T08/T10)
current_case="skill-update-local"
./scripts/test-skill-update-local.sh

# 5) remove path + state consistency (T09 lifecycle)
current_case="skill-remove-local"
./scripts/test-skill-remove-local.sh

# 6) abnormal remove paths (not-found/invalid-name/permission)
current_case="skill-remove-abnormal"
./scripts/test-skill-remove-abnormal.sh

echo "[r4-skill-suite] PASS"
