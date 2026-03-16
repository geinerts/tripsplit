#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOBILE_DIR="$ROOT_DIR/mobile"
FLUTTER_BIN="${FLUTTER_BIN:-$HOME/Developer/flutter/bin/flutter}"

if [[ ! -x "$FLUTTER_BIN" ]]; then
  echo "Flutter binary not found: $FLUTTER_BIN" >&2
  echo "Set FLUTTER_BIN or install Flutter first." >&2
  exit 1
fi

cd "$MOBILE_DIR"

echo "[check] Flutter: $FLUTTER_BIN"
"$FLUTTER_BIN" analyze

echo "[check] flutter test"
"$FLUTTER_BIN" test

echo
echo "Manual pre-TestFlight performance checklist:"
echo "1) Run app in profile/release mode on iOS + Android."
echo "2) Verify no visible jank in Trips/Workspace/Friends lists."
echo "3) Confirm API slow calls from [PERF] logs (p95 trends)."
echo "4) Confirm add expense / notifications / profile edit flows."
echo
echo "OK: static checks passed."
