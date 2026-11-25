# Personal expenses in group trips

Status: approved by the owner on 2026-11-25 (plan: `docs/mobile/personal-expenses-plan.md`).
The migration below must run before the server update. Nothing is deployed yet.

A personal expense is one person's own spending in a group trip. It is not part of the trip
total, the balances or the settlements. Other members see only that it exists, its amount and
who paid; everything else is hidden from them by the server.

A "treat" (someone pays and is the only participant, method `equal`, `is_personal` false) is
not personal: it counts in the trip total as before.

## Migration

`sql/migrations/2026-11-25-add-expense-is-personal.sql` adds
`trip_expenses.is_personal TINYINT(1) NOT NULL DEFAULT 0`. Existing expenses become `0`.

Until it runs, the server works as before: every expense reads as `is_personal: false`, and a
request with `is_personal: true` returns 409 `Personal expenses are not available yet.`

## `add_expense` and `update_expense`

New optional field `is_personal` (boolean).

- `true`: `participants` must be empty or exactly `[paid_by]`, and `split_mode` must be
  `equal` (or omitted). The server stores the payer as the only participant. `splits` and
  `items` are ignored. Otherwise 400 `Personal expenses cannot be shared.`
- Solo trips: `true` returns 400 `Solo trips have no personal expenses.`
- `add_expense` without the field: `false`.
- `update_expense` without the field (older apps): the stored value is kept while the expense
  still has only the payer as participant with `equal`; any other split clears it.
- Who may edit or delete does not change: the payer (or the trip owner for a guest payer).

`expense_added` notifications go to participants other than the payer, so a personal expense
notifies no one. Nothing changes there.

## Expense rows

`list_expenses` and `workspace_snapshot` add to each expense:

- `is_personal` (boolean)
- `locked` (boolean): true when the expense is personal and the requester is not its payer
  (and does not act for the payer as a trip guest's owner).

A locked row keeps `id`, `amount`, `trip_currency_code`, `expense_date`, `created_at`,
`paid_by_id` and `paid_by_nickname`. The date stays so lists keep their order and pagination.
Everything else is replaced by neutral values, so older apps that don't know `locked` still
read a valid expense:

| Field | Locked value |
| --- | --- |
| `category` | `other` |
| `subcategory` | `null` |
| `note` | `""` |
| `split_mode` | `equal` |
| `expense_currency_code` | trip currency |
| `original_amount` | same as `amount` |
| `fx_rate_to_trip` | `1` |
| `receipt_path`, `receipt_url`, `receipt_thumb_url` | `null` |
| `participants` | only the payer, owing the full amount |
| `items`, `extra_amount` | absent |
| `from_quick_split` | `false` |

## Workspace snapshot and `balances`

- `balances` (and so the suggested settlements, `paid`, `owed` and `net`) leave personal
  expenses out. For a personal expense the payer paid and owes the same amount, so `net` and
  settlements are unchanged; only `paid` and `owed` get smaller.
- New `personal_total_cents` (integer, trip currency) in both responses: the requester's own
  personal expenses.

## Other actions

| Action | Change |
| --- | --- |
| `trips` | `total_amount_cents`, `my_paid_cents`, `my_owed_cents` leave personal expenses out. |
| `analytics_summary` | Personal expenses are left out of `buckets`, `members` and the largest lists. Each trip gets `personal_cents`: the requester's own personal expenses. |
| `list_trip_activity` | `expense.*` events of a personal expense carry `is_personal: true`. For anyone but the payer the payload keeps only `amount_cents`, `trip_currency_code` and `is_personal`. |
| Comments and reactions (`list_expense_comments`, `add_expense_comment`, `update_expense_comment`, `list_expense_reactions`, `toggle_expense_reaction`, `list_expense_comment_reactions`, `toggle_expense_comment_reaction`) | 403 `Personal expense is locked.` for anyone but the payer. |
| Trip report (PDF/e-mail) | Group totals, categories, expense rows and balances leave personal expenses out. The reader's own personal total is shown on its own line. Other members' personal expenses are not in the report. |
| Year summary | Unchanged: it counts the requester's own parts, which include their personal expenses. |

## Older app versions

They read a personal expense as an `equal` expense with only the payer, and a locked one as an
empty expense of category `other`. Opening its comments returns 403. Balances and totals come
from the server, so they match newer apps.
