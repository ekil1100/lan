#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
TARGET_DIR="${2:-$HOME/.local/bin}"

if [[ -z "$PKG_PATH" ]]; then
  echo "[trial-precheck] FAIL reason=missing_package_path"
  echo "next: run ./scripts/trial-precheck.sh <artifact.tar.gz> [target-dir]"
  exit 1
fi

pass=0
fail=0
json_lines=()

run_check() {
  local case_name="$1" cmd="$2" next_step="$3"
  local log="/tmp/lan-trial-precheck-${case_name}-$$.log"
  if bash -lc "$cmd" >"$log" 2>&1; then
    pass=$((pass+1))
    json_lines+=("{\"case\":\"$case_name\",\"status\":\"PASS\",\"next\":\"-\"}")
    echo "[trial-precheck] PASS case=$case_name"
  else
    fail=$((fail+1))
    local next="$next_step"
    local hinted
    hinted="$(grep -m1 '^next:' "$log" | sed 's/^next:[ ]*//' || true)"
    [[ -n "$hinted" ]] && next="$hinted"
    json_lines+=("{\"case\":\"$case_name\",\"status\":\"FAIL\",\"next\":\"$next\"}")
    echo "[trial-precheck] FAIL case=$case_name"
    sed -n '1,4p' "$log" | sed 's/^/[trial-precheck] detail: /'
    echo "next: $next"
  fi
  rm -f "$log" || true
}

run_check "package_exists" "test -f '$PKG_PATH'" "generate or download candidate package first"
run_check "target_dir_ready" "mkdir -p '$TARGET_DIR' && test -w '$TARGET_DIR'" "use a writable target dir, e.g. ~/.local/bin"
run_check "sha_tool" "command -v shasum >/dev/null 2>&1 || command -v sha256sum >/dev/null 2>&1" "install shasum/sha256sum"
run_check "feedback_template" "test -f docs/release/beta-feedback-template.md" "restore beta feedback template file"

rate=$(( (pass*100)/((pass+fail)==0?1:(pass+fail)) ))

echo "[trial-precheck] SUMMARY pass=$pass fail=$fail pass_rate=${rate}%"
for l in "${json_lines[@]}"; do
  echo "$l"
done

if [[ "$fail" -gt 0 ]]; then
  echo "[trial-precheck] FAIL summary=${fail}_case(s)_failed"
  echo "next: fix failed checks above, then rerun trial-precheck"
  exit 1
fi

echo "[trial-precheck] PASS summary=all_checks_passed"