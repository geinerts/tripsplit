# Manual Premium and partners

## Scope

Manual, fixed-term Premium grants are independent from RevenueCat, sandbox
purchases and future paid subscriptions. No checkout, charges or Free limits
are enabled by this release. `premium_access` is a display-only server projection;
future feature gates must resolve entitlements on the server, never trust a
client flag. There is no permanent/lifetime grant option; expiry is required,
up to five years in the future.

## Operations

- Admin panel: **Users > View user > Grant Premium**.
- Select testing, compensation, or partner. Partner grants require an existing
  partner; create one under **Partners > Add partner** first.
- Enter an expiry (displayed in the administrator's local timezone) and a reason.
  Storage and API dates use UTC.
- Existing grants can be extended or revoked. A stale edit version is rejected;
  reload before trying again. Revocation affects only that grant, not other grants.
- **Premium** lists active, expiring within 14 days, expired, revoked, or all grants.
  Search accepts nickname, email or partner name. **Partners > View grants**
  applies a partner filter. Both lists have bounded, 40-row pagination.
- User details show grant history (latest 100 events) including actor, reason,
  previous/new expiry. Partner creation is also in the normal audit log.

## Authorization and data

Only active superadmins with enabled and verified 2FA may mutate. Every mutation
requires a session-bound CSRF header, UUIDv4 idempotency key and reason. Admin role
and active status are rechecked under a row lock. Changes, dedicated Premium
events and the standard admin audit entry commit in one transaction; failure of
either audit write rolls back the grant. UI restrictions are not the authorization
boundary. Database audit tables are append-only through these endpoints, not
tamper-proof against a database administrator.

Hard account deletion cascades its live grants, without breaking the existing
account deletion flow. Audit snapshots remain under the admin audit retention
policy; they contain IDs/reasons, not a copied email or bank profile.

Admins can read lists/history. Support sees only the effective status on the
user detail screen, without grant reasons/history/CSRF. Ops and readonly roles
cannot use Premium endpoints. User detail now selects an explicit identity
allowlist; no bank/payment fields, password hashes, expense descriptions or push
token fragments are returned.

The mobile `me` payload carries account ID, plan, server check time and expiry,
not partner identities, grant reasons or audit records. The profile displays the
status and expiry; refresh requests the current profile. Display data is fresh
for at most five minutes (or until expiry), then becomes unknown. It is never
saved/restored from offline profile storage and is discarded on account changes.
With a missing migration/backend failure, status is unknown instead of inferred
Free. Current app functionality remains unrestricted.

## Release order

1. Confirm MySQL/InnoDB, `trip_` prefix, existing admin audit tables, and functioning
   superadmin 2FA. Inspect the migration runner's pending list first.
2. Apply `sql/migrations/2026-09-24-add-premium-grants.sql` using the established
   migration process. Do not baseline or blindly apply unrelated pending changes.
   No existing user/trip records are modified by this migration.
3. Deploy PHP and `admin2` files together. Test with a dedicated test account:
   grant, retry, extend, revoke, overlap, insufficient role, missing 2FA, expiry.
   Verify both audit records and concurrent edits on MySQL.
4. Ship the app build; refresh Profile after a grant. Keep RevenueCat flags off.

Rollback the UI/API code if needed; keep the ledger tables and audit history.
Do not drop grant data as a rollback. No VPS migration, production deployment or
TestFlight upload is performed by the local tests.

## Verification

- PHP unit suite includes real SQLite transactions/constraints, audit failure
  rollback, idempotency, role/2FA/CSRF, account isolation, expiry, filters and paging.
- SQLite strips `FOR UPDATE`; this does not prove MySQL locking/deadlock behavior.
  The local machine currently has no running MySQL/Docker server. MySQL staging
  validation remains a release prerequisite.
- Browser tests exercise forms/retries/lifecycle/filters on desktop and mobile
  with fixture APIs under CSP. These are not live VPS end-to-end tests.
- Flutter tests cover parsing, ownership, cache rejection, freshness and narrow
  profile layouts in English, Latvian and Spanish, both light and dark.
