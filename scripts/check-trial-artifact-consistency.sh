#!/usr/bin/env bash
set -euo pipefail

TRACKER="${1:-}"
SUMMARY_JSON="${2:-}"
SNAPSHOT_DIR="${3:-}"

if [[ -z "$TRACKER" || -z "$SUMMARY_JSON" || -z "$SNAPSHOT_DIR" ]]; then
  echo "[trial-artifact-check] FAIL reason=missing_args"
  echo "next: run ./scripts/check-trial-artifact-consistency.sh <tracker.md> <summary.json> <snapshot_dir>"
  exit 1
fi

for p in "$TRACKER" "$SUMMARY_JSON"; do
  [[ -f "$p" ]] || { echo "[trial-artifact-check] FAIL reason=file_not_found path=$p"; echo "next: provide valid input files"; exit 1; }
done
[[ -d "$SNAPSHOT_DIR" ]] || { echo "[trial-artifact-check] FAIL reason=snapshot_dir_not_found path=$SNAPSHOT_DIR"; echo "next: provide a valid snapshot directory"; exit 1; }

# collect batch ids from tracker markdown
batch_ids=$(awk -F'|' '/^\|/ && $0 !~ /^\|---/ && $0 !~ /Batch[[:space:]]*\|[[:space:]]*Device ID/ {gsub(/^ +| +$/,"",$2); if($2!="") print $2}' "$TRACKER" | sort -u)

# summary fields
failed_items=$(sed -n 's/.*"failed_items":"\([^"]*\)".*/\1/p' "$SUMMARY_JSON")
pending_items=$(sed -n 's/.*"pending_items":"\([^"]*\)".*/\1/p' "$SUMMARY_JSON")

inconsistent=0
issues=""
while IFS= read -r b; do
  [[ -z "$b" ]] && continue
  if [[ "$failed_items" != *"$b/"* && "$pending_items" != *"$b/"* ]]; then
    issues+="batch_missing_in_summary:${b};"
    inconsistent=$((inconsistent+1))
  fi
done <<< "$batch_ids"

run_id="$(basename "$SNAPSHOT_DIR")"
if [[ ! -f "$SNAPSHOT_DIR/results.jsonl" ]]; then
  issues+="snapshot_missing_results:${run_id};"
  inconsistent=$((inconsistent+1))
fi
if [[ ! -f "$SNAPSHOT_DIR/report-mapping.json" ]]; then
  issues+="snapshot_missing_mapping:${run_id};"
  inconsistent=$((inconsistent+1))
fi

echo "{\"run_id\":\"$run_id\",\"batch_ids\":\"$(echo "$batch_ids" | paste -sd ',' -)\",\"issues\":\"${issues:--}\"}"

if [[ "$inconsistent" -gt 0 ]]; then
  echo "[trial-artifact-check] FAIL issues=$inconsistent"
  echo "[trial-artifact-check] INCONSISTENT ${issues:--}"
  echo "next: align tracker batch ids with summary fields and ensure snapshot artifacts exist"
  exit 1
fi

echo "[trial-artifact-check] PASS run_id=$run_id"