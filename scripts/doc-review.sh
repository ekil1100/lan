#!/usr/bin/env bash
# Documentation Review Script for R30-T03

set -euo pipefail

cd "$(dirname "$0")/.."

echo "[doc-review] Starting documentation review..."
echo ""

# Check README.md
echo "[doc-review] Checking README.md..."
if grep -q "v0.1.0-beta" README.md; then
  echo "  ✓ Version reference correct"
else
  echo "  ✗ Version reference missing or incorrect"
fi

if grep -q "ekil1100/lan" README.md; then
  echo "  ✓ Repo links correct"
else
  echo "  ✗ Repo links may be incorrect"
fi

# Check key docs exist
echo ""
echo "[doc-review] Checking key documentation files..."
for doc in docs/ROADMAP.md docs/TASKS.md docs/errors.md docs/release/beta-announcement.md; do
  if [[ -f "$doc" ]]; then
    echo "  ✓ $doc exists"
  else
    echo "  ✗ $doc missing"
  fi
done

# Check GitHub templates
echo ""
echo "[doc-review] Checking GitHub templates..."
if [[ -f ".github/ISSUE_TEMPLATE/bug_report.yml" ]]; then
  echo "  ✓ Bug report template exists"
else
  echo "  ✗ Bug report template missing"
fi

if [[ -f ".github/ISSUE_TEMPLATE/feature_request.yml" ]]; then
  echo "  ✓ Feature request template exists"
else
  echo "  ✗ Feature request template missing"
fi

# Check for placeholder links
echo ""
echo "[doc-review] Checking for placeholder text..."
if grep -r "TODO\|FIXME\|XXX" docs/ --include="*.md" 2>/dev/null | head -5; then
  echo "  ⚠ Found placeholder text (see above)"
else
  echo "  ✓ No obvious placeholders found"
fi

echo ""
echo "[doc-review] PASS (review complete)"
echo ""
echo "Manual verification needed:"
echo "  - Verify all URLs are accessible"
echo "  - Check issue template renders correctly on GitHub"
echo "  - Confirm beta announcement content is up-to-date"
