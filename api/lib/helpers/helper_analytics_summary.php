<?php
declare(strict_types=1);

const ANALYTICS_LARGEST_LIMIT = 5;

/** Thrown when totals would otherwise rest on a guessed share. */
final class AnalyticsIncompleteException extends RuntimeException
{
}

/** Highest first, then newest. Rows at zero are left out. */
function analytics_largest(array $rows, string $amountKey): array
{
    $rows = array_values(array_filter($rows, static fn(array $row): bool => $row[$amountKey] > 0));
    usort($rows, static fn(array $a, array $b): int => [$b[$amountKey], $b['date'], $b['id']]
        <=> [$a[$amountKey], $a['date'], $a['id']]);
    return array_map(static fn(array $row): array => [
        'id' => $row['id'],
        'category' => $row['category'],
        'note' => $row['note'],
        'amount_cents' => $row[$amountKey],
    ], array_slice($rows, 0, ANALYTICS_LARGEST_LIMIT));
}

/**
 * @param array $expenses Rows with id, amount, category, note, split_mode, expense_date, paid_by, paid_by_nickname.
 * @param array $participantsByExpense Rows per expense id, in the order `list_expenses` uses.
 */
function analytics_trip_summary(array $expenses, array $participantsByExpense, int $userId): array
{
    $buckets = [];
    $names = [];
    $paid = [];
    $rows = [];
    foreach ($expenses as $expense) {
        $id = (int) $expense['id'];
        $amountCents = decimal_to_cents($expense['amount']);
        $participants = $participantsByExpense[$id] ?? [];
        if ($amountCents < 0 || ($participants === [] && $amountCents !== 0)) {
            throw new AnalyticsIncompleteException('Expense ' . $id . ' has no usable allocation.');
        }

        $shareCents = 0;
        $allocations = build_expense_participants_payload_rows(
            $amountCents,
            normalize_expense_split_mode($expense['split_mode'] ?? 'equal'),
            $participants
        );
        foreach ($allocations as $allocation) {
            $names[$allocation['id']] = $allocation['nickname'];
            if ($allocation['id'] === $userId) {
                $shareCents += decimal_to_cents($allocation['owed']);
            }
        }

        $payerId = (int) $expense['paid_by'];
        $names[$payerId] = (string) ($expense['paid_by_nickname'] ?? '');
        $paid[$payerId] = ($paid[$payerId] ?? 0) + $amountCents;

        $date = substr((string) ($expense['expense_date'] ?? ''), 0, 10);
        $category = trim((string) ($expense['category'] ?? ''));
        $category = $category !== '' ? $category : 'other';
        $key = $date . '|' . $category;
        $buckets[$key] ??= [
            'date' => $date,
            'category' => $category,
            'total_cents' => 0,
            'share_cents' => 0,
            'paid_cents' => 0,
            'expense_count' => 0,
            'shared_expense_count' => 0,
        ];
        $buckets[$key]['total_cents'] += $amountCents;
        $buckets[$key]['share_cents'] += $shareCents;
        $buckets[$key]['paid_cents'] += $payerId === $userId ? $amountCents : 0;
        $buckets[$key]['expense_count']++;
        $buckets[$key]['shared_expense_count'] += $shareCents !== 0 ? 1 : 0;

        $rows[] = [
            'id' => $id,
            'date' => $date,
            'category' => $category,
            'note' => (string) ($expense['note'] ?? ''),
            'total_cents' => $amountCents,
            'share_cents' => $shareCents,
        ];
    }
    ksort($buckets, SORT_STRING);

    $members = [];
    foreach ($names as $id => $nickname) {
        $members[] = ['id' => (int) $id, 'nickname' => $nickname, 'paid_cents' => $paid[$id] ?? 0];
    }
    usort($members, static fn(array $a, array $b): int => [$b['paid_cents'], $a['id']] <=> [$a['paid_cents'], $b['id']]);

    return [
        'buckets' => array_values($buckets),
        'members' => $members,
        'largest_by_total' => analytics_largest($rows, 'total_cents'),
        'largest_by_share' => analytics_largest($rows, 'share_cents'),
    ];
}

function analytics_summary_build(PDO $pdo, int $userId): array
{
    $expensesTable = table_name('expenses');
    $usersTable = table_name('users');
    $participantsTable = table_name('expense_participants');
    $currencySelect = trips_currency_column_available($pdo)
        ? 't.currency_code'
        : "'" . default_trip_currency_code() . "' AS currency_code";

    $tripsStmt = $pdo->prepare(
        'SELECT t.id, ' . $currencySelect . '
         FROM ' . table_name('trips') . ' t
         JOIN ' . table_name('trip_members') . ' tm ON tm.trip_id = t.id
         WHERE tm.user_id = :user_id
         ORDER BY t.created_at DESC, t.id DESC'
    );
    $tripsStmt->execute(['user_id' => $userId]);

    $expensesStmt = $pdo->prepare(
        'SELECT e.id, e.amount, e.category, e.note, e.split_mode, e.expense_date, e.paid_by,
                u.nickname AS paid_by_nickname
         FROM ' . $expensesTable . ' e
         JOIN ' . $usersTable . ' u ON u.id = e.paid_by
         WHERE e.trip_id = :trip_id'
    );
    $participantsStmt = $pdo->prepare(
        'SELECT ep.expense_id, ep.owed_cents, ep.split_value, u.id, u.nickname
         FROM ' . $participantsTable . ' ep
         JOIN ' . $expensesTable . ' e ON e.id = ep.expense_id
         JOIN ' . $usersTable . ' u ON u.id = ep.user_id
         WHERE e.trip_id = :trip_id
         ORDER BY ep.expense_id DESC, u.created_at ASC, u.id ASC'
    );

    $summaries = [];
    foreach ($tripsStmt->fetchAll() as $trip) {
        $tripId = (int) $trip['id'];
        $expensesStmt->execute(['trip_id' => $tripId]);
        $expenses = $expensesStmt->fetchAll();
        $participantsStmt->execute(['trip_id' => $tripId]);
        $participantsByExpense = [];
        foreach ($participantsStmt->fetchAll() as $participant) {
            $participantsByExpense[(int) $participant['expense_id']][] = $participant;
        }
        $summaries[] = [
            'trip_id' => $tripId,
            'currency_code' => normalize_currency_code($trip['currency_code'] ?? default_trip_currency_code()),
        ] + analytics_trip_summary($expenses, $participantsByExpense, $userId);
    }
    return $summaries;
}
