#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PKG_PATH="${1:-}"
TARGET_DIR="${2:-$HOME/.local/bin}"

if [[ -z "$PKG_PATH" ]]; then
  echo "[beta-candidate-verify] FAIL case=args reason=missing_package_path"
  echo "next: run ./scripts/verify-beta-candidate.sh <artifact.tar.gz> [target-dir]"
  exit 1
fi

current_case=""
on_error() {
  local code="$?"
  echo "[beta-candidate-verify] FAIL case=${current_case:-unknown} exit=${code}"
  echo "next: fix the failed case and rerun the same command"
  exit "$code"
}
trap on_error ERR

current_case="verify-package"
./scripts/verify-package.sh "$PKG_PATH" >/tmp/lan-beta-verify.$$ 2>&1

current_case="preflight"
./scripts/preflight.sh "$TARGET_DIR" >/tmp/lan-beta-preflight.$$ 2>&1

current_case="install"
./scripts/install.sh "$PKG_PATH" "$TARGET_DIR" >/tmp/lan-beta-install.$$ 2>&1

rm -f /tmp/lan-beta-verify.$$ /tmp/lan-beta-preflight.$$ /tmp/lan-beta-install.$$ || true

echo "[beta-candidate-verify] PASS package=$PKG_PATH target=$TARGET_DIR"
