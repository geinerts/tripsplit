# Splyto security baseline

Last targeted review: 2026-09-23. See `audit-2026-09-18.md` for the wider review and `offline-account-isolation.md` for the subsequent mobile isolation work.

## Trust boundaries

- Mobile clients are untrusted. Every read and mutation must be authorized by the API.
- `splyto.eu` and `ops.splyto.eu` accept web traffic only through Cloudflare.
- Production secrets live in `/etc/splyto/splyto.env` and `/etc/splyto/keys`, outside the web root.
- MySQL listens on localhost only. SSH accepts keys for `splytoadmin` only.

## Enforced controls

- Cloudflare IP allowlist blocks direct origin access with HTTP 403.
- Cloudflare Access protects `ops.splyto.eu` before the admin login page.
- Legacy `X-Admin-Key` API actions are not routable.
- Admin session cookies are Secure, HttpOnly and SameSite=Strict.
- Only SHA-256 hashes of admin session tokens are stored in MySQL.
- Admin TOTP secrets are encrypted with AES-256-GCM and a key outside the database.
- Access tokens expire quickly; refresh tokens are random, hash-stored and rotated.
- Android backups and cleartext HTTP are disabled.
- App caches are cleared on logout and exclude payment profile details.
- Offline caches and queues are account/API-host scoped and protected against stale login generations. Legacy unowned queues are quarantined for recovery, never automatically replayed; see the migration notes for their retention exception.
- Feedback screenshots are not publicly served.
- Receipt storage is not publicly served. Authorized API responses issue short-lived signed image URLs; new attachments are bound to the uploader.
- Receipt delivery has both positive (valid image) and negative (unsigned/direct storage) checks. An unsigned 404 alone does not demonstrate working receipt delivery.
- Admin action arguments are encoded as data, not executable inline handlers.
- Upload, log and backup filesystem permissions use least-readable modes.
- HSTS, nosniff, frame, referrer and permissions headers are set by Nginx.
- UFW, Fail2ban and unattended security updates are enabled.

## Required operations

1. Keep Cloudflare proxy enabled for both public hostnames.
2. Update `ops/nginx/cloudflare-origin-only.conf` if Cloudflare changes its published ranges.
3. Run `nginx -t` before every Nginx reload.
4. Keep every active admin account protected by TOTP.
5. Rotate a secret immediately after suspected exposure; never paste secret values into tickets or chat.
6. Run PHPUnit, Flutter tests, Flutter analyze, Gitleaks and Composer audit before a release.

## Remaining priority work

1. Complete live multi-device session-revocation concurrency checks. Account-scoped offline storage now has focused regression coverage. Signed receipt URLs remain bearer capabilities until expiry, not per-request membership checks.
2. Encrypt backups and send them to an isolated offsite account with tested restore procedures.
3. Split the MySQL runtime, migration and backup users; remove `ALL PRIVILEGES` from runtime.
4. Replace local SharedPreferences snapshots with an encrypted database if long-term offline storage is required.
5. Add Cloudflare Authenticated Origin Pulls or migrate the origin to Cloudflare Tunnel.
6. Add admin recovery codes and enforce TOTP enrollment for every privileged role.
