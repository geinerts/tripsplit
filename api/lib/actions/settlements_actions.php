<?php
declare(strict_types=1);

function normalize_settlement_status($value): string
{
    $raw = strtolower(trim((string) $value));
    if ($raw === 'sent' || $raw === 'confirmed') {
        return $raw;
    }
    return 'pending';
}

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

function settlement_row_to_payload(array $row, int $currentUserId, array $stats = []): array
{
    $fromUserId = (int) ($row['from_user_id'] ?? 0);
    $toUserId = (int) ($row['to_user_id'] ?? 0);
    $status = normalize_settlement_status($row['status'] ?? 'pending');

    $fromName = trim((string) ($row['from_nickname'] ?? ''));
    if ($fromName === '') {
        $fromName = (string) ($stats[$fromUserId]['nickname'] ?? ('User ' . $fromUserId));
    }

    $toName = trim((string) ($row['to_nickname'] ?? ''));
    if ($toName === '') {
        $toName = (string) ($stats[$toUserId]['nickname'] ?? ('User ' . $toUserId));
    }

    $amountCents = (int) ($row['amount_cents'] ?? 0);
    return [
        'id' => array_key_exists('id', $row) ? (int) $row['id'] : null,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
        'from' => $fromName,
        'to' => $toName,
        'amount' => cents_to_float($amountCents),
        'status' => $status,
        'marked_sent_at' => $row['marked_sent_at'] ?? null,
        'confirmed_at' => $row['confirmed_at'] ?? null,
        'can_mark_sent' => $status === 'pending' && $currentUserId > 0 && $currentUserId === $fromUserId,
        'can_confirm_received' => $status === 'sent' && $currentUserId > 0 && $currentUserId === $toUserId,
        'is_confirmed' => $status === 'confirmed',
    ];
}

function load_trip_settlement_payload(PDO $pdo, int $tripId, int $currentUserId, array $stats): array
{
    $settlementsTable = table_name('settlements');
    $usersTable = table_name('users');
    $stmt = $pdo->prepare(
        'SELECT
            s.id,
            s.trip_id,
            s.from_user_id,
            s.to_user_id,
            s.amount_cents,
            s.status,
            s.marked_sent_at,
            s.confirmed_at,
            uf.nickname AS from_nickname,
            ut.nickname AS to_nickname
         FROM ' . $settlementsTable . ' s
         JOIN ' . $usersTable . ' uf ON uf.id = s.from_user_id
         JOIN ' . $usersTable . ' ut ON ut.id = s.to_user_id
         WHERE s.trip_id = :trip_id
         ORDER BY s.id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    $rows = $stmt->fetchAll();

    $settlements = [];
    $confirmedCount = 0;
    foreach ($rows as $row) {
        $item = settlement_row_to_payload($row, $currentUserId, $stats);
        if ($item['is_confirmed'] === true) {
            $confirmedCount++;
        }
        $settlements[] = $item;
    }

    $total = count($settlements);
    $remaining = max(0, $total - $confirmedCount);
    $allSettled = $total === 0 ? true : $remaining === 0;

    return [
        'settlements' => $settlements,
        'progress' => [
            'total' => $total,
            'confirmed' => $confirmedCount,
            'remaining' => $remaining,
            'all_settled' => $allSettled,
        ],
    ];
}

function balances_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];
    $status = normalize_trip_status($trip['status'] ?? 'active');

    $computed = compute_trip_balance_data($pdo, $tripId);
    $stats = $computed['stats'];
    $balances = $computed['balances'];

    if ($status === 'active') {
        $settlements = array_map(
            static fn(array $item): array => [
                'id' => null,
                'from_user_id' => (int) $item['from_user_id'],
                'to_user_id' => (int) $item['to_user_id'],
                'from' => (string) $item['from'],
                'to' => (string) $item['to'],
                'amount' => (float) $item['amount'],
                'status' => 'suggested',
                'marked_sent_at' => null,
                'confirmed_at' => null,
                'can_mark_sent' => false,
                'can_confirm_received' => false,
                'is_confirmed' => false,
            ],
            $computed['recommended_settlements']
        );
        $progress = [
            'total' => count($settlements),
            'confirmed' => 0,
            'remaining' => count($settlements),
            'all_settled' => false,
        ];
    } else {
        $stored = load_trip_settlement_payload($pdo, $tripId, (int) $me['id'], $stats);
        $settlements = $stored['settlements'];
        $progress = $stored['progress'];

        if ($status === 'settling' && $progress['all_settled'] === true) {
            $tripsTable = table_name('trips');
            $archiveStmt = $pdo->prepare(
                'UPDATE ' . $tripsTable . '
                 SET status = "archived",
                     archived_at = COALESCE(archived_at, CURRENT_TIMESTAMP)
                 WHERE id = :trip_id
                   AND status = "settling"'
            );
            $archiveStmt->execute(['trip_id' => $tripId]);

            $freshTrip = find_trip_for_user($pdo, (int) $me['id'], $tripId);
            if (is_array($freshTrip)) {
                $trip = normalize_trip_row($freshTrip);
                $status = (string) $trip['status'];
            }
        }
    }

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'balances' => $balances,
        'settlements' => $settlements,
        'settlement_progress' => $progress,
        'all_settled' => (bool) ($progress['all_settled'] ?? false),
    ]);
}

function end_trip_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];
    $status = normalize_trip_status($trip['status'] ?? 'active');

    if ($status !== 'active') {
        json_out([
            'ok' => false,
            'error' => 'Trip is already closed.',
            'trip' => build_trip_payload($trip),
        ], 409);
    }

    $creatorId = (int) ($trip['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only trip creator can close the trip.'], 403);
    }

    $computed = compute_trip_balance_data($pdo, $tripId);
    $recommended = array_values(
        array_filter(
            $computed['recommended_settlements'],
            static fn(array $item): bool => ((int) ($item['amount_cents'] ?? 0)) > 0
        )
    );
    $nextStatus = count($recommended) > 0 ? 'settling' : 'archived';

    $tripsTable = table_name('trips');
    $settlementsTable = table_name('settlements');
    $tripMembersTable = table_name('trip_members');

    $pdo->beginTransaction();
    try {
        if ($nextStatus === 'settling') {
            $tripUpdate = $pdo->prepare(
                'UPDATE ' . $tripsTable . '
                 SET status = "settling",
                     ended_at = COALESCE(ended_at, CURRENT_TIMESTAMP),
                     archived_at = NULL
                 WHERE id = :trip_id'
            );
            $tripUpdate->execute(['trip_id' => $tripId]);
        } else {
            $tripUpdate = $pdo->prepare(
                'UPDATE ' . $tripsTable . '
                 SET status = "archived",
                     ended_at = COALESCE(ended_at, CURRENT_TIMESTAMP),
                     archived_at = COALESCE(archived_at, CURRENT_TIMESTAMP)
                 WHERE id = :trip_id'
            );
            $tripUpdate->execute(['trip_id' => $tripId]);
        }

        $deleteSettlements = $pdo->prepare('DELETE FROM ' . $settlementsTable . ' WHERE trip_id = :trip_id');
        $deleteSettlements->execute(['trip_id' => $tripId]);

        if ($nextStatus === 'settling') {
            $insertSettlement = $pdo->prepare(
                'INSERT INTO ' . $settlementsTable . ' (trip_id, from_user_id, to_user_id, amount_cents, status)
                 VALUES (:trip_id, :from_user_id, :to_user_id, :amount_cents, "pending")'
            );
            foreach ($recommended as $item) {
                $insertSettlement->execute([
                    'trip_id' => $tripId,
                    'from_user_id' => (int) $item['from_user_id'],
                    'to_user_id' => (int) $item['to_user_id'],
                    'amount_cents' => (int) $item['amount_cents'],
                ]);
            }
        }

        $memberStmt = $pdo->prepare(
            'SELECT tm.user_id
             FROM ' . $tripMembersTable . ' tm
             WHERE tm.trip_id = :trip_id'
        );
        $memberStmt->execute(['trip_id' => $tripId]);
        $memberIds = array_values(
            array_filter(
                array_map(
                    static fn(array $row): int => (int) ($row['user_id'] ?? 0),
                    $memberStmt->fetchAll()
                ),
                static fn(int $id): bool => $id > 0
            )
        );
        $memberIds = normalize_user_ids($memberIds);

        $tripName = trim((string) ($trip['name'] ?? ''));
        if ($tripName === '') {
            $tripName = 'Trip';
        }
        $creatorName = trim((string) ($me['nickname'] ?? ''));
        if ($creatorName === '') {
            $creatorName = 'Trip creator';
        }
        $notificationBody = $nextStatus === 'settling'
            ? $creatorName . ' finished "' . $tripName . '". Settlements are ready.'
            : $creatorName . ' finished "' . $tripName . '". Trip is archived.';

        foreach ($memberIds as $userId) {
            create_user_notification(
                $pdo,
                $tripId,
                $userId,
                'trip_finished',
                'Trip finished',
                $notificationBody,
                [
                    'trip_id' => $tripId,
                    'ended_by_user_id' => (int) $me['id'],
                    'status' => $nextStatus,
                    'settlements_count' => count($recommended),
                ]
            );
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $freshTrip = find_trip_for_user($pdo, (int) $me['id'], $tripId);
    if (is_array($freshTrip)) {
        $trip = normalize_trip_row($freshTrip);
    } else {
        $trip['status'] = $nextStatus;
    }

    $stored = load_trip_settlement_payload($pdo, $tripId, (int) $me['id'], $computed['stats']);
    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'balances' => $computed['balances'],
        'settlements' => $stored['settlements'],
        'settlement_progress' => $stored['progress'],
    ]);
}

function mark_settlement_sent_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $settlementId = (int) ($body['settlement_id'] ?? 0);
    if ($settlementId <= 0) {
        json_out(['ok' => false, 'error' => 'settlement_id is required.'], 400);
    }

    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];
    if (normalize_trip_status($trip['status'] ?? 'active') !== 'settling') {
        json_out(['ok' => false, 'error' => 'Trip is not in settling mode.'], 409);
    }

    $settlementsTable = table_name('settlements');
    $usersTable = table_name('users');
    $pdo->beginTransaction();
    try {
        $rowStmt = $pdo->prepare(
            'SELECT
                s.id,
                s.trip_id,
                s.from_user_id,
                s.to_user_id,
                s.amount_cents,
                s.status,
                s.marked_sent_at,
                s.confirmed_at,
                uf.nickname AS from_nickname,
                ut.nickname AS to_nickname
             FROM ' . $settlementsTable . ' s
             JOIN ' . $usersTable . ' uf ON uf.id = s.from_user_id
             JOIN ' . $usersTable . ' ut ON ut.id = s.to_user_id
             WHERE s.id = :id AND s.trip_id = :trip_id
             LIMIT 1
             FOR UPDATE'
        );
        $rowStmt->execute([
            'id' => $settlementId,
            'trip_id' => $tripId,
        ]);
        $row = $rowStmt->fetch();
        if (!$row) {
            json_out(['ok' => false, 'error' => 'Settlement not found.'], 404);
        }

        $fromUserId = (int) ($row['from_user_id'] ?? 0);
        if ($fromUserId !== (int) $me['id']) {
            json_out(['ok' => false, 'error' => 'Only payer can mark transfer as sent.'], 403);
        }

        $status = normalize_settlement_status($row['status'] ?? 'pending');
        if ($status === 'confirmed') {
            json_out(['ok' => false, 'error' => 'Settlement is already confirmed.'], 409);
        }

        $sentNow = false;
        if ($status === 'pending') {
            $update = $pdo->prepare(
                'UPDATE ' . $settlementsTable . '
                 SET status = "sent",
                     marked_sent_by = :user_id,
                     marked_sent_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $update->execute([
                'user_id' => (int) $me['id'],
                'id' => $settlementId,
            ]);
            $sentNow = true;
        }

        if ($sentNow) {
            $fromName = trim((string) ($row['from_nickname'] ?? ''));
            if ($fromName === '') {
                $fromName = 'Trip member';
            }
            $amount = '€' . cents_to_decimal((int) ($row['amount_cents'] ?? 0));
            create_user_notification(
                $pdo,
                $tripId,
                (int) ($row['to_user_id'] ?? 0),
                'settlement_sent',
                'Transfer marked as sent',
                $fromName . ' marked ' . $amount . ' as sent to you.',
                [
                    'settlement_id' => $settlementId,
                    'from_user_id' => (int) ($row['from_user_id'] ?? 0),
                    'to_user_id' => (int) ($row['to_user_id'] ?? 0),
                    'amount_cents' => (int) ($row['amount_cents'] ?? 0),
                ]
            );
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $computed = compute_trip_balance_data($pdo, $tripId);
    $stored = load_trip_settlement_payload($pdo, $tripId, (int) $me['id'], $computed['stats']);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'settlements' => $stored['settlements'],
        'settlement_progress' => $stored['progress'],
        'updated_settlement_id' => $settlementId,
    ]);
}

function confirm_settlement_received_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $settlementId = (int) ($body['settlement_id'] ?? 0);
    if ($settlementId <= 0) {
        json_out(['ok' => false, 'error' => 'settlement_id is required.'], 400);
    }

    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];
    if (normalize_trip_status($trip['status'] ?? 'active') !== 'settling') {
        json_out(['ok' => false, 'error' => 'Trip is not in settling mode.'], 409);
    }

    $settlementsTable = table_name('settlements');
    $tripsTable = table_name('trips');
    $usersTable = table_name('users');
    $pdo->beginTransaction();
    try {
        $rowStmt = $pdo->prepare(
            'SELECT
                s.id,
                s.trip_id,
                s.from_user_id,
                s.to_user_id,
                s.amount_cents,
                s.status,
                s.marked_sent_at,
                s.confirmed_at,
                uf.nickname AS from_nickname,
                ut.nickname AS to_nickname
             FROM ' . $settlementsTable . ' s
             JOIN ' . $usersTable . ' uf ON uf.id = s.from_user_id
             JOIN ' . $usersTable . ' ut ON ut.id = s.to_user_id
             WHERE s.id = :id AND s.trip_id = :trip_id
             LIMIT 1
             FOR UPDATE'
        );
        $rowStmt->execute([
            'id' => $settlementId,
            'trip_id' => $tripId,
        ]);
        $row = $rowStmt->fetch();
        if (!$row) {
            json_out(['ok' => false, 'error' => 'Settlement not found.'], 404);
        }

        $toUserId = (int) ($row['to_user_id'] ?? 0);
        if ($toUserId !== (int) $me['id']) {
            json_out(['ok' => false, 'error' => 'Only receiver can confirm transfer.'], 403);
        }

        $status = normalize_settlement_status($row['status'] ?? 'pending');
        if ($status === 'pending') {
            json_out(['ok' => false, 'error' => 'Payer has not marked this transfer as sent yet.'], 409);
        }

        $confirmedNow = false;
        if ($status === 'sent') {
            $update = $pdo->prepare(
                'UPDATE ' . $settlementsTable . '
                 SET status = "confirmed",
                     confirmed_by = :user_id,
                     confirmed_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $update->execute([
                'user_id' => (int) $me['id'],
                'id' => $settlementId,
            ]);
            $confirmedNow = true;
        }

        if ($confirmedNow) {
            $toName = trim((string) ($row['to_nickname'] ?? ''));
            if ($toName === '') {
                $toName = 'Trip member';
            }
            $amount = '€' . cents_to_decimal((int) ($row['amount_cents'] ?? 0));
            create_user_notification(
                $pdo,
                $tripId,
                (int) ($row['from_user_id'] ?? 0),
                'settlement_confirmed',
                'Transfer confirmed',
                $toName . ' confirmed receiving ' . $amount . ' from you.',
                [
                    'settlement_id' => $settlementId,
                    'from_user_id' => (int) ($row['from_user_id'] ?? 0),
                    'to_user_id' => (int) ($row['to_user_id'] ?? 0),
                    'amount_cents' => (int) ($row['amount_cents'] ?? 0),
                ]
            );
        }

        $remainingStmt = $pdo->prepare(
            'SELECT COUNT(*)
             FROM ' . $settlementsTable . '
             WHERE trip_id = :trip_id
               AND status <> "confirmed"'
        );
        $remainingStmt->execute(['trip_id' => $tripId]);
        $remaining = (int) ($remainingStmt->fetchColumn() ?: 0);
        if ($remaining === 0) {
            $archiveTrip = $pdo->prepare(
                'UPDATE ' . $tripsTable . '
                 SET status = "archived",
                     archived_at = COALESCE(archived_at, CURRENT_TIMESTAMP)
                 WHERE id = :trip_id
                   AND status <> "archived"'
            );
            $archiveTrip->execute(['trip_id' => $tripId]);
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $freshTrip = find_trip_for_user($pdo, (int) $me['id'], $tripId);
    if (is_array($freshTrip)) {
        $trip = normalize_trip_row($freshTrip);
    }

    $computed = compute_trip_balance_data($pdo, $tripId);
    $stored = load_trip_settlement_payload($pdo, $tripId, (int) $me['id'], $computed['stats']);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'settlements' => $stored['settlements'],
        'settlement_progress' => $stored['progress'],
        'updated_settlement_id' => $settlementId,
    ]);
}
