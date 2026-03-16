# TripSplit API v1 Outline

## Auth
- `POST /api/v1/register`
- `POST /api/v1/login`
- `POST /api/v1/set-credentials`
- `GET /api/v1/me`

## Trips
- `GET /api/v1/trips`
- `POST /api/v1/trips`
- `POST /api/v1/trips/{tripId}/members`
- `GET /api/v1/trips/{tripId}/users`

## Expenses
- `POST /api/v1/trips/{tripId}/receipts`
- `POST /api/v1/trips/{tripId}/expenses`
- `PUT /api/v1/trips/{tripId}/expenses/{expenseId}`
- `DELETE /api/v1/trips/{tripId}/expenses/{expenseId}`
- `GET /api/v1/trips/{tripId}/expenses`

## Balances
- `GET /api/v1/trips/{tripId}/balances`

## Random
- `POST /api/v1/trips/{tripId}/random/draw`
- `GET /api/v1/trips/{tripId}/random/history`

## Admin
- `GET /api/v1/admin/summary`
- `GET /api/v1/admin/users`
- `GET /api/v1/admin/users/{id}`
- `PATCH /api/v1/admin/users/{id}`
- `DELETE /api/v1/admin/users/{id}`
- `DELETE /api/v1/admin/expenses/{id}`

## Notes
Current production-compatible API still exists in `api/api.php` (legacy endpoint style with `action=` query).
This document is the target contract shape for the structured v1 migration.
