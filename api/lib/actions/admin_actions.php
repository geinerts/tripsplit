<?php
declare(strict_types=1);

function admin_summary_action(): void
{
    require_admin();
    $pdo = db();
    $usersTable = table_name('users');
    $expensesTable = table_name('expenses');

    $usersTotal = (int) $pdo->query('SELECT COUNT(*) AS c FROM ' . $usersTable)->fetchColumn();
    $expenseTotals = $pdo->query(
        'SELECT COUNT(*) AS c, COALESCE(SUM(amount), 0) AS total
         FROM ' . $expensesTable
    )->fetch();

    $summary = [
        'users_total' => $usersTotal,
        'expenses_total' => (int) ($expenseTotals['c'] ?? 0),
        'amount_total' => (float) ($expenseTotals['total'] ?? 0),
    ];

    json_out(['ok' => true, 'summary' => $summary]);
}

function admin_users_action(): void
{
    require_admin();
    $pdo = db();
    $usersTable = table_name('users');
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');

    $rows = $pdo->query(
        'SELECT
            u.id,
            u.nickname,
            u.created_at,
            COUNT(e.id) AS expenses_count,
            COALESCE(SUM(e.amount), 0) AS total_paid,
            (
              SELECT COUNT(*)
              FROM ' . $participantsTable . ' ep
              WHERE ep.user_id = u.id
            ) AS participant_rows
         FROM ' . $usersTable . ' u
         LEFT JOIN ' . $expensesTable . ' e ON e.paid_by = u.id
         GROUP BY u.id, u.nickname, u.created_at
         ORDER BY total_paid DESC, u.created_at ASC'
    )->fetchAll();

    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $row['expenses_count'] = (int) $row['expenses_count'];
        $row['participant_rows'] = (int) $row['participant_rows'];
        $row['total_paid'] = (float) $row['total_paid'];
    }
    unset($row);

    json_out(['ok' => true, 'users' => $rows]);
}

function admin_user_detail_action(): void
{
    require_admin();
    $userId = (int) ($_GET['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $pdo = db();
    $usersTable = table_name('users');
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');

    $userStmt = $pdo->prepare('SELECT id, nickname, created_at FROM ' . $usersTable . ' WHERE id = :id LIMIT 1');
    $userStmt->execute(['id' => $userId]);
    $user = $userStmt->fetch();
    if (!$user) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    $totalsStmt = $pdo->prepare(
        'SELECT COUNT(*) AS expenses_count, COALESCE(SUM(amount), 0) AS total_paid
         FROM ' . $expensesTable . '
         WHERE paid_by = :user_id'
    );
    $totalsStmt->execute(['user_id' => $userId]);
    $totals = $totalsStmt->fetch() ?: ['expenses_count' => 0, 'total_paid' => 0];

    $participationStmt = $pdo->prepare(
        'SELECT COUNT(*) AS c
         FROM ' . $participantsTable . '
         WHERE user_id = :user_id'
    );
    $participationStmt->execute(['user_id' => $userId]);
    $participantRows = (int) $participationStmt->fetchColumn();

    $expensesStmt = $pdo->prepare(
        'SELECT
            e.id,
            e.amount,
            e.note,
            e.expense_date,
            e.created_at,
            e.receipt_path,
            (
              SELECT COUNT(*)
              FROM ' . $participantsTable . ' ep
              WHERE ep.expense_id = e.id
            ) AS participants_count
         FROM ' . $expensesTable . ' e
         WHERE e.paid_by = :user_id
         ORDER BY e.expense_date DESC, e.id DESC
         LIMIT 300'
    );
    $expensesStmt->execute(['user_id' => $userId]);
    $expenses = $expensesStmt->fetchAll();

    foreach ($expenses as &$expense) {
        $expense['id'] = (int) $expense['id'];
        $expense['amount'] = (float) $expense['amount'];
        $expense['participants_count'] = (int) $expense['participants_count'];
        $path = (string) ($expense['receipt_path'] ?? '');
        $expense['receipt_path'] = $path !== '' ? $path : null;
        $expense['receipt_url'] = $path !== '' ? receipt_public_url($path) : null;
    }
    unset($expense);

    $user['id'] = (int) $user['id'];
    $user['expenses_count'] = (int) ($totals['expenses_count'] ?? 0);
    $user['total_paid'] = (float) ($totals['total_paid'] ?? 0);
    $user['participant_rows'] = $participantRows;

    json_out([
        'ok' => true,
        'user' => $user,
        'expenses' => $expenses,
    ]);
}

function admin_delete_expense_action(): void
{
    require_post();
    require_admin();
    $body = read_json();
    $expenseId = (int) ($body['expense_id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }

    $pdo = db();
    $expensesTable = table_name('expenses');
    $usersTable = table_name('users');

    $stmt = $pdo->prepare(
        'SELECT e.id, e.note, e.receipt_path, e.paid_by, u.nickname AS paid_by_nickname
         FROM ' . $expensesTable . ' e
         JOIN ' . $usersTable . ' u ON u.id = e.paid_by
         WHERE e.id = :id
         LIMIT 1'
    );
    $stmt->execute(['id' => $expenseId]);
    $expense = $stmt->fetch();
    if (!$expense) {
        json_out(['ok' => false, 'error' => 'Expense not found.'], 404);
    }

    $delete = $pdo->prepare('DELETE FROM ' . $expensesTable . ' WHERE id = :id');
    $delete->execute(['id' => $expenseId]);

    delete_receipt_file((string) ($expense['receipt_path'] ?? ''));
    json_out([
        'ok' => true,
        'deleted' => [
            'id' => (int) $expense['id'],
            'paid_by' => (int) $expense['paid_by'],
            'paid_by_nickname' => $expense['paid_by_nickname'],
            'note' => (string) ($expense['note'] ?? ''),
        ],
    ]);
}

function admin_update_user_action(): void
{
    require_post();
    require_admin();
    $body = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $nickname = validate_nickname((string) ($body['nickname'] ?? ''));
    $pdo = db();
    $usersTable = table_name('users');

    $stmt = $pdo->prepare('UPDATE ' . $usersTable . ' SET nickname = :nickname WHERE id = :id');
    $stmt->execute([
        'nickname' => $nickname,
        'id' => $userId,
    ]);
    if ($stmt->rowCount() === 0) {
        json_out(['ok' => false, 'error' => 'User not found or unchanged.'], 404);
    }

    $fetch = $pdo->prepare('SELECT id, nickname, created_at FROM ' . $usersTable . ' WHERE id = :id LIMIT 1');
    $fetch->execute(['id' => $userId]);
    $user = $fetch->fetch();

    json_out(['ok' => true, 'user' => $user]);
}

function admin_delete_user_action(): void
{
    require_post();
    require_admin();
    $body = read_json();
    $userId = (int) ($body['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $pdo = db();
    $usersTable = table_name('users');
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');
    $ordersTable = table_name('random_orders');
    $orderMembersTable = table_name('random_order_members');

    $userStmt = $pdo->prepare('SELECT id, nickname FROM ' . $usersTable . ' WHERE id = :id LIMIT 1');
    $userStmt->execute(['id' => $userId]);
    $user = $userStmt->fetch();
    if (!$user) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    $receiptStmt = $pdo->prepare(
        'SELECT receipt_path
         FROM ' . $expensesTable . '
         WHERE paid_by = :user_id AND receipt_path IS NOT NULL AND receipt_path <> ""'
    );
    $receiptStmt->execute(['user_id' => $userId]);
    $receiptPaths = array_map(
        static fn(array $row): string => (string) ($row['receipt_path'] ?? ''),
        $receiptStmt->fetchAll()
    );

    $pdo->beginTransaction();
    try {
        $deleteOrderMembers = $pdo->prepare('DELETE FROM ' . $orderMembersTable . ' WHERE user_id = :user_id');
        $deleteOrderMembers->execute(['user_id' => $userId]);

        $deleteOrders = $pdo->prepare('DELETE FROM ' . $ordersTable . ' WHERE created_by = :user_id');
        $deleteOrders->execute(['user_id' => $userId]);

        $deleteParticipantRows = $pdo->prepare('DELETE FROM ' . $participantsTable . ' WHERE user_id = :user_id');
        $deleteParticipantRows->execute(['user_id' => $userId]);

        $clearTripCreator = $pdo->prepare('UPDATE ' . $tripsTable . ' SET created_by = NULL WHERE created_by = :user_id');
        $clearTripCreator->execute(['user_id' => $userId]);

        $deleteTripMembers = $pdo->prepare('DELETE FROM ' . $tripMembersTable . ' WHERE user_id = :user_id');
        $deleteTripMembers->execute(['user_id' => $userId]);

        $deleteExpenses = $pdo->prepare('DELETE FROM ' . $expensesTable . ' WHERE paid_by = :user_id');
        $deleteExpenses->execute(['user_id' => $userId]);

        $deleteUser = $pdo->prepare('DELETE FROM ' . $usersTable . ' WHERE id = :id');
        $deleteUser->execute(['id' => $userId]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    foreach ($receiptPaths as $path) {
        delete_receipt_file($path);
    }

    json_out([
        'ok' => true,
        'deleted' => [
            'id' => (int) $user['id'],
            'nickname' => $user['nickname'],
        ],
    ]);
}
