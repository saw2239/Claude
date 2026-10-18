# Shared helpers for disable.sh and restore.sh. Source, don't run.

# Git Bash on Windows rewrites paths like /data/local/tmp otherwise.
export MSYS_NO_PATHCONV=1

# Packages these scripts refuse to touch, whatever the list says. Disabling any of them can
# break HDMI input switching, the remote, CEC, the keyboard or the Play Store.
PROTECTED_EXACT="com.tcl.tv com.tcl.tvinput com.tcl.suspension com.tcl.dashboard
com.tcl.systemserver com.tcl.autopair com.tcl.tcl_bt_rcu_service
com.google.android.apps.tv.launcherx com.google.android.tvlauncher
com.google.android.gms com.google.android.gsf com.android.vending
com.google.android.inputmethod.latin com.android.tv.settings com.android.systemui
com.google.android.tungsten.setupwraith"
PROTECTED_PATTERN='hdmi|cec|tvinput|bluetooth|inputmethod|setupwizard|packageinstaller|permission|systemui|providers|ota'

usage() {
  echo "usage: $0 <tv-ip> <package-list.txt>" >&2
  exit 2
}

# Prints the packages in a list file: strips comments and blank lines.
read_list() {
  sed -e 's/#.*//' -e 's/[[:space:]]//g' "$1" | grep -v '^$'
}

is_protected() {
  local pkg="$1" p
  for p in $PROTECTED_EXACT; do
    [ "$pkg" = "$p" ] && return 0
  done
  echo "$pkg" | grep -Eiq "$PROTECTED_PATTERN"
}

connect() {
  command -v adb >/dev/null || { echo "adb not found. Install Android platform-tools first." >&2; exit 1; }
  SERIAL="$1:5555"
  adb connect "$SERIAL" >/dev/null
  if [ "$(adb -s "$SERIAL" get-state 2>/dev/null)" != "device" ]; then
    echo "Can't reach $SERIAL. Is debugging on, and did you accept the prompt on the TV?" >&2
    exit 1
  fi
}

installed() {
  adb -s "$SERIAL" shell pm list packages "$1" | tr -d '\r' | grep -qx "package:$1"
}
