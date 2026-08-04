#!/usr/bin/env bash
set -euo pipefail

DEVICE_ID="${1:-d32df159}"
API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:8000/api}"

adb reverse tcp:8000 tcp:8000

flutter run \
  -d "$DEVICE_ID" \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL="$API_BASE_URL"
