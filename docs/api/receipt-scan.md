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
5. Same image (server SHA-256) scanned by this account in the last 7 days → that result,
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
    "merchant": "Rimi", "date": "2026-11-20", "currency": "EUR",
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
- An item's `total_cents` is after the discount printed for that line (for example "Atlaide"
  under it; fixed 2026-11-20), while `unit_price_cents` stays the printed price. Discount lines
  that belong to no item may appear as negative items; `discount_cents` holds discounts on the
  whole receipt, which the app spreads over the lines. Results read before this fix are not
  reused from the same-image cache.
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

"Fill from receipt" is a button in the "By item" split editor, in trip expenses and in Quick
split, shown only when the account's `features.receipt_ai` is true. The first use per account on
a device shows a notice that the photo goes to OpenAI; nothing is sent until the user agrees.
Without an uploaded receipt the button takes a photo first (the expense's receipt). The result
fills the item lines (no people assigned), the extra (tax + tip + service), currency, date and an
empty note. Equal and other splits have no AI button.

## Limits (test phase; server configuration, no app change)

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
