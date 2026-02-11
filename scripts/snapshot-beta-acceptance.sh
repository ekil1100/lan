#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
TARGET_DIR="${2:-$HOME/.local/bin}"
OUT_DIR="${3:-dist/beta-snapshots}"

if [[ -z "$PKG_PATH" ]]; then
  echo "[beta-snapshot] FAIL reason=missing_package_path"
  echo "next: run ./scripts/snapshot-beta-acceptance.sh <artifact.tar.gz> [target-dir] [out-dir]"
  exit 1
fi

ts="$(date +%Y%m%d-%H%M%S)"
run_dir="$OUT_DIR/$ts"
mkdir -p "$run_dir"

run_case() {
  local name="$1" cmd="$2"
  local log="$run_dir/${name}.log"
  local status="PASS"
  if bash -lc "$cmd" >"$log" 2>&1; then
    status="PASS"
  else
    status="FAIL"
  fi

  local next="-"
  if [[ "$status" == "FAIL" ]]; then
    next="$(grep -m1 '^next:' "$log" | sed 's/^next:[ ]*//' || true)"
    [[ -n "$next" ]] || next="check ${name}.log and fix the failed step"
  fi

  printf '{"case":"%s","status":"%s","next":"%s","log":"%s"}\n' \
    "$name" "$status" "$next" "$log" >> "$run_dir/results.jsonl"
}

: > "$run_dir/results.jsonl"
run_case "checklist" "./scripts/check-beta-readiness.sh"
run_case "verify" "./scripts/verify-beta-candidate.sh '$PKG_PATH' '$TARGET_DIR'"
run_case "post_health" "./scripts/post-install-health.sh '$TARGET_DIR/lan'"
run_case "acceptance" "./scripts/run-beta-acceptance.sh '$PKG_PATH' '$TARGET_DIR' '$run_dir/acceptance-report.md'"

pass_count="$(grep -c '"status":"PASS"' "$run_dir/results.jsonl" || true)"
fail_count="$(grep -c '"status":"FAIL"' "$run_dir/results.jsonl" || true)"

summary="$run_dir/summary.txt"
{
  echo "beta_snapshot_ts=$ts"
  echo "package=$PKG_PATH"
  echo "target=$TARGET_DIR"
  echo "pass_count=$pass_count"
  echo "fail_count=$fail_count"
  echo "report=$run_dir/acceptance-report.md"
  echo ""
  echo "Human Summary"
  echo "- PASS: $pass_count"
  echo "- FAIL: $fail_count"
  if [[ "$fail_count" -gt 0 ]]; then
    echo "- Next steps:"
    grep '"status":"FAIL"' "$run_dir/results.jsonl" | sed -E 's/.*"case":"([^"]+)".*"next":"([^"]+)".*/  - \1: \2/'
  else
    echo "- Next steps: none"
  fi
} > "$summary"

if [[ "$fail_count" -gt 0 ]]; then
  echo "[beta-snapshot] FAIL out=$run_dir fail_count=$fail_count"
  echo "next: review $run_dir/results.jsonl and per-case logs"
  exit 1
fi

echo "[beta-snapshot] PASS out=$run_dir pass_count=$pass_count"