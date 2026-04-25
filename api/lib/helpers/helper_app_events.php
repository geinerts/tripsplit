<?php
declare(strict_types=1);

function app_events_column_available(PDO $pdo, string $columnName): bool
{
    static $cache = [];
    $column = strtolower(trim($columnName));
    if ($column === '' || !preg_match('/^[a-z0-9_]+$/', $column)) {
        return false;
    }
    if (array_key_exists($column, $cache)) {
        return $cache[$column];
    }

    try {
        $table = trim(table_name('app_events'), '`');
        if ($table === '' || !preg_match('/^[A-Za-z0-9_]+$/', $table)) {
            $cache[$column] = false;
            return false;
        }

        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name = :column_name'
        );
        $stmt->execute([
            'table_name' => $table,
            'column_name' => $column,
        ]);
        $cache[$column] = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable) {
        $cache[$column] = false;
    }

    return $cache[$column];
}

function app_events_trip_activity_available(PDO $pdo): bool
{
    return app_events_column_available($pdo, 'trip_id')
        && app_events_column_available($pdo, 'payload_json');
}

// Logs a privacy-safe app-level event — no personal content, only IDs and compact metadata.
function app_event(
    PDO     $pdo,
    ?int    $userId,
    string  $eventType,
    ?string $entityType = null,
    ?int    $entityId   = null,
    ?int    $tripId     = null,
    array   $payload    = []
): void {
    try {
        $tbl = table_name('app_events');
        $columns = ['user_id', 'event_type', 'entity_type', 'entity_id'];
        $values = [$userId, $eventType, $entityType, $entityId];

        if ($tripId !== null && $tripId > 0 && app_events_column_available($pdo, 'trip_id')) {
            $columns[] = 'trip_id';
            $values[] = $tripId;
        }

        if ($payload !== [] && app_events_column_available($pdo, 'payload_json')) {
            $encodedPayload = json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE);
            if (is_string($encodedPayload) && $encodedPayload !== '') {
                $columns[] = 'payload_json';
                $values[] = $encodedPayload;
            }
        }

        $columnSql = implode(', ', array_map(static fn(string $column): string => '`' . $column . '`', $columns));
        $placeholders = implode(', ', array_fill(0, count($columns), '?'));
        $pdo->prepare("
            INSERT INTO {$tbl} ({$columnSql})
            VALUES ({$placeholders})
        ")->execute($values);
    } catch (Throwable) {
        // Non-fatal — don't break the actual action if event log fails
    }
}
