#!/usr/bin/env bash
set -euo pipefail

INPUT="${1:-docs/release/beta-trial-tracker-template.md}"
OUT_DIR="${2:-dist/beta-trial-summary}"

mkdir -p "$OUT_DIR"
ts="$(date +%Y%m%d-%H%M%S)"
json_out="$OUT_DIR/summary-$ts.json"
text_out="$OUT_DIR/summary-$ts.txt"

collect_trackers() {
  local input="$1"
  if [[ -d "$input" ]]; then
    find "$input" -maxdepth 1 -type f -name '*.md' | sort
  elif [[ "$input" == *,* ]]; then
    echo "$input" | tr ',' '\n'
  else
    echo "$input"
  fi
}

trackers=()
while IFS= read -r t; do
  [[ -n "$t" ]] && trackers+=("$t")
done < <(collect_trackers "$INPUT")
if [[ "${#trackers[@]}" -eq 0 ]]; then
  echo "[beta-trial-summary] FAIL reason=no_tracker_input"
  echo "next: provide tracker file(s), csv list, or directory"
  exit 1
fi

for t in "${trackers[@]}"; do
  if [[ ! -f "$t" ]]; then
    echo "[beta-trial-summary] FAIL reason=tracker_not_found path=$t"
    echo "next: provide valid tracker file path(s)"
    exit 1
  fi
done

total=0; pass=0; fail=0; blocked=0; running=0; not_started=0; pending=0
failed_items=""; pending_items=""; batches=""

parse_tracker() {
  local tracker="$1"
  local rows
  rows=$(awk -F'|' '
    /^\|/ {
      if ($0 ~ /^\|---/ || $0 ~ /Batch[[:space:]]*\|[[:space:]]*Device ID/) next;
      print $0;
    }
  ' "$tracker")

  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    total=$((total+1))
    batch=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$2); print $2}')
    device=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$3); print $3}')
    status=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$10); print $10}')
    sev=$(echo "$line" | awk -F'|' '{gsub(/^ +| +$/,"",$11); print $11}')

    [[ ",$batches," == *",$batch,"* ]] || batches+="$batch,"

    case "$status" in
      Pass|PASS|pass) pass=$((pass+1)) ;;
      Fail|FAIL|fail) fail=$((fail+1)); failed_items+="${batch}/${device}(sev=${sev:--});" ;;
      Blocked|BLOCKED|blocked) blocked=$((blocked+1)); pending=$((pending+1)); pending_items+="${batch}/${device}(blocked);" ;;
      Running|RUNNING|running) running=$((running+1)); pending=$((pending+1)); pending_items+="${batch}/${device}(running);" ;;
      Not\ Started|Not\ started|not\ started|NotStarted|not_started) not_started=$((not_started+1)); pending=$((pending+1)); pending_items+="${batch}/${device}(not_started);" ;;
      *) pending=$((pending+1)); pending_items+="${batch}/${device}(unknown:${status});" ;;
    esac
  done <<< "$rows"
}

for t in "${trackers[@]}"; do
  parse_tracker "$t"
done

rate=0
[[ "$total" -gt 0 ]] && rate=$((pass*100/total))
next_step="none"
if [[ "$fail" -gt 0 ]]; then
  next_step="prioritize FAIL items first, create fixes and rerun trial checks"
elif [[ "$pending" -gt 0 ]]; then
  next_step="continue pending devices until all become Pass/Fail"
fi

cat > "$json_out" <<EOF
{"ts":"$ts","trackers":"${trackers[*]}","batch_count":$(echo "$batches" | tr ',' '\n' | sed '/^$/d' | wc -l | xargs),"total":$total,"pass":$pass,"fail":$fail,"blocked":$blocked,"running":$running,"not_started":$not_started,"pending":$pending,"pass_rate":$rate,"failed_items":"${failed_items:--}","pending_items":"${pending_items:--}","next_step":"$next_step"}
EOF

cat > "$text_out" <<EOF
[beta-trial-summary] SUMMARY
- trackers: ${trackers[*]}
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