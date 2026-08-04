# Mobile Environments and Release

## Development profiles

### USB development

Laravel:

```bash
cd /home/lordpakeer/development/agrilink-lanka/apps/api
php artisan serve --host=127.0.0.1 --port=8000
```

Flutter:

```bash
cd /home/lordpakeer/development/agrilink-lanka/apps/mobile
./tool/run_android_usb.sh
```

This profile uses ADB reverse and:

```text
APP_ENV=development
API_BASE_URL=http://127.0.0.1:8000/api
```

### LAN development

Laravel:

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

Flutter:

```bash
./tool/run_android_lan.sh http://YOUR_COMPUTER_IP:8000/api
```

The Android device and computer must be on the same network.

## Production release

A distributable release APK must use a real HTTPS API endpoint.

```bash
./tool/build_release_apk.sh https://api.example.com/api
```

The script rejects non-HTTPS release URLs.

Output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## Current version

```text
1.0.0+2
```

## Important

Do not distribute an APK built with:

```text
http://127.0.0.1:8000/api
```

That address only works on the development phone while ADB reverse is active.
