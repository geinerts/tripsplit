# Feature usage counters

Status: approved by the owner and deployed to the server on 2026-11-07, with the migration
below.

The owner wants to know which features people use before deciding on Premium, without
collecting more data than that. The server keeps one number per feature per month.

## What is stored

`trip_feature_usage_counts` holds `usage_month` (`YYYY-MM`, UTC), `feature` and `use_count`.

It has no user, trip, device, IP address or day. There are no individual events to read back,
so a count can't be traced to a request from this table.

This describes the table only. Requests still pass through Cloudflare and the web server,
which handle IP addresses as they do for every request. Don't describe the whole app or all of
its data as anonymous.

## What is counted

A feature is counted when its action succeeds. Rejected requests, such as `premium_required`,
aren't counted. No request or response changes.

| Feature | Action | What the number means |
|---|---|---|
| `trip_export_pdf` | `trip_export` with `format=pdf` | exports created |
| `trip_export_csv` | `trip_export` with `format=csv` | exports created |
| `year_summary_view` | `travel_year_summary` | loads, so a repeat view counts again |
| `receipt_upload` | `upload_receipt` | images uploaded |
| `travel_map_open` | `list_travel_places` | map loads, including reloads on that screen |
| `travel_place_save` | `save_travel_place` | new and edited visits |
| `live_location_start` | `start_trip_live_location` | sharing started or renewed |
| `random_pick` | `generate_order` | draws |
| `analytics_open` | `analytics_summary` | screen loads, including refreshes |

`analytics_open` only appears from app builds that use `analytics_summary`. `list_orders`,
`list_trip_live_locations` and `update_trip_live_location` aren't counted, because the app
calls them repeatedly on its own.

The numbers include the owner's own testing, because the table can't tell who did what.

A total doesn't say how many people use a feature, since 40 uploads can be one person. It does
give a ceiling: 3 exports means at most 3 people.

## Failures

Counting never affects the feature. If the table is missing or the write fails, the request
continues and nothing is logged.

The count is written after the action's transaction commits, so it never rolls back or holds up
a real change, and a failed action leaves no count.

## Retention

The current month and the 23 before it are kept. The first count of each feature in a new
month deletes anything older, so no timer is needed. Routine backups can hold deleted rows for
longer, under their own retention.

## Admin panel

`admin_panel_dashboard` adds `stats.feature_usage`, behind the existing private host and
dashboard roles:

```json
{
  "available": true,
  "months": [
    {
      "month": "2026-11",
      "counts": [
        { "feature": "trip_export_pdf", "count": 3 }
      ]
    }
  ]
}
```

`months` holds up to 6 months that have counts, newest first. Each lists every feature in a fixed
order, with 0 for no use. If the table can't be read, `available` is `false` and `months` is
empty, and the rest of the dashboard still loads.

Don't publish a number below 5 outside the panel. With few users it can point to one person.

## Migration

`sql/migrations/2026-11-07-add-feature-usage-counts.sql` creates the table. The migration
runner reads files from the server's checkout, so the code arrives first. Until the table
exists the counters do nothing.

## Open before store release

These aren't settled by this document:

- A lawyer must confirm whether these counts are personal data and which legal basis applies,
  including for the moment a signed-in request is counted.
- The privacy policy needs a sentence about the counters. It must not say that everything in
  the app is collected anonymously.
- App Store Connect and Google Play need reviewing. The cautious answers are Usage Data →
  Product Interaction, and App activity → App interactions, for analytics and without tracking.
  Whether Apple's "not linked to you" fits depends on the lawyer's answer.

No app code sends a signal for this, and nothing is stored on the device.
