# SPLYTO development instructions

SPLYTO (package/repository name `tripsplit`) is an existing Flutter application for iOS and Android with a shared PHP backend. Preserve working behavior and keep changes scoped to the user's request.

## Project map and architecture

- Run Flutter/Dart commands from `mobile/`, which contains `pubspec.yaml`, `test/`, and `integration_test/`.
- `mobile/lib/app/` owns bootstrap, dependency wiring (`AppDependencies`), routing (`AppRouter`), theme, and locale preferences.
- `mobile/lib/features/<feature>/` owns feature behavior. Follow the existing `data/`, `domain/`, and `presentation/` boundaries where present. Domain code stays independent of Flutter UI; data sources and repository implementations own persistence/network access; controllers and widgets handle presentation.
- `mobile/lib/core/` contains shared network, account/session storage, configuration, localization helpers, and reusable UI. Preserve account-scoped cache isolation and existing error handling.
- Reuse the existing explicit dependency wiring, controllers, and routing. Do not introduce a new state-management framework, router, or architecture merely because an upstream skill demonstrates one. Avoid new cross-feature presentation dependencies.
- Read `mobile/docs/APP_ARCHITECTURE.md` for mobile structure, `docs/architecture/overview.md` for platform boundaries, and the relevant `docs/api/` contract before changing an integration. Treat structural cleanup as scoped work, not permission for a repository-wide refactor.

## Implementation rules

- Preserve existing functionality, navigation, offline behavior, and iOS/Android compatibility. Inspect existing work before editing; do not overwrite unrelated changes.
- Follow Dart/Flutter best practices and `mobile/analysis_options.yaml`. Use APIs and language features supported by the project's SDK constraints and installed SDK; an installed skill is not authorization to upgrade them.
- Do not change API contracts without explicit user permission. This includes legacy action names, endpoints, request/response fields, authentication semantics, and error formats. After approval, update the relevant contract documentation before implementation.
- Prefer small, maintainable widgets and existing shared components in `core/ui/` and `app/theme/`. Use the existing responsive helpers in `core/ui/responsive.dart`; account for safe areas, keyboards, text scaling, loading/error states, and accessibility.
- Reuse existing dependencies and SDK facilities. Add a dependency only when the requested behavior needs it and the existing stack cannot reasonably provide it; explain the reason. Avoid incidental SDK, package, lockfile, or platform upgrades.
- For localization, follow `docs/mobile/localization.md`: edit ARB sources under `mobile/lib/l10n/`, preserve message keys/placeholders/plurals across supported locales, and run `flutter gen-l10n`. Do not hand-edit generated localization Dart files. Notification catalog generation can affect backend files, so keep it within the authorized scope; generation does not authorize deployment.
- Never expose API keys, credentials, signing material, session tokens, or secrets in source, examples, logs, tool output, or chat. Use the project's ignored local configuration and approved secure storage. Do not inspect secret values merely to check whether credentials exist.
- Ask before potentially destructive changes. Production configuration changes, deployments, database migrations, and release publishing require explicit task authorization.

## Verification

- After Flutter/Dart code changes, run `flutter analyze` from `mobile/` (use `--no-pub` when dependencies are already resolved). Format only the changed Dart files.
- Run relevant unit/widget tests for behavior changes and refactors. Use the Dart MCP `run_tests` tool when connected; otherwise run the corresponding Flutter tests from `mobile/`. Expand testing when the affected scope warrants it.
- Use existing `integration_test/` tests for affected end-to-end flows when an appropriate iOS/Android test device and non-production configuration are available. Do not inject Flutter Driver support into the production entry point just to follow a generic skill. State device, credential, or backend prerequisites when integration tests cannot run.
- Report the checks actually run and their results. Distinguish existing failures from regressions; do not silently fix unrelated issues. Documentation/configuration-only changes need configuration and instruction checks, not a full app test suite.

## Codex skills, MCP, and documentation

- Official Flutter/Dart skills are installed once in `.agents/skills/`. Select those relevant to the task and adapt examples to this existing project.
- The `dart` MCP server is configured in `.codex/config.toml`. Register `mobile/` with `add_roots` using its absolute file URI before project-scoped calls. Prefer its available analysis, test, package-source, symbol, hover, and runtime tools where appropriate.
- Runtime inspection and hot reload require a running development app and a valid Dart Tooling Daemon connection. Use the actual exposed tool schemas; upstream skill examples may target a newer server.
- For documentation, prefer installed SDK/package source and MCP hover/signature information for version-specific APIs. Use official `dart.dev`, `docs.flutter.dev`, and `api.flutter.dev` documentation for broader guidance. If the Google Developer Knowledge MCP is enabled and authenticated, use it for official documentation retrieval; otherwise browse those official sources. Do not mistake missing credentials for missing documentation.
