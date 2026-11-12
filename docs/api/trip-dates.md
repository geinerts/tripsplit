# Trip dates

Contract change approved by the owner on 2026-11-11: a trip can be created with
only a start date, because the return date is not always known.

## API

`create_trip` and `create_solo_trip` accept optional `date_from` and `date_to`
(`YYYY-MM-DD` strings):

- Both omitted or empty: the trip has no dates (unchanged).
- `date_from` only: allowed. The trip has a start date and `date_to` is null.
- Both: `date_to` must be on or after `date_from`, otherwise 400
  `Trip end date must be on or after start date.` (unchanged).
- `date_to` without `date_from`: 400 `Trip end date needs a start date.`
  (previously `Trip period must include both date_from and date_to.` for either
  half missing).
- An invalid date string returns 400 as before.

`update_trip` does not change dates. Responses keep returning `date_from` and
`date_to` as nullable strings, so existing clients already handle a null end date.

## Behaviour with no end date

- Trip cards and the trip header show the start date; a finished trip falls back
  to its finish date (`ended_at`), as for trips without dates.
- The PDF trip report shows the start date to the last expense date, or to the
  finish date when there are no expenses after the start.
- The year summary already falls back to the last expense day.
