# P0 Test Readiness (2026-03-16)

This checklist tracks critical stability checks before wider TestFlight/Android testing.

## Automated checks

0. Critical trust flows covered in code/tests
   - Status: UPDATED LOCALLY (2026-04-25)
   - Covers:
     - trip Activity/audit feed for expense create/edit/delete, trip/member changes, settlement sent/confirmed/dispute actions
     - safe confirmation before expense edit, expense delete, settlement sent, and settlement confirmation
     - settlement dispute recovery: cancel sent status and report not received
     - visible trip sync status: all synced / syncing / waiting to sync / retry
     - API smoke script extended for create trip, add/edit/delete expense, finish trip, mark sent, cancel sent, report not received, confirm received, activity feed, notifications feed

1. Release build (Android)
   - Command:
     - `/Users/matissgeinerts/Developer/flutter/bin/flutter build apk --release`
   - Status: PASS
   - Artifact:
     - `mobile/build/app/outputs/flutter-apk/app-release.apk`

2. Release build (iOS, no codesign)
   - Command:
     - `/Users/matissgeinerts/Developer/flutter/bin/flutter build ios --release --no-codesign`
   - Status: PASS
   - Artifact:
     - `mobile/build/ios/iphoneos/Runner.app`

3. Integration smoke bootstrap
   - Command:
     - `/Users/matissgeinerts/Developer/flutter/bin/flutter test integration_test/app_smoke_test.dart`
   - Status: PASS

4. API P0 smoke (happy path + data isolation + token flow + request-id echo)
   - Command:
     - `scripts/p0_api_smoke.sh`
   - Status: PASS
   - Covers:
     - register/login
     - create trip
     - add/list expense
     - settlement sent/confirm
     - logout/login cycle (re-login on fresh device token)
     - data isolation (user B blocked from user A private trip)
     - refresh token valid/invalid behavior
     - `X-Request-Id` response echo

## Manual checks still required

1. Offline/weak network UX
   - Ensure no red-screen crash and user sees retry/failure UI.
   - Android quick toggle:
     - `adb shell svc wifi disable`
     - `adb shell svc data disable`
     - then enable both back with `enable`.
   - iOS Simulator:
     - Use macOS Network Link Conditioner profile (Very Bad Network), then retry key flows.

2. Monitoring pipeline end-to-end
   - Confirm `TRIPSPLIT_SENTRY_DSN` is set for release builds.
   - Trigger a handled error and verify event arrives in Sentry with:
     - user context
     - trip context (when open)
     - request id metadata for API failures
   - Correlate API request id in server responses/logs.

3. Human exploratory happy path
   - register/login -> create trip -> invite friend -> add/edit expense -> end trip -> settle -> logout/login.
   - Run on both iOS and Android release builds.
