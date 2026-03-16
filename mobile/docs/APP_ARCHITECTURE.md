# TripSplit Mobile App Architecture

This document defines the target structure for the Flutter app (`mobile`) used for iOS and Android.

## Scope

- Primary platforms: iOS + Android.
- Flutter web UI is not a product target; keep only for local debugging when needed.
- Backend API remains shared.

## Current Structure (Good Baseline)

The app already follows a feature-first structure with layered modules:

```text
lib/
  app/        # app bootstrap, theme, locale, routes, dependency wiring
  core/       # cross-feature building blocks (network, config, auth storage, UI helpers)
  features/
    auth/
    trips/
    workspace/
    friends/
    analytics/
    shell/
```

This is the right direction and should be kept.

## Structural Rules

1. Keep business logic inside feature boundaries.
2. Keep `app/` as composition/root only (no feature-specific logic).
3. `core/` must stay generic and reusable across features.
4. Avoid "god files" by splitting by responsibility:
   - `page` (screen orchestration)
   - `actions` (mutations, side effects)
   - `dialogs/sheets`
   - `widgets` (pure UI pieces)
   - `formatters/helpers` (pure functions)
5. Prefer private widgets/classes in dedicated files instead of very long single files.

## File Size Budgets

- Page orchestration file: target <= 250 lines (hard limit 400).
- Helper/widget file: target <= 300 lines (hard limit 450).
- Any file > 700 lines should be split immediately.

## Priority Split Backlog

### Completed

- `features/shell/presentation/pages/main_shell_page.dart`
- `features/auth/presentation/pages/login_page.dart`
- `features/auth/presentation/pages/profile_page.dart`
- `features/analytics/presentation/pages/analytics_page.dart`
- `features/friends/presentation/pages/friends_page.dart`
- `features/workspace/presentation/pages/workspace_page_tab_balances.dart` (split into tab + details parts)
- `features/trips/presentation/pages/trips_page_widgets.dart` (split into widgets/cards/navigation parts)
- `features/workspace/presentation/pages/workspace_page_layout.dart` (split into layout/navigation/overview parts)
- `features/workspace/presentation/pages/workspace_page_actions_expenses.dart` (split into mutations + details parts)

### P1 (next)

- Keep splitting any file above soft budget (>300 lines) when touching related logic.
- Prefer moving reusable UI chunks from page-part files into `presentation/widgets/`.

### P2 (next)

- Split long dialog builders in `workspace_page_dialogs.dart` into smaller builders/sections.
- Extract repeated bottom-nav/avatar builders into shared widgets where practical.

## Suggested Pattern Per Feature

```text
features/<feature>/
  data/
    datasources/
    models/
    repositories/
  domain/
    entities/
    repositories/
    usecases/
  presentation/
    controllers/
    pages/
    widgets/
```

For large pages:

```text
presentation/pages/<page_name>/
  <page_name>_page.dart
  <page_name>_actions.dart
  <page_name>_dialogs.dart
  <page_name>_widgets.dart
  <page_name>_helpers.dart
```

## Practical Next Steps

1. Keep reducing high-churn files that still exceed soft line budget.
2. Continue replacing duplicated UI patterns with shared widgets.
3. After each split: run `flutter analyze` and smoke test on Android + iOS.
