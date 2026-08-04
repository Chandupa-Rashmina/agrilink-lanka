#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 http://YOUR_COMPUTER_IP:8000/api [DEVICE_ID]"
  exit 1
fi

API_BASE_URL="$1"
DEVICE_ID="${2:-d32df159}"

flutter run \
  -d "$DEVICE_ID" \
  --dart-define=APP_ENV=development \
  --dart-define=API_BASE_URL="$API_BASE_URL"
