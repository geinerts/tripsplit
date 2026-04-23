<?php
declare(strict_types=1);

// ---------------------------------------------------------------------------
// Allowed emoji for expense reactions (preset whitelist).
// ---------------------------------------------------------------------------
const ALLOWED_EXPENSE_REACTIONS = ['😂', '👍', '😤', '🤩', '💸', '😅', '🔥', '❤'];

// ---------------------------------------------------------------------------
// Helper: assert the expense belongs to the current trip, return expense row.
// ---------------------------------------------------------------------------
function get_expense_for_trip(PDO $pdo, int $expenseId, int $tripId): array
{
    $expensesTable = table_name('expenses');
    $stmt = $pdo->prepare(
        'SELECT id FROM ' . $expensesTable . '
         WHERE id = :id AND trip_id = :trip_id
         LIMIT 1'
    );
    $stmt->execute(['id' => $expenseId, 'trip_id' => $tripId]);
    $row = $stmt->fetch();
    if (!$row) {
        json_out(['ok' => false, 'error' => 'Expense not found.'], 404);
    }
    return (array) $row;
}

// ---------------------------------------------------------------------------
// Helper: assert comment belongs to current trip + expense, return row.
// ---------------------------------------------------------------------------
function get_comment_for_trip_expense(
    PDO $pdo,
    int $commentId,
    int $tripId,
    int $expenseId
): array {
    $commentsTable = table_name('expense_comments');
    $usersTable = table_name('users');
    $stmt = $pdo->prepare(
        'SELECT c.id, c.user_id, c.trip_id, c.expense_id, c.parent_comment_id, c.body, u.nickname
         FROM ' . $commentsTable . ' c
         LEFT JOIN ' . $usersTable . ' u ON u.id = c.user_id
         WHERE c.id = :id
         LIMIT 1'
    );
    $stmt->execute(['id' => $commentId]);
    $row = $stmt->fetch();
    if (!$row) {
        json_out(['ok' => false, 'error' => 'Comment not found.'], 404);
    }
    if ((int) $row['trip_id'] !== $tripId || (int) $row['expense_id'] !== $expenseId) {
        json_out(['ok' => false, 'error' => 'Comment not found in this expense.'], 404);
    }
    return (array) $row;
}

// ---------------------------------------------------------------------------
// list_expense_comment_reactions  GET  ?trip_id=…&expense_id=…
// ---------------------------------------------------------------------------
function list_expense_comment_reactions_action(): void
{
    $me     = get_me();
    $pdo    = db();
    $trip   = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);

    $expenseId = (int) ($_GET['expense_id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }

    get_expense_for_trip($pdo, $expenseId, $tripId);

    $reactionsTable = table_name('expense_comment_reactions');
    $usersTable     = table_name('users');

    $stmt = $pdo->prepare(
        'SELECT r.comment_id, r.emoji, r.user_id, u.nickname, r.created_at
         FROM ' . $reactionsTable . ' r
         LEFT JOIN ' . $usersTable . ' u ON u.id = r.user_id
         WHERE r.expense_id = :expense_id
         ORDER BY r.created_at ASC, r.id ASC'
    );
    $stmt->execute(['expense_id' => $expenseId]);

    $reactions = array_map(
        static function (array $row): array {
            return [
                'comment_id' => (int) $row['comment_id'],
                'emoji'      => (string) ($row['emoji'] ?? ''),
                'user_id'    => (int) $row['user_id'],
                'nickname'   => (string) ($row['nickname'] ?? ''),
                'created_at' => (string) ($row['created_at'] ?? ''),
            ];
        },
        $stmt->fetchAll()
    );

    json_out(['ok' => true, 'reactions' => $reactions]);
}

// ---------------------------------------------------------------------------
// toggle_expense_comment_reaction  POST
// Body: { trip_id, expense_id, comment_id, emoji }
// Behaviour:
//   • no prior reaction  → INSERT  (action: added)
//   • same emoji         → DELETE  (action: removed)
//   • different emoji    → UPDATE  (action: updated)
// ---------------------------------------------------------------------------
function toggle_expense_comment_reaction_action(): void
{
    require_post();
    $me     = get_me();
    $body   = read_json();
    $pdo    = db();
    $trip   = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'comment_write_ip',
        client_ip_address(),
        RATE_LIMIT_COMMENT_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'comment_write_user',
        (string) $userId,
        RATE_LIMIT_COMMENT_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expenseId = (int) ($body['expense_id'] ?? 0);
    $commentId = (int) ($body['comment_id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }
    if ($commentId <= 0) {
        json_out(['ok' => false, 'error' => 'comment_id is required.'], 400);
    }

    $emoji = trim((string) ($body['emoji'] ?? ''));
    if (!in_array($emoji, ALLOWED_EXPENSE_REACTIONS, true)) {
        json_out(['ok' => false, 'error' => 'Invalid emoji.'], 400);
    }

    get_expense_for_trip($pdo, $expenseId, $tripId);
    get_comment_for_trip_expense($pdo, $commentId, $tripId, $expenseId);

    $reactionsTable = table_name('expense_comment_reactions');
    $existingStmt   = $pdo->prepare(
        'SELECT id, emoji FROM ' . $reactionsTable . '
         WHERE comment_id = :comment_id AND user_id = :user_id
         LIMIT 1'
    );
    $existingStmt->execute(['comment_id' => $commentId, 'user_id' => $userId]);
    $existing = $existingStmt->fetch();

    if ($existing) {
        if ((string) $existing['emoji'] === $emoji) {
            $pdo->prepare('DELETE FROM ' . $reactionsTable . ' WHERE id = :id')
                ->execute(['id' => (int) $existing['id']]);
            json_out([
                'ok'         => true,
                'action'     => 'removed',
                'emoji'      => $emoji,
                'comment_id' => $commentId,
            ]);
        }
        $pdo->prepare('UPDATE ' . $reactionsTable . ' SET emoji = :emoji WHERE id = :id')
            ->execute(['emoji' => $emoji, 'id' => (int) $existing['id']]);
        json_out([
            'ok'         => true,
            'action'     => 'updated',
            'emoji'      => $emoji,
            'comment_id' => $commentId,
        ]);
    }

    $pdo->prepare(
        'INSERT INTO ' . $reactionsTable . ' (comment_id, expense_id, trip_id, user_id, emoji)
         VALUES (:comment_id, :expense_id, :trip_id, :user_id, :emoji)'
    )->execute([
        'comment_id' => $commentId,
        'expense_id' => $expenseId,
        'trip_id'    => $tripId,
        'user_id'    => $userId,
        'emoji'      => $emoji,
    ]);

    json_out([
        'ok'         => true,
        'action'     => 'added',
        'emoji'      => $emoji,
        'comment_id' => $commentId,
    ]);
}

// ---------------------------------------------------------------------------
// list_expense_reactions  GET  ?trip_id=…&expense_id=…
// ---------------------------------------------------------------------------
function list_expense_reactions_action(): void
{
    $me    = get_me();
    $pdo   = db();
    $trip  = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);

    $expenseId = (int) ($_GET['expense_id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }

    get_expense_for_trip($pdo, $expenseId, $tripId);

    $reactionsTable = table_name('expense_reactions');
    $usersTable     = table_name('users');

    $stmt = $pdo->prepare(
        'SELECT r.emoji, r.user_id, u.nickname, r.created_at
         FROM ' . $reactionsTable . ' r
         LEFT JOIN ' . $usersTable . ' u ON u.id = r.user_id
         WHERE r.expense_id = :expense_id
         ORDER BY r.created_at ASC'
    );
    $stmt->execute(['expense_id' => $expenseId]);

    $reactions = array_map(
        static function (array $row): array {
            return [
                'emoji'      => $row['emoji'],
                'user_id'    => (int) $row['user_id'],
                'nickname'   => (string) ($row['nickname'] ?? ''),
                'created_at' => (string) ($row['created_at'] ?? ''),
            ];
        },
        $stmt->fetchAll()
    );

    json_out(['ok' => true, 'reactions' => $reactions]);
}

// ---------------------------------------------------------------------------
// toggle_expense_reaction  POST
// Body: { trip_id, expense_id, emoji }
// Behaviour:
//   • no prior reaction  → INSERT  (action: added)
//   • same emoji         → DELETE  (action: removed)
//   • different emoji    → UPDATE  (action: updated)
// ---------------------------------------------------------------------------
function toggle_expense_reaction_action(): void
{
    require_post();
    $me     = get_me();
    $body   = read_json();
    $pdo    = db();
    $trip   = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'comment_write_ip',
        client_ip_address(),
        RATE_LIMIT_COMMENT_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'comment_write_user',
        (string) $userId,
        RATE_LIMIT_COMMENT_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expenseId = (int) ($body['expense_id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }

    $emoji = trim((string) ($body['emoji'] ?? ''));
    if (!in_array($emoji, ALLOWED_EXPENSE_REACTIONS, true)) {
        json_out(['ok' => false, 'error' => 'Invalid emoji.'], 400);
    }

    get_expense_for_trip($pdo, $expenseId, $tripId);

    $reactionsTable = table_name('expense_reactions');

    $existingStmt = $pdo->prepare(
        'SELECT id, emoji FROM ' . $reactionsTable . '
         WHERE expense_id = :expense_id AND user_id = :user_id
         LIMIT 1'
    );
    $existingStmt->execute(['expense_id' => $expenseId, 'user_id' => $userId]);
    $existing = $existingStmt->fetch();

    if ($existing) {
        if ($existing['emoji'] === $emoji) {
            // Toggle off — remove reaction.
            $pdo->prepare('DELETE FROM ' . $reactionsTable . ' WHERE id = :id')
                ->execute(['id' => (int) $existing['id']]);
            json_out(['ok' => true, 'action' => 'removed', 'emoji' => $emoji]);
        } else {
            // Switch to a different emoji.
            $pdo->prepare('UPDATE ' . $reactionsTable . ' SET emoji = :emoji WHERE id = :id')
                ->execute(['emoji' => $emoji, 'id' => (int) $existing['id']]);
            json_out(['ok' => true, 'action' => 'updated', 'emoji' => $emoji]);
        }
    } else {
        $pdo->prepare(
            'INSERT INTO ' . $reactionsTable . ' (expense_id, trip_id, user_id, emoji)
             VALUES (:expense_id, :trip_id, :user_id, :emoji)'
        )->execute([
            'expense_id' => $expenseId,
            'trip_id'    => $tripId,
            'user_id'    => $userId,
            'emoji'      => $emoji,
        ]);
        json_out(['ok' => true, 'action' => 'added', 'emoji' => $emoji]);
    }
}

// ---------------------------------------------------------------------------
// list_expense_comments  GET  ?trip_id=…&expense_id=…
// ---------------------------------------------------------------------------
function list_expense_comments_action(): void
{
    $me     = get_me();
    $pdo    = db();
    $trip   = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);

    $expenseId = (int) ($_GET['expense_id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }

    get_expense_for_trip($pdo, $expenseId, $tripId);

    $commentsTable = table_name('expense_comments');
    $usersTable    = table_name('users');

    $stmt = $pdo->prepare(
        'SELECT
            c.id,
            c.user_id,
            u.nickname,
            c.body,
            c.created_at,
            c.parent_comment_id,
            pu.nickname AS reply_to_nickname,
            pc.body AS reply_to_body
         FROM ' . $commentsTable . ' c
         LEFT JOIN ' . $usersTable . ' u ON u.id = c.user_id
         LEFT JOIN ' . $commentsTable . ' pc ON pc.id = c.parent_comment_id
         LEFT JOIN ' . $usersTable . ' pu ON pu.id = pc.user_id
         WHERE c.expense_id = :expense_id
         ORDER BY c.created_at ASC, c.id ASC'
    );
    $stmt->execute(['expense_id' => $expenseId]);

    $comments = array_map(
        static function (array $row): array {
            return [
                'id'         => (int) $row['id'],
                'user_id'    => (int) $row['user_id'],
                'nickname'   => (string) ($row['nickname'] ?? ''),
                'body'       => (string) ($row['body'] ?? ''),
                'created_at' => (string) ($row['created_at'] ?? ''),
                'parent_comment_id' => isset($row['parent_comment_id'])
                    ? (int) $row['parent_comment_id']
                    : null,
                'reply_to_nickname' => $row['reply_to_nickname'] !== null
                    ? (string) $row['reply_to_nickname']
                    : null,
                'reply_to_body' => $row['reply_to_body'] !== null
                    ? (string) $row['reply_to_body']
                    : null,
            ];
        },
        $stmt->fetchAll()
    );

    json_out(['ok' => true, 'comments' => $comments]);
}

// ---------------------------------------------------------------------------
// add_expense_comment  POST
// Body: { trip_id, expense_id, body, parent_comment_id? }
// ---------------------------------------------------------------------------
function add_expense_comment_action(): void
{
    require_post();
    $me     = get_me();
    $body   = read_json();
    $pdo    = db();
    $trip   = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'comment_write_ip',
        client_ip_address(),
        RATE_LIMIT_COMMENT_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'comment_write_user',
        (string) $userId,
        RATE_LIMIT_COMMENT_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expenseId   = (int) ($body['expense_id'] ?? 0);
    $commentBody = trim((string) ($body['body'] ?? ''));
    $parentCommentId = (int) ($body['parent_comment_id'] ?? 0);

    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'expense_id is required.'], 400);
    }
    if ($commentBody === '') {
        json_out(['ok' => false, 'error' => 'Comment body is required.'], 400);
    }
    if (str_length($commentBody) > 280) {
        json_out(['ok' => false, 'error' => 'Comment is too long (max 280 characters).'], 400);
    }
    ensure_text_has_no_links($commentBody, 'Comment');

    get_expense_for_trip($pdo, $expenseId, $tripId);
    $parentComment = null;
    if ($parentCommentId > 0) {
        $parentComment = get_comment_for_trip_expense(
            $pdo,
            $parentCommentId,
            $tripId,
            $expenseId
        );
        // Keep one-level threading for UI clarity:
        // if replying to a reply, attach to its top-level parent.
        $topParentId = (int) ($parentComment['parent_comment_id'] ?? 0);
        if ($topParentId > 0) {
            $parentComment = get_comment_for_trip_expense(
                $pdo,
                $topParentId,
                $tripId,
                $expenseId
            );
            $parentCommentId = (int) $parentComment['id'];
        }
    } else {
        $parentCommentId = 0;
    }

    $commentsTable = table_name('expense_comments');
    $usersTable    = table_name('users');

    $pdo->prepare(
        'INSERT INTO ' . $commentsTable . ' (expense_id, trip_id, user_id, parent_comment_id, body)
         VALUES (:expense_id, :trip_id, :user_id, :parent_comment_id, :body)'
    )->execute([
        'expense_id' => $expenseId,
        'trip_id'    => $tripId,
        'user_id'    => $userId,
        'parent_comment_id' => $parentCommentId > 0 ? $parentCommentId : null,
        'body'       => $commentBody,
    ]);
    $commentId = (int) $pdo->lastInsertId();

    $nickStmt = $pdo->prepare(
        'SELECT nickname FROM ' . $usersTable . ' WHERE id = :id LIMIT 1'
    );
    $nickStmt->execute(['id' => $userId]);
    $userRow  = $nickStmt->fetch();
    $nickname = (string) ($userRow['nickname'] ?? '');

    json_out([
        'ok'      => true,
        'comment' => [
            'id'         => $commentId,
            'user_id'    => $userId,
            'nickname'   => $nickname,
            'body'       => $commentBody,
            'created_at' => date('Y-m-d H:i:s'),
            'parent_comment_id' => $parentCommentId > 0 ? $parentCommentId : null,
            'reply_to_nickname' => is_array($parentComment)
                ? (string) ($parentComment['nickname'] ?? '')
                : null,
            'reply_to_body' => is_array($parentComment)
                ? (string) ($parentComment['body'] ?? '')
                : null,
        ],
    ]);
}

// ---------------------------------------------------------------------------
// update_expense_comment  POST
// Body: { trip_id, comment_id, expense_id?, body }
// Only the comment author may edit their own comment.
// ---------------------------------------------------------------------------
function update_expense_comment_action(): void
{
    require_post();
    $me     = get_me();
    $body   = read_json();
    $pdo    = db();
    $trip   = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'comment_write_ip',
        client_ip_address(),
        RATE_LIMIT_COMMENT_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'comment_write_user',
        (string) $userId,
        RATE_LIMIT_COMMENT_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $commentId = (int) ($body['comment_id'] ?? 0);
    $expenseId = (int) ($body['expense_id'] ?? 0);
    $commentBody = trim((string) ($body['body'] ?? ''));

    if ($commentId <= 0) {
        json_out(['ok' => false, 'error' => 'comment_id is required.'], 400);
    }
    if ($commentBody === '') {
        json_out(['ok' => false, 'error' => 'Comment body is required.'], 400);
    }
    if (str_length($commentBody) > 280) {
        json_out(['ok' => false, 'error' => 'Comment is too long (max 280 characters).'], 400);
    }
    ensure_text_has_no_links($commentBody, 'Comment');

    $commentsTable = table_name('expense_comments');
    $usersTable    = table_name('users');

    $rowStmt = $pdo->prepare(
        'SELECT id, user_id, trip_id, expense_id, parent_comment_id, created_at
         FROM ' . $commentsTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $rowStmt->execute(['id' => $commentId]);
    $comment = $rowStmt->fetch();

    if (!$comment) {
        json_out(['ok' => false, 'error' => 'Comment not found.'], 404);
    }
    if ((int) $comment['trip_id'] !== $tripId) {
        json_out(['ok' => false, 'error' => 'Comment not found in this trip.'], 404);
    }
    if ($expenseId > 0 && (int) $comment['expense_id'] !== $expenseId) {
        json_out(['ok' => false, 'error' => 'Comment not found in this expense.'], 404);
    }
    if ((int) $comment['user_id'] !== $userId) {
        json_out(['ok' => false, 'error' => 'You can only edit your own comments.'], 403);
    }

    $pdo->prepare(
        'UPDATE ' . $commentsTable . '
         SET body = :body
         WHERE id = :id'
    )->execute([
        'body' => $commentBody,
        'id'   => $commentId,
    ]);

    $parentCommentId = (int) ($comment['parent_comment_id'] ?? 0);
    $parentComment = null;
    if ($parentCommentId > 0) {
        $parentComment = get_comment_for_trip_expense(
            $pdo,
            $parentCommentId,
            $tripId,
            (int) ($comment['expense_id'] ?? 0)
        );
    }

    $nickStmt = $pdo->prepare(
        'SELECT nickname FROM ' . $usersTable . ' WHERE id = :id LIMIT 1'
    );
    $nickStmt->execute(['id' => $userId]);
    $userRow  = $nickStmt->fetch();
    $nickname = (string) ($userRow['nickname'] ?? '');

    json_out([
        'ok'      => true,
        'comment' => [
            'id'         => $commentId,
            'user_id'    => $userId,
            'nickname'   => $nickname,
            'body'       => $commentBody,
            'created_at' => (string) ($comment['created_at'] ?? ''),
            'parent_comment_id' => $parentCommentId > 0 ? $parentCommentId : null,
            'reply_to_nickname' => is_array($parentComment)
                ? (string) ($parentComment['nickname'] ?? '')
                : null,
            'reply_to_body' => is_array($parentComment)
                ? (string) ($parentComment['body'] ?? '')
                : null,
        ],
    ]);
}

// ---------------------------------------------------------------------------
// delete_expense_comment  POST
// Body: { trip_id, comment_id }
// Only the comment author may delete their own comment.
// ---------------------------------------------------------------------------
function delete_expense_comment_action(): void
{
    require_post();
    $me        = get_me();
    $body      = read_json();
    $pdo       = db();
    $trip      = get_current_trip($pdo, $me, true);
    $tripId    = (int) ($trip['id'] ?? 0);
    $userId    = (int) ($me['id'] ?? 0);
    $commentId = (int) ($body['comment_id'] ?? 0);

    if ($commentId <= 0) {
        json_out(['ok' => false, 'error' => 'comment_id is required.'], 400);
    }

    $commentsTable = table_name('expense_comments');

    $stmt = $pdo->prepare(
        'SELECT id, user_id, trip_id FROM ' . $commentsTable . '
         WHERE id = :id LIMIT 1'
    );
    $stmt->execute(['id' => $commentId]);
    $comment = $stmt->fetch();

    if (!$comment) {
        json_out(['ok' => false, 'error' => 'Comment not found.'], 404);
    }
    if ((int) $comment['trip_id'] !== $tripId) {
        json_out(['ok' => false, 'error' => 'Comment not found in this trip.'], 404);
    }
    if ((int) $comment['user_id'] !== $userId) {
        json_out(['ok' => false, 'error' => 'You can only delete your own comments.'], 403);
    }

    $pdo->prepare('DELETE FROM ' . $commentsTable . ' WHERE id = :id')
        ->execute(['id' => $commentId]);

    json_out(['ok' => true, 'deleted_id' => $commentId]);
}
