# Splyto Monitoring (P0)

## 1) Required runtime flags

Set these when running/building app:

- `TRIPSPLIT_SENTRY_DSN` - Sentry DSN.
- `TRIPSPLIT_MONITORING_ENV` - e.g. `testflight`, `internal-android`, `prod`.
- `TRIPSPLIT_RELEASE_CHANNEL` - e.g. `dev`, `qa`, `testflight`, `prod`.
- `TRIPSPLIT_MONITORING_TRACE_SAMPLE_RATE` - `0.0..1.0` (recommended `0.05` for tests).

Example:

```bash
flutter run \
  --dart-define=TRIPSPLIT_SENTRY_DSN=https://<dsn> \
  --dart-define=TRIPSPLIT_MONITORING_ENV=testflight \
  --dart-define=TRIPSPLIT_RELEASE_CHANNEL=testflight \
  --dart-define=TRIPSPLIT_MONITORING_TRACE_SAMPLE_RATE=0.05
```

## 2) What is captured

- Unhandled Flutter errors.
- Platform dispatcher errors.
- Unhandled zone errors.
- Handled network/server errors from API client (`5xx`, network failures).

With context tags:

- `user_id` (if logged in),
- `trip_id` (when trip workspace is open),
- `release_channel`,
- `app_version`,
- `build_number`,
- `platform`,
- `origin`.

## 3) Symbolication checklist (before broad beta)

### iOS

- Build with Xcode archive.
- Ensure dSYM upload to Sentry is enabled in CI/release step.

### Android

- If using obfuscation/minify, upload `mapping.txt` to Sentry per release.

Without symbol uploads, stack traces from production builds can be unreadable.
