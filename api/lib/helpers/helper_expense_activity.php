<?php
declare(strict_types=1);

/**
 * What an expense edit changed, for the `expense.updated` activity event, in a fixed order.
 * Only names, never values: the event already carries the new values members can see.
 *
 * @param array $before Keys: amount_cents, source_amount_cents, currency_code, paid_by, category,
 *                      subcategory, note, expense_date, split_mode, is_personal, receipt_path.
 * @param array $after  The same keys after the edit.
 * @param array<int, int> $participantsBefore user id => owed cents.
 * @param array<int, int> $participantsAfter  user id => owed cents.
 * @return list<string>
 */
function expense_activity_changes(array $before, array $after, array $participantsBefore, array $participantsAfter): array
{
    $same = static fn(string $key): bool => (string) ($before[$key] ?? '') === (string) ($after[$key] ?? '');
    ksort($participantsBefore);
    ksort($participantsAfter);
    $changes = [];
    if (!$same('amount_cents') || !$same('source_amount_cents') || !$same('currency_code')) {
        $changes[] = 'amount';
    }
    if (!$same('paid_by')) {
        $changes[] = 'payer';
    }
    if (!$same('category') || !$same('subcategory')) {
        $changes[] = 'category';
    }
    if (!$same('note')) {
        $changes[] = 'note';
    }
    if (substr((string) ($before['expense_date'] ?? ''), 0, 10) !== substr((string) ($after['expense_date'] ?? ''), 0, 10)) {
        $changes[] = 'date';
    }
    if (!$same('split_mode') || !$same('is_personal') || $participantsBefore !== $participantsAfter) {
        $changes[] = 'split';
    }
    if (!$same('receipt_path')) {
        $changes[] = 'receipt';
    }
    return $changes;
}

/** user id => owed cents of an expense, read before it is rewritten. */
function expense_activity_participants(PDO $pdo, int $expenseId): array
{
    $stmt = $pdo->prepare(
        'SELECT user_id, owed_cents FROM ' . table_name('expense_participants') . ' WHERE expense_id = :id'
    );
    $stmt->execute(['id' => $expenseId]);
    $result = [];
    foreach ($stmt->fetchAll() as $row) {
        $result[(int) $row['user_id']] = (int) ($row['owed_cents'] ?? 0);
    }
    return $result;
}
