# Scripts

Place repeatable project automation here.

Suggested scripts:
- `bootstrap.sh` setup local dev env
- `check.sh` run lint + tests
- `release.sh` build release artifacts

Available:
- `check_mobile_perf.sh` runs mobile `analyze + test` and prints pre-TestFlight perf checklist.
- `backfill_legacy_expense_owed_cents.php` repairs legacy `trip_expense_participants.owed_cents` rows where per-expense sum does not match amount.
- `run_settlement_reminders.php` emits automatic settlement reminders for overdue `pending/sent` settlements.
- `run_push_delivery.php` processes queued push deliveries to APNs/FCM.
- `run_migrations.php` runs SQL migrations from `sql/migrations` and tracks applied files in `trip_schema_migrations`.
- `vps_run_migrations.sh` runs `run_migrations.php` remotely on VPS over SSH.
- `monitor_api_health.sh` verifies API health endpoints and sends alerts (webhook/Telegram), optional healthcheck ping.
- `monitor_push_queue.sh` checks push queue backlog/failures against alert thresholds.
- `monitor_system_updates.sh` checks pending package updates, reboot-required flag, and core service health.
- `backup_vps.sh` creates DB + app state backups with retention cleanup.
- `backup_restore_check.sh` performs restore smoke-test from latest DB backup into temp DB.
- `weekly_maintenance.sh` runs weekly apt maintenance (upgrade/autoremove/autoclean) with alerts.

Alert routing:
- Preferred: set `TRIP_ALERT_TELEGRAM_BOT_TOKEN` + `TRIP_ALERT_TELEGRAM_CHAT_ID` in `.env`.
- If Telegram is configured, alerts are sent only to Telegram.
- `TRIP_ALERT_WEBHOOK_URL` is kept as legacy fallback when Telegram is not configured.

Usage:
- Dry run: `php scripts/backfill_legacy_expense_owed_cents.php --dry-run`
- Apply all trips: `php scripts/backfill_legacy_expense_owed_cents.php`
- Apply one trip: `php scripts/backfill_legacy_expense_owed_cents.php --trip-id=1`
- Dry run reminders: `php scripts/run_settlement_reminders.php --dry-run`
- Run reminders: `php scripts/run_settlement_reminders.php --limit=120`
- Dry run push: `php scripts/run_push_delivery.php --dry-run`
- Run push worker: `php scripts/run_push_delivery.php --limit=100`
- Check API health: `scripts/monitor_api_health.sh`
- Check push queue health: `scripts/monitor_push_queue.sh`
- Check system updates/reboot/services: `scripts/monitor_system_updates.sh`
- Run backup: `scripts/backup_vps.sh`
- Run backup restore smoke test: `scripts/backup_restore_check.sh`
- Run weekly maintenance dry run: `scripts/weekly_maintenance.sh --dry-run`
- Run weekly maintenance apply: `scripts/weekly_maintenance.sh`
- Show pending DB migrations: `php scripts/run_migrations.php --dry-run`
- One-time baseline on already migrated DB: `php scripts/run_migrations.php --baseline`
- Apply pending DB migrations: `php scripts/run_migrations.php`
- Remote dry run on VPS: `VPS_HOST=204.168.239.179 VPS_USER=splytoadmin scripts/vps_run_migrations.sh dry-run`
- Remote baseline on VPS (one-time): `VPS_HOST=204.168.239.179 VPS_USER=splytoadmin scripts/vps_run_migrations.sh baseline`
- Remote apply on VPS: `VPS_HOST=204.168.239.179 VPS_USER=splytoadmin scripts/vps_run_migrations.sh apply`
