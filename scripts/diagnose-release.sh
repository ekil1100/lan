#!/usr/bin/env bash
# Release Workflow Diagnostic Script for R31-T02
# Checks workflow file, secrets, and runner availability

set -euo pipefail

cd "$(dirname "$0")/.."

echo "[release-diagnose] Starting release workflow diagnostics..."
echo ""

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

errors=0
warnings=0

# 1. Check workflow file exists
echo "[release-diagnose] 1. Checking workflow file..."
if [[ -f ".github/workflows/release.yml" ]]; then
    echo -e "${GREEN}✓${NC} release.yml exists"
else
    echo -e "${RED}✗${NC} release.yml not found"
    ((errors++))
fi

# 2. Check workflow syntax (basic)
echo ""
echo "[release-diagnose] 2. Checking workflow syntax..."
if command -v actionlint > /dev/null 2>&1; then
    if actionlint .github/workflows/release.yml 2>&1; then
        echo -e "${GREEN}✓${NC} Workflow syntax valid (actionlint)"
    else
        echo -e "${RED}✗${NC} Workflow syntax errors found"
        ((errors++))
    fi
else
    echo -e "${YELLOW}⚠${NC} actionlint not installed, skipping syntax check"
    echo "  Install with: brew install actionlint"
    ((warnings++))
fi

# 3. Check for required secrets references
echo ""
echo "[release-diagnose] 3. Checking secrets references..."
if grep -q "secrets\." .github/workflows/release.yml; then
    echo -e "${GREEN}✓${NC} Secrets referenced in workflow"
    echo "  Required secrets:"
    grep -o "secrets\.[A-Z_]*" .github/workflows/release.yml | sort -u | while read -r secret; do
        echo "    - $secret"
    done
else
    echo -e "${YELLOW}⚠${NC} No secrets referenced (may be expected)"
fi

# 4. Check GitHub CLI availability
echo ""
echo "[release-diagnose] 4. Checking GitHub CLI..."
if command -v gh > /dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} GitHub CLI installed"
    if gh auth status 2>&1 | grep -q "Logged in"; then
        echo -e "${GREEN}✓${NC} GitHub CLI authenticated"
    else
        echo -e "${YELLOW}⚠${NC} GitHub CLI not authenticated"
        echo "  Run: gh auth login"
        ((warnings++))
    fi
else
    echo -e "${YELLOW}⚠${NC} GitHub CLI not installed"
    echo "  Install with: brew install gh"
    ((warnings++))
fi

# 5. Check local git tags
echo ""
echo "[release-diagnose] 5. Checking local git tags..."
if git tag | grep -q "v"; then
    latest_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "none")
    echo -e "${GREEN}✓${NC} Latest tag: $latest_tag"
else
    echo -e "${YELLOW}⚠${NC} No version tags found"
    ((warnings++))
fi

# 6. Check remote connectivity
echo ""
echo "[release-diagnose] 6. Checking remote connectivity..."
if git ls-remote origin >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} Can connect to remote"
else
    echo -e "${RED}✗${NC} Cannot connect to remote"
    ((errors++))
fi

# 7. Summary
echo ""
echo "[release-diagnose] ==================================="
echo "[release-diagnose] Diagnostic Summary"
echo "[release-diagnose] ==================================="
if [[ $errors -eq 0 && $warnings -eq 0 ]]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${YELLOW}Warnings: $warnings${NC}"
    echo -e "${RED}Errors: $errors${NC}"
    if [[ $errors -gt 0 ]]; then
        echo ""
        echo "Fix errors before proceeding with release."
        exit 1
    fi
fi
