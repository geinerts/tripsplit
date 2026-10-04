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
- Owner subsequently removed email changes. `request_email_change`, `confirm_email_change`
  and `cancel_email_change` return 410 without modifying users, sessions or pending requests.
  Both legacy web links are retired too; profile email is read-only. See
  `account-deactivation-security.md` for this follow-up and lifecycle confirmation.

## Mobile compatibility

The profile password screen asks for the current password and offers password recovery,
including for social users who do not know their generated placeholder password.
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
