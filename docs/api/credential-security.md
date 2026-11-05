# Credential enrollment and changes

Local implementation/verification: 2026-10-04 (SEC-01 / audit F01).
Not deployed. No schema migration added. Existing user unique-email constraint,
verification-token storage and refresh-token storage are required.

## Endpoint contracts

- `set_credentials`: authenticated initial enrollment only. Under a user-row lock,
  require `credentials_required = 1`, empty email/password hash and no previous email
  verification. Established, social and partially initialized identities are rejected.
  Store the email as unverified, revoke all guest refresh tokens in the same transaction.
  Verification must be enabled and its storage available; otherwise fail closed.
- Enrollment returns `ok: true`, `email_verification_required: true` and
  `verification_email_sent`, without a `me` or `auth` payload. Do not treat it as login.
  Delivery happens after commit. Failure leaves the credentials saved but unverified;
  the public verification-resend/login flow is the recovery path. Delivery is not atomic
  with the database and this batch does not introduce an email outbox.
- `update_profile` ordinary name/payment/currency changes retain the existing behavior.
  Any `email`, `password` or `current_password` field enters a separate credential policy.
  A password-only submission must contain the existing verified email, new password and
  exact current password. It cannot also change profile fields or email. Mixed/partial
  submissions are rejected without changing either profile or credentials.
- Password reauthentication is checked against the freshly locked row, not the limited
  `get_me()` payload. Missing/incorrect current password returns HTTP 403 with
  `REAUTHENTICATION_REQUIRED`, avoiding an unrelated HTTP 401 session-refresh retry.
  The update, revocation of existing refresh tokens and replacement session issuance
  commit together; write failures roll all of these back.
- Enrollment and password-change attempts use existing IP/account rate-limit infrastructure
  under separate `credential_change_ip` / `credential_change_user` scopes, with login limits.
- Owner subsequently removed email changes entirely (2026-11-05: routes, web pages, email
  templates and handlers deleted; unknown actions are now rejected by the router). Profile
  email is read-only. See `account-lifecycle-link-security.md` for lifecycle confirmation.

## Mobile compatibility

The profile password screen asks for the current password only when `has_password`
is true. False/unknown states use verified email setup/recovery (see capability below).
Current password is passed unchanged through controller/use case/repository/data source.
It is not saved to preferences, logs or offline queues by this flow.

After enrollment the controller clears local authentication/profile data, and the screen
returns to login with verification guidance. An account-generation guard prevents a late
enrollment response from logging out a different account. Mail delivery failure gives
resend guidance instead of claiming that the account is ready to use.

Older mobile builds without the current-password field cannot use password change after
backend rollout; they must update or use the recovery flow. Older enrollment UI does not
understand the verification-required response. Coordinate a new mobile build and backend
rollout; never reopen session-only credential replacement for compatibility.

## Evidence

- `CredentialsSecurityTest`: 23 tests / 300 assertions on host PHP 8.5.4/SQLite and
  isolated PHP 8.3.35/MySQL 8.4.11. Real handlers, access-token checks, password hashing,
  verification token creation/confirmation and refresh-session writes; synthetic users.
- Established/social/partial/inactive/unverified accounts, stolen-session-only writes,
  wrong/missing current password, email substitution, mixed profile writes, replay,
  duplicate email, failed mail, missing refresh storage and transaction failure injection.
- MySQL: five rounds each of enrollment/password-change races, four workers per race
  (10 races / 40 requests). One mutation wins; rejected requests issue no mail/session.
- Prior registration suite still passes: 19 tests / 231 assertions and 20 races / 120 requests.
- Latest full host PHP suite: 276 tests / 2203 assertions. Full Flutter suite: 88 tests.
- Flutter auth analysis reports four pre-existing `use_build_context_synchronously`
  informational lints in unchanged `login_page_actions.dart` / `profile_page_actions.dart`.
  No new analyzer errors/warnings. `git diff --check` passes.
- HTTP transport, mail delivery/templates, full profile payload building, real rate-limit
  enforcement and device/production behavior are not established by these handler tests.

## Deliberately unresolved

- Signed access tokens are not immediately revoked. The audited/default access lifetime
  is 900 seconds, configurable by the server. This is a residual data-access window, not
  a guarantee that all sessions end instantly. SEC-05 must implement/test the intended
  access-token invalidation policy and login/refresh/security-event race ordering.
- Subsequent local batches hardened password reset and social identity matching; see
  `password-recovery-security.md` and `social-auth-security.md`. Email changes are removed.
  Remaining lifecycle/session races, fixture-email shortcut removal (F11) and real social
  recovery E2E are separate gates; do not claim the entire account lifecycle is secure.
- No deployment, migration, commit, push, TestFlight upload or production mail was performed.

## Password capability (approved 2026-11-02)

The private `me` payload adds `has_password`: `true`, `false`, or `null`.
This is presentation metadata, never authorization to replace credentials.
`true` means an explicitly chosen password was saved or successfully verified;
`false` means a new social account has only a random placeholder (or a new guest
has no password); `null` means unknown, including legacy accounts and servers
without the optional column. Do not infer capability from a hash or provider link.

Migration `2026-11-02-add-password-capability.sql` adds nullable `users.has_password`.
Existing rows remain NULL; no credential hashes or provider identities are changed.
New password registration/enrollment, successful password login/change, and
email-confirmed reset record true. New social accounts record false. Returning
social login preserves the recorded state unless an empty hash is replaced with
an inaccessible placeholder. Credential mutation and capability writes share the
existing transaction; registration includes the field in its INSERT.

Mobile shows Change password for true, Set password for false, and Set or change
password for unknown. False/unknown use the existing verified email reset flow,
without a current-password field. Email proof expiry, rate limits, state binding,
one-time use and session revocation are unchanged. Google/Apple links remain intact.
A missing column degrades to unknown and the existing reset flow; it does not
bypass reauthentication. Deployment/migration are separate from local implementation.
