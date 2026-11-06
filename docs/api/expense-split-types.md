# Adjustment and itemized expense splits

Status: approved by the owner on 2026-11-06. Needs the migration below before the
server is deployed.

`add_expense` and `update_expense` accept two more `split_mode` values next to `equal`,
`exact`, `percent` and `shares`. Other modes and existing fields don't change. Amounts in
this document are decimal numbers in the expense's own currency, like `amount` is.

## `adjustment`

Everyone pays an equal part of what remains after the adjustments, plus their adjustment.

`splits` lists every participant as `{user_id, value}`. `value` may be zero or negative.

```json
{"amount": 100, "split_mode": "adjustment", "participants": [1, 2, 3],
 "splits": [{"user_id": 1, "value": 10}, {"user_id": 2, "value": 0}, {"user_id": 3, "value": 0}]}
```

This gives 40, 30 and 30. Cents left over from the division go to the first participants.

Returns 400 `Adjustments exceed the expense amount.` if the adjustments add up to more than
the amount, or if someone's part would be below zero.

In responses `participants[].split_value` is the adjustment, and may be negative.

## `itemized`

`items` lists each line of the bill, and `extra_amount` optionally holds tax or tip.

```json
{"amount": 20, "split_mode": "itemized",
 "items": [{"name": "Pizza", "amount": 12, "participant_ids": [1, 2]},
           {"name": "Beer", "amount": 5, "participant_ids": [2]}],
 "extra_amount": 3}
```

- An item is shared equally among its `participant_ids`.
- `extra_amount` is shared in proportion to what each person's items add up to.
- `participants` and `splits` are ignored: the participants are everyone named in `items`.

| Rule | Error (400) |
| --- | --- |
| 1 to 100 items | `Add at least one item.`, `Too many items.` |
| Name of 1 to 80 characters, without links | `Item name is required.`, `Item name is too long.` |
| At least one trip member per item | `Each item needs at least one person.` |
| Items and extra add up to `amount` | `Items must add up to the expense amount.` |

Item amounts and `extra_amount` stay in the expense's currency. Each person's total is then
converted to the trip's currency the same way as an `exact` split.

Responses that list expenses (`list_expenses` and the workspace snapshot) add `items` and
`extra_amount` to itemized expenses. `participants[].split_value` is the person's total in
the expense's currency.

## Solo trips

Personal trips stay limited to `equal`, as they are now.

## Older app versions

They read an unknown mode as `equal`. Balances stay correct, since they use the stored
`owed` amounts, but editing such an expense in an older version replaces its split.

## Migration

`sql/migrations/2026-11-06-add-expense-split-types.sql` runs before the server is updated:

- `trip_expenses.split_mode` gets the two values.
- `trip_expense_participants.split_value` becomes signed, for negative adjustments.
- New tables `trip_expense_items` and `trip_expense_item_participants`.
