#!/usr/bin/env bash
# Re-enables every package in a list. Safe to run more than once.
set -u
. "$(dirname "$0")/common.sh"
[ $# -eq 2 ] || usage
connect "$1"

for pkg in $(read_list "$2"); do
  if ! installed "$pkg"; then
    echo "SKIP  $pkg (not installed)"
  else
    out=$(adb -s "$SERIAL" shell pm enable "$pkg" 2>&1 | tr -d '\r')
    echo "ON    $pkg  $out"
  fi
done
