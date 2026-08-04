#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 https://api.example.com/api"
  exit 1
fi

API_BASE_URL="$1"

case "$API_BASE_URL" in
  https://*/api|https://*/api/)
    ;;
  *)
    echo "Release API URL must use HTTPS and end with /api"
    exit 1
    ;;
esac

flutter clean
flutter pub get

flutter analyze
flutter test

flutter build apk \
  --release \
  --dart-define=APP_ENV=production \
  --dart-define=API_BASE_URL="$API_BASE_URL"

APK="build/app/outputs/flutter-apk/app-release.apk"

echo
echo "Release APK:"
ls -lh "$APK"
sha256sum "$APK"
