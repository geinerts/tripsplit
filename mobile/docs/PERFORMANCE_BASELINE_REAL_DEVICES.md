# Splyto Profile-Mode Baseline (Real Devices)

This table must be filled before each TestFlight rollout.  
Use **profile mode** and the same test account + seeded trip data set.

## Test dataset (minimum)

- 5 active trips
- 1 trip with 1,000+ expenses
- 100+ friends
- 500+ notifications

## Capture rules

- Build: `flutter run --profile`
- Run on real iOS + real Android (not simulators/emulators)
- Network: stable Wi‑Fi and one run on mobile data
- Record p50 and p95 when applicable (3-5 repetitions)

## Baseline table

| Date | Build SHA | Device | OS | Network | Cold start (s) | Login -> Home (s) | Home -> Trip open (s) | Trip expenses scroll jank | Notifications open (s) | API p95 core (ms) | Notes |
|---|---|---|---|---|---:|---:|---:|---|---:|---:|---|
| YYYY-MM-DD | abc1234 | iPhone 16e | iOS 26.x | Wi‑Fi |  |  |  |  |  |  |  |
| YYYY-MM-DD | abc1234 | Pixel 8 | Android 16 | Wi‑Fi |  |  |  |  |  |  |  |
| YYYY-MM-DD | abc1234 | iPhone 16e | iOS 26.x | 4G/5G |  |  |  |  |  |  |  |
| YYYY-MM-DD | abc1234 | Pixel 8 | Android 16 | 4G/5G |  |  |  |  |  |  |  |

## Acceptance gate (P0)

- Cold start <= `2.0s` (recent devices)
- Home -> Trip open p95 <= `1.2s`
- Core API p95 <= `500ms` (stable network)
- No visible frame drops on long expenses/friends/notifications lists

