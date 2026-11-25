# Receipt scan (AI receipt reading)

Approved by the owner on 2026-11-20. Reads an uploaded receipt photo with AI and returns its
items so the app can fill "By item". Nothing is saved as an expense; the user checks and saves.
Gated by the feature flag `receipt_ai` (`docs/api/feature-flags.md`). Plan and rationale:
`docs/mobile/quick-split-ai-plan.md` (sections 6 and 12).

Provider: OpenAI Responses API, model `gpt-5.4-mini-2026-03-17` (configurable, see below).
Only the receipt image is sent: no names, emails, trip or account data. Requests use
`store: false`.

## `scan_receipt` (POST, signed in)

Request:

```json
{ "receipt_path": "<path from upload_receipt>", "request_id": "<8–64 chars [A-Za-z0-9_-]>" }
```

Optional `rescan: true` explicitly requests a new AI reading after clearing the item
list (approved 2026-11-22). It bypasses only the same-image result cache; ownership,
feature access, rate limits, concurrency, account quotas and global budget reservations
still apply. Omitted/false retains normal cache reuse; other types return 400.
Each intentional rescan uses a new `request_id`. Retrying an existing ID remains
idempotent even when `rescan` is true, so network retries never start another AI call.

The receipt must have been uploaded by the caller (same ownership rule as `add_expense`).
`request_id` makes the call idempotent: repeating it returns the stored result (or
`scan_in_progress`) and never calls the AI again. A repeated `request_id` is answered before
the per-minute limits, so the app may ask again (every few seconds) while a slow scan runs or
after its own request timed out. The same `request_id` with another `receipt_path` answers 409.

Checks run in this order, cheapest first; none of the later steps runs if one fails:

1. Signed in, active, not a trip guest, email verified.
2. `receipt_ai` enabled for the account (uncached).
3. Rate: 2 per minute per account, 10 per minute per IP; 1 scan at a time per account.
4. Receipt owned by the caller, file present, at most 5 MB and 40 megapixels.
5. Unless `rescan: true`, same image (server SHA-256) scanned by this account in the last 7 days → that result,
   no AI call, no quota used.
6. Account quota and global budget reserved together in one MySQL transaction.
7. Image scaled to at most 1568 px on the long side, sent once (timeout 30 s, at most 2000
   output tokens, no automatic retries).
8. Result validated by the server (schema, lengths, currency, date, money in cents).

Success (`200`):

```json
{
  "ok": true,
  "scan": {
    "id": 123, "request_id": "…", "cached": false,
    "is_receipt": true,
    "merchant": "Rimi", "date": "2026-11-20", "currency": "EUR", "category": "groceries", "subcategory": null,
    "items": [ { "name": "Milk", "quantity": 1, "unit_price_cents": 129, "total_cents": 129, "uncertain": false } ],
    "discount_cents": 0, "tax_cents": 0, "tip_cents": 0, "service_cents": 0,
    "total_cents": 129,
    "sum_matches": true, "difference_cents": 0,
    "notes": null
  },
  "quota": { "day_remaining": 19, "month_remaining": 199 }
}
```

- Amounts are integer cents in `currency`. `tax_cents` is only tax added on top of the item
  prices; VAT already included in prices is not repeated.
  The validator removes a duplicate tax only when the sum with tax fails the printed-total
  check and items after discounts plus tip/service without tax match that total (±1 cent).
  Genuine additional tax and ambiguous or missing totals are left for review. This check
  also applies when returning old cached scans and request-ID retries, without a new AI call.
  The provider is instructed to read the printed payable total independently of its item arithmetic.
- Optional AI category selection requested on 2026-11-22 adds nullable `category` to
  the scan response. Allowed suggestions: `food`, `groceries`, `fuel`, `transport`,
  `accommodation`, `activities`, `tickets`, `shopping`, `party`, `parking`.
  Use `null` for unclear/mixed evidence, unknown categories or a non-receipt; do not
  substitute `other`. This is one suggestion for the whole expense, inferred in the
  existing receipt request with no additional user/account data or extra AI call.
  Old cached results may omit the field; clients treat missing as no suggestion.
  The app fills only an unselected category, preserves manual/custom selections and
  lets the user change the suggestion. With no suggestion, an empty field stays Choose.
  Existing app versions ignore the additional response field.
- Optional AI type selection requested on 2026-11-22 adds nullable `subcategory`.
  Only built-in types from `docs/api/expense-subcategories.md` are suggested:
  Food: `restaurant`, `cafe`, `bar`, `fast_food`, `snacks`;
  Transport: `taxi`, `flight`, `train`, `bus`, `car_rental`, `ferry`, `public_transport`;
  Accommodation: `hotel`, `hostel`, `apartment`, `camping`.
  The server rejects a type that does not belong to the suggested category by returning
  `null`. Unknown category/type or any category without built-in types returns no type;
  AI does not invent custom types. The app applies a suggested type only if its selected
  category matches the AI category and no type has already been selected. Users may
  change or clear either field; a manually cleared type is not filled again by a rescan.
  Missing fields in older cached results mean no suggestion. No extra AI call is made.
- An item's `total_cents` is after the discount printed for that line (for example "Atlaide"
  under it; fixed 2026-11-20), while `unit_price_cents` stays the printed price. Discount lines
  that belong to no item may appear as negative items; `discount_cents` holds discounts on the
  whole receipt, which the app spreads over the lines. Results read before this fix are not
  reused from the same-image cache.
- Purchased items should retain their original printed order. The provider instructions
  explicitly keep container deposits as separate lines where printed (including quantity
  and unit price), without grouping repeated deposits or moving them to the end or extras.
  Server validation and mobile draft conversion preserve the provider's item order;
  they cannot reconstruct a printed order the model failed to return. Line discounts
  continue to be applied to their item rather than displayed as separate discount rows.
  Same-image results created before the latest prompt cutoff (2026-11-22
  15:27:00 UTC, category/type rollout) are not reused for new requests; retries with
  an existing request ID remain idempotent.
- `sum_matches` is computed by the server: items − discount + tax + tip + service = total
  (±1 cent). When false, the app shows "Totals don't match, check the items".
- `currency` is `null` when unknown or unsupported; `date` is `null` when unreadable or
  implausible. Item names are trimmed to 80 characters; at most 100 items.
- When the photo is not a receipt: `is_receipt: false`, empty items, all amounts 0.

Errors (`ok: false`, `code`):

| HTTP | `code` | Meaning |
| --- | --- | --- |
| 403 | `feature_disabled` | Flag off for this account. |
| 403 | `email_not_verified` | Verify the email first. |
| 403 | — | Receipt not uploaded by the caller. |
| 404 | `receipt_not_found` | File no longer exists. |
| 409 | `scan_in_progress` | This account already has a scan running (or this `request_id` is running). |
| 409 | `request_id_reused` | Same `request_id` with a different receipt. |
| 413 | `image_too_large` | Over 5 MB or 40 megapixels. |
| 429 | `quota_exceeded` | Daily or monthly account quota used; `resets_at` (UTC) included. |
| 429 | — | Too many requests (per-minute limits). |
| 503 | `ai_unavailable` | Budget reached, provider failed or timed out, or AI not configured. Manual entry still works. |

A provider failure after the request was sent still counts against the quota and budget,
because the provider may already have charged for it.

## App

The item editor offers **Clear all items** above the list. It clears local rows,
assignments, tax/tip, the scanned total and scan warnings, retaining the receipt photo.
Receipt reading is disabled while the list contains any entered item or tax/tip.
After clearing, reading is enabled again and requests an explicit rescan in the same
editor. Clearing does not save or delete a stored expense.

The optional rescan handler was deployed to the VPS on 2026-11-22 with a private
backup, matching file hashes and PHP syntax checks. No migration or quota/configuration
change was required. The clear-list button and client rescan flag require the next
mobile build; no mobile release was published by this change. Validation: 236 Flutter
tests and 12 PHP receipt-scan tests (130 assertions) passed using fake AI responses,
including cache bypass, idempotent retries, quota enforcement, manual-input protection
and clearing/rescanning without leaving the editor. Flutter analysis retained the same
17 pre-existing diagnostics. No paid provider request was used for verification.

"Fill from receipt" is a button in the "By item" split editor, in trip expenses and in Quick
split, shown only when the account's `features.receipt_ai` is true. Tapping the button starts
the receipt flow directly, including first use; there is no additional AI notice dialog.
Receipt-processing information is covered by the Privacy Policy; website and Quick Start
notices are separate from this action.
Without an uploaded receipt the button takes a photo first (the expense's receipt). The result
fills the item lines (no people assigned), the extra (tax + tip + service), currency, date and an
empty note. Equal and other splits have no AI button.
The item editor compares its editable sum against the scan's printed `total_cents`, not
against the sum of the imported draft. An unreadable total does not receive a match checkmark.

### Included VAT fix — deployed 2026-11-22

Deployed only `api/lib/helpers/helper_receipt_ai.php` and
`api/lib/actions/receipt_scan_actions.php` to the production VPS, after comparing the
live files and confirming that only the VAT prompt/reconciliation changes were pending.
A private backup was retained; deployed hashes match local files. PHP 8.3 syntax checks,
synthetic included-tax / added-tax / cached-result checks, and anonymous API smoke checks
(unknown action: 404; me: 401) passed. No database migration, provider call or expense
mutation was performed. Local verification: 13 PHP tests (174 assertions), 384 Flutter
workspace/Quick Split tests, and the unchanged 17 existing analyzer diagnostics.

The server fix applies to the existing mobile build. The independent-total display check
is local mobile code and still requires a new build; existing saved expenses are not modified.

The printed-order/deposit instructions and old same-image cache cutoff were also deployed
on 2026-11-22, in `helper_receipt_ai.php` only. A private backup, matching SHA-256,
server PHP syntax check, active PHP-FPM after reload and API 404 JSON smoke check were
verified. Local checks passed: 14 PHP tests (197 assertions), 8 receipt draft tests,
and the same 17 pre-existing Flutter analyzer diagnostics. Tests use synthetic receipts;
no paid provider request was made. Existing mobile builds preserve returned item order,
so this prompt update requires no mobile release. Already saved expenses are unchanged.

## Limits (test phase; server configuration, no app change)

Production override updated on 2026-11-22 at the owner's request for receipt testing:
`TRIP_RECEIPT_AI_USER_DAY_MAX=100` (previously the default 20). Applies per account
with AI access. Monthly limit remains 200; global budgets, access flags and rate limits
are unchanged. Runtime configuration was verified after the change; a private server
configuration backup was retained. The defaults below remain unchanged in code.

Later on 2026-11-22, recent failed scans showed `provider_incomplete` with exactly
2000 output tokens after 7–10 seconds. At the owner's request, production
`TRIP_RECEIPT_AI_MAX_OUTPUT_TOKENS` was raised to 4000. The per-scan budget
reservation (`TRIP_RECEIPT_AI_RESERVE_MICROUSD`) was increased from 15000 to 30000
to cover longer output; settlement still uses actual reported token usage.
Global budget ceilings, the 30-second timeout and account quotas were left unchanged.
Runtime configuration was verified and a private configuration backup retained.
No paid AI call was made for verification; the owner will retry the long receipt.

| Setting | Env | Default |
| --- | --- | --- |
| Scans per account per UTC day / month | `TRIP_RECEIPT_AI_USER_DAY_MAX` / `_USER_MONTH_MAX` | 20 / 200 |
| Global budget per hour / UTC day / month (USD) | `TRIP_RECEIPT_AI_BUDGET_HOUR_MICROUSD` / `_DAY_` / `_MONTH_` | 0.50 / 2.00 / 15.00 |
| Reservation per scan (USD) | `TRIP_RECEIPT_AI_RESERVE_MICROUSD` | 0.015 |
| Model | `TRIP_RECEIPT_AI_MODEL` | `gpt-5.4-mini-2026-03-17` |
| Price per 1M input / output tokens (USD) | `TRIP_RECEIPT_AI_PRICE_INPUT_MICROUSD` / `_OUTPUT_` | 0.75 / 4.50 |
| API key | `TRIP_OPENAI_API_KEY` | none → `ai_unavailable` |

Budget amounts are stored in micro-USD (integers). A reservation is replaced by the real cost
from the provider's `usage` when the answer arrives. If the call was sent but no usable answer
came back, the reservation stays as spent. `spent + reserved + new reservation` may never exceed
any limit. If the budget tables cannot be read, no call is made.

## Storage

Migration `sql/migrations/2026-11-20-receipt-scans.sql`:

- `trip_ai_scans`: one row per scan: user, `request_id`, image SHA-256, status
  (`reserved`, `sent`, `done`, `failed`), model, tokens, cost, duration, error code, and the
  validated result JSON (kept 7 days for the same-image cache, then cleared). No image and no
  raw provider text are stored; logs never contain receipt content, keys or tokens.
- `trip_ai_budget`: spent and reserved micro-USD per period (`h:YYYY-MM-DDTHH`, `d:YYYY-MM-DD`,
  `m:YYYY-MM`, UTC).

Rows are removed with the user (cascade) and on account deletion.

## Admin

`admin_panel_features` gains `receipt_ai_usage`: spent/reserved/limit for the current hour, day
and month, scans and failures today, and the last 20 scans (time, account id, status, cost,
duration, error code; no receipt content).

### Category/type suggestions — deployed 2026-11-22

Deployed only `api/lib/helpers/helper_receipt_ai.php` to the existing Splyto VPS.
The same-image cache cutoff is now `2026-11-22 15:27:00` UTC so new scans do not
reuse pre-category results; existing request IDs remain idempotent. No configuration
or database changes. Previous code: `/var/backups/splyto/receipt-category-20261122-1527/`.

Local receipt tests passed (16 tests, 222 assertions). Production PHP 8.3 lint,
synthetic category/type validation, FPM reload/active status, SHA-256 match and API
unknown-action smoke (404 JSON) passed. Deployed SHA-256:
`a134584429b229a3e9c29a87f1bd9b503e9229fcdc29d9c25acdaff7433449ef`.
No paid provider call was made during deployment. Mobile category/type selection
requires the new app build; older versions ignore these optional response fields.
