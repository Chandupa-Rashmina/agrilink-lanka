# AgriLink Lanka Android Builds

## USB test release

File: `agrilink-lanka-android-usb-test.apk`

This build uses:

- `APP_ENV=development`
- `API_BASE_URL=http://127.0.0.1:8000/api`

Use it only with:

```bash
adb reverse tcp:8000 tcp:8000
```

SHA-256: `6342f172cfd683e50f4d6d921ac86e41a1f0e322ed9f306c987f924f1a152c9a`

For public distribution, rebuild with the deployed HTTPS API URL.
