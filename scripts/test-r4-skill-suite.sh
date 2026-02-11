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

# 1) manifest schema validation (valid + invalid sample)
current_case="manifest-schema"
zig test src/skill_manifest.zig --test-filter "skill manifest schema v1"

# 2) list command offline (empty index should provide actionable hint)
current_case="skill-list-empty"
tmp_home=".lan_skill_list_suite_home_$(date +%s)"
trap 'rm -rf "$tmp_home"' EXIT
mkdir -p "$tmp_home"
list_out="$(HOME="$tmp_home" ./zig-out/bin/lan skill list 2>&1 || true)"
echo "$list_out" | grep -q "No skills installed"
echo "$list_out" | grep -q "next:"

# 3) add/remove scripted checks (already include list consistency)
current_case="skill-add-local"
./scripts/test-skill-add-local.sh

current_case="skill-remove-local"
./scripts/test-skill-remove-local.sh

echo "[r4-skill-suite] PASS"
