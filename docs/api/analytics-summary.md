# Analytics summary

Status: approved by the owner and deployed to the server on 2026-11-07. App builds made
before that date still use `list_expenses`. New builds have no fallback to the old way of
loading, so this action must stay in place.

The Analytics screen used to download every expense of every trip and add them up on the
phone. `analytics_summary` returns those numbers in one request. Filtering by currency, trip
and month stays on the phone, so changing a filter sends no request.

Nothing else changes. `list_expenses` stays as it is, and older apps keep using it. There is
no migration.

## Request

`GET api.php?action=analytics_summary`

Needs a signed-in user. It takes no parameters and no `X-Trip-Id`, because it covers every
trip the user is a member of, the same trips as `trips`: active, finished and archived.

Limited to 120 requests per user in 15 minutes. Past that it returns the usual 429. The
response is sent with `Cache-Control: private, no-store`.

## Response

```json
{
  "ok": true,
  "trips": [
    {
      "trip_id": 10,
      "currency_code": "EUR",
      "buckets": [
        {
          "date": "2026-03-02",
          "category": "food",
          "total_cents": 20000,
          "share_cents": 10000,
          "paid_cents": 20000,
          "expense_count": 1,
          "shared_expense_count": 1
        }
      ],
      "members": [
        { "id": 4, "nickname": "Anna", "paid_cents": 20000 }
      ],
      "largest_by_total": [
        { "id": 100, "category": "food", "note": "Dinner", "amount_cents": 20000 }
      ],
      "largest_by_share": [
        { "id": 100, "category": "food", "note": "Dinner", "amount_cents": 10000 }
      ]
    }
  ]
}
```

A trip without expenses is included with empty lists. All amounts are in the trip's currency.

- `buckets`: one row per date and category, ordered by date and then category. An empty
  category becomes `other`.
  - `total_cents`: the full amount of those expenses.
  - `share_cents`: the requesting user's part. It uses the same stored allocations as
    `list_expenses`, including the equal split fallback for rows without valid stored amounts.
  - `paid_cents`: the amount the requesting user paid.
  - `expense_count`: all expenses in the row.
  - `shared_expense_count`: those where the requesting user's part isn't zero.
- `members`: everyone who paid or took part in an expense, including guests, with what they
  paid. Ordered by `paid_cents` from highest, then by `id`.
- `largest_by_total`, `largest_by_share`: at most five expenses above zero for that trip,
  highest first, then newest. `amount_cents` is the full amount in the first list and the
  user's part in the second. The notes in these lists are the only expense notes in the response.

The response has no receipts, exchange rates, split details or other members' parts.

## Errors

| Case | Result |
|---|---|
| Not signed in | the usual 401 |
| Too many requests | the usual 429 |
| An expense above zero has no participants, or an amount is negative | 500, `code: analytics_incomplete` |

The last case fails the whole response, as the app's own check did before. Totals must not be
shown with a guessed share.

## App behaviour

The app still loads `trips` for names, dates and covers, then `analytics_summary`. A trip in
`trips` that is missing from the summary shows as having no expenses. A trip in the summary
that is missing from `trips` is ignored. If a trip's currency differs between the two, the load
fails and shows the usual error, because the two responses no longer describe the same trip.

The Analytics screen still needs a connection. On failure it keeps the last loaded report and
says so.

## Rollout

1. Deploy the server. Older apps aren't affected.
2. Release an app build that uses the new action.
