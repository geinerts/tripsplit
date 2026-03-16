<?php
declare(strict_types=1);

function normalize_expense_split_mode($value): string
{
    $raw = strtolower(trim((string) $value));
    if ($raw === '' || $raw === 'equal') {
        return 'equal';
    }
    if ($raw === 'exact' || $raw === 'percent' || $raw === 'shares') {
        return $raw;
    }
    json_out(['ok' => false, 'error' => 'Unsupported split mode.'], 400);
}

function normalize_expense_category($value): string
{
    $raw = trim((string) $value);
    if ($raw === '') {
        return 'other';
    }

    $raw = preg_replace('/\s+/', ' ', $raw) ?? $raw;
    $raw = trim($raw);
    if ($raw === '') {
        return 'other';
    }

    $normalized = strtolower($raw);
    if ($normalized === 'health') {
        return 'party';
    }
    $builtIn = [
        'food' => true,
        'groceries' => true,
        'fuel' => true,
        'transport' => true,
        'accommodation' => true,
        'activities' => true,
        'tickets' => true,
        'shopping' => true,
        'party' => true,
        'parking' => true,
        'other' => true,
    ];
    if (isset($builtIn[$normalized])) {
        return $normalized;
    }

    if (str_length($raw) < 2 || str_length($raw) > 64) {
        json_out(['ok' => false, 'error' => 'Category must be 2-64 chars.'], 400);
    }
    if (!preg_match('/^[\p{L}\p{N}][\p{L}\p{N} .,_\-&\/()+]*$/u', $raw)) {
        json_out(['ok' => false, 'error' => 'Category has unsupported characters.'], 400);
    }
    ensure_text_has_no_links($raw, 'Category');

    return $raw;
}

function parse_expense_split_entries(array $rawSplits): array
{
    $out = [];
    foreach ($rawSplits as $item) {
        if (!is_array($item)) {
            json_out(['ok' => false, 'error' => 'Invalid split payload.'], 400);
        }
        $userId = (int) ($item['user_id'] ?? 0);
        if ($userId <= 0) {
            json_out(['ok' => false, 'error' => 'Split user_id is required.'], 400);
        }
        $valueRaw = $item['value'] ?? null;
        if (is_string($valueRaw)) {
            $valueRaw = str_replace(',', '.', trim($valueRaw));
        }
        if (!is_numeric($valueRaw)) {
            json_out(['ok' => false, 'error' => 'Split value must be numeric.'], 400);
        }
        $value = (float) $valueRaw;
        if ($value < 0) {
            json_out(['ok' => false, 'error' => 'Split value cannot be negative.'], 400);
        }
        $out[$userId] = $value;
    }
    return $out;
}

function allocate_weighted_shares_cents(int $amountCents, array $participantIds, array $weightsByUser): array
{
    $participantIds = normalize_user_ids($participantIds);
    if (count($participantIds) < 1) {
        return [];
    }

    $totalWeight = 0;
    foreach ($participantIds as $userId) {
        $weight = (int) ($weightsByUser[$userId] ?? 0);
        if ($weight > 0) {
            $totalWeight += $weight;
        }
    }
    if ($totalWeight <= 0) {
        json_out(['ok' => false, 'error' => 'Split weights must be positive.'], 400);
    }

    $owedByUser = [];
    $allocated = 0;
    $remainders = [];
    foreach ($participantIds as $index => $userId) {
        $weight = (int) ($weightsByUser[$userId] ?? 0);
        if ($weight <= 0) {
            $owedByUser[$userId] = 0;
            $remainders[] = [
                'user_id' => $userId,
                'index' => (int) $index,
                'remainder' => 0,
            ];
            continue;
        }

        $weighted = $amountCents * $weight;
        $base = intdiv($weighted, $totalWeight);
        $remainder = $weighted % $totalWeight;
        $owedByUser[$userId] = $base;
        $allocated += $base;
        $remainders[] = [
            'user_id' => $userId,
            'index' => (int) $index,
            'remainder' => (int) $remainder,
        ];
    }

    $left = $amountCents - $allocated;
    usort(
        $remainders,
        static function (array $a, array $b): int {
            $cmp = ((int) $b['remainder']) <=> ((int) $a['remainder']);
            if ($cmp !== 0) {
                return $cmp;
            }
            return ((int) $a['index']) <=> ((int) $b['index']);
        }
    );

    $count = count($remainders);
    $cursor = 0;
    while ($left > 0 && $count > 0) {
        $row = $remainders[$cursor % $count];
        $userId = (int) $row['user_id'];
        $owedByUser[$userId] = (int) ($owedByUser[$userId] ?? 0) + 1;
        $left--;
        $cursor++;
    }

    return $owedByUser;
}

function build_expense_split_rows(
    int $amountCents,
    array $participantIds,
    string $splitMode,
    array $rawSplits
): array {
    $participantIds = normalize_user_ids($participantIds);
    if (count($participantIds) < 1) {
        json_out(['ok' => false, 'error' => 'Pick at least one participant.'], 400);
    }

    $rows = [];
    if ($splitMode === 'equal') {
        $count = count($participantIds);
        $base = intdiv($amountCents, $count);
        $remainder = $amountCents % $count;
        foreach ($participantIds as $index => $userId) {
            $owedCents = $base + ($index < $remainder ? 1 : 0);
            $rows[] = [
                'user_id' => (int) $userId,
                'owed_cents' => (int) $owedCents,
                'split_value' => 0,
            ];
        }
        return $rows;
    }

    $splitEntries = parse_expense_split_entries($rawSplits);
    foreach ($participantIds as $userId) {
        if (!array_key_exists($userId, $splitEntries)) {
            json_out(['ok' => false, 'error' => 'Split values are missing for some participants.'], 400);
        }
    }
    foreach ($splitEntries as $userId => $_value) {
        if (!in_array((int) $userId, $participantIds, true)) {
            json_out(['ok' => false, 'error' => 'Split values include user outside participants.'], 400);
        }
    }

    if ($splitMode === 'exact') {
        $sumCents = 0;
        foreach ($participantIds as $userId) {
            $value = (float) ($splitEntries[$userId] ?? 0);
            $cents = (int) round($value * 100);
            if ($cents < 0) {
                json_out(['ok' => false, 'error' => 'Exact split cannot be negative.'], 400);
            }
            $sumCents += $cents;
            $rows[] = [
                'user_id' => (int) $userId,
                'owed_cents' => $cents,
                'split_value' => $cents,
            ];
        }
        if ($sumCents !== $amountCents) {
            json_out(['ok' => false, 'error' => 'Exact split must sum to full expense amount.'], 400);
        }
        return $rows;
    }

    if ($splitMode === 'percent') {
        $weights = [];
        $sumBasisPoints = 0;
        foreach ($participantIds as $userId) {
            $value = (float) ($splitEntries[$userId] ?? 0);
            $basisPoints = (int) round($value * 100);
            if ($basisPoints < 0) {
                json_out(['ok' => false, 'error' => 'Percent split cannot be negative.'], 400);
            }
            $weights[$userId] = $basisPoints;
            $sumBasisPoints += $basisPoints;
        }
        if ($sumBasisPoints !== 10000) {
            json_out(['ok' => false, 'error' => 'Percent split must total 100%.'], 400);
        }

        $owedByUser = allocate_weighted_shares_cents($amountCents, $participantIds, $weights);
        foreach ($participantIds as $userId) {
            $rows[] = [
                'user_id' => (int) $userId,
                'owed_cents' => (int) ($owedByUser[$userId] ?? 0),
                'split_value' => (int) ($weights[$userId] ?? 0),
            ];
        }
        return $rows;
    }

    if ($splitMode === 'shares') {
        $weights = [];
        foreach ($participantIds as $userId) {
            $value = (float) ($splitEntries[$userId] ?? 0);
            $rounded = (int) round($value);
            if ($rounded <= 0 || abs($value - $rounded) > 0.000001) {
                json_out(['ok' => false, 'error' => 'Shares must be positive whole numbers.'], 400);
            }
            $weights[$userId] = $rounded;
        }

        $owedByUser = allocate_weighted_shares_cents($amountCents, $participantIds, $weights);
        foreach ($participantIds as $userId) {
            $rows[] = [
                'user_id' => (int) $userId,
                'owed_cents' => (int) ($owedByUser[$userId] ?? 0),
                'split_value' => (int) ($weights[$userId] ?? 0),
            ];
        }
        return $rows;
    }

    json_out(['ok' => false, 'error' => 'Unsupported split mode.'], 400);
}

function add_expense_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    assert_trip_is_active($trip);

    enforce_rate_limit(
        $pdo,
        'expense_write_ip',
        client_ip_address(),
        RATE_LIMIT_EXPENSE_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'expense_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_EXPENSE_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');

    $amountCents = validate_amount_cents($body['amount'] ?? null);
    $category = normalize_expense_category($body['category'] ?? '');
    $note = trim((string) ($body['note'] ?? ''));
    if (str_length($note) > 255) {
        json_out(['ok' => false, 'error' => 'Note is too long.'], 400);
    }
    ensure_text_has_no_links($note, 'Note');
    $expenseDate = validate_date_iso((string) ($body['date'] ?? date('Y-m-d')));
    $rawParticipants = $body['participants'] ?? [];
    if (is_array($rawParticipants) && count($rawParticipants) > 0) {
        $participants = require_valid_trip_member_ids($pdo, (int) $trip['id'], $rawParticipants, true);
    } else {
        $participants = all_trip_member_ids($pdo, (int) $trip['id']);
    }
    $receiptPath = normalize_receipt_path((string) ($body['receipt_path'] ?? ''), true);
    $splitMode = normalize_expense_split_mode($body['split_mode'] ?? 'equal');
    $rawSplits = $body['splits'] ?? [];
    if (!is_array($rawSplits)) {
        json_out(['ok' => false, 'error' => 'Invalid splits payload.'], 400);
    }
    $participantRows = build_expense_split_rows($amountCents, $participants, $splitMode, $rawSplits);
    $payerId = (int) ($me['id'] ?? 0);
    $payerName = trim((string) ($me['nickname'] ?? ''));
    if ($payerName === '') {
        $payerName = 'Trip member';
    }
    $tripId = (int) ($trip['id'] ?? 0);
    $tripName = trim((string) ($trip['name'] ?? ''));

    $pdo->beginTransaction();
    try {
        $insertExpense = $pdo->prepare(
            'INSERT INTO ' . $expensesTable . ' (trip_id, amount, category, note, split_mode, paid_by, expense_date, receipt_path)
             VALUES (:trip_id, :amount, :category, :note, :split_mode, :paid_by, :expense_date, :receipt_path)'
        );
        $insertExpense->execute([
            'trip_id' => (int) $trip['id'],
            'amount' => cents_to_decimal($amountCents),
            'category' => $category,
            'note' => $note,
            'split_mode' => $splitMode,
            'paid_by' => (int) $me['id'],
            'expense_date' => $expenseDate,
            'receipt_path' => $receiptPath !== '' ? $receiptPath : null,
        ]);
        $expenseId = (int) $pdo->lastInsertId();

        $insertParticipant = $pdo->prepare(
            'INSERT INTO ' . $participantsTable . ' (expense_id, user_id, owed_cents, split_value)
             VALUES (:expense_id, :user_id, :owed_cents, :split_value)'
        );
        foreach ($participantRows as $participantRow) {
            $insertParticipant->execute([
                'expense_id' => $expenseId,
                'user_id' => (int) ($participantRow['user_id'] ?? 0),
                'owed_cents' => (int) ($participantRow['owed_cents'] ?? 0),
                'split_value' => (int) ($participantRow['split_value'] ?? 0),
            ]);
        }

        $notifyUserIds = [];
        foreach ($participantRows as $participantRow) {
            $userId = (int) ($participantRow['user_id'] ?? 0);
            if ($userId > 0 && $userId !== $payerId) {
                $notifyUserIds[$userId] = true;
            }
        }
        $notifyTripName = $tripName !== '' ? $tripName : ('Trip #' . $tripId);
        $amountText = '€' . cents_to_decimal($amountCents);
        $expenseBody = $payerName . ' added an expense of ' . $amountText . ' in "' . $notifyTripName . '".';
        if ($note !== '') {
            $expenseBody = $payerName . ' added an expense of ' . $amountText . ': ' . $note;
        }
        foreach (array_keys($notifyUserIds) as $userId) {
            create_user_notification(
                $pdo,
                $tripId,
                (int) $userId,
                'expense_added',
                'New expense added',
                $expenseBody,
                [
                    'trip_id' => $tripId,
                    'expense_id' => $expenseId,
                    'paid_by_user_id' => $payerId,
                    'amount_cents' => $amountCents,
                ]
            );
        }

        $pdo->commit();
        json_out([
            'ok' => true,
            'expense_id' => $expenseId,
            'trip_id' => $tripId,
            'receipt_url' => $receiptPath !== '' ? receipt_public_url($receiptPath) : null,
            'receipt_thumb_url' => $receiptPath !== '' ? receipt_thumb_public_url($receiptPath) : null,
        ]);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

function update_expense_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    assert_trip_is_active($trip);

    enforce_rate_limit(
        $pdo,
        'expense_write_ip',
        client_ip_address(),
        RATE_LIMIT_EXPENSE_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'expense_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_EXPENSE_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');

    $expenseId = (int) ($body['id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'Expense id is required.'], 400);
    }

    $ownerStmt = $pdo->prepare(
        'SELECT id, trip_id, paid_by, category, receipt_path
         FROM ' . $expensesTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $ownerStmt->execute(['id' => $expenseId]);
    $expense = $ownerStmt->fetch();
    if (!$expense) {
        json_out(['ok' => false, 'error' => 'Expense not found.'], 404);
    }
    if ((int) $expense['trip_id'] !== (int) $trip['id']) {
        json_out(['ok' => false, 'error' => 'Expense not found in this trip.'], 404);
    }
    if ((int) $expense['paid_by'] !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only expense owner can edit.'], 403);
    }

    $oldReceiptPath = (string) ($expense['receipt_path'] ?? '');
    $newReceiptPath = normalize_receipt_path((string) ($body['receipt_path'] ?? ''), true);
    $removeReceipt = (bool) ($body['remove_receipt'] ?? false);
    $nextReceiptPath = $oldReceiptPath;
    if ($newReceiptPath !== '') {
        $nextReceiptPath = $newReceiptPath;
    } elseif ($removeReceipt) {
        $nextReceiptPath = '';
    }

    $amountCents = validate_amount_cents($body['amount'] ?? null);
    $existingCategory = trim((string) ($expense['category'] ?? ''));
    $category = array_key_exists('category', $body)
        ? normalize_expense_category($body['category'] ?? '')
        : ($existingCategory !== '' ? $existingCategory : 'other');
    $note = trim((string) ($body['note'] ?? ''));
    if (str_length($note) > 255) {
        json_out(['ok' => false, 'error' => 'Note is too long.'], 400);
    }
    ensure_text_has_no_links($note, 'Note');
    $expenseDate = validate_date_iso((string) ($body['date'] ?? date('Y-m-d')));
    $rawParticipants = $body['participants'] ?? [];
    if (is_array($rawParticipants) && count($rawParticipants) > 0) {
        $participants = require_valid_trip_member_ids($pdo, (int) $trip['id'], $rawParticipants, true);
    } else {
        $participants = all_trip_member_ids($pdo, (int) $trip['id']);
    }
    $splitMode = normalize_expense_split_mode($body['split_mode'] ?? 'equal');
    $rawSplits = $body['splits'] ?? [];
    if (!is_array($rawSplits)) {
        json_out(['ok' => false, 'error' => 'Invalid splits payload.'], 400);
    }
    $participantRows = build_expense_split_rows($amountCents, $participants, $splitMode, $rawSplits);

    $pdo->beginTransaction();
    try {
        $update = $pdo->prepare(
            'UPDATE ' . $expensesTable . '
             SET amount = :amount, category = :category, note = :note, split_mode = :split_mode, expense_date = :expense_date, receipt_path = :receipt_path
             WHERE id = :id AND trip_id = :trip_id'
        );
        $update->execute([
            'amount' => cents_to_decimal($amountCents),
            'category' => $category,
            'note' => $note,
            'split_mode' => $splitMode,
            'expense_date' => $expenseDate,
            'receipt_path' => $nextReceiptPath !== '' ? $nextReceiptPath : null,
            'id' => $expenseId,
            'trip_id' => (int) $trip['id'],
        ]);

        $deleteParticipants = $pdo->prepare('DELETE FROM ' . $participantsTable . ' WHERE expense_id = :expense_id');
        $deleteParticipants->execute(['expense_id' => $expenseId]);

        $insertParticipant = $pdo->prepare(
            'INSERT INTO ' . $participantsTable . ' (expense_id, user_id, owed_cents, split_value)
             VALUES (:expense_id, :user_id, :owed_cents, :split_value)'
        );
        foreach ($participantRows as $participantRow) {
            $insertParticipant->execute([
                'expense_id' => $expenseId,
                'user_id' => (int) ($participantRow['user_id'] ?? 0),
                'owed_cents' => (int) ($participantRow['owed_cents'] ?? 0),
                'split_value' => (int) ($participantRow['split_value'] ?? 0),
            ]);
        }

        $pdo->commit();

        if ($oldReceiptPath !== '' && $oldReceiptPath !== $nextReceiptPath) {
            delete_receipt_file($oldReceiptPath);
        }

        json_out([
            'ok' => true,
            'expense_id' => $expenseId,
            'receipt_url' => $nextReceiptPath !== '' ? receipt_public_url($nextReceiptPath) : null,
            'receipt_thumb_url' => $nextReceiptPath !== '' ? receipt_thumb_public_url($nextReceiptPath) : null,
        ]);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

function delete_expense_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    assert_trip_is_active($trip);

    enforce_rate_limit(
        $pdo,
        'expense_write_ip',
        client_ip_address(),
        RATE_LIMIT_EXPENSE_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'expense_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_EXPENSE_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expensesTable = table_name('expenses');

    $expenseId = (int) ($body['id'] ?? 0);
    if ($expenseId <= 0) {
        json_out(['ok' => false, 'error' => 'Expense id is required.'], 400);
    }

    $ownerStmt = $pdo->prepare(
        'SELECT id, trip_id, paid_by, receipt_path
         FROM ' . $expensesTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $ownerStmt->execute(['id' => $expenseId]);
    $expense = $ownerStmt->fetch();
    if (!$expense) {
        json_out(['ok' => false, 'error' => 'Expense not found.'], 404);
    }
    if ((int) $expense['trip_id'] !== (int) $trip['id']) {
        json_out(['ok' => false, 'error' => 'Expense not found in this trip.'], 404);
    }
    if ((int) $expense['paid_by'] !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only expense owner can delete.'], 403);
    }

    $delete = $pdo->prepare('DELETE FROM ' . $expensesTable . ' WHERE id = :id AND trip_id = :trip_id');
    $delete->execute([
        'id' => $expenseId,
        'trip_id' => (int) $trip['id'],
    ]);

    delete_receipt_file((string) ($expense['receipt_path'] ?? ''));
    json_out(['ok' => true, 'deleted_id' => $expenseId]);
}

function list_expenses_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $expensesTable = table_name('expenses');
    $usersTable = table_name('users');
    $participantsTable = table_name('expense_participants');

    $query = $_GET;
    $hasCursor = trim((string) ($query['cursor'] ?? '')) !== '';
    $cursor = null;
    if ($hasCursor) {
        $cursorPayload = pagination_decode_cursor((string) $query['cursor']);
        $cursorDate = validate_date_iso((string) ($cursorPayload['expense_date'] ?? ''));
        $cursorId = (int) ($cursorPayload['id'] ?? 0);
        if ($cursorId <= 0) {
            json_out(['ok' => false, 'error' => 'Invalid pagination cursor.'], 400);
        }
        $cursor = [
            'expense_date' => $cursorDate,
            'id' => $cursorId,
        ];
    }

    $hasOffset = array_key_exists('offset', $query);
    $offset = (!$hasCursor && $hasOffset)
        ? pagination_offset($query['offset'])
        : 0;
    $defaultLimit = pagination_requested($query) ? 50 : 300;
    $limit = pagination_limit($query['limit'] ?? $defaultLimit, $defaultLimit, 300);
    $limitPlusOne = $limit + 1;

    $sql =
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
         WHERE e.trip_id = :trip_id';
    $params = ['trip_id' => (int) $trip['id']];

    if ($cursor !== null) {
        $sql .= '
           AND (
                e.expense_date < :cursor_expense_date
                OR (e.expense_date = :cursor_expense_date AND e.id < :cursor_id)
           )';
        $params['cursor_expense_date'] = (string) $cursor['expense_date'];
        $params['cursor_id'] = (int) $cursor['id'];
    }

    $sql .= '
         ORDER BY e.expense_date DESC, e.id DESC';
    if ($cursor !== null) {
        $sql .= '
         LIMIT ' . $limitPlusOne;
    } else {
        $sql .= '
         LIMIT ' . $offset . ', ' . $limitPlusOne;
    }

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();

    $hasMore = count($rows) > $limit;
    if ($hasMore) {
        $rows = array_slice($rows, 0, $limit);
    }

    $expenseIds = array_map(static fn(array $row): int => (int) $row['id'], $rows);
    $participantsByExpense = [];
    if ($expenseIds) {
        $placeholders = implode(',', array_fill(0, count($expenseIds), '?'));
        $stmt = $pdo->prepare(
            "SELECT ep.expense_id, ep.user_id, ep.owed_cents, ep.split_value, u.id, u.nickname
             FROM $participantsTable ep
             JOIN $usersTable u ON u.id = ep.user_id
             WHERE ep.expense_id IN ($placeholders)
             ORDER BY ep.expense_id DESC, u.created_at ASC, u.id ASC"
        );
        $stmt->execute($expenseIds);
        foreach ($stmt->fetchAll() as $participant) {
            $expenseId = (int) $participant['expense_id'];
            $participantsByExpense[$expenseId][] = [
                'id' => (int) $participant['id'],
                'nickname' => $participant['nickname'],
                'owed_cents' => (int) ($participant['owed_cents'] ?? 0),
                'split_value' => (int) ($participant['split_value'] ?? 0),
            ];
        }
    }

    foreach ($rows as &$row) {
        $id = (int) $row['id'];
        $amountCents = decimal_to_cents($row['amount']);
        $splitMode = normalize_expense_split_mode($row['split_mode'] ?? 'equal');
        $participantRows = $participantsByExpense[$id] ?? [];
        $storedOwedTotal = 0;
        foreach ($participantRows as $participantRow) {
            $storedOwedTotal += (int) ($participantRow['owed_cents'] ?? 0);
        }
        $hasStoredOwed = count($participantRows) > 0 && $storedOwedTotal === $amountCents;
        $receiptPath = (string) ($row['receipt_path'] ?? '');
        $row['id'] = $id;
        $row['paid_by_id'] = (int) $row['paid_by_id'];
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

    $nextCursor = null;
    if ($hasMore && count($rows) > 0) {
        $last = $rows[count($rows) - 1];
        $nextCursor = pagination_encode_cursor([
            'expense_date' => (string) ($last['expense_date'] ?? ''),
            'id' => (int) ($last['id'] ?? 0),
        ]);
    }
    $isPagedRequest = pagination_requested($query);
    $nextOffset = null;
    if ($hasMore && $cursor === null && $isPagedRequest) {
        $nextOffset = $offset + $limit;
    }

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'expenses' => $rows,
        'pagination' => [
            'mode' => $cursor !== null ? 'cursor' : 'offset',
            'limit' => $limit,
            'offset' => $cursor !== null ? null : $offset,
            'has_more' => $hasMore,
            'next_cursor' => $nextCursor !== '' ? $nextCursor : null,
            'next_offset' => $nextOffset,
        ],
    ]);
}
