#!/usr/bin/env bash
set -euo pipefail

TRACKER_FILE="${1:-docs/release/beta-trial-tracker-template.md}"
OUT_DIR="${2:-dist/beta-trial-summary}"

mkdir -p "$OUT_DIR"
ts="$(date +%Y%m%d-%H%M%S)"
json_out="$OUT_DIR/summary-$ts.json"
text_out="$OUT_DIR/summary-$ts.txt"

if [[ ! -f "$TRACKER_FILE" ]]; then
  echo "[beta-trial-summary] FAIL reason=tracker_not_found path=$TRACKER_FILE"
  echo "next: provide a valid tracker file path"
  exit 1
fi

# parse markdown table rows (skip header/separator)
rows=$(awk -F'|' '
  /^\|/ {
    if ($0 ~ /^\|---/ || $0 ~ /Batch[[:space:]]*\|[[:space:]]*Device ID/) next;
    print $0;
  }
' "$TRACKER_FILE")

total=0
pass=0
fail=0
blocked=0
running=0
not_started=0
pending=0
failed_items=""
pending_items=""

while IFS= read -r line; do
  [[ -z "$line" ]] && continue
  total=$((total+1))
  # trim each column
  batch=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$2); print $2}')
  device=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
  status=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$10); print $10}')
  sev=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$11); print $11}')
  note=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$12); print $12}')

  case "$status" in
    Pass|PASS|pass) pass=$((pass+1)) ;;
    Fail|FAIL|fail) fail=$((fail+1)); failed_items+="${batch}/${device}(sev=${sev:--});" ;;
    Blocked|BLOCKED|blocked) blocked=$((blocked+1)); pending=$((pending+1)); pending_items+="${batch}/${device}(blocked);" ;;
    Running|RUNNING|running) running=$((running+1)); pending=$((pending+1)); pending_items+="${batch}/${device}(running);" ;;
    Not\ Started|Not\ started|not\ started|NotStarted|not_started) not_started=$((not_started+1)); pending=$((pending+1)); pending_items+="${batch}/${device}(not_started);" ;;
    *) pending=$((pending+1)); pending_items+="${batch}/${device}(unknown:${status});" ;;
  esac
done <<< "$rows"

rate=0
if [[ "$total" -gt 0 ]]; then
  rate=$((pass*100/total))
fi

next_step="none"
if [[ "$fail" -gt 0 ]]; then
  next_step="prioritize FAIL items first, create fixes and rerun trial checks"
elif [[ "$pending" -gt 0 ]]; then
  next_step="continue pending devices until all become Pass/Fail"
fi

cat > "$json_out" <<EOF
{"ts":"$ts","tracker":"$TRACKER_FILE","total":$total,"pass":$pass,"fail":$fail,"blocked":$blocked,"running":$running,"not_started":$not_started,"pending":$pending,"pass_rate":$rate,"failed_items":"${failed_items:--}","pending_items":"${pending_items:--}","next_step":"$next_step"}
EOF

cat > "$text_out" <<EOF
[beta-trial-summary] SUMMARY
- tracker: $TRACKER_FILE
- total: $total
- pass: $pass
- fail: $fail
- blocked: $blocked
- running: $running
- not_started: $not_started
- pending: $pending
- pass_rate: ${rate}%
- failed_items: ${failed_items:--}
- pending_items: ${pending_items:--}
- next: $next_step
EOF

if [[ "$fail" -gt 0 ]]; then
  echo "[beta-trial-summary] FAIL json=$json_out text=$text_out fail=$fail"
  echo "next: $next_step"
  exit 1
fi

echo "[beta-trial-summary] PASS json=$json_out text=$text_out pass_rate=${rate}%"