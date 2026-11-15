#!/usr/bin/env bash
# Builds the app, boots an iPhone Pro Max simulator (newest available model first), runs the
# screen-capture UI tests while recording the simulator screen, and collects screenshots,
# video, logs and the .xcresult bundle into $OUTPUT_DIR.
set -euo pipefail

PROJECT="${PROJECT:-NeuralKey.xcodeproj}"
SCHEME="${SCHEME:-NeuralKey}"
OUTPUT_DIR="${OUTPUT_DIR:-$PWD/simulator-captures}"
DERIVED_DATA="${DERIVED_DATA:-$PWD/.build/DerivedData}"
PREFERRED_DEVICES="${PREFERRED_DEVICES:-iPhone 18 Pro Max,iPhone 17 Pro Max,iPhone 16 Pro Max}"

mkdir -p "$OUTPUT_DIR/screenshots" "$OUTPUT_DIR/video" "$OUTPUT_DIR/logs"
rm -rf "$OUTPUT_DIR/TestResults.xcresult"

read -r RUNTIME_ID DEVICE_TYPE_ID DEVICE_NAME RUNTIME_NAME < <(
  xcrun simctl list runtimes --json | python3 -c '
import json, sys
preferred = [name.strip() for name in sys.argv[1].split(",")]
runtimes = [
    r for r in json.load(sys.stdin)["runtimes"]
    if r.get("isAvailable") and (r.get("platform") == "iOS" or r.get("name", "").startswith("iOS"))
]
runtimes.sort(key=lambda r: [int(p) for p in r["version"].split(".")], reverse=True)
for runtime in runtimes:
    supported = {t["name"]: t["identifier"] for t in runtime.get("supportedDeviceTypes", [])}
    for name in preferred:
        if name in supported:
            print(runtime["identifier"], supported[name], name.replace(" ", "_"), runtime["name"].replace(" ", "_"))
            sys.exit(0)
sys.exit("No iOS runtime supports any of: " + ", ".join(preferred))
' "$PREFERRED_DEVICES"
)
DEVICE_NAME="${DEVICE_NAME//_/ }"
RUNTIME_NAME="${RUNTIME_NAME//_/ }"

UDID="$(xcrun simctl create "NeuralKey Capture" "$DEVICE_TYPE_ID" "$RUNTIME_ID")"
echo "$DEVICE_NAME ($RUNTIME_NAME)" > "$OUTPUT_DIR/logs/device.txt"
echo "Simulator: $DEVICE_NAME, $RUNTIME_NAME, $UDID"

VIDEO_PID=""
LOG_PID=""
cleanup() {
  if [[ -n "$VIDEO_PID" ]] && kill -0 "$VIDEO_PID" 2>/dev/null; then
    kill -INT "$VIDEO_PID" || true
    wait "$VIDEO_PID" || true
  fi
  if [[ -n "$LOG_PID" ]]; then
    kill "$LOG_PID" 2>/dev/null || true
  fi
  xcrun simctl shutdown "$UDID" >/dev/null 2>&1 || true
  xcrun simctl delete "$UDID" >/dev/null 2>&1 || true
}
trap cleanup EXIT

xcrun simctl boot "$UDID"
xcrun simctl bootstatus "$UDID" -b
xcrun simctl ui "$UDID" appearance dark
xcrun simctl status_bar "$UDID" override \
  --time "9:41" \
  --dataNetwork wifi --wifiMode active --wifiBars 3 \
  --cellularMode active --cellularBars 4 \
  --batteryState charged --batteryLevel 100

xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$OUTPUT_DIR/logs/build-for-testing.log"

xcrun simctl spawn "$UDID" log stream --level debug --style compact \
  --predicate 'process == "NeuralKey"' > "$OUTPUT_DIR/logs/app.log" 2>&1 &
LOG_PID=$!

xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$OUTPUT_DIR/video/simulator-flow.mp4" \
  > "$OUTPUT_DIR/logs/video.log" 2>&1 &
VIDEO_PID=$!
sleep 3

set +e
TEST_RUNNER_NK_CAPTURE_DIR="$OUTPUT_DIR/screenshots" xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$OUTPUT_DIR/TestResults.xcresult" \
  -parallel-testing-enabled NO \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$OUTPUT_DIR/logs/test.log"
TEST_STATUS=${PIPESTATUS[0]}
set -e

sleep 2
kill -INT "$VIDEO_PID" || true
wait "$VIDEO_PID" || true
VIDEO_PID=""

echo "Captured screenshots:"
ls -la "$OUTPUT_DIR/screenshots" || true
exit "$TEST_STATUS"
