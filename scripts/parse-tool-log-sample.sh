#!/usr/bin/env bash
set -euo pipefail

# Stable machine-parse contract for tool_event lines.
line='tool_event phase=end ts=1739239200 name=model_tool_call result=success duration_ms=42 summary=tool_call_processed next=-'

echo "$line" | awk '
  {
    if ($1 != "tool_event") exit 2;
    for (i=2; i<=NF; i++) {
      split($i, kv, "=");
      key=kv[1]; val=kv[2];
      seen[key]=val;
    }
  }
  END {
    required[1]="phase"; required[2]="ts"; required[3]="name"; required[4]="result"; required[5]="duration_ms"; required[6]="summary"; required[7]="next";
    for (i=1; i<=7; i++) {
      if (!(required[i] in seen)) exit 3;
    }
    print "[tool-log-parse] PASS";
  }
'