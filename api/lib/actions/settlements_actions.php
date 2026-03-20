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

function parse_request_bool($value, bool $fallback = false): bool
{
    if (is_bool($value)) {
        return $value;
    }
    if (is_numeric($value)) {
        return ((int) $value) === 1;
    }
    if (is_string($value)) {
        $normalized = strtolower(trim($value));
        if ($normalized === '1' || $normalized === 'true' || $normalized === 'yes' || $normalized === 'y') {
            return true;
        }
        if ($normalized === '0' || $normalized === 'false' || $normalized === 'no' || $normalized === 'n') {
            return false;
        }
    }
    return $fallback;
}

function load_trip_ready_to_settle_state(PDO $pdo, int $tripId, int $currentUserId): array
{
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $readyColumnsAvailable = trip_members_ready_columns_available($pdo);
    $readySelect = $readyColumnsAvailable
        ? 'tm.ready_to_settle, tm.ready_to_settle_at, '
        : '1 AS ready_to_settle, NULL AS ready_to_settle_at, ';

    $stmt = $pdo->prepare(
        'SELECT
            tm.user_id,
            ' . $readySelect . '
            u.nickname
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    $rows = $stmt->fetchAll();

    $members = [];
    $readyMembers = 0;
    $currentUserReady = false;
    foreach ($rows as $row) {
        $userId = (int) ($row['user_id'] ?? 0);
        $isReady = ((int) ($row['ready_to_settle'] ?? 0)) === 1;
        if ($isReady) {
            $readyMembers++;
        }
        if ($userId > 0 && $userId === $currentUserId) {
            $currentUserReady = $isReady;
        }
        $members[] = [
            'user_id' => $userId,
            'nickname' => (string) ($row['nickname'] ?? ''),
            'is_ready' => $isReady,
            'ready_at' => $row['ready_to_settle_at'] ?: null,
        ];
    }

    $membersTotal = count($members);
    return [
        'enabled' => $readyColumnsAvailable,
        'members_total' => $membersTotal,
        'ready_members' => $readyMembers,
        'all_ready' => $membersTotal > 0 && $readyMembers === $membersTotal,
        'current_user_ready' => $currentUserReady,
        'members' => $members,
    ];
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
    $readyToSettle = load_trip_ready_to_settle_state($pdo, $tripId, (int) ($me['id'] ?? 0));

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
        'ready_to_settle' => $readyToSettle,
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

    $readyToSettle = load_trip_ready_to_settle_state($pdo, $tripId, (int) ($me['id'] ?? 0));
    if (
        ($readyToSettle['enabled'] ?? false) === true
        && ($readyToSettle['all_ready'] ?? false) !== true
    ) {
        json_out([
            'ok' => false,
            'error' => 'All trip members must mark ready before starting settlements.',
            'ready_to_settle' => $readyToSettle,
        ], 409);
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
        'ready_to_settle' => load_trip_ready_to_settle_state($pdo, $tripId, (int) ($me['id'] ?? 0)),
    ]);
}

function set_ready_to_settle_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);

    if (!trip_members_ready_columns_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Ready-to-settle feature is not enabled on server yet. Run migration first.',
        ], 409);
    }

    if (normalize_trip_status($trip['status'] ?? 'active') !== 'active') {
        json_out(['ok' => false, 'error' => 'Trip is already closed.'], 409);
    }

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $isReady = parse_request_bool($body['is_ready'] ?? ($body['ready'] ?? true), true);
    $tripMembersTable = table_name('trip_members');
    $tripsTable = table_name('trips');
    $actorId = (int) ($me['id'] ?? 0);

    $pdo->beginTransaction();
    try {
        $memberUpdate = $pdo->prepare(
            'UPDATE ' . $tripMembersTable . '
             SET ready_to_settle = :ready_to_settle,
                 ready_to_settle_at = :ready_to_settle_at
             WHERE trip_id = :trip_id
               AND user_id = :user_id'
        );
        $memberUpdate->execute([
            'ready_to_settle' => $isReady ? 1 : 0,
            'ready_to_settle_at' => $isReady ? date('Y-m-d H:i:s') : null,
            'trip_id' => $tripId,
            'user_id' => $actorId,
        ]);
        if ($memberUpdate->rowCount() < 1) {
            json_out(['ok' => false, 'error' => 'Trip member not found.'], 404);
        }

        $touchTrip = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET updated_at = CURRENT_TIMESTAMP
             WHERE id = :trip_id'
        );
        $touchTrip->execute(['trip_id' => $tripId]);

        $readyToSettle = load_trip_ready_to_settle_state($pdo, $tripId, $actorId);
        $tripName = trim((string) ($trip['name'] ?? ''));
        if ($tripName === '') {
            $tripName = 'Trip';
        }

        if ($isReady) {
            $actorName = trim((string) ($me['nickname'] ?? ''));
            if ($actorName === '') {
                $actorName = trim((string) ($me['full_name'] ?? ''));
            }
            if ($actorName === '') {
                $actorName = 'Trip member';
            }

            foreach ($readyToSettle['members'] as $memberRow) {
                $targetUserId = (int) ($memberRow['user_id'] ?? 0);
                if ($targetUserId <= 0 || $targetUserId === $actorId) {
                    continue;
                }
                create_user_notification(
                    $pdo,
                    $tripId,
                    $targetUserId,
                    'member_ready_to_settle',
                    'Member marked ready',
                    $actorName . ' is ready to settle in "' . $tripName . '".',
                    [
                        'trip_id' => $tripId,
                        'user_id' => $actorId,
                        'is_ready' => true,
                    ]
                );
            }

            if (($readyToSettle['all_ready'] ?? false) === true) {
                foreach ($readyToSettle['members'] as $memberRow) {
                    $targetUserId = (int) ($memberRow['user_id'] ?? 0);
                    if ($targetUserId <= 0) {
                        continue;
                    }
                    create_user_notification(
                        $pdo,
                        $tripId,
                        $targetUserId,
                        'trip_ready_to_settle',
                        'All members are ready',
                        'All members marked ready in "' . $tripName . '". You can start settlements.',
                        [
                            'trip_id' => $tripId,
                            'all_ready' => true,
                        ]
                    );
                }
            }
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'ready_to_settle' => load_trip_ready_to_settle_state($pdo, $tripId, $actorId),
    ]);
}

function remind_settlement_action(): void
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

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

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

        $status = normalize_settlement_status($row['status'] ?? 'pending');
        if ($status === 'confirmed') {
            json_out(['ok' => false, 'error' => 'Settlement is already confirmed.'], 409);
        }

        $fromUserId = (int) ($row['from_user_id'] ?? 0);
        $toUserId = (int) ($row['to_user_id'] ?? 0);
        $actorId = (int) ($me['id'] ?? 0);

        $targetUserId = 0;
        $title = 'Settlement reminder';
        $message = '';
        $amount = '€' . cents_to_decimal((int) ($row['amount_cents'] ?? 0));

        $actorName = trim((string) ($me['nickname'] ?? ''));
        if ($actorName === '') {
            $actorName = trim((string) ($me['full_name'] ?? ''));
        }
        if ($actorName === '') {
            $actorName = 'Trip member';
        }

        if ($status === 'pending') {
            if ($actorId !== $toUserId) {
                json_out(['ok' => false, 'error' => 'Only receiver can send this reminder.'], 403);
            }
            $targetUserId = $fromUserId;
            $targetName = trim((string) ($row['from_nickname'] ?? ''));
            if ($targetName === '') {
                $targetName = 'payer';
            }
            $message = $actorName . ' reminded ' . $targetName . ' to mark ' . $amount . ' as sent.';
        } elseif ($status === 'sent') {
            if ($actorId !== $fromUserId) {
                json_out(['ok' => false, 'error' => 'Only payer can send this reminder.'], 403);
            }
            $targetUserId = $toUserId;
            $targetName = trim((string) ($row['to_nickname'] ?? ''));
            if ($targetName === '') {
                $targetName = 'receiver';
            }
            $message = $actorName . ' reminded ' . $targetName . ' to confirm receiving ' . $amount . '.';
        }

        if ($targetUserId <= 0 || $targetUserId === $actorId) {
            json_out(['ok' => false, 'error' => 'Reminder target is invalid.'], 409);
        }

        create_user_notification(
            $pdo,
            $tripId,
            $targetUserId,
            'settlement_reminder',
            $title,
            $message,
            [
                'settlement_id' => $settlementId,
                'from_user_id' => $fromUserId,
                'to_user_id' => $toUserId,
                'amount_cents' => (int) ($row['amount_cents'] ?? 0),
                'status' => $status,
                'reminded_by_user_id' => $actorId,
            ]
        );

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out([
        'ok' => true,
        'settlement_id' => $settlementId,
        'reminded' => true,
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
