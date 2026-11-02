# Account deletion experience — 2 November 2026

The app removes the user-facing deactivation option and opens a dedicated account
deletion form from Profile. Historical deactivated accounts, administrative
suspension and legacy secured lifecycle handlers remain supported; these are not
exposed as new choices in the app.

## Request contract

Existing authenticated POST `request_account_deletion_link` retains its password,
session, verified-account, rate-limit and one-time-email-proof requirements.
Optional `reason_codes` is an array of unique strings from:
`not_using`, `another_way`, `too_complicated`, `technical_issue`, `privacy`, `other`.
No free text or recipient address is accepted. Omission/empty array means no
feedback. Unknown codes, duplicate codes and malformed types are ignored; feedback
never prevents requesting deletion. Limits allow at most these six reasons.

After a NEW proof is successfully emailed, selected codes increment anonymous
aggregate request-feedback counters. No user ID, email, proof, individual event
or time is stored in these counters. They measure feedback on deletion requests,
not completed deletions. Cooldown reuse, rejected authentication and failed email
send do not count feedback. Counter storage failure is non-fatal to deletion.

Apply `sql/migrations/2026-11-02-account-deletion-reasons.sql` to enable aggregate
feedback. A missing table leaves the existing email/delete flow operational.
Legacy clients do not need to send the optional field; updated clients can use
an older server (reasons are ignored there). No response shape changes.

The app first requests the email without a password. A local-password account's
existing `REAUTHENTICATION_REQUIRED` response reveals the current-password field;
its password is passed unchanged on retry. Social-only accounts can proceed with
their authenticated session plus email proof. Selecting a reason is optional.
The app stays signed in after requesting the link and shows the account email.
It never calls the actual delete endpoint and prevents duplicate in-flight sends.

## Admin reporting contract

`admin_panel_dashboard` adds `stats.account_deletion_feedback` behind the
existing private HTTPS host and authenticated dashboard-role boundary. It contains
`available` (boolean), `total_selections` (integer or null when unavailable), and
`reasons` (six allowlisted `{code, count}` rows, or an empty array if unavailable).
Missing counter storage or a read failure does not break the dashboard and is
shown as unavailable, never as zero. Available but empty storage returns six zeros.
The report covers all collected selections, without a date filter or user details.
Percentages use total selections, not users or confirmed deletions; a request can
select multiple reasons. The admin2 dashboard displays a donut and a text legend.
No changes to collection timing, retention, authentication or public routes.

Reporting validation: 10 PHP tests / 85 assertions for aggregation and admin host
boundaries; two browser tests at 1440px and 390px cover populated, empty and
unavailable data plus unsafe count rejection. Screenshot fixtures in
`output/design/account-deletion-admin/` use synthetic data, not live statistics.
Rollout also includes `admin2/app.js`, `admin2/app.css` and `admin2/index.html`.

## Confirmation details

Email leads to the existing non-mutating confirmation page. Opening a link or
email scanner preview does not delete anything. Explicit DELETE + confirmation
submits the existing POST `confirm_account_deletion`. Expiry, binding, replay,
transactional revocation and anonymisation remain as documented in
`account-lifecycle-link-security.md` and `session-revocation.md`.

Copy explains permanent access removal/profile anonymisation and retained shared
trip/expense accounting on the email/web confirmation step, rather than promising
every historical record vanishes. The app uses a short email-confirmation and
irreversibility notice, optional reasons and no repeated explanatory panels.
Checkboxes and close/email symbols use the existing cyan/pink Splyto palette.
No real user emails, deletions, production migrations or deployment are part of
local implementation/test validation.

## Local verification

- PHP lifecycle security and feedback tests: 80 tests, 805 assertions passed.
- Flutter deletion, credentials, profile and localization tests: 92 passed,
  including all 15 locales at 320px/200% text in light and dark themes.
- Whole-mobile Dart analysis: no errors; 21 pre-existing warnings/info remain.
- Changed PHP files pass syntax checks; `git diff --check` passes.
- Widget-rendered previews: `output/design/account-deletion/` (light/dark form
  and email-sent state). No real mailbox/device end-to-end test was performed.
- Reviewed 238 new translations; regenerated the localization catalogs and
  review tables. The confirmation email/web page retain existing English copy.
- Concise-copy follow-up: shortened four messages in all 15 locales; 50 relevant
  Flutter tests passed, with no new analysis issues. Previews were regenerated.

Rollout is pending: deploy the PHP changes and apply the optional counter
migration (adapt `trip_` for a non-default table prefix), then include the mobile
changes in the next build. No archive or production deployment was made here.
