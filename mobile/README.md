# Mobile App (Flutter)

Feature-first clean structure.

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
