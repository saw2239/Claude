#!/usr/bin/env bash
# Disables (for user 0, reversibly) every package in a list. One pm call per package,
# because chained pm commands can silently stop after the first.
set -u
. "$(dirname "$0")/common.sh"
[ $# -eq 2 ] || usage
connect "$1"

for pkg in $(read_list "$2"); do
  if is_protected "$pkg"; then
    echo "SKIP  $pkg (protected)"
  elif ! installed "$pkg"; then
    echo "SKIP  $pkg (not installed)"
  else
    out=$(adb -s "$SERIAL" shell pm disable-user --user 0 "$pkg" 2>&1 | tr -d '\r')
    echo "OFF   $pkg  $out"
  fi
done
echo "Done. Test the Apple TV input, the Siri remote (power, volume) and the TCL remote."
