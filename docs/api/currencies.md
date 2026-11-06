# Supported currencies and amounts

Status: approved by the owner on 2026-11-06. Needs the migration below before the
server is deployed.

## Currencies

Trips and expenses can use 120 currencies, listed in
`api/lib/helpers/helper_currency_catalog.php`. The profile's preferred currency can
use the same list, since each one has exchange rates. Requests with any other code
still return 400 `Unsupported currency code.`

`mobile/tool/generate_currencies.py` generates the app's and the server's lists from
one source. Currency names come from Unicode CLDR.

## Exchange rates

Rates come from Frankfurter v2, `GET /v2/rate/{from}/{to}?date=YYYY-MM-DD`. A date
ahead of the server's clock uses today's rate. If no rate can be fetched, the expense
request still returns 502 with the existing error.

The Bulgarian lev has no rates from 2026-01-01, when Bulgaria adopted the euro. From
that date it converts through its fixed rate of 1.95583 per euro.

## Amounts

API fields and their formats don't change. Amounts stay decimal numbers with two
places, and stored cents stay hundredths of a unit for every currency.

| Limit | Before | Now |
| --- | --- | --- |
| Expense amount in the request | 99,999,999 | 9,999,999,999 |
| Conversion result stored on the expense | Database error above about 10 billion | 400 `Converted amount is out of range.` |

The higher limit is what makes currencies like the Vietnamese dong usable: the old one
was only about €3,300. It needs these columns to be `BIGINT UNSIGNED`, so the migration
`sql/migrations/2026-11-06-widen-money-columns.sql` runs before the server is updated:

- `trip_expense_participants.owed_cents` and `split_value`
- `trip_settlements.amount_cents`
- `trip_payments.amount_cents`

## Decimals

Display only. Currencies like JPY, KRW and VND show no decimals, and the app's expense
amount field has no decimal key for them. Currencies with three decimals, like KWD and OMR, show
two, because amounts are stored in hundredths. A share that isn't a whole number stays
exact in storage, so totals still add up, and shows rounded.

Older app versions keep working, but they don't list the new currencies. A trip in one
of them shows its code rather than its name on those versions.
