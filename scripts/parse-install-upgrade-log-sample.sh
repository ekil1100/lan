#!/usr/bin/env bash
set -euo pipefail

line='install_event phase=end action=upgrade target=/tmp/lan result=success reason=upgrade_completed duration_ms=123'

echo "$line" | awk '
  {
    if ($1 != "install_event") exit 2;
    for (i=2; i<=NF; i++) { split($i, kv, "="); seen[kv[1]] = kv[2]; }
  }
  END {
    required[1]="phase"; required[2]="action"; required[3]="target"; required[4]="result"; required[5]="reason"; required[6]="duration_ms";
    for (i=1; i<=6; i++) if (!(required[i] in seen)) exit 3;
    print "[install-upgrade-log-parse] PASS";
  }
'