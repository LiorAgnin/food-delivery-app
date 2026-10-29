#!/usr/bin/env bash
# Patrol e2e against the Android emulator. Never run `patrol test` outside
# this script: there is one emulator, and the lock below is the mutex.
# usage: tool/e2e.sh [--device SERIAL] [--target FILE] [--port PORT]
set -euo pipefail
cd "$(dirname "$0")/.."

lock=/tmp/fda-e2e.lock
while ! mkdir "$lock" 2>/dev/null; do
  echo "waiting for $lock" >&2
  sleep 5
done
cleanup() {
  rmdir "$lock" 2>/dev/null || true
}
trap cleanup EXIT

device=""
target="patrol_test/catalog_test.dart"
port="${API_PORT:-3101}"
while [ $# -gt 0 ]; do
  case "$1" in
    --device) device="${2:-}"; shift 2 ;;
    --target) target="${2:-}"; shift 2 ;;
    --port) port="${2:-}"; shift 2 ;;
    *) echo "unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [ ! -f "$target" ]; then
  echo "missing target $target" >&2
  exit 2
fi

if ! command -v patrol >/dev/null 2>&1; then
  echo "patrol_cli is not on PATH (dart pub global activate patrol_cli)" >&2
  exit 2
fi
if ! command -v adb >/dev/null 2>&1; then
  echo "adb is not on PATH; set ANDROID_HOME" >&2
  exit 2
fi

if [ -z "$device" ]; then
  device="$(adb devices | awk 'NR>1 && $1 ~ /^emulator-/ && $2=="device" {print $1; exit}')"
fi
if [ -z "$device" ]; then
  echo "no emulator running; booting AVD Pixel_10_Pro" >&2
  "${ANDROID_HOME:-$HOME/Library/Android/sdk}/emulator/emulator" \
    -avd Pixel_10_Pro -no-snapshot-load >/dev/null 2>&1 &
  until device="$(adb devices | awk 'NR>1 && $1 ~ /^emulator-/ && $2=="device" {print $1; exit}')" \
    && [ -n "$device" ]; do
    sleep 2
  done
  until [ "$(adb -s "$device" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" = "1" ]; do
    sleep 2
  done
fi

base="http://10.0.2.2:${port}/api"
echo "== patrol $target on $device against $base"
patrol test --device "$device" --target "$target" \
  --dart-define="API_BASE_URL=${base}"
