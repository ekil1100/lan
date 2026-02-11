#!/usr/bin/env bash
set -euo pipefail

line='route_event phase=end provider=kimi model=kimi-k2-0711-preview result=success reason=primary_success duration_ms=42'

echo "$line" | awk '
  {
    if ($1 != "route_event") exit 2;
    for (i=2; i<=NF; i++) {
      split($i, kv, "=");
      seen[kv[1]] = kv[2];
    }
  }
  END {
    required[1]="phase"; required[2]="provider"; required[3]="model"; required[4]="result"; required[5]="reason"; required[6]="duration_ms";
    for (i=1; i<=6; i++) if (!(required[i] in seen)) exit 3;
    print "[route-log-parse] PASS";
  }
'