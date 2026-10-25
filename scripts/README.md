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
- Migrations and backups require separate protected operator credentials, never
  the runtime DB account. See [database access](../docs/operations/database-access.md).
- `monitor_api_health.sh` verifies API health endpoints and sends alerts (webhook/Telegram), optional healthcheck ping.
- `monitor_push_queue.sh` checks push queue backlog/failures against alert thresholds.
- `monitor_system_updates.sh` checks pending package updates, reboot-required flag, and core service health, then includes package names/version changes in Telegram alerts.
- `send_daily_ops_digest.sh` sends a read-only daily Telegram summary for API, push queue, services, updates, reboot, disk, and backups.
- `backup_vps.sh` creates DB + app state backups and prunes expired complete sets after checksum/archive verification. Requires Python 3.
- `backup_retention.py` defaults to a read-only cleanup plan. It preserves a verified recent backup, rejects unsafe paths and stops if no complete valid backup from the last 48 hours exists. Only manifest-linked routine sets are eligible; partial/manual/provider backups are excluded.
- `backup_restore_check.sh` performs restore smoke-test from latest DB backup into temp DB.
- `weekly_maintenance.sh` runs weekly apt maintenance (upgrade/autoremove/autoclean) with alerts.

Alert routing:
- Preferred: set `TRIP_ALERT_TELEGRAM_BOT_TOKEN` + `TRIP_ALERT_TELEGRAM_CHAT_ID` in `.env`.
- If Telegram is configured, alerts are sent only to Telegram.
- `TRIP_ALERT_WEBHOOK_URL` is kept as legacy fallback when Telegram is not configured.
- `TRIP_SYSTEM_MONITOR_MAX_UPDATE_LINES` limits how many package names are shown per update group in one Telegram alert.

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
- Send daily ops digest: `scripts/send_daily_ops_digest.sh`
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
- Direct SSH to VPS: `ssh -p 22 splytoadmin@204.168.239.179`
- Check deployed commit on VPS: `ssh -p 22 splytoadmin@204.168.239.179 "cd /var/www/splyto && git rev-parse --short HEAD && git status --short --branch"`

## Routine backup retention

The selected Splyto recovery window is 14 days (operator decision, not a universal
GDPR deadline). `TRIP_BACKUP_RETENTION_DAYS=14` is set in the server environment.
The existing daily backup job invokes cleanup after producing the new set.
A set is expired only when its timestamp and every member's modification time
are older than the exact 14 × 24-hour cutoff. There is no `find -mtime` rounding.
Deletion occurs on the next successful daily run; failed integrity checks stop
cleanup and the backup job retains its existing failure-alert behavior.

Read-only plan (as a server operator):

```sh
python3 scripts/backup_retention.py --root /var/backups/splyto --database splyto --days 14
```

For an authorized one-off cleanup, use the existing backup job's lock and `--apply`:

```sh
flock -n /tmp/splyto_backup.lock python3 scripts/backup_retention.py --root /var/backups/splyto --database splyto --days 14 --apply
```

Do not run this concurrently with a restore that is reading expired copies.
The helper verifies checksums/gzip/tar readability, not a full SQL restoration;
continue isolated restore checks separately. Never run application/mail/push
workers against a restored production snapshot. Incomplete sets, partial files,
manual recovery copies and Hetzner snapshots require separate review and expiry.

Synthetic safety checks:

```sh
PYTHONDONTWRITEBYTECODE=1 python3 -m unittest discover -s scripts/tests -p test_backup_retention.py
```
