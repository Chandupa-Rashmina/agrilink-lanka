#!/usr/bin/env bash

set -uo pipefail

failures=0

section() {
  printf '\n===== %s =====\n' "$1"
}

check_command() {
  local command_name="$1"

  if command -v "$command_name" >/dev/null 2>&1; then
    printf '[OK] %s: %s\n' \
      "$command_name" \
      "$(command -v "$command_name")"
  else
    printf '[FAIL] %s was not found in PATH\n' "$command_name"
    failures=$((failures + 1))
  fi
}

section "SYSTEM"
. /etc/os-release
printf 'OS: %s\n' "$PRETTY_NAME"
printf 'Architecture: %s\n' "$(uname -m)"

section "REQUIRED COMMANDS"

commands=(
  git
  gh
  docker
  node
  npm
  corepack
  pnpm
  php
  composer
  java
  adb
  sdkmanager
  flutter
  curl
  jq
  unzip
)

for command_name in "${commands[@]}"; do
  check_command "$command_name"
done

section "DOCKER"

if docker info >/dev/null 2>&1; then
  printf '[OK] Docker server: %s\n' \
    "$(docker info --format '{{.ServerVersion}}')"
else
  printf '[FAIL] Docker server is unavailable to the current user\n'
  failures=$((failures + 1))
fi

docker compose version 2>/dev/null || {
  printf '[FAIL] Docker Compose is unavailable\n'
  failures=$((failures + 1))
}

docker buildx version 2>/dev/null || {
  printf '[FAIL] Docker Buildx is unavailable\n'
  failures=$((failures + 1))
}

section "PHP EXTENSIONS"

php -r '
$required = [
    "bcmath",
    "curl",
    "intl",
    "mbstring",
    "pdo_pgsql",
    "pdo_sqlite",
    "xml",
    "zip",
];

$missing = array_filter(
    $required,
    fn ($extension) => !extension_loaded($extension)
);

if ($missing) {
    fwrite(
        STDERR,
        "[FAIL] Missing PHP extensions: "
        . implode(", ", $missing)
        . PHP_EOL
    );
    exit(1);
}

echo "[OK] Required PHP extensions are available" . PHP_EOL;
' || failures=$((failures + 1))

section "ENVIRONMENT VARIABLES"

for variable_name in JAVA_HOME ANDROID_HOME ANDROID_SDK_ROOT; do
  variable_value="${!variable_name:-}"

  if [[ -n "$variable_value" && -d "$variable_value" ]]; then
    printf '[OK] %s=%s\n' "$variable_name" "$variable_value"
  else
    printf '[FAIL] %s is missing or points to no directory\n' \
      "$variable_name"
    failures=$((failures + 1))
  fi
done

section "GITHUB"

if gh auth status >/dev/null 2>&1; then
  printf '[OK] GitHub CLI authentication is active\n'
else
  printf '[FAIL] GitHub CLI authentication is unavailable\n'
  failures=$((failures + 1))
fi

section "FLUTTER"

flutter_doctor_output="$(flutter doctor 2>&1)"
flutter_doctor_exit=$?

printf "%s\n" "$flutter_doctor_output"

if (( flutter_doctor_exit == 0 )) && grep -q "No issues found" <<< "$flutter_doctor_output"; then
  printf "[OK] Flutter doctor reports no issues\n"
else
  printf "[FAIL] Flutter doctor reported a problem\n"
  failures=$((failures + 1))
fi

section "DISK SPACE"
df -h "$HOME"

section "FINAL RESULT"

if (( failures == 0 )); then
  printf 'PASS: workstation is ready for AgriLink Lanka.\n'
  exit 0
fi

printf 'FAIL: %d workstation check(s) failed.\n' "$failures"
exit 1
