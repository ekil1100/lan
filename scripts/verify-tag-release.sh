#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

TAG="${1:-v0.0.0-test}"

echo "[verify-tag-release] tag=$TAG"

# 1) Validate workflow file syntax
echo "[verify-tag-release] check=workflow-syntax"
if ! python3 -c "import yaml,sys; yaml.safe_load(open('.github/workflows/release.yml'))" 2>/dev/null; then
  # Try yq if available
  if command -v yq >/dev/null 2>&1; then
    yq '.github/workflows/release.yml' > /dev/null 2>&1 || { echo "[verify-tag-release] FAIL reason=workflow-syntax-error"; exit 1; }
  else
    echo "[verify-tag-release] WARN reason=yaml-validation-skipped (install python3-yaml or yq)"
  fi
fi

# 2) Check required workflow steps exist
echo "[verify-tag-release] check=workflow-steps"
if ! grep -q "upload-artifact" .github/workflows/release.yml; then
  echo "[verify-tag-release] FAIL reason=missing-upload-artifact-step"
  exit 1
fi
if ! grep -q "action-gh-release" .github/workflows/release.yml; then
  echo "[verify-tag-release] FAIL reason=missing-release-step"
  exit 1
fi

# 3) Simulate artifact generation locally
echo "[verify-tag-release] check=local-artifact-build"
if ! make package-release >/dev/null 2>&1; then
  echo "[verify-tag-release] FAIL reason=package-release-failed"
  exit 1
fi

# 4) Verify artifacts exist
artifact_count=0
for artifact in dist/*.tar.gz; do
  [[ -f "$artifact" ]] || continue
  echo "[verify-tag-release] artifact=$(basename "$artifact")"
  artifact_count=$((artifact_count+1))
done

if [[ "$artifact_count" -eq 0 ]]; then
  echo "[verify-tag-release] FAIL reason=no-artifacts-generated"
  exit 1
fi

# 5) Checksum files
checksum_count=0
for cs in dist/*.sha256; do
  [[ -f "$cs" ]] || continue
  checksum_count=$((checksum_count+1))
done
if [[ "$checksum_count" -eq 0 ]]; then
  echo "[verify-tag-release] WARN reason=no-checksum-files"
fi

echo "[verify-tag-release] PASS tag=$TAG"
echo "next: push tag with 'git push origin $TAG' to trigger CI release"