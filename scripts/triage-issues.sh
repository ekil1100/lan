#!/usr/bin/env bash
# Issue Triage Helper for Lan Beta
# Usage: ./scripts/triage-issues.sh

set -euo pipefail

cd "$(dirname "$0")/.."

echo "[triage] Issue Triage Guide for Lan Beta"
echo ""
echo "Severity Labels:"
echo "  P0 - Critical (crash/data loss) → Fix immediately, block release"
echo "  P1 - High (feature broken, no workaround) → Next sprint priority"
echo "  P2 - Medium (feature broken, workaround exists) → Backlog queue"
echo "  P3 - Low (cosmetic/minor) → Icebox, good first issue"
echo ""
echo "Category Labels:"
echo "  bug        - Something not working as expected"
echo "  enhancement - Feature request or improvement"
echo "  docs       - Documentation related"
echo "  ci/build   - Build system or CI issues"
echo "  provider   - LLM provider integration issues"
echo "  skill      - Skill system issues"
echo "  tui        - Terminal UI issues"
echo ""
echo "Triage Process:"
echo "1. Check https://github.com/ekil1100/lan/issues"
echo "2. For each unlabeled issue:"
echo "   - Reproduce if possible"
echo "   - Assign severity (P0-P3)"
echo "   - Assign category"
echo "   - Add 'triage/verified' once confirmed"
echo ""
echo "R27 Planning Criteria:"
echo "  - All P0/P1 issues → Must be in R27"
echo "  - P2 issues with >2 upvotes → Consider for R27"
echo "  - P3 issues → Backlog for future releases"
echo ""
echo "Current Open Issues:"
curl -s "https://api.github.com/repos/ekil1100/lan/issues?state=open" 2>/dev/null | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print(f'  Open issues: {len(d)}'); [print(f\"  - #{i['number']}: {i['title'][:50]}...\") for i in d[:5]]" 2>/dev/null || \
  echo "  (Unable to fetch - check manually at https://github.com/ekil1100/lan/issues)"

echo ""
echo "[triage] PASS (process documented)"