#!/usr/bin/env bash
# Builds the app, boots an iPhone Pro Max simulator (newest available model first), runs the
# screen-capture UI tests and collects screenshots, logs and the .xcresult bundle into
# $OUTPUT_DIR.
#   CAPTURE_TESTS  comma-separated -only-testing identifiers; empty runs every UI test.
#   RECORD_VIDEO   true records and compresses a video of the run (off by default).
#   VIDEO_CROP_RATIO  keeps only the bottom of the video (height = width x ratio), e.g. the keyboard.
#   EXTRA_DEVICES  comma-separated simulators that rerun the same tests (screenshots/<device>/).
set -euo pipefail

PROJECT="${PROJECT:-NeuralKey.xcodeproj}"
SCHEME="${SCHEME:-NeuralKey}"
OUTPUT_DIR="${OUTPUT_DIR:-$PWD/simulator-captures}"
DERIVED_DATA="${DERIVED_DATA:-$PWD/.build/DerivedData}"
PREFERRED_DEVICES="${PREFERRED_DEVICES:-iPhone 18 Pro Max,iPhone 17 Pro Max,iPhone 16 Pro Max}"
EXTRA_DEVICES="${EXTRA_DEVICES:-}"
CAPTURE_TESTS="${CAPTURE_TESTS:-}"
RECORD_VIDEO="${RECORD_VIDEO:-false}"
VIDEO_CROP_RATIO="${VIDEO_CROP_RATIO:-}"

ONLY_TESTING_ARGS=()
if [[ -n "$CAPTURE_TESTS" ]]; then
  IFS=',' read -r -a CAPTURE_TEST_LIST <<< "$CAPTURE_TESTS"
  for capture_test in "${CAPTURE_TEST_LIST[@]}"; do
    ONLY_TESTING_ARGS+=("-only-testing:$capture_test")
  done
fi

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

prepare_simulator() {
  local udid="$1"
  # Show the on-screen keyboard so system keyboards (NeuralKey) can be tested.
  defaults write com.apple.iphonesimulator ConnectHardwareKeyboard -bool false || true
  xcrun simctl boot "$udid"
  xcrun simctl bootstatus "$udid" -b
  xcrun simctl ui "$udid" appearance dark
  xcrun simctl status_bar "$udid" override \
    --time "9:41" \
    --dataNetwork wifi --wifiMode active --wifiBars 3 \
    --cellularMode active --cellularBars 4 \
    --batteryState charged --batteryLevel 100
}

device_type_for() {
  xcrun simctl list runtimes --json | python3 -c '
import json, sys
runtime_id, name = sys.argv[1], sys.argv[2]
for runtime in json.load(sys.stdin)["runtimes"]:
    if runtime["identifier"] == runtime_id:
        for device_type in runtime.get("supportedDeviceTypes", []):
            if device_type["name"] == name:
                print(device_type["identifier"])
                sys.exit(0)
' "$RUNTIME_ID" "$1"
}

VIDEO_PID=""
LOG_PID=""
EXTRA_UDID=""
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
  if [[ -n "$EXTRA_UDID" ]]; then
    xcrun simctl shutdown "$EXTRA_UDID" >/dev/null 2>&1 || true
    xcrun simctl delete "$EXTRA_UDID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT

prepare_simulator "$UDID"

xcodebuild build-for-testing \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  CODE_SIGNING_ALLOWED=NO \
  GEMINI_API_KEY="${GEMINI_API_KEY:-}" \
  2>&1 | tee "$OUTPUT_DIR/logs/build-for-testing.log"

# The simulator only registers app extensions that carry a signature, so the
# unsigned CI build is signed ad hoc (no team or certificate needed).
APP_PRODUCT="$DERIVED_DATA/Build/Products/Debug-iphonesimulator/NeuralKey.app"
if [[ -d "$APP_PRODUCT/PlugIns" ]]; then
  for appex in "$APP_PRODUCT"/PlugIns/*.appex; do
    codesign --force --deep --sign - --timestamp=none "$appex"
  done
  codesign --force --sign - --timestamp=none "$APP_PRODUCT"
  codesign --verify --deep "$APP_PRODUCT" && echo "Ad hoc signed $APP_PRODUCT"
fi

xcrun simctl spawn "$UDID" log stream --level debug --style compact \
  --predicate 'process == "NeuralKey"' > "$OUTPUT_DIR/logs/app.log" 2>&1 &
LOG_PID=$!

RAW_VIDEO="$OUTPUT_DIR/video/simulator-flow-raw.mp4"
FINAL_VIDEO="$OUTPUT_DIR/video/simulator-flow.mp4"
MAX_VIDEO_BYTES=$((90 * 1024 * 1024))

compress_video() {
  if [[ -n "$VIDEO_CROP_RATIO" ]] && xcrun swift "$(dirname "$0")/crop_video.swift" "$RAW_VIDEO" "$FINAL_VIDEO" "$VIDEO_CROP_RATIO" > "$OUTPUT_DIR/logs/video-crop.log" 2>&1 \
    && [[ -s "$FINAL_VIDEO" ]] && [[ "$(stat -f%z "$FINAL_VIDEO")" -le "$MAX_VIDEO_BYTES" ]]; then
    rm -f "$RAW_VIDEO"
    return
  fi
  for preset in PresetHEVC1920x1080 Preset1280x720 Preset960x540; do
    rm -f "$FINAL_VIDEO"
    if avconvert --preset "$preset" --source "$RAW_VIDEO" --output "$FINAL_VIDEO" --replace >/dev/null 2>&1 \
      && [[ -s "$FINAL_VIDEO" ]] && [[ "$(stat -f%z "$FINAL_VIDEO")" -le "$MAX_VIDEO_BYTES" ]]; then
      echo "Video compressed with $preset: $(stat -f%z "$FINAL_VIDEO") bytes"
      rm -f "$RAW_VIDEO"
      return
    fi
  done
  echo "Video compression failed; keeping the original recording"
  mv -f "$RAW_VIDEO" "$FINAL_VIDEO"
}

if [[ "$RECORD_VIDEO" == "true" ]]; then
  xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$RAW_VIDEO" \
    > "$OUTPUT_DIR/logs/video.log" 2>&1 &
  VIDEO_PID=$!
  sleep 3
fi

# Host capture helper: UI tests drop request files here to have the simulator
# screenshotted while a key is held down (XCTest cannot screenshot mid-touch) or to
# start and stop a dedicated video. See hostCapture(_:command:) in the UI tests.
REQUEST_DIR="$OUTPUT_DIR/screenshots/.requests"
mkdir -p "$REQUEST_DIR" "$OUTPUT_DIR/video"
capture_agent() {
  local clip_pid="" request name command
  while true; do
    for request in "$REQUEST_DIR"/*.request; do
      [[ -e "$request" ]] || continue
      name="$(basename "$request" .request)"
      command="$(cat "$request")"
      case "$command" in
        screenshot)
          echo "$(date +%T) request $name"
          sleep 1.2
          xcrun simctl io "$UDID" screenshot --type=png "$OUTPUT_DIR/screenshots/$name.png" >/dev/null 2>&1 \
            || echo "Host screenshot $name failed"
          echo "$(date +%T) captured $name"
          ;;
        video-start)
          # The whole run is already being filmed; a second recording would compete with it.
          if [[ "$RECORD_VIDEO" == "true" ]]; then
            rm -f "$request"
            continue
          fi
          xcrun simctl io "$UDID" recordVideo --codec=h264 --force "$OUTPUT_DIR/video/$name-raw.mp4" \
            > "$OUTPUT_DIR/logs/$name-video.log" 2>&1 &
          clip_pid=$!
          sleep 2
          ;;
        video-stop)
          if [[ -n "$clip_pid" ]]; then
            sleep 1.5
            kill -INT "$clip_pid" 2>/dev/null || true
            wait "$clip_pid" 2>/dev/null || true
            clip_pid=""
          fi
          ;;
      esac
      rm -f "$request"
    done
    sleep 0.1
  done
}
capture_agent > "$OUTPUT_DIR/logs/capture-agent.log" 2>&1 &
AGENT_PID=$!

set +e
TEST_RUNNER_NK_CAPTURE_DIR="$OUTPUT_DIR/screenshots" xcodebuild test-without-building \
  -project "$PROJECT" \
  -scheme "$SCHEME" \
  -configuration Debug \
  -destination "id=$UDID" \
  -derivedDataPath "$DERIVED_DATA" \
  -resultBundlePath "$OUTPUT_DIR/TestResults.xcresult" \
  -parallel-testing-enabled NO \
  ${ONLY_TESTING_ARGS[@]+"${ONLY_TESTING_ARGS[@]}"} \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee "$OUTPUT_DIR/logs/test.log"
TEST_STATUS=${PIPESTATUS[0]}
set -e

sleep 3
kill "$AGENT_PID" 2>/dev/null || true
wait "$AGENT_PID" 2>/dev/null || true
rm -rf "$REQUEST_DIR"
for clip in "$OUTPUT_DIR"/video/*-raw.mp4; do
  [[ -e "$clip" ]] || continue
  [[ "$clip" == "$RAW_VIDEO" ]] && continue
  final_clip="${clip%-raw.mp4}.mp4"
  # Re-encode to standard H.264 with regular keyframes so the clip plays and seeks
  # everywhere (raw simulator recordings only play correctly from the start).
  for preset in Preset1920x1080 Preset1280x720; do
    rm -f "$final_clip"
    if avconvert --preset "$preset" --source "$clip" --output "$final_clip" --replace >/dev/null 2>&1 \
      && [[ -s "$final_clip" ]] && [[ "$(stat -f%z "$final_clip")" -le "$MAX_VIDEO_BYTES" ]]; then
      break
    fi
  done
  if [[ -s "$final_clip" ]]; then
    rm -f "$clip"
  else
    mv -f "$clip" "$final_clip"
  fi
  echo "Clip ready: $final_clip ($(stat -f%z "$final_clip") bytes)"
done

if [[ -n "$VIDEO_PID" ]]; then
  sleep 2
  kill -INT "$VIDEO_PID" || true
  wait "$VIDEO_PID" || true
  VIDEO_PID=""
  compress_video
else
  rmdir "$OUTPUT_DIR/video" 2>/dev/null || true
fi

EXTRA_DEVICE_LIST=()
if [[ -n "$EXTRA_DEVICES" ]]; then
  IFS=',' read -r -a EXTRA_DEVICE_LIST <<< "$EXTRA_DEVICES"
fi
for extra_name in ${EXTRA_DEVICE_LIST[@]+"${EXTRA_DEVICE_LIST[@]}"}; do
  extra_type="$(device_type_for "$extra_name")"
  if [[ -z "$extra_type" ]]; then
    echo "Skipping $extra_name: not available for $RUNTIME_NAME"
    continue
  fi
  extra_slug="$(echo "$extra_name" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed 's/-$//')"
  EXTRA_UDID="$(xcrun simctl create "NeuralKey $extra_name" "$extra_type" "$RUNTIME_ID")"
  echo "Extra simulator: $extra_name, $EXTRA_UDID"
  prepare_simulator "$EXTRA_UDID"

  set +e
  TEST_RUNNER_NK_CAPTURE_DIR="$OUTPUT_DIR/screenshots/$extra_slug" xcodebuild test-without-building \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -destination "id=$EXTRA_UDID" \
    -derivedDataPath "$DERIVED_DATA" \
    -parallel-testing-enabled NO \
    ${ONLY_TESTING_ARGS[@]+"${ONLY_TESTING_ARGS[@]}"} \
    CODE_SIGNING_ALLOWED=NO \
    2>&1 | tee "$OUTPUT_DIR/logs/test-$extra_slug.log"
  extra_status=${PIPESTATUS[0]}
  set -e
  if [[ "$extra_status" -ne 0 && "$TEST_STATUS" -eq 0 ]]; then
    TEST_STATUS="$extra_status"
  fi

  xcrun simctl shutdown "$EXTRA_UDID" >/dev/null 2>&1 || true
  xcrun simctl delete "$EXTRA_UDID" >/dev/null 2>&1 || true
  EXTRA_UDID=""
done

echo "Captured screenshots:"
ls -laR "$OUTPUT_DIR/screenshots" || true
exit "$TEST_STATUS"
