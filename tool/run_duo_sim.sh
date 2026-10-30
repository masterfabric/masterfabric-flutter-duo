#!/usr/bin/env bash
# Boots the iPhone Duo + iPhone 18 Pro simulators and runs the app on both.
# Usage: tool/run_duo_sim.sh            (debug, detached, logs in build/sim_logs)
#        DUO_ONLY=1 tool/run_duo_sim.sh  (only the iPhone Duo)
set -euo pipefail
[ -f "$HOME/.zprofile" ] && source "$HOME/.zprofile" >/dev/null 2>&1 || true

cd "$(dirname "$0")/.."
DUO_ID="${DUO_ID:-766A853B-9680-4840-9009-8016CD6FA10F}"
PRO_ID="${PRO_ID:-8AF2D6B8-1BD8-4C27-BF4E-BBB6FF72E884}"
LOG_DIR="build/sim_logs"
mkdir -p "$LOG_DIR"

devices=("$DUO_ID")
[ "${DUO_ONLY:-0}" = "1" ] || devices+=("$PRO_ID")

for id in "${devices[@]}"; do
  state=$(xcrun simctl list devices | grep "$id" | sed -E 's/.*\((Booted|Shutdown|[A-Za-z ]+)\) *$/\1/')
  if [ "$state" != "Booted" ]; then
    echo "Booting $id ..."
    xcrun simctl boot "$id" || true
  fi
  xcrun simctl bootstatus "$id" -b >/dev/null
done

# Xcode 27 ships the simulator UI as DeviceHub.app (Simulator.app on older Xcodes).
DEV="$(xcode-select -p)"
for app in "$DEV/../Applications/DeviceHub.app" "$DEV/Applications/Simulator.app"; do
  if [ -d "$app" ]; then open -a "$app" || true; break; fi
done

flutter pub get >/dev/null

for id in "${devices[@]}"; do
  log="$LOG_DIR/run_$id.log"
  echo "flutter run -d $id  ->  $log"
  nohup flutter run -d "$id" >"$log" 2>&1 </dev/null &
  # Stagger: both runs share the same Xcode build folder.
  for _ in $(seq 1 120); do
    grep -qE "Flutter run key commands|Error|error:" "$log" 2>/dev/null && break
    sleep 5
  done
done

echo "Done. Logs: $LOG_DIR"
