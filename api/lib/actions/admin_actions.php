<?php
declare(strict_types=1);

function normalize_admin_feedback_status_filter(string $raw): string
{
    $status = strtolower(trim($raw));
    if ($status === '') {
        return 'all';
    }
    if ($status === 'all' || $status === 'open' || $status === 'archived') {
        return $status;
    }
    json_out(['ok' => false, 'error' => 'Invalid status filter.'], 400);
}

function admin_feedback_actor(): string
{
    return normalize_feedback_history_actor((string) ($_SERVER['HTTP_X_ADMIN_ACTOR'] ?? ''), 'admin');
}

function admin_feedback_comment_from_body(array $body, bool $required): string
{
    $comment = trim((string) ($body['comment'] ?? ''));
    if ($required && $comment === '') {
        json_out(['ok' => false, 'error' => 'Comment is required.'], 400);
    }
    if (str_length($comment) > 500) {
        json_out(['ok' => false, 'error' => 'Comment is too long (max 500 chars).'], 400);
    }
    return $comment;
}

function admin_feedback_feed_action(): void
{
    require_admin();
    $pdo = db();
    $feedbackTable = table_name('feedback');
    $usersTable = table_name('users');
    $tripsTable = table_name('trips');

    $limit = (int) ($_GET['limit'] ?? 40);
    if ($limit < 1) {
        $limit = 40;
    }
    if ($limit > 120) {
        $limit = 120;
    }

    $offset = (int) ($_GET['offset'] ?? 0);
    if ($offset < 0) {
        $offset = 0;
    }

    $type = strtolower(trim((string) ($_GET['type'] ?? 'all')));
    if ($type !== 'all' && $type !== 'bug' && $type !== 'suggestion') {
        json_out(['ok' => false, 'error' => 'Invalid type filter.'], 400);
    }
    $statusFilter = normalize_admin_feedback_status_filter((string) ($_GET['status'] ?? 'all'));

    $hasScreenshot = strtolower(trim((string) ($_GET['has_screenshot'] ?? 'all')));
    if ($hasScreenshot !== 'all' && $hasScreenshot !== 'yes' && $hasScreenshot !== 'no') {
        json_out(['ok' => false, 'error' => 'Invalid screenshot filter.'], 400);
    }

    $query = trim((string) ($_GET['q'] ?? ''));
    if (str_length($query) > 100) {
        json_out(['ok' => false, 'error' => 'Search query is too long.'], 400);
    }

    $where = ['1=1'];
    $params = [];
    if ($type !== 'all') {
        $where[] = 'f.type = :type';
        $params['type'] = $type;
    }
    if ($statusFilter !== 'all') {
        $where[] = 'f.status = :status_filter';
        $params['status_filter'] = $statusFilter;
    }
    if ($hasScreenshot === 'yes') {
        $where[] = 'f.screenshot_path IS NOT NULL AND f.screenshot_path <> ""';
    } elseif ($hasScreenshot === 'no') {
        $where[] = '(f.screenshot_path IS NULL OR f.screenshot_path = "")';
    }
    if ($query !== '') {
        $where[] = '(
            u.nickname LIKE :query
            OR u.email LIKE :query
            OR u.first_name LIKE :query
            OR u.last_name LIKE :query
            OR f.note LIKE :query
            OR t.name LIKE :query
        )';
        $params['query'] = '%' . $query . '%';
    }

    $whereSql = implode(' AND ', $where);

    $countStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $feedbackTable . ' f
         JOIN ' . $usersTable . ' u ON u.id = f.user_id
         LEFT JOIN ' . $tripsTable . ' t ON t.id = f.trip_id
         WHERE ' . $whereSql
    );
    foreach ($params as $key => $value) {
        $countStmt->bindValue(':' . $key, $value, PDO::PARAM_STR);
    }
    $countStmt->execute();
    $total = (int) ($countStmt->fetchColumn() ?: 0);

    $listStmt = $pdo->prepare(
        'SELECT
            f.id,
            f.user_id,
            f.trip_id,
            f.type,
            f.note,
            f.status,
            f.archived_at,
            f.archived_comment,
            f.updated_at,
            f.screenshot_path,
            f.screenshot_size,
            f.app_platform,
            f.app_version,
            f.build_number,
            f.locale,
            f.context_json,
            f.created_at,
            u.nickname AS user_nickname,
            u.first_name AS user_first_name,
            u.last_name AS user_last_name,
            u.email AS user_email,
            t.name AS trip_name
         FROM ' . $feedbackTable . ' f
         JOIN ' . $usersTable . ' u ON u.id = f.user_id
         LEFT JOIN ' . $tripsTable . ' t ON t.id = f.trip_id
         WHERE ' . $whereSql . '
         ORDER BY f.id DESC
         LIMIT :limit OFFSET :offset'
    );
    foreach ($params as $key => $value) {
        $listStmt->bindValue(':' . $key, $value, PDO::PARAM_STR);
    }
    $listStmt->bindValue(':limit', $limit, PDO::PARAM_INT);
    $listStmt->bindValue(':offset', $offset, PDO::PARAM_INT);
    $listStmt->execute();
    $rows = $listStmt->fetchAll();
    $feedbackIds = array_map(
        static fn(array $row): int => (int) ($row['id'] ?? 0),
        $rows
    );
    $historyByFeedbackId = load_feedback_history_map($pdo, $feedbackIds);

    $items = [];
    foreach ($rows as $row) {
        $screenshotPath = trim((string) ($row['screenshot_path'] ?? ''));
        $fullName = trim(
            trim((string) ($row['user_first_name'] ?? '')) . ' ' .
            trim((string) ($row['user_last_name'] ?? ''))
        );
        $context = null;
        $rawContext = trim((string) ($row['context_json'] ?? ''));
        if ($rawContext !== '') {
            $decoded = json_decode($rawContext, true);
            if (is_array($decoded)) {
                $context = $decoded;
            }
        }
        $feedbackId = (int) ($row['id'] ?? 0);
        $history = $historyByFeedbackId[$feedbackId] ?? [];
        if (count($history) === 0) {
            $history[] = [
                'action' => 'created',
                'from_status' => null,
                'to_status' => 'open',
                'comment' => null,
                'actor' => 'system',
                'created_at' => $row['created_at'] ?: null,
            ];
            if ((string) ($row['status'] ?? '') === 'archived') {
                $history[] = [
                    'action' => 'archived',
                    'from_status' => 'open',
                    'to_status' => 'archived',
                    'comment' => ($row['archived_comment'] ?? null) !== null
                        ? (string) $row['archived_comment']
                        : null,
                    'actor' => 'admin',
                    'created_at' => ($row['archived_at'] ?? null) !== null
                        ? (string) $row['archived_at']
                        : null,
                ];
            }
        }

        $items[] = [
            'id' => $feedbackId,
            'type' => (string) ($row['type'] ?? 'bug'),
            'note' => (string) ($row['note'] ?? ''),
            'created_at' => $row['created_at'] ?: null,
            'updated_at' => $row['updated_at'] ?: null,
            'user' => [
                'id' => (int) ($row['user_id'] ?? 0),
                'nickname' => (string) ($row['user_nickname'] ?? ''),
                'full_name' => $fullName,
                'email' => (string) ($row['user_email'] ?? ''),
            ],
            'trip' => [
                'id' => array_key_exists('trip_id', $row) && $row['trip_id'] !== null
                    ? (int) $row['trip_id']
                    : null,
                'name' => (string) ($row['trip_name'] ?? ''),
            ],
            'app' => [
                'platform' => (string) ($row['app_platform'] ?? ''),
                'version' => (string) ($row['app_version'] ?? ''),
                'build_number' => (string) ($row['build_number'] ?? ''),
                'locale' => (string) ($row['locale'] ?? ''),
            ],
            'status' => [
                'current' => (string) ($row['status'] ?? 'open'),
                'archived_at' => ($row['archived_at'] ?? null) !== null ? (string) $row['archived_at'] : null,
                'archived_comment' => ($row['archived_comment'] ?? null) !== null ? (string) $row['archived_comment'] : null,
            ],
            'screenshot' => $screenshotPath !== '' ? [
                'path' => $screenshotPath,
                'size' => (int) ($row['screenshot_size'] ?? 0),
                'url' => feedback_public_url($screenshotPath),
                'thumb_url' => feedback_thumb_public_url($screenshotPath),
            ] : null,
            'context' => $context,
            'history' => $history,
        ];
    }

    $statsRow = $pdo->query(
        'SELECT
            COUNT(*) AS total_count,
            SUM(CASE WHEN type = "bug" THEN 1 ELSE 0 END) AS bug_count,
            SUM(CASE WHEN type = "suggestion" THEN 1 ELSE 0 END) AS suggestion_count,
            SUM(CASE WHEN status = "open" THEN 1 ELSE 0 END) AS open_count,
            SUM(CASE WHEN status = "archived" THEN 1 ELSE 0 END) AS archived_count,
            SUM(CASE WHEN screenshot_path IS NOT NULL AND screenshot_path <> "" THEN 1 ELSE 0 END) AS with_screenshot_count
         FROM ' . $feedbackTable
    )->fetch() ?: [];

    json_out([
        'ok' => true,
        'stats' => [
            'total' => (int) ($statsRow['total_count'] ?? 0),
            'bug' => (int) ($statsRow['bug_count'] ?? 0),
            'suggestion' => (int) ($statsRow['suggestion_count'] ?? 0),
            'open' => (int) ($statsRow['open_count'] ?? 0),
            'archived' => (int) ($statsRow['archived_count'] ?? 0),
            'with_screenshot' => (int) ($statsRow['with_screenshot_count'] ?? 0),
        ],
        'paging' => [
            'offset' => $offset,
            'limit' => $limit,
            'total' => $total,
            'has_more' => ($offset + count($items)) < $total,
            'next_offset' => ($offset + count($items)) < $total ? ($offset + count($items)) : null,
        ],
        'filters' => [
            'type' => $type,
            'status' => $statusFilter,
            'has_screenshot' => $hasScreenshot,
            'q' => $query,
        ],
        'items' => $items,
    ]);
}

function admin_archive_feedback_action(): void
{
    require_post();
    require_admin();
    $body = read_json();
    $feedbackId = (int) ($body['feedback_id'] ?? 0);
    if ($feedbackId <= 0) {
        json_out(['ok' => false, 'error' => 'feedback_id is required.'], 400);
    }

    $comment = admin_feedback_comment_from_body($body, true);
    ensure_text_has_no_links($comment, 'Comment');
    $actor = admin_feedback_actor();

    $pdo = db();
    $feedbackTable = table_name('feedback');

    $select = $pdo->prepare(
        'SELECT id, status
         FROM ' . $feedbackTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $select->execute(['id' => $feedbackId]);
    $feedback = $select->fetch();
    if (!$feedback) {
        json_out(['ok' => false, 'error' => 'Report not found.'], 404);
    }

    $currentStatus = (string) ($feedback['status'] ?? 'open');
    if ($currentStatus === 'archived') {
        json_out(['ok' => false, 'error' => 'Report is already archived.'], 409);
    }

    $update = $pdo->prepare(
        'UPDATE ' . $feedbackTable . '
         SET status = "archived",
             archived_at = CURRENT_TIMESTAMP,
             archived_comment = :archived_comment,
             archived_by_admin = :archived_by_admin
         WHERE id = :id
           AND status <> "archived"'
    );
    $update->execute([
        'archived_comment' => $comment,
        'archived_by_admin' => $actor,
        'id' => $feedbackId,
    ]);
    if ((int) $update->rowCount() < 1) {
        json_out(['ok' => false, 'error' => 'Report could not be archived.'], 409);
    }

    append_feedback_history_event(
        $pdo,
        $feedbackId,
        'archived',
        $currentStatus,
        'archived',
        $comment,
        $actor
    );

    json_out([
        'ok' => true,
        'feedback_id' => $feedbackId,
        'status' => 'archived',
        'archived_comment' => $comment,
    ]);
}

function admin_delete_feedback_action(): void
{
    require_post();
    require_admin();
    $body = read_json();
    $feedbackId = (int) ($body['feedback_id'] ?? 0);
    if ($feedbackId <= 0) {
        json_out(['ok' => false, 'error' => 'feedback_id is required.'], 400);
    }

    $comment = admin_feedback_comment_from_body($body, false);
    if ($comment !== '') {
        ensure_text_has_no_links($comment, 'Comment');
    }
    $actor = admin_feedback_actor();

    $pdo = db();
    $feedbackTable = table_name('feedback');

    $select = $pdo->prepare(
        'SELECT id, status, screenshot_path
         FROM ' . $feedbackTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $select->execute(['id' => $feedbackId]);
    $feedback = $select->fetch();
    if (!$feedback) {
        json_out(['ok' => false, 'error' => 'Report not found.'], 404);
    }

    $screenshotPath = trim((string) ($feedback['screenshot_path'] ?? ''));
    $status = (string) ($feedback['status'] ?? 'open');

    $pdo->beginTransaction();
    try {
        append_feedback_history_event(
            $pdo,
            $feedbackId,
            'deleted',
            $status,
            null,
            $comment !== '' ? $comment : null,
            $actor
        );

        $delete = $pdo->prepare('DELETE FROM ' . $feedbackTable . ' WHERE id = :id');
        $delete->execute(['id' => $feedbackId]);
        if ((int) $delete->rowCount() < 1) {
            throw new RuntimeException('Report could not be deleted.');
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($screenshotPath !== '') {
        delete_feedback_file($screenshotPath);
    }

    json_out([
        'ok' => true,
        'deleted' => [
            'id' => $feedbackId,
        ],
    ]);
}

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
