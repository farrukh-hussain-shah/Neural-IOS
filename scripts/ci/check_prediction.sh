#!/usr/bin/env bash
# Builds and runs the word prediction checks (scripts/ci/prediction_check) on macOS, against
# the real downloadable word lists. No simulator needed.
set -euo pipefail

cd "$(dirname "$0")/../.."
output="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/prediction-check"
mkdir -p "$output"

sources=()
while IFS= read -r -d '' file; do
  sources+=("$file")
done < <(find Shared/TextPrediction -name '*.swift' -print0)

xcrun --sdk macosx swiftc -O -swift-version 5 -parse-as-library   "${sources[@]}"   Shared/Keyboard/Model/KeyboardSharedState.swift   scripts/ci/prediction_check/PredictionCheck.swift   -o "$output/prediction-check"

"$output/prediction-check"
