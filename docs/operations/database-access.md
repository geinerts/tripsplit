# Database identities

Runtime, migrations and backup exports use separate MySQL accounts. Credentials
are server-local, outside the web root and never committed or passed on the command line.

| Identity | Scope | Privileges |
| --- | --- | --- |
| Runtime | App schema only | SELECT, INSERT, UPDATE, DELETE |
| Migrator | App schema only | Runtime privileges plus CREATE, ALTER, DROP, INDEX, REFERENCES |
| Backup | App schema only | SELECT, SHOW VIEW |

No identity has GRANT OPTION, FILE, SUPER, CREATE USER or global data access.
The runtime identity also serves current admin and background-job code; separating
admin DML/table permissions further is a separate boundary-hardening task.
Schema-wide DML still permits data exfiltration/modification after a SQL injection
or runtime compromise. This change limits blast radius; it does not replace
authorization, parameterized SQL or application security.

## Protected credentials

- Runtime continues using the existing application environment and password.
- Migrator: `/etc/splyto/migrations.cnf`, root-owned mode 0600.
- Backup: `/etc/splyto/backup.cnf`, root-owned mode 0600.
- Each operator file contains only a `[client]` section with `host`, `user`, `password`.
- Local development may override `TRIP_MIGRATION_CREDENTIALS_FILE` or
  `TRIP_BACKUP_CREDENTIALS_FILE` with an operator-owned mode-0600 file.
- Missing/unsafe operator files fail closed. There is no runtime-credential fallback.
- Do not put operator passwords in the web-readable `.env` or mobile configuration.

## One-time VPS transition

Inspect actual runtime SQL, grants, jobs and schema first. The current application
does not execute DDL; it checks for required migrations instead. All current base
tables must be InnoDB. The supported schema has no routines, triggers or events.

1. Keep root-only rollback copies of the affected operational scripts.
2. Install `scripts/lib/database_access.php`, `scripts/provision_database_access.php`,
   `scripts/backup_database.php` and the updated migration, backup and restore scripts.
3. Under the existing backup job's exclusive lock, run
   `sudo php scripts/provision_database_access.php` for read-only preflight, then
   `sudo php scripts/provision_database_access.php --apply`.
4. Provisioning generates two independent random secrets locally, tests both
   connections, then revokes only excess runtime schema privileges, retaining DML.
5. Re-running provisioning after account/file creation is deliberately refused.
   On partial failure inspect accounts and protected files as administrator; do not
   delete or rotate them blindly. No passwords are printed, including SQL errors.
6. Verify grants through `information_schema`, operator file permissions, and that
   `www-data` cannot read either operator credential file.
7. Run a migration dry-run, real backup and restore smoke check. Verify API health.
   Do not apply unrelated pending migrations as part of this transition.

Production commands run via the established administrative SSH user with sudo,
not a remote root login. Emergency restoration of former schema privileges is
an explicit administrator operation, never an automatic application fallback.
Rolling scripts back alone does not restore the old database grants.

## Migrations and exports

The migration runner uses only the migrator account and records checksums as before.
Dry-run does not create its bookkeeping table. Apply and backup exports share the
same MySQL advisory lock, held for the full operation; manual schema changes must
respect that maintenance boundary too.

Exports use `--single-transaction --quick --no-tablespaces --set-gtid-purged=OFF`
and explicitly skip routines/triggers/events. Those objects do not exist in the
verified schema and the migrator cannot create them. Before introducing them,
revisit export coverage and privileges instead of silently omitting them.
GTID state is intentionally not part of this application-level recovery backup.
Only successful exports are renamed from `.partial` to `.sql.gz`.

Restore is a separate local administrator operation via the root Unix socket.
`backup_restore_check.sh` creates a uniquely named temporary schema, imports the
latest local backup, checks tables and drops only that schema. Neither runtime
nor backup credentials can create restore databases. Never start an app/mail/push
worker against a restored production snapshot during a smoke test.

## Verification and limits

`ops/testing/compose.yaml` runs synthetic account-permission tests, actual migration
apply/dry-run, maintenance-lock exclusion and fail-closed checks. Unit tests check
credential file permissions, links, unexpected options and the privilege matrix.
The Docker database currently uses MySQL 8.4; the deployed Ubuntu MySQL version
must additionally be checked during rollout.

This does not complete independent encrypted recovery: external configuration and
keys (including these operator files), encryption, offsite storage and full-service
restore remain the separate recovery workstream. Keep all backup directories
operator-only; do not transfer real dumps into development or CI.
