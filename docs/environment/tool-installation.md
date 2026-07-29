# AgriLink Lanka Workstation Tooling

## Purpose

This document records the development tools required to build AgriLink Lanka.

The project uses:

- Laravel for the backend API
- Nuxt for the web frontend
- Flutter for mobile and desktop clients
- Docker for repeatable service environments
- GitHub for source control and future CI/CD

## Verified Workstation

Operating system:

- Debian GNU/Linux 13 (Trixie)
- x86_64

Source control:

- Git 2.47.3
- GitHub CLI 2.46.0
- GitHub authentication configured

Container tooling:

- Docker Engine 29.6.2
- Docker Compose 5.3.1
- Docker Buildx 0.35.0
- Docker access configured for the normal user

JavaScript tooling:

- Node.js 24.18.0
- npm 11.16.0
- Corepack 0.35.0
- pnpm 11.17.0

PHP tooling:

- PHP CLI 8.4.23
- Composer 2.8.8
- Required Laravel PHP extensions installed

Flutter and Android tooling:

- Flutter 3.44.5
- Dart 3.12.2
- Java 21
- Android SDK 36.1
- Android licences accepted
- Flutter doctor reports no issues

## Important Environment Variables

```text
JAVA_HOME=/opt/android-studio/jbr
ANDROID_HOME=/home/lordpakeer/Android/Sdk
ANDROID_SDK_ROOT=/home/lordpakeer/Android/Sdk


```

## Installation Principles

The workstation was prepared using this process:

1. Audit the existing state.
2. Use trusted package repositories.
3. Install only required tools.
4. Configure permissions and environment variables.
5. Verify actual runtime behaviour.
6. Preserve rollback options.

Project services such as PostgreSQL and Redis will run through Docker instead of being installed directly on the workstation.
