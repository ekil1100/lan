#!/usr/bin/env bash
# Issue Response Tracker for R27-T02
# Run periodically to check and respond to new issues

set -euo pipefail

echo "[issue-response] Checking open issues..."
echo ""

# Fetch open issues
issues_json="$(curl -s "https://api.github.com/repos/ekil1100/lan/issues?state=open" 2>/dev/null || echo '[]')"

# Parse and display
issue_count="$(echo "$issues_json" | python3 -c "import sys,json; print(len(json.load(sys.stdin)))" 2>/dev/null || echo 0)"

echo "Open issues: $issue_count"
echo ""

if [[ "$issue_count" -gt 0 ]]; then
  echo "$issues_json" | python3 -c "
import sys, json
d = json.load(sys.stdin)
for i in d:
    labels = ','.join([l['name'] for l in i.get('labels', [])])
    print(f\"  #{i['number']}: {i['title'][:40]}... [{labels or 'unlabeled'}]\")
" 2>/dev/null || echo "  (Failed to parse issue list)"
else
  echo "  No open issues - all clear!"
fi

echo ""
echo "Response SLA Targets:"
echo "  P0 (Critical): 24 hours"
echo "  P1 (High): 72 hours"
echo "  P2/P3: Next sprint planning"
echo ""
echo "Actions:"
echo "  1. Label incoming issues with severity (P0-P3) and category"
echo "  2. Respond within SLA timeframe"
echo "  3. Link fixed issues to commits with 'Fixes #XXX'"
echo ""
echo "[issue-response] Tracking active"