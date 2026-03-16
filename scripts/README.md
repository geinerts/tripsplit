# Scripts

Place repeatable project automation here.

Suggested scripts:
- `bootstrap.sh` setup local dev env
- `check.sh` run lint + tests
- `release.sh` build release artifacts

Available:
- `check_mobile_perf.sh` runs mobile `analyze + test` and prints pre-TestFlight perf checklist.
- `backfill_legacy_expense_owed_cents.php` repairs legacy `trip_expense_participants.owed_cents` rows where per-expense sum does not match amount.

Usage:
- Dry run: `php scripts/backfill_legacy_expense_owed_cents.php --dry-run`
- Apply all trips: `php scripts/backfill_legacy_expense_owed_cents.php`
- Apply one trip: `php scripts/backfill_legacy_expense_owed_cents.php --trip-id=1`
