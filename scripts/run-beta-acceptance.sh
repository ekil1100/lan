#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
TARGET_DIR="${2:-$HOME/.local/bin}"
REPORT_OUT="${3:-dist/beta-acceptance-report.md}"

if [[ -z "$PKG_PATH" ]]; then
  echo "[beta-acceptance] FAIL case=args reason=missing_package_path"
  echo "next: run ./scripts/run-beta-acceptance.sh <artifact.tar.gz> [target-dir] [report-out]"
  exit 1
fi

current_case=""
on_error() {
  local code="$?"
  echo "[beta-acceptance] FAIL case=${current_case:-unknown} exit=${code}"
  echo "next: fix failed case output above, then rerun the same command"
  exit "$code"
}
trap on_error ERR

current_case="checklist"
./scripts/check-beta-readiness.sh

current_case="verify"
./scripts/verify-beta-candidate.sh "$PKG_PATH" "$TARGET_DIR"

current_case="post-health"
./scripts/post-install-health.sh "$TARGET_DIR/lan"

current_case="acceptance-report"
mkdir -p "$(dirname "$REPORT_OUT")"
cp docs/release/beta-acceptance-report-template.md "$REPORT_OUT"

echo "[beta-acceptance] PASS package=$PKG_PATH target=$TARGET_DIR report=$REPORT_OUT"