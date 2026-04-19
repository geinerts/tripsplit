# Splyto Mobile Professionalization Plan

Last updated: 2026-04-19
Scope: Flutter mobile app (`mobile/`) + release process

## Goal
Move from "works well" to a stable production-grade process:
- predictable releases
- consistent architecture
- full localization discipline
- lower regression risk

## Status legend
- [ ] Not started
- [~] In progress
- [x] Done

## Timeline (6 weeks)

### Week 1 (2026-04-20 to 2026-04-26): Standards + Quality Gates
- [ ] Create `mobile/docs/ARCHITECTURE_RULES.md`
- [ ] Create PR checklist (required items: analyze, tests, l10n, no new hardcoded UI text)
- [ ] Add CI quality gate to block merge if `flutter analyze` or tests fail
- [ ] Add release checklist draft (`mobile/docs/RELEASE_CHECKLIST.md`)

Definition of done:
- Merge cannot happen with broken analyze/tests.
- Team has one shared coding checklist.

### Week 2 (2026-04-27 to 2026-05-03): State Management Consistency
- [ ] Freeze standard: `Controller + ChangeNotifier` (for this phase)
- [ ] Add page template pattern (`page + actions + widgets + controller`)
- [ ] Refactor top 3 high-churn pages to match pattern
- [ ] Document allowed exceptions

Definition of done:
- New code follows one state pattern.
- Business logic is not added directly into widget build blocks.

### Week 3 (2026-05-04 to 2026-05-10): Full l10n Discipline
- [ ] Add script: `scripts/check_hardcoded_strings.sh`
- [ ] Add CI step to run hardcoded text check
- [ ] Move remaining user-facing hardcoded strings to ARB (`en/lv/es`)
- [ ] Create allowlist for technical labels only

Definition of done:
- Hardcoded user-facing text count in UI = 0 (except explicit allowlist).

### Week 4 (2026-05-11 to 2026-05-17): Design System + UI States
- [ ] Create reusable UI states: `LoadingState`, `EmptyState`, `ErrorState`, `RetryCard`
- [ ] Apply those states to top 8 core screens
- [ ] Normalize spacing/typography/button usage to `AppDesign/Theme`
- [ ] Remove duplicate ad-hoc style blocks in touched screens

Definition of done:
- Core screens have consistent visual and state behavior.

### Week 5 (2026-05-18 to 2026-05-24): API Reliability + Security
- [ ] Centralize API error mapping (timeout/network/401/403/5xx)
- [ ] Document retry + timeout behavior in one place
- [ ] Add tests for token refresh/session edge cases
- [ ] Run secrets audit (no sensitive values in repo/client plaintext)

Definition of done:
- Auth/session edge cases are covered.
- API failures produce consistent user messages.

### Week 6 (2026-05-25 to 2026-05-31): Tests + Release Hardening
- [ ] Expand unit tests for critical domain logic (auth/trips/workspace)
- [ ] Add widget tests for critical flows
- [ ] Strengthen integration smoke flow (login -> trips -> workspace -> notifications)
- [ ] Finalize release process for dev/stage/prod + rollback notes

Definition of done:
- Stable pre-release gate exists and is repeatable.

## Weekly KPIs
Track every week in PR summary or release notes:
1. Hardcoded UI text count
2. Crash-free sessions (%)
3. API p95 for critical actions
4. Test pass rate and flaky count
5. Hotfix count after release

## Priority order (if capacity is tight)
1. Week 1 quality gates
2. Week 3 l10n discipline
3. Week 6 tests/release hardening
4. Week 2, 4, 5 improvements

## Immediate next actions
1. Create `ARCHITECTURE_RULES.md`.
2. Add PR checklist markdown file.
3. Add CI check job for analyze/tests.
4. Start hardcoded text scanner script.

## Server-side next steps (VPS backlog)
Context: security/ops baseline is already in place (SSH hardening, UFW/fail2ban, backups, restore smoke-test, cron monitors, weekly maintenance).

### Performance and reliability (next phase)
- [ ] Enable MySQL slow query log and run weekly index/query audit.
- [ ] Tune PHP-FPM + OPcache based on real memory/traffic profile.
- [ ] Tune Nginx worker/timeout/buffer settings for current traffic pattern.
- [ ] Add Nginx API rate limiting (`limit_req`) and connection limiting (`limit_conn`) for abuse spikes.
- [ ] Add Cloudflare WAF + rate-limit rules for critical endpoints (auth, register, invite, write actions).
- [ ] Add CPU/RAM/disk/load alert thresholds (Telegram) with clear severity.
- [ ] Add API latency monitor (p50/p95/p99) for core endpoints.

### Operational maturity
- [ ] Add monthly disaster-recovery drill (restore to clean target and verify API).
- [ ] Add quarterly dependency review window (Nginx/PHP/MySQL/runtime packages).
- [ ] Add maintenance runbook with rollback playbooks for failed updates.

### Admin backoffice (future)
- [ ] Build separate web admin panel (not inside mobile app).
- [ ] Add strict admin auth: RBAC roles, 2FA, session controls, audit logs.
- [ ] Add support tools: user lookup, account status actions, notification/email delivery logs.
- [ ] Add ops tools: queue health, cron status, incident notes, safe retry actions.
