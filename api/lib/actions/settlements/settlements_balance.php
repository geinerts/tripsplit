<?php
declare(strict_types=1);

function compute_trip_balance_data(PDO $pdo, int $tripId): array
{
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');

    $usersStmt = $pdo->prepare(
        'SELECT u.id, u.nickname
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $usersStmt->execute(['trip_id' => $tripId]);
    $users = $usersStmt->fetchAll();

    $stats = [];
    foreach ($users as $user) {
        $id = (int) $user['id'];
        $stats[$id] = [
            'id' => $id,
            'nickname' => (string) ($user['nickname'] ?? ''),
            'paid_cents' => 0,
            'owed_cents' => 0,
        ];
    }

    if (!$stats) {
        return [
            'stats' => [],
            'balances' => [],
            'recommended_settlements' => [],
        ];
    }

    $expensesStmt = $pdo->prepare(
        'SELECT id, amount, paid_by
         FROM ' . $expensesTable . '
         WHERE trip_id = :trip_id
         ORDER BY id ASC'
    );
    $expensesStmt->execute(['trip_id' => $tripId]);
    $expenses = $expensesStmt->fetchAll();

    $expenseIds = array_map(static fn(array $row): int => (int) $row['id'], $expenses);
    $participantsByExpense = [];
    if ($expenseIds) {
        $placeholders = implode(',', array_fill(0, count($expenseIds), '?'));
        $participantsStmt = $pdo->prepare(
            'SELECT expense_id, user_id, owed_cents
             FROM ' . $participantsTable . '
             WHERE expense_id IN (' . $placeholders . ')
             ORDER BY expense_id ASC, user_id ASC'
        );
        $participantsStmt->execute($expenseIds);
        foreach ($participantsStmt->fetchAll() as $row) {
            $expenseId = (int) $row['expense_id'];
            $participantsByExpense[$expenseId][] = [
                'user_id' => (int) $row['user_id'],
                'owed_cents' => (int) ($row['owed_cents'] ?? 0),
            ];
        }
    }

    // Keep this function as DB adapter only: fetch data, then delegate
    // all math to pure settlement algorithm helpers.
    return compute_balance_from_data($stats, $expenses, $participantsByExpense);
}
