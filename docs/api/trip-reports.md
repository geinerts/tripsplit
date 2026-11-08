# Trip reports, exports and the year summary

Status: approved by the owner on 2026-11-06. Needs the migration below before the
server is deployed, and the worker timer before any report is sent.

## Trip report email (free)

When `end_trip` succeeds, each current member gets one queued report. `end_trip`'s
request and response don't change. The worker `scripts/run_trip_report_delivery.php`
sends the queue, so finishing a trip never waits for a PDF or for email.

A member receives the email only if, when the worker runs:

- the account is active and its email is verified
- `email_trip_report_enabled` is on, which is the default
- the trip has at least one expense

Otherwise the row is marked `skipped` and nothing is sent. Each member gets one report
per trip. A failed send retries up to 5 times with growing delays, then is marked `failed`.
Rows are deleted after 30 days. PDFs are built when sending and never stored.

The attached PDF holds the trip's name, dates, destinations and totals, the recipient's
paid amount, share and balance, their settlements, spending by category and a member
table. It never holds bank details, payment links, email addresses, receipts or individual
expenses.

Trips closed from the admin panel send no report.

## Language

`POST set_account_locale` with `{"locale": "lv"}` returns `{ok: true, locale: "lv"}`. It
stores the app language in `trip_users.locale`. Unknown values become `en`, like the push
locale. The app sends it after sign-in and when the language changes. Reports use the
recipient's stored language. If none is stored they use the locale of the most recently
updated push token, then English.

## Notification preferences

`get_notification_preferences` and `update_notification_preferences` gain the flat boolean
`email_trip_report_enabled`. Older apps ignore it. Without the migration it reads as `true`
and changes are ignored.

## Premium

The two actions below are the features `trip_export` and `year_summary` in the server's
feature list. They check the requesting account, so the organizer's plan doesn't matter. The
detailed export is also allowed in a trip with [trip Premium](trip-premium.md).
When the account's `premium_access.features` entry is false, including for plan `unknown`,
they return:

```json
{"ok": false, "code": "premium_required", "error": "This feature requires Premium."}
```

with status 403. Premium never replaces the membership checks. The app shows these features
only when `features` allows them. With Premium for everyone switched on, every active
account is allowed. See [subscriptions](../architecture/subscriptions.md). There is no
purchase flow.

## Detailed export (Premium)

`GET trip_export?format=pdf|csv` with the usual `X-Trip-Id` header. Any current member can
export a trip of any status. Limited to 20 requests per 15 minutes per account. Responses
are `Cache-Control: private, no-store`. The optional `locale` parameter takes a language
code and defaults to the stored language.

```json
{"ok": true, "filename": "splyto-rome-2026.pdf", "mime_type": "application/pdf",
 "content_base64": "..."}
```

Other `format` values return 400 `Unsupported export format.`

The PDF has the report above plus every expense and every confirmed payment. Each expense
has its date, description, category, payer, original amount, exchange rate, trip-currency
amount and each person's share.

The CSV is UTF-8 with a byte order mark and uses `;` as the separator, which opens in
columns in Excel under European regional settings. There is one row per expense and one
share column per person. Decimals use `.` and follow the currency's display decimals.
Text cells starting with `=`, `+`, `-`, `@`, tab or carriage return get a leading `'`, so a
spreadsheet can't run them as formulas.

## Year summary (Premium)

`GET travel_year_summary?year=2026` returns the requesting account's year:

```json
{"ok": true, "summary": {
  "year": 2026,
  "available_years": [2026, 2025],
  "trip_count": 4,
  "days_away": 23,
  "expense_count": 120,
  "countries": [{"code": "IT", "name": "Italy"}],
  "cities": ["Rome"],
  "currency_code": "EUR",
  "total_share": 1234.56,
  "conversion_complete": true,
  "biggest_trip": {"name": "Rome", "share": 800.0},
  "top_category": {"key": "food", "share": 300.0},
  "top_companion": {"nickname": "Anna", "trip_count": 3}
}}
```

- `year` defaults to the current UTC year. A value outside 2000 to the current year returns
  400 `Invalid year.`
- A trip counts when it is finished and its start date, or its finish date when it has no
  start date, falls in the year.
- `days_away` merges overlapping trips. A trip without dates uses the range of its expense
  dates.
- Countries and cities combine trip destinations with the account's own travel map visits
  in that year.
- Amounts are the account's own share, in its preferred currency, converted at the rate on
  the trip's finish date. If a rate can't be fetched, that trip is left out of the amounts and
  `conversion_complete` is `false`. Null fields mean there's nothing to show.
- Rates are kept in `trip_fx_rate_cache`, since past rates don't change.

The summary is calculated on request and not stored. Limited to 30 requests per 15
minutes per account.

## Migration and deployment

Run `sql/migrations/2026-11-06-add-trip-reports.sql` before the server is updated. It adds
`trip_report_deliveries`, `trip_fx_rate_cache`, `trip_users.locale` and
`trip_user_notification_preferences.email_trip_report_enabled`. The code tolerates the
migration being absent: no report is queued and the rest of `end_trip` works.

Install `ops/systemd/splyto-trip-report-delivery.{service,timer}` on the server. The server
needs the PHP extensions `dom`, `mbstring` and `gd`. dompdf is committed under
`api/lib/dompdf/`, so `git pull` still deploys everything.

## For the new privacy policy

- A new email purpose: the trip report, on by default, with a switch under Notifications.
- The PDF holds co-travellers' nicknames and amounts, and Resend processes it as an
  attachment.
- A sent email stays in the recipient's mailbox after a trip or account is deleted.
- `trip_report_deliveries` keeps trip id, account id and status for 30 days, with no PDF.
- The year summary combines an account's trips, places, spending and travel companions. It
  is calculated on request and not stored.

## Known limits

The PDF font, DejaVu Sans, covers all 15 app languages. Emoji and scripts such as Chinese in
names or notes don't render in the PDF. The CSV keeps them.
