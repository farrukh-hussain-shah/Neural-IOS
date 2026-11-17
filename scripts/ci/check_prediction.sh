#!/usr/bin/env bash
# Builds and runs the word prediction checks (scripts/ci/prediction_check) on macOS, against
# the real downloadable word lists. No simulator needed.
#
# Compiler errors and failed checks are also reported as GitHub annotations, which show on the
# run page without signing in.
set -uo pipefail

cd "$(dirname "$0")/../.."
output="${RUNNER_TEMP:-${TMPDIR:-/tmp}}/prediction-check"
mkdir -p "$output"

annotate() {
  # $1: file with lines to report; only lines matching $2 become annotations.
  if [[ -n "${GITHUB_ACTIONS:-}" ]]; then
    grep -E "$2" "$1" | head -40 | while IFS= read -r line; do
      echo "::error title=Word prediction::${line}"
    done
  fi
}

sources=()
while IFS= read -r -d '' file; do
  sources+=("$file")
done < <(find Shared/TextPrediction -name '*.swift' -print0)

if ! xcrun --sdk macosx swiftc -O -swift-version 5 -parse-as-library \
  -target "$(uname -m)-apple-macosx14.0" \
  "${sources[@]}" \
  Shared/Keyboard/Model/KeyboardSharedState.swift \
  scripts/ci/prediction_check/PredictionCheck.swift \
  -o "$output/prediction-check" 2>&1 | tee "$output/build.log"; then
  annotate "$output/build.log" "error:"
  exit 1
fi

"$output/prediction-check" 2>&1 | tee "$output/run.log"
status=${PIPESTATUS[0]}
if [[ $status -ne 0 ]]; then
  annotate "$output/run.log" "FAIL|Fatal|fatal|failed"
  [[ -s "$output/run.log" ]] || echo "::error title=Word prediction::check exited with $status and no output"
fi
exit "$status"
