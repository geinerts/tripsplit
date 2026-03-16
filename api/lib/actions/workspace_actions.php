<?php
declare(strict_types=1);

function workspace_parse_since_cursor(): int
{
    $raw = trim((string) ($_GET['since'] ?? ''));
    if ($raw === '') {
        return 0;
    }
    $since = (int) $raw;
    if ($since < 0) {
        return 0;
    }
    return $since;
}

function workspace_timestamp_to_epoch($raw): int
{
    if (!is_scalar($raw)) {
        return 0;
    }
    $value = trim((string) $raw);
    if ($value === '') {
        return 0;
    }
    $ts = strtotime($value);
    if ($ts === false || $ts < 0) {
        return 0;
    }
    return (int) $ts;
}

function workspace_sync_cursor_for_trip(PDO $pdo, int $tripId, int $userId): int
{
    $cursor = 0;
    $tripsTable = table_name('trips');
    $expensesTable = table_name('expenses');
    $settlementsTable = table_name('settlements');
    $tripMembersTable = table_name('trip_members');
    $ordersTable = table_name('random_orders');
    $notificationsTable = table_name('notifications');

    $tripStmt = $pdo->prepare(
        'SELECT
            GREATEST(
                COALESCE(updated_at, created_at),
                COALESCE(ended_at, "1970-01-01 00:00:00"),
                COALESCE(archived_at, "1970-01-01 00:00:00")
            ) AS changed_at
         FROM ' . $tripsTable . '
         WHERE id = :trip_id
         LIMIT 1'
    );
    $tripStmt->execute(['trip_id' => $tripId]);
    $cursor = max($cursor, workspace_timestamp_to_epoch($tripStmt->fetchColumn()));

    $sources = [
        [
            'sql' => 'SELECT MAX(updated_at) FROM ' . $expensesTable . ' WHERE trip_id = :trip_id',
            'params' => ['trip_id' => $tripId],
        ],
        [
            'sql' => 'SELECT MAX(updated_at) FROM ' . $settlementsTable . ' WHERE trip_id = :trip_id',
            'params' => ['trip_id' => $tripId],
        ],
        [
            'sql' => 'SELECT MAX(joined_at) FROM ' . $tripMembersTable . ' WHERE trip_id = :trip_id',
            'params' => ['trip_id' => $tripId],
        ],
        [
            'sql' => 'SELECT MAX(created_at) FROM ' . $ordersTable . ' WHERE trip_id = :trip_id',
            'params' => ['trip_id' => $tripId],
        ],
        [
            'sql' =>
                'SELECT MAX(GREATEST(created_at, COALESCE(read_at, created_at)))
                 FROM ' . $notificationsTable . '
                 WHERE trip_id = :trip_id
                   AND user_id = :user_id',
            'params' => [
                'trip_id' => $tripId,
                'user_id' => $userId,
            ],
        ],
    ];

    foreach ($sources as $source) {
        $stmt = $pdo->prepare((string) $source['sql']);
        $stmt->execute((array) $source['params']);
        $cursor = max($cursor, workspace_timestamp_to_epoch($stmt->fetchColumn()));
    }

    if ($cursor <= 0) {
        $cursor = time();
    }
    return $cursor;
}

function workspace_load_trip_users(PDO $pdo, int $tripId): array
{
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';

    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $nameSelect . 'u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int) ($row['id'] ?? 0);
        $firstName = normalize_me_name_value($row['first_name'] ?? null);
        $lastName = normalize_me_name_value($row['last_name'] ?? null);
        $displayName = combine_full_name($firstName, $lastName);
        $row['first_name'] = $firstName;
        $row['last_name'] = $lastName;
        $row['display_name'] = $displayName !== null
            ? $displayName
            : trim((string) ($row['nickname'] ?? ''));
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path']);
    }
    unset($row);

    return $rows;
}

function workspace_load_trip_expenses(PDO $pdo, int $tripId, int $limit = 300): array
{
    $expensesTable = table_name('expenses');
    $usersTable = table_name('users');
    $participantsTable = table_name('expense_participants');
    $limit = pagination_limit($limit, 300, 500);

    $stmt = $pdo->prepare(
        'SELECT
            e.id,
            e.amount,
            e.category,
            e.note,
            e.split_mode,
            e.expense_date,
            e.created_at,
            e.receipt_path,
            e.paid_by AS paid_by_id,
            u.nickname AS paid_by_nickname
         FROM ' . $expensesTable . ' e
         JOIN ' . $usersTable . ' u ON u.id = e.paid_by
         WHERE e.trip_id = :trip_id
         ORDER BY e.expense_date DESC, e.id DESC
         LIMIT ' . $limit
    );
    $stmt->execute(['trip_id' => $tripId]);
    $rows = $stmt->fetchAll();

    $expenseIds = array_map(static fn(array $row): int => (int) $row['id'], $rows);
    $participantsByExpense = [];
    if ($expenseIds) {
        $placeholders = implode(',', array_fill(0, count($expenseIds), '?'));
        $partsStmt = $pdo->prepare(
            'SELECT ep.expense_id, ep.user_id, ep.owed_cents, ep.split_value, u.id, u.nickname
             FROM ' . $participantsTable . ' ep
             JOIN ' . $usersTable . ' u ON u.id = ep.user_id
             WHERE ep.expense_id IN (' . $placeholders . ')
             ORDER BY ep.expense_id DESC, u.created_at ASC, u.id ASC'
        );
        $partsStmt->execute($expenseIds);
        foreach ($partsStmt->fetchAll() as $participant) {
            $expenseId = (int) ($participant['expense_id'] ?? 0);
            $participantsByExpense[$expenseId][] = [
                'id' => (int) ($participant['id'] ?? 0),
                'nickname' => (string) ($participant['nickname'] ?? ''),
                'owed_cents' => (int) ($participant['owed_cents'] ?? 0),
                'split_value' => (int) ($participant['split_value'] ?? 0),
            ];
        }
    }

    foreach ($rows as &$row) {
        $id = (int) ($row['id'] ?? 0);
        $amountCents = decimal_to_cents($row['amount'] ?? 0);
        $splitMode = normalize_expense_split_mode($row['split_mode'] ?? 'equal');
        $participantRows = $participantsByExpense[$id] ?? [];
        $storedOwedTotal = 0;
        foreach ($participantRows as $participantRow) {
            $storedOwedTotal += (int) ($participantRow['owed_cents'] ?? 0);
        }
        $hasStoredOwed = count($participantRows) > 0 && $storedOwedTotal === $amountCents;
        $receiptPath = trim((string) ($row['receipt_path'] ?? ''));

        $row['id'] = $id;
        $row['paid_by_id'] = (int) ($row['paid_by_id'] ?? 0);
        $row['amount'] = cents_to_float($amountCents);
        $rowCategory = trim((string) ($row['category'] ?? ''));
        $row['category'] = $rowCategory !== '' ? $rowCategory : 'other';
        $row['split_mode'] = $splitMode;
        $row['receipt_path'] = $receiptPath !== '' ? $receiptPath : null;
        $row['receipt_url'] = $receiptPath !== '' ? receipt_public_url($receiptPath) : null;
        $row['receipt_thumb_url'] = $receiptPath !== '' ? receipt_thumb_public_url($receiptPath) : null;

        $count = count($participantRows);
        $base = $count > 0 ? intdiv($amountCents, $count) : 0;
        $remainder = $count > 0 ? ($amountCents % $count) : 0;

        $participants = [];
        foreach ($participantRows as $index => $participantRow) {
            $storedOwedCents = (int) ($participantRow['owed_cents'] ?? 0);
            $owedCents = $hasStoredOwed
                ? $storedOwedCents
                : ($base + ($index < $remainder ? 1 : 0));

            $splitValue = null;
            $rawSplitValue = (int) ($participantRow['split_value'] ?? 0);
            if ($splitMode === 'exact') {
                $splitValue = cents_to_float($rawSplitValue);
            } elseif ($splitMode === 'percent') {
                $splitValue = $rawSplitValue / 100;
            } elseif ($splitMode === 'shares') {
                $splitValue = $rawSplitValue;
            }

            $participants[] = [
                'id' => (int) ($participantRow['id'] ?? 0),
                'nickname' => (string) ($participantRow['nickname'] ?? ''),
                'owed' => cents_to_float($owedCents),
                'split_value' => $splitValue,
            ];
        }

        $row['participants'] = $participants;
    }
    unset($row);

    return $rows;
}

function workspace_load_trip_orders(PDO $pdo, int $tripId, int $limit = 30): array
{
    $ordersTable = table_name('random_orders');
    $usersTable = table_name('users');
    $orderMembersTable = table_name('random_order_members');
    $limit = pagination_limit($limit, 30, 100);

    $ordersStmt = $pdo->prepare(
        'SELECT ro.id, ro.created_at, ro.created_by, u.nickname AS created_by_nickname
         FROM ' . $ordersTable . ' ro
         JOIN ' . $usersTable . ' u ON u.id = ro.created_by
         WHERE ro.trip_id = :trip_id
         ORDER BY ro.id DESC
         LIMIT ' . $limit
    );
    $ordersStmt->execute(['trip_id' => $tripId]);
    $orders = $ordersStmt->fetchAll();
    if (!$orders) {
        return [];
    }

    $orderIds = array_map(static fn(array $row): int => (int) ($row['id'] ?? 0), $orders);
    $placeholders = implode(',', array_fill(0, count($orderIds), '?'));
    $stmt = $pdo->prepare(
        'SELECT rom.order_id, rom.position, u.nickname
         FROM ' . $orderMembersTable . ' rom
         JOIN ' . $usersTable . ' u ON u.id = rom.user_id
         WHERE rom.order_id IN (' . $placeholders . ')
         ORDER BY rom.order_id DESC, rom.position ASC'
    );
    $stmt->execute($orderIds);

    $membersByOrder = [];
    foreach ($stmt->fetchAll() as $row) {
        $orderId = (int) ($row['order_id'] ?? 0);
        $membersByOrder[$orderId][] = [
            'pos' => (int) ($row['position'] ?? 0),
            'nickname' => (string) ($row['nickname'] ?? ''),
        ];
    }

    foreach ($orders as &$order) {
        $id = (int) ($order['id'] ?? 0);
        $order['id'] = $id;
        $order['created_by'] = (int) ($order['created_by'] ?? 0);
        $order['members'] = $membersByOrder[$id] ?? [];
    }
    unset($order);

    return $orders;
}

function workspace_load_trip_notifications(
    PDO $pdo,
    int $tripId,
    int $userId,
    int $limit = 50
): array {
    $notificationsTable = table_name('notifications');
    $limit = pagination_limit($limit, 50, 200);

    $rowsStmt = $pdo->prepare(
        'SELECT id, trip_id, user_id, type, title, body, payload_json, is_read, read_at, created_at
         FROM ' . $notificationsTable . '
         WHERE user_id = :user_id
           AND trip_id = :trip_id
         ORDER BY id DESC
         LIMIT ' . $limit
    );
    $rowsStmt->execute([
        'user_id' => $userId,
        'trip_id' => $tripId,
    ]);
    $rows = $rowsStmt->fetchAll();

    $unreadStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $notificationsTable . '
         WHERE user_id = :user_id
           AND trip_id = :trip_id
           AND is_read = 0'
    );
    $unreadStmt->execute([
        'user_id' => $userId,
        'trip_id' => $tripId,
    ]);
    $unreadCount = (int) ($unreadStmt->fetchColumn() ?: 0);

    $notifications = [];
    foreach ($rows as $row) {
        $payload = null;
        $rawPayload = trim((string) ($row['payload_json'] ?? ''));
        if ($rawPayload !== '') {
            $decoded = json_decode($rawPayload, true);
            if (is_array($decoded)) {
                $payload = $decoded;
            }
        }
        $notifications[] = [
            'id' => (int) ($row['id'] ?? 0),
            'trip_id' => (int) ($row['trip_id'] ?? 0),
            'type' => (string) ($row['type'] ?? 'info'),
            'title' => (string) ($row['title'] ?? ''),
            'body' => (string) ($row['body'] ?? ''),
            'payload' => $payload,
            'is_read' => ((int) ($row['is_read'] ?? 0)) === 1,
            'read_at' => $row['read_at'] ?? null,
            'created_at' => $row['created_at'] ?? null,
        ];
    }

    return [
        'unread_count' => $unreadCount < 0 ? 0 : $unreadCount,
        'notifications' => $notifications,
    ];
}

function workspace_snapshot_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'No trip found.'], 400);
    }

    $userId = (int) ($me['id'] ?? 0);
    $serverCursor = workspace_sync_cursor_for_trip($pdo, $tripId, $userId);
    $since = workspace_parse_since_cursor();
    if ($since > 0 && $since >= $serverCursor) {
        json_out([
            'ok' => true,
            'trip' => build_trip_payload($trip),
            'sync' => [
                'changed' => false,
                'since' => $since,
                'cursor' => $serverCursor,
            ],
        ]);
    }

    $status = normalize_trip_status($trip['status'] ?? 'active');
    $computed = compute_trip_balance_data($pdo, $tripId);
    $stats = is_array($computed['stats'] ?? null) ? $computed['stats'] : [];
    $balances = is_array($computed['balances'] ?? null) ? $computed['balances'] : [];

    if ($status === 'active') {
        $settlements = array_map(
            static fn(array $item): array => [
                'id' => null,
                'from_user_id' => (int) ($item['from_user_id'] ?? 0),
                'to_user_id' => (int) ($item['to_user_id'] ?? 0),
                'from' => (string) ($item['from'] ?? ''),
                'to' => (string) ($item['to'] ?? ''),
                'amount' => (float) ($item['amount'] ?? 0),
                'status' => 'suggested',
                'marked_sent_at' => null,
                'confirmed_at' => null,
                'can_mark_sent' => false,
                'can_confirm_received' => false,
                'is_confirmed' => false,
            ],
            is_array($computed['recommended_settlements'] ?? null)
                ? $computed['recommended_settlements']
                : []
        );
        $progress = [
            'total' => count($settlements),
            'confirmed' => 0,
            'remaining' => count($settlements),
            'all_settled' => false,
        ];
    } else {
        $stored = load_trip_settlement_payload($pdo, $tripId, $userId, $stats);
        $settlements = is_array($stored['settlements'] ?? null)
            ? $stored['settlements']
            : [];
        $progress = is_array($stored['progress'] ?? null)
            ? $stored['progress']
            : [
                'total' => count($settlements),
                'confirmed' => 0,
                'remaining' => count($settlements),
                'all_settled' => false,
            ];
    }

    $users = workspace_load_trip_users($pdo, $tripId);
    $expenses = workspace_load_trip_expenses($pdo, $tripId, 300);
    $orders = workspace_load_trip_orders($pdo, $tripId, 30);
    $tripNotifications = workspace_load_trip_notifications($pdo, $tripId, $userId, 50);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'sync' => [
            'changed' => true,
            'since' => $since,
            'cursor' => $serverCursor,
        ],
        'users' => $users,
        'balances' => $balances,
        'settlements' => $settlements,
        'settlement_progress' => $progress,
        'all_settled' => (bool) ($progress['all_settled'] ?? false),
        'expenses' => $expenses,
        'orders' => $orders,
        'notifications' => $tripNotifications['notifications'],
        'unread_count' => (int) ($tripNotifications['unread_count'] ?? 0),
    ]);
}
