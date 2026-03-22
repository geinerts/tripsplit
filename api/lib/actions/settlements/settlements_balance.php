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

    foreach ($expenses as $expense) {
        $expenseId = (int) $expense['id'];
        $paidBy = (int) $expense['paid_by'];
        $amountCents = decimal_to_cents($expense['amount']);

        if (isset($stats[$paidBy])) {
            $stats[$paidBy]['paid_cents'] += $amountCents;
        }

        $participants = $participantsByExpense[$expenseId] ?? [];
        $count = count($participants);
        if ($count < 1) {
            continue;
        }

        $storedOwedTotal = 0;
        foreach ($participants as $participantRow) {
            $storedOwedTotal += (int) ($participantRow['owed_cents'] ?? 0);
        }
        $useStoredOwed = $storedOwedTotal === $amountCents;

        if ($useStoredOwed) {
            foreach ($participants as $participantRow) {
                $userId = (int) ($participantRow['user_id'] ?? 0);
                if (!isset($stats[$userId])) {
                    continue;
                }
                $stats[$userId]['owed_cents'] += (int) ($participantRow['owed_cents'] ?? 0);
            }
            continue;
        }

        $base = intdiv($amountCents, $count);
        $remainder = $amountCents % $count;
        foreach ($participants as $index => $participantRow) {
            $userId = (int) ($participantRow['user_id'] ?? 0);
            if (!isset($stats[$userId])) {
                continue;
            }
            $share = $base + ($index < $remainder ? 1 : 0);
            $stats[$userId]['owed_cents'] += $share;
        }
    }

    $creditors = [];
    $debtors = [];
    $balances = [];

    foreach ($stats as $stat) {
        $net = $stat['paid_cents'] - $stat['owed_cents'];
        if ($net > 0) {
            $creditors[] = ['id' => $stat['id'], 'amount_cents' => $net];
        } elseif ($net < 0) {
            $debtors[] = ['id' => $stat['id'], 'amount_cents' => -$net];
        }

        $balances[] = [
            'id' => $stat['id'],
            'nickname' => $stat['nickname'],
            'paid' => cents_to_float($stat['paid_cents']),
            'owed' => cents_to_float($stat['owed_cents']),
            'net' => cents_to_float($net),
        ];
    }

    usort($creditors, static fn(array $a, array $b): int => $b['amount_cents'] <=> $a['amount_cents']);
    usort($debtors, static fn(array $a, array $b): int => $b['amount_cents'] <=> $a['amount_cents']);

    $recommended = [];
    $i = 0;
    $j = 0;
    while ($i < count($debtors) && $j < count($creditors)) {
        $debt = $debtors[$i];
        $credit = $creditors[$j];
        $payCents = min($debt['amount_cents'], $credit['amount_cents']);

        $fromUserId = (int) $debt['id'];
        $toUserId = (int) $credit['id'];
        $recommended[] = [
            'from_user_id' => $fromUserId,
            'to_user_id' => $toUserId,
            'from' => $stats[$fromUserId]['nickname'],
            'to' => $stats[$toUserId]['nickname'],
            'amount_cents' => $payCents,
            'amount' => cents_to_float($payCents),
        ];

        $debtors[$i]['amount_cents'] -= $payCents;
        $creditors[$j]['amount_cents'] -= $payCents;
        if ($debtors[$i]['amount_cents'] === 0) {
            $i++;
        }
        if ($creditors[$j]['amount_cents'] === 0) {
            $j++;
        }
    }

    return [
        'stats' => $stats,
        'balances' => $balances,
        'recommended_settlements' => $recommended,
    ];
}
