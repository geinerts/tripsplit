# Dedicated admin API boundary

Implemented 2026-10-25. This is a bounded hardening change, not a complete security
assessment or an MFA implementation.

## Policy

Every routed `admin_panel_*` action, including login, session checks and premium
operations, requires the dedicated HTTPS virtual host. The application expects
`TRIP_ADMIN_PANEL_HOST=ops.splyto.eu` unless explicitly configured otherwise.

`SERVER_NAME` must be supplied by Nginx as `$server_name`, never `$host`, an
unvalidated forwarded header or other client input. `HTTP_HOST` must also match
that name, optionally with `:443`; HTTPS must be enabled by the origin server.
Missing/malformed configuration, alternate vhosts, cleartext and mismatched Host
headers fail closed with the normal unknown-action response (404).

Admin POST requests require an exact HTTPS `Origin` for that same host, optionally
with port 443. Missing/null/foreign origins and cross-site/same-site fetch metadata
are rejected with 403 before a handler runs. This includes login to prevent
login-CSRF. Browser requests from the existing same-origin admin frontend already
send Origin. Scripts that use cookie-based admin POSTs must send the correct
Origin too; it is a CSRF boundary, not a replacement for session authentication.

Public mobile endpoints retain their existing authentication and routing. The
new restriction does not depend on a user-supplied forwarded-host/protocol header,
does not accept a Cloudflare header as proof of Access authentication, and does
not create a development bypass. Local admin testing needs an explicitly named
HTTPS reverse-proxy vhost with the same trusted server variables.

## Verification and rollout

- Six PHPUnit cases cover the valid host/origin, invalid/foreign hosts and ports,
  cleartext/proxy spoofing, cross-origin writes and every registered admin route
  being hidden on the public vhost.
- Full local PHP suite: 439 tests / 3,826 assertions. Two OpenSSL test-environment
  random-state warnings disappeared when the five affected APNs tests were rerun
  with a writable test-only RANDFILE (215 assertions).
- Composer locked audit: no reported advisories or abandoned packages at check time.
- Gitleaks: no findings in 164 scanned commits. This is not proof against earlier
  exposure elsewhere or a scan of ignored private files.

Before rollout verify the production Nginx FastCGI configuration uses
`SERVER_NAME $server_name` and supplies HTTPS from the origin connection. Preserve
the previous router/config files in an operator-only directory, lint the new
files, and verify the exact source hashes. After rollout check public admin
actions return 404, regular `me` returns 401 anonymously, unknown actions return
404, and the dedicated admin login route still reaches its GET method guard (405).
Test a foreign-Origin admin POST returns 403 without attempting a login. No user
credentials or customer mutations are needed for these checks.

## Open work

The owner explicitly deferred MFA enrollment and factor-lifecycle changes until
release. These remain open; the boundary does not make password-only admin access
equivalent to MFA. Recovery procedures and safe factor replacement are required.

Cloudflare Access policies were not inspected in its dashboard. A VPS-originated
request to the ops site returned HTTP 200, so enforcement for all clients is not
established. Origin IP allowlisting still trusts Cloudflare generally, not a
cryptographically authenticated request from this specific zone. AOP/Tunnel is a
separate step.

Backup encryption/offsite transfer, external config/key recovery and real-device
multi-account checks also remain separate. The 14-day local backup retention and
today's backup manifest do not establish offsite disaster recovery.
