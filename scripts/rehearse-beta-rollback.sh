#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

MODE="${1:-success}"
WORK_DIR="${2:-.lan_beta_rollback_rehearsal}"

case "$MODE" in
  success|fail) ;;
  *)
    echo "[beta-rollback-rehearsal] FAIL case=args reason=invalid_mode mode=$MODE"
    echo "next: use mode 'success' or 'fail'"
    exit 1
    ;;
esac

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR/bin" "$WORK_DIR/config"

pkg_out="$(./scripts/package-release.sh 2>&1 || true)"
pkg="$(echo "$pkg_out" | sed -n 's/^\[package\] PASS artifact=\([^ ]*\).*/\1/p')"
if [[ -z "$pkg" ]]; then
  echo "[beta-rollback-rehearsal] FAIL case=package reason=artifact_missing"
  echo "$pkg_out"
  echo "next: fix package-release and rerun"
  exit 1
fi

# seed a known-good binary as rollback source
./scripts/install.sh "$pkg" "$WORK_DIR/bin" >/dev/null 2>&1 || {
  echo "[beta-rollback-rehearsal] FAIL case=seed reason=install_failed"
  echo "next: fix install path/permissions then rerun"
  exit 1
}

if [[ "$MODE" == "success" ]]; then
  out="$(./scripts/upgrade.sh "$pkg" "$WORK_DIR/bin" "$WORK_DIR/config" 2>&1 || true)"
  echo "$out" | grep -q "Upgrade success:" || {
    echo "[beta-rollback-rehearsal] FAIL case=success-path reason=upgrade_not_success"
    echo "$out"
    echo "next: inspect upgrade logs and fix upgrade path"
    exit 1
  }
  echo "[beta-rollback-rehearsal] PASS case=success-path"
  exit 0
fi

# fail branch: build a tarball containing invalid lan binary to trigger rollback
mkdir -p "$WORK_DIR/badpkg"
printf 'not-a-real-binary\n' > "$WORK_DIR/badpkg/lan"
chmod +x "$WORK_DIR/badpkg/lan"
tar -czf "$WORK_DIR/bad.tgz" -C "$WORK_DIR/badpkg" .
out="$(./scripts/upgrade.sh "$WORK_DIR/bad.tgz" "$WORK_DIR/bin" "$WORK_DIR/config" 2>&1 || true)"

echo "$out" | grep -q "Upgrade rollback:" || {
  echo "[beta-rollback-rehearsal] FAIL case=fail-path reason=rollback_not_triggered"
  echo "$out"
  echo "next: verify rollback guard and retry fail rehearsal"
  exit 1
}

echo "$out" | grep -q "next:" || {
  echo "[beta-rollback-rehearsal] FAIL case=fail-path reason=next_missing"
  echo "$out"
  echo "next: ensure rollback failure message includes next-step"
  exit 1
}

echo "[beta-rollback-rehearsal] PASS case=fail-path"