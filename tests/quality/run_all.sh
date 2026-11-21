#!/usr/bin/env bash
set -uo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$ROOT_DIR"

RADC="${RADC:-$ROOT_DIR/bin/radc}"
if [[ ! -x "$RADC" ]]; then
    echo "error: radc not found; set RADC=/path/to/radc" >&2
    exit 2
fi

set +e
RADC="$RADC" bash tests/radtest/runner/run_tests.sh
regression_status=$?
RADC="$RADC" bash tests/quality/run.sh
quality_status=$?
set -e

printf '\nRad test summary: regression=%s quality=%s\n' "$regression_status" "$quality_status"
if [[ "$regression_status" -ne 0 || "$quality_status" -ne 0 ]]; then
    exit 1
fi
