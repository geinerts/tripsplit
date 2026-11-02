# Mobile App (Flutter)

Feature-first clean structure.

## Live and travel maps (Mapbox)

iOS/Android use the official Mapbox SDK when a public `MAPBOX_ACCESS_TOKEN`
(`pk.…`) is provided at build time. Put it in an ignored
`config/env/testflight.local.json`, alongside the existing environment settings.
Do not put tokens in tracked source, example files, or use a secret `sk.` token.

```sh
flutter run --dart-define-from-file=config/env/testflight.local.json
flutter build ios --config-only --release --dart-define-from-file=config/env/testflight.local.json
```

Run the second command before archiving directly in Xcode so its generated build
configuration includes the token. Builds without a public token retain OSM for
live locations and the bundled Natural Earth overview for private memories; native Mapbox rendering needs a token and an iOS/Android
device or simulator.
Light/dark appearance follows the app theme. Mapbox's attribution and telemetry
opt-out remain available at the bottom of each map. The private travel map uses
quiet, flat Light/Dark styles with country/city labels and small check markers;
the live map uses Standard with street-level points of interest. Opening either
map does not initialise the SDK location component. Both use the same public token.

## Layout
- `lib/app` app shell and routing
- `lib/core` shared low-level concerns (network, config, errors)
- `lib/features/<feature>` domain-isolated feature modules

## Architecture
- See `docs/APP_ARCHITECTURE.md` for structure rules, file size budgets, and refactor priorities.
- See `docs/PERFORMANCE_TESTFLIGHT_P0.md` for current release/performance checklist before TestFlight.

## Feature Template
Each feature contains:
- `data/`
- `domain/`
- `presentation/`

## First Features
- auth
- trips
