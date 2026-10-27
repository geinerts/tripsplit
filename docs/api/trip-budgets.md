# Optional trip budgets

Local implementation, 2026-10-26. Requires the database migration and updated API
before users can save a budget. These changes have not been deployed or archived.

## API

`create_trip`, `create_solo_trip`, and `update_trip` accept `budget_cents`:

- Positive JSON integer in the trip's main currency, from 1 to 99999999999.
- `null` removes a budget; omitted on update preserves the current value.
- Omitted or null on create means no budget. Existing trips default to null.
- Strings, floating point values, booleans, arrays, zero and negatives return 400.
- Only the trip owner or admin may update details, including this shared budget.
- Changing the currency of a budgeted trip requires explicitly setting or removing
  the budget in the same request, preventing silent reinterpretation of an amount.

The trips list, create/update responses and workspace trip payload include the
nullable integer. It is private trip information: only members receive the trip
payload; public invitations do not expose a budget.

Run `sql/migrations/2026-10-26-add-trip-budget.sql` before enabling saves. The API
supports an unmigrated database for existing operations, returning null on reads
and 409 for a budget write. No table data is removed by the migration.

## Mobile

Create and Edit trip offer an opt-in switch and amount input. Groups have one
shared whole-trip budget; solo trips have the owner's budget. Without a budget,
the overview keeps its existing appearance. A budget card shows spent, limit,
remaining or excess, and a bounded progress bar. Spending comes from complete
trip balances in the main currency, not the paginated expense list or a single
member's share. Over-budget trips can still add expenses and settle normally.

Account-scoped trip and workspace caches retain the budget. Workspace metadata
distinguishes an old response without a budget field from an explicit removal,
so a freshly removed budget does not fall back to stale home-list information.

## Verification

- `api/tests/Unit/TripBudgetTest.php`: actual create/update handlers on an isolated
  SQLite database, migration, permissions, integer bounds, omission/removal,
  currency changes and no writes on invalid requests.
- `mobile/test/features/trips/trip_budget_test.dart`: API payload semantics,
  offline cache, form validation, decimal-comma input, removal, light/dark layout
  in EN/LV/ES at 320 px and 200% text size.
- `mobile/test/features/workspace/workspace_redesign_test.dart`: whole-trip totals
  rather than partial expenses; `BUDGET_PREVIEWS=true` exports overview and edit
  examples to `output/design/trip-budget/` using synthetic test data.
