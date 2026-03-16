<?php
declare(strict_types=1);

function generate_order_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    assert_trip_is_active($trip);
    $tripId = (int) $trip['id'];
    $usersTable = table_name('users');
    $ordersTable = table_name('random_orders');
    $orderMembersTable = table_name('random_order_members');
    $drawStateTable = table_name('random_draw_state');

    $members = require_valid_trip_member_ids($pdo, $tripId, (array) ($body['members'] ?? []), true);
    if (count($members) < 2) {
        json_out(['ok' => false, 'error' => 'Pick at least 2 users.'], 400);
    }
    sort($members);
    $membersCsv = ids_to_csv($members);

    $pdo->beginTransaction();
    try {
        $stateStmt = $pdo->prepare(
            'SELECT trip_id, members_csv, remaining_csv, cycle_no, draw_no
             FROM ' . $drawStateTable . '
             WHERE trip_id = :trip_id
             FOR UPDATE'
        );
        $stateStmt->execute(['trip_id' => $tripId]);
        $state = $stateStmt->fetch();

        $cycleNo = 1;
        $drawNo = 0;
        $remaining = $members;
        if ($state) {
            $savedMembersCsv = (string) ($state['members_csv'] ?? '');
            $savedRemaining = ids_from_csv((string) ($state['remaining_csv'] ?? ''));
            $cycleNo = max(1, (int) ($state['cycle_no'] ?? 1));
            $drawNo = max(0, (int) ($state['draw_no'] ?? 0));

            if ($savedMembersCsv === $membersCsv) {
                if (count($savedRemaining) > 0) {
                    $remaining = $savedRemaining;
                } else {
                    $remaining = $members;
                    $cycleNo++;
                    $drawNo = 0;
                }
            } else {
                $remaining = $members;
                $cycleNo = 1;
                $drawNo = 0;
            }
        }

        if (count($remaining) < 1) {
            $remaining = $members;
            $cycleNo++;
            $drawNo = 0;
        }

        $pickIndex = random_int(0, count($remaining) - 1);
        $pickedUserId = (int) $remaining[$pickIndex];
        array_splice($remaining, $pickIndex, 1);
        $drawNo++;

        $remainingCsv = ids_to_csv($remaining);
        if ($state) {
            $updateState = $pdo->prepare(
                'UPDATE ' . $drawStateTable . '
                 SET members_csv = :members_csv,
                     remaining_csv = :remaining_csv,
                     cycle_no = :cycle_no,
                     draw_no = :draw_no
                 WHERE trip_id = :trip_id'
            );
            $updateState->execute([
                'members_csv' => $membersCsv,
                'remaining_csv' => $remainingCsv,
                'cycle_no' => $cycleNo,
                'draw_no' => $drawNo,
                'trip_id' => $tripId,
            ]);
        } else {
            $insertState = $pdo->prepare(
                'INSERT INTO ' . $drawStateTable . ' (trip_id, members_csv, remaining_csv, cycle_no, draw_no)
                 VALUES (:trip_id, :members_csv, :remaining_csv, :cycle_no, :draw_no)'
            );
            $insertState->execute([
                'trip_id' => $tripId,
                'members_csv' => $membersCsv,
                'remaining_csv' => $remainingCsv,
                'cycle_no' => $cycleNo,
                'draw_no' => $drawNo,
            ]);
        }

        $insertOrder = $pdo->prepare(
            'INSERT INTO ' . $ordersTable . ' (trip_id, created_by)
             VALUES (:trip_id, :created_by)'
        );
        $insertOrder->execute([
            'trip_id' => $tripId,
            'created_by' => (int) $me['id'],
        ]);
        $orderId = (int) $pdo->lastInsertId();

        $insertMember = $pdo->prepare(
            'INSERT INTO ' . $orderMembersTable . ' (order_id, user_id, position)
             VALUES (:order_id, :user_id, :position)'
        );
        $insertMember->execute([
            'order_id' => $orderId,
            'user_id' => $pickedUserId,
            'position' => 1,
        ]);

        $nameStmt = $pdo->prepare('SELECT nickname FROM ' . $usersTable . ' WHERE id = :id LIMIT 1');
        $nameStmt->execute(['id' => $pickedUserId]);
        $pickedNickname = (string) ($nameStmt->fetchColumn() ?: '');

        $pdo->commit();
        json_out([
            'ok' => true,
            'order_id' => $orderId,
            'trip_id' => $tripId,
            'picked_user_id' => $pickedUserId,
            'picked_user_nickname' => $pickedNickname,
            'members_ids' => $members,
            'remaining_ids' => array_values($remaining),
            'remaining_count' => count($remaining),
            'cycle_no' => $cycleNo,
            'draw_no' => $drawNo,
            'cycle_completed' => count($remaining) === 0,
        ]);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

function list_orders_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];
    $ordersTable = table_name('random_orders');
    $usersTable = table_name('users');
    $orderMembersTable = table_name('random_order_members');
    $ordersStmt = $pdo->prepare(
        'SELECT ro.id, ro.created_at, ro.created_by, u.nickname AS created_by_nickname
         FROM ' . $ordersTable . ' ro
         JOIN ' . $usersTable . ' u ON u.id = ro.created_by
         WHERE ro.trip_id = :trip_id
         ORDER BY ro.id DESC
         LIMIT 30'
    );
    $ordersStmt->execute(['trip_id' => $tripId]);
    $orders = $ordersStmt->fetchAll();

    if (!$orders) {
        json_out(['ok' => true, 'orders' => []]);
    }

    $orderIds = array_map(static fn(array $row): int => (int) $row['id'], $orders);
    $placeholders = implode(',', array_fill(0, count($orderIds), '?'));
    $stmt = $pdo->prepare(
        "SELECT rom.order_id, rom.position, u.nickname
         FROM $orderMembersTable rom
         JOIN $usersTable u ON u.id = rom.user_id
         WHERE rom.order_id IN ($placeholders)
         ORDER BY rom.order_id DESC, rom.position ASC"
    );
    $stmt->execute($orderIds);

    $membersByOrder = [];
    foreach ($stmt->fetchAll() as $row) {
        $orderId = (int) $row['order_id'];
        $membersByOrder[$orderId][] = [
            'pos' => (int) $row['position'],
            'nickname' => $row['nickname'],
        ];
    }

    foreach ($orders as &$order) {
        $id = (int) $order['id'];
        $order['id'] = $id;
        $order['created_by'] = (int) $order['created_by'];
        $order['members'] = $membersByOrder[$id] ?? [];
    }
    unset($order);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'orders' => $orders,
    ]);
}
