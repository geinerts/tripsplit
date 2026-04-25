<?php
declare(strict_types=1);

// Logs a privacy-safe app-level event — no personal content, only IDs and event type.
function app_event(
    PDO     $pdo,
    ?int    $userId,
    string  $eventType,
    ?string $entityType = null,
    ?int    $entityId   = null
): void {
    try {
        $tbl = table_name('app_events');
        $pdo->prepare("
            INSERT INTO {$tbl} (user_id, event_type, entity_type, entity_id)
            VALUES (?, ?, ?, ?)
        ")->execute([$userId, $eventType, $entityType, $entityId]);
    } catch (Throwable) {
        // Non-fatal — don't break the actual action if event log fails
    }
}
