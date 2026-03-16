# Legacy Action -> v1 Path Mapping

| Legacy action (`api.php?action=`) | Target v1 endpoint |
| --- | --- |
| `register` | `POST /api/v1/register` |
| `login` | `POST /api/v1/login` |
| `set_credentials` | `POST /api/v1/set-credentials` |
| `me` | `GET /api/v1/me` |
| `trips` | `GET /api/v1/trips` |
| `create_trip` | `POST /api/v1/trips` |
| `add_trip_members` | `POST /api/v1/trips/{tripId}/members` |
| `users` | `GET /api/v1/trips/{tripId}/users` |
| `upload_receipt` | `POST /api/v1/trips/{tripId}/receipts` |
| `add_expense` | `POST /api/v1/trips/{tripId}/expenses` |
| `update_expense` | `PUT /api/v1/trips/{tripId}/expenses/{expenseId}` |
| `delete_expense` | `DELETE /api/v1/trips/{tripId}/expenses/{expenseId}` |
| `list_expenses` | `GET /api/v1/trips/{tripId}/expenses` |
| `balances` | `GET /api/v1/trips/{tripId}/balances` |
| `generate_order` | `POST /api/v1/trips/{tripId}/random/draw` |
| `list_orders` | `GET /api/v1/trips/{tripId}/random/history` |
