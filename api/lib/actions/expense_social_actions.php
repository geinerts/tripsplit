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
        'SELECT id, note FROM ' . $expensesTable . '
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
// Mentions: see docs/api/expense-comment-mentions.md
// ---------------------------------------------------------------------------
function expense_comment_mentions_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }
    try {
        $cached = $pdo->query('SELECT 1 FROM ' . table_name('expense_comment_mentions') . ' LIMIT 1') !== false;
    } catch (Throwable $error) {
        $cached = false;
    }
    return $cached;
}

/** Normalize the request list to unique positive IDs; a bad value is ignored, not an error. */
function normalize_mentioned_user_ids($raw): array
{
    if (!is_array($raw)) {
        return [];
    }
    $ids = [];
    foreach ($raw as $value) {
        $id = is_int($value) || is_string($value) ? filter_var($value, FILTER_VALIDATE_INT) : false;
        if ($id !== false && $id > 0) {
            $ids[$id] = $id;
        }
    }
    return array_slice(array_values($ids), 0, 50);
}

/**
 * The short trip names the apps insert for a member: the first name, and the
 * first name with the last initial (`Anna B.`), as in `WorkspaceUser.withTripNames`.
 *
 * @return list<string>
 */
function expense_comment_short_names(?string $firstName, ?string $lastName, string $fullName): array
{
    $words = preg_split('/\s+/u', trim($fullName), -1, PREG_SPLIT_NO_EMPTY) ?: [];
    $first = $firstName ?? ($words[0] ?? '');
    $last = $lastName ?? (count($words) > 1 ? $words[count($words) - 1] : '');
    if ($first === '') {
        return [];
    }
    $names = [$first];
    if ($last !== '') {
        $names[] = $first . ' ' . mb_strtoupper(mb_substr($last, 0, 1)) . '.';
    }
    return $names;
}

function expense_comment_mention_text(string $commentBody, array $names): ?string
{
    usort($names, static fn(string $a, string $b): int => str_length($b) <=> str_length($a));
    foreach ($names as $name) {
        $name = trim($name);
        $pattern = '/(?<![\p{L}\p{N}_])@(' . preg_quote($name, '/') . ')(?![\p{L}\p{N}_])/iu';
        if ($name !== '' && preg_match($pattern, $commentBody, $match) === 1) {
            return $match[1];
        }
    }
    return null;
}

/** @return array<int, array{text: string, active: bool}> */
function load_expense_comment_mention_rows(PDO $pdo, int $commentId): array
{
    $stmt = $pdo->prepare(
        'SELECT user_id, mention_text, is_active
         FROM ' . table_name('expense_comment_mentions') . '
         WHERE comment_id = :comment_id'
    );
    $stmt->execute(['comment_id' => $commentId]);
    $rows = [];
    foreach ($stmt->fetchAll() as $row) {
        $rows[(int) $row['user_id']] = [
            'text' => (string) $row['mention_text'],
            'active' => (int) $row['is_active'] === 1,
        ];
    }
    return $rows;
}

/**
 * Keep only IDs of active trip members whose mention is really in the text.
 *
 * @return array<int, string> user ID => mention text as written in the body
 */
function resolve_expense_comment_mentions(
    PDO $pdo,
    int $tripId,
    string $commentBody,
    array $requestedIds,
    array $existingRows = []
): array {
    if (!$requestedIds) {
        return [];
    }
    $placeholders = implode(',', array_fill(0, count($requestedIds), '?'));
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $nameSelect . 'u.nickname
         FROM ' . table_name('trip_members') . ' tm
         JOIN ' . table_name('users') . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = ? AND tm.user_id IN (' . $placeholders . ')'
         . users_active_filter_sql($pdo, 'u')
    );
    $stmt->execute(array_merge([$tripId], $requestedIds));

    $resolved = [];
    foreach ($stmt->fetchAll() as $row) {
        $userId = (int) $row['id'];
        $fullName = combine_full_name(
            normalize_me_name_value($row['first_name'] ?? null),
            normalize_me_name_value($row['last_name'] ?? null)
        );
        $text = expense_comment_mention_text($commentBody, array_filter([
            (string) $fullName,
            (string) ($row['nickname'] ?? ''),
            ...expense_comment_short_names(
                normalize_me_name_value($row['first_name'] ?? null),
                normalize_me_name_value($row['last_name'] ?? null),
                (string) ($fullName ?? $row['nickname'] ?? '')
            ),
            (string) ($existingRows[$userId]['text'] ?? ''),
        ], static fn(string $name): bool => $name !== ''));
        if ($text !== null) {
            $resolved[$userId] = $text;
        }
    }
    return $resolved;
}

/** Store the comment's mentions and notify only people who were never mentioned in it. */
function save_expense_comment_mentions(
    PDO $pdo,
    int $tripId,
    int $expenseId,
    string $expenseNote,
    int $commentId,
    int $actorId,
    string $commentBody,
    array $requestedIds
): void {
    if (!expense_comment_mentions_available($pdo)) {
        return;
    }
    // The comment is already saved, so a mention failure must not fail the request.
    try {
        $existing = load_expense_comment_mention_rows($pdo, $commentId);
        $resolved = resolve_expense_comment_mentions($pdo, $tripId, $commentBody, $requestedIds, $existing);
        $table = table_name('expense_comment_mentions');
        $insert = $pdo->prepare(
            'INSERT INTO ' . $table . ' (comment_id, user_id, mention_text, is_active)
             VALUES (:comment_id, :user_id, :mention_text, 1)'
        );
        $update = $pdo->prepare(
            'UPDATE ' . $table . ' SET mention_text = :mention_text, is_active = :is_active
             WHERE comment_id = :comment_id AND user_id = :user_id'
        );
        foreach ($existing as $userId => $row) {
            $update->execute([
                'mention_text' => $resolved[$userId] ?? $row['text'],
                'is_active' => isset($resolved[$userId]) ? 1 : 0,
                'comment_id' => $commentId,
                'user_id' => $userId,
            ]);
        }
        $newUserIds = array_diff(array_keys($resolved), array_keys($existing));
        foreach ($newUserIds as $userId) {
            $insert->execute([
                'comment_id' => $commentId,
                'user_id' => $userId,
                'mention_text' => $resolved[$userId],
            ]);
        }
        notify_expense_comment_mentions($pdo, $tripId, $expenseId, $expenseNote, $commentId, $actorId, $newUserIds);
    } catch (Throwable $error) {
        log_api_exception($error, 'save_expense_comment_mentions');
    }
}

function notify_expense_comment_mentions(
    PDO $pdo,
    int $tripId,
    int $expenseId,
    string $expenseNote,
    int $commentId,
    int $actorId,
    array $userIds
): void {
    $userIds = array_diff($userIds, [$actorId]);
    if (!$userIds) {
        return;
    }
    $actorName = trip_member_label($pdo, $actorId);
    $note = trim($expenseNote);
    $notificationBody = $note !== ''
        ? $actorName . ' mentioned you in a comment on "' . $note . '".'
        : $actorName . ' mentioned you in a comment.';
    foreach ($userIds as $userId) {
        create_user_notification(
            $pdo,
            $tripId,
            (int) $userId,
            'expense_comment_mention',
            'You were mentioned in a comment',
            $notificationBody,
            [
                'trip_id' => $tripId,
                'expense_id' => $expenseId,
                'comment_id' => $commentId,
                'mentioned_by_user_id' => $actorId,
            ]
        );
    }
}

/** Tell the expense's payer about a new comment, unless they wrote it or are mentioned in it. */
function notify_expense_comment_added(
    PDO $pdo,
    int $tripId,
    int $expenseId,
    string $expenseNote,
    int $commentId,
    int $actorId
): void {
    // The comment is already saved, so a notification failure must not fail the request.
    try {
        $stmt = $pdo->prepare(
            'SELECT paid_by FROM ' . table_name('expenses') . ' WHERE id = :id AND trip_id = :trip_id LIMIT 1'
        );
        $stmt->execute(['id' => $expenseId, 'trip_id' => $tripId]);
        $payerId = (int) ($stmt->fetchColumn() ?: 0);
        if ($payerId <= 0 || $payerId === $actorId) {
            return;
        }
        if (expense_comment_mentions_available($pdo)) {
            $mentions = load_expense_comment_mention_rows($pdo, $commentId);
            if (!empty($mentions[$payerId]['active'])) {
                return;
            }
        }
        $actorName = trip_member_label($pdo, $actorId);
        $note = trim($expenseNote);
        create_user_notification(
            $pdo,
            $tripId,
            $payerId,
            'expense_comment_added',
            'New comment on your expense',
            $note !== ''
                ? $actorName . ' commented on "' . $note . '".'
                : $actorName . ' commented on your expense.',
            [
                'trip_id' => $tripId,
                'expense_id' => $expenseId,
                'comment_id' => $commentId,
                'commented_by_user_id' => $actorId,
            ]
        );
    } catch (Throwable $error) {
        log_api_exception($error, 'notify_expense_comment_added');
    }
}

/** @return list<array{user_id: int, name: string}> */
function expense_comment_mentions_payload(PDO $pdo, int $commentId): array
{
    if (!expense_comment_mentions_available($pdo)) {
        return [];
    }
    $mentions = [];
    foreach (load_expense_comment_mention_rows($pdo, $commentId) as $userId => $row) {
        if ($row['active']) {
            $mentions[] = ['user_id' => $userId, 'name' => $row['text']];
        }
    }
    return $mentions;
}

/** @return array<int, list<array{user_id: int, name: string}>> comment ID => mentions */
function expense_mentions_by_comment(PDO $pdo, int $expenseId): array
{
    if (!expense_comment_mentions_available($pdo)) {
        return [];
    }
    $stmt = $pdo->prepare(
        'SELECT m.comment_id, m.user_id, m.mention_text
         FROM ' . table_name('expense_comment_mentions') . ' m
         JOIN ' . table_name('expense_comments') . ' c ON c.id = m.comment_id
         WHERE c.expense_id = :expense_id AND m.is_active = 1'
    );
    $stmt->execute(['expense_id' => $expenseId]);
    $byComment = [];
    foreach ($stmt->fetchAll() as $row) {
        $byComment[(int) $row['comment_id']][] = [
            'user_id' => (int) $row['user_id'],
            'name' => (string) $row['mention_text'],
        ];
    }
    return $byComment;
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
    $mentionsByComment = expense_mentions_by_comment($pdo, $expenseId);

    $comments = array_map(
        static function (array $row) use ($mentionsByComment): array {
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
                'mentions' => $mentionsByComment[(int) $row['id']] ?? [],
            ];
        },
        $stmt->fetchAll()
    );

    json_out(['ok' => true, 'comments' => $comments]);
}

// ---------------------------------------------------------------------------
// add_expense_comment  POST
// Body: { trip_id, expense_id, body, parent_comment_id?, mentioned_user_ids? }
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

    $expense = get_expense_for_trip($pdo, $expenseId, $tripId);
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

    app_event($pdo, $userId, 'expense.comment_added', 'expense', $expenseId, $tripId, [
        'comment_id' => $commentId,
        'note' => trim((string) ($expense['note'] ?? '')),
    ]);

    save_expense_comment_mentions(
        $pdo,
        $tripId,
        $expenseId,
        (string) ($expense['note'] ?? ''),
        $commentId,
        $userId,
        $commentBody,
        normalize_mentioned_user_ids($body['mentioned_user_ids'] ?? [])
    );
    notify_expense_comment_added(
        $pdo,
        $tripId,
        $expenseId,
        (string) ($expense['note'] ?? ''),
        $commentId,
        $userId
    );

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
            'mentions'   => expense_comment_mentions_payload($pdo, $commentId),
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
// Body: { trip_id, comment_id, expense_id?, body, mentioned_user_ids? }
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

    if (array_key_exists('mentioned_user_ids', $body)) {
        $commentExpenseId = (int) ($comment['expense_id'] ?? 0);
        save_expense_comment_mentions(
            $pdo,
            $tripId,
            $commentExpenseId,
            (string) (get_expense_for_trip($pdo, $commentExpenseId, $tripId)['note'] ?? ''),
            $commentId,
            $userId,
            $commentBody,
            normalize_mentioned_user_ids($body['mentioned_user_ids'])
        );
    }

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
            'mentions'   => expense_comment_mentions_payload($pdo, $commentId),
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
