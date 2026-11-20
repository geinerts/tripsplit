<?php
declare(strict_types=1);

/**
 * Marks trip expenses that were added from a quick split ("from_quick_split"),
 * so every member sees where they came from. docs/api/quick-splits.md.
 * Before the quick split migration, or if the lookup fails, all are false.
 */
function attach_quick_split_origin(PDO $pdo, int $tripId, array &$rows): void
{
    $ids = [];
    foreach ($rows as &$row) {
        $row['from_quick_split'] = false;
        $ids[] = (int) ($row['id'] ?? 0);
    }
    unset($row);
    $ids = array_values(array_filter($ids, static fn (int $id): bool => $id > 0));
    if ($tripId <= 0 || $ids === []) {
        return;
    }
    try {
        $marks = implode(',', array_fill(0, count($ids), '?'));
        $stmt = $pdo->prepare('SELECT moved_expense_id FROM ' . table_name('quick_splits')
            . ' WHERE moved_trip_id = ? AND moved_expense_id IN (' . $marks . ')');
        $stmt->execute(array_merge([$tripId], $ids));
        $moved = array_flip(array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN)));
    } catch (Throwable $error) {
        return;
    }
    foreach ($rows as &$row) {
        $row['from_quick_split'] = isset($moved[(int) ($row['id'] ?? 0)]);
    }
    unset($row);
}
