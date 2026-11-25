<?php
declare(strict_types=1);

// Personal expenses in group trips: see docs/api/personal-expenses.md.
// They stay out of trip totals and balances, and only their payer sees the details.

function expenses_personal_column_available(PDO $pdo): bool
{
    static $found = [];
    $key = spl_object_id($pdo);
    if (isset($found[$key])) {
        return true;
    }
    try {
        $pdo->query('SELECT is_personal FROM ' . table_name('expenses') . ' LIMIT 0');
    } catch (Throwable $error) {
        return false;
    }
    $found[$key] = true;
    return true;
}

/** `e.is_personal`, or a constant 0 before the migration. */
function expense_is_personal_select(PDO $pdo, string $alias = 'e'): string
{
    $prefix = $alias !== '' ? $alias . '.' : '';
    return expenses_personal_column_available($pdo) ? $prefix . 'is_personal' : '0 AS is_personal';
}

/** ` AND e.is_personal = 0`, which keeps group expenses only; empty before the migration. */
function expense_group_only_sql(PDO $pdo, string $alias = 'e'): string
{
    if (!expenses_personal_column_available($pdo)) {
        return '';
    }
    return ' AND ' . ($alias !== '' ? $alias . '.' : '') . 'is_personal = 0';
}

/** The value of `is_personal` in a request: true, false, or null when it is left out. */
function expense_personal_request_value(array $body): ?bool
{
    if (!array_key_exists('is_personal', $body) || $body['is_personal'] === null) {
        return null;
    }
    $value = $body['is_personal'];
    if (is_bool($value)) {
        return $value;
    }
    if ($value === 0 || $value === 1 || $value === '0' || $value === '1') {
        return (bool) (int) $value;
    }
    json_out(['ok' => false, 'error' => 'Invalid is_personal.'], 400);
}

/**
 * Checks a request that marks an expense personal: only the payer may take part, split equally.
 * Returns true when the expense is to be stored as personal.
 */
function expense_personal_requested(PDO $pdo, array $body, bool $isSoloTrip, int $payerId): bool
{
    if (expense_personal_request_value($body) !== true) {
        return false;
    }
    if ($isSoloTrip) {
        json_out(['ok' => false, 'error' => 'Solo trips have no personal expenses.'], 400);
    }
    if (!expenses_personal_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Personal expenses are not available yet.'], 409);
    }
    $rawParticipants = $body['participants'] ?? [];
    $participants = is_array($rawParticipants) ? normalize_user_ids($rawParticipants) : [];
    $splitMode = strtolower(trim((string) ($body['split_mode'] ?? 'equal')));
    if (($participants !== [] && $participants !== [$payerId]) || ($splitMode !== '' && $splitMode !== 'equal')) {
        json_out(['ok' => false, 'error' => 'Personal expenses cannot be shared.'], 400);
    }
    return true;
}

/**
 * For `update_expense` without `is_personal` (older apps): a personal expense stays personal
 * while it still has only the payer, split equally.
 */
function expense_personal_kept(bool $wasPersonal, int $payerId, array $participantIds, string $splitMode): bool
{
    return $wasPersonal && $splitMode === 'equal' && normalize_user_ids($participantIds) === [$payerId];
}

/** True when the viewer may see this personal expense in full: its payer, or the owner of a guest payer. */
function expense_personal_visible_to(int $payerId, int $viewerId, array $guestIds): bool
{
    return $viewerId > 0 && trip_actor_acts_for($viewerId, $payerId, $guestIds);
}

/** What others see of a personal expense: that it exists, its amount, its date and who paid. */
function lock_personal_expense_row(array $row): array
{
    $amount = (float) ($row['amount'] ?? 0);
    $payerId = (int) ($row['paid_by_id'] ?? 0);
    $payerName = (string) ($row['paid_by_nickname'] ?? '');
    $tripCurrency = (string) ($row['trip_currency_code'] ?? '');
    $locked = [
        'id' => (int) ($row['id'] ?? 0),
        'amount' => $amount,
        'trip_currency_code' => $tripCurrency,
        'expense_currency_code' => $tripCurrency,
        'original_amount' => $amount,
        'fx_rate_to_trip' => 1.0,
        'category' => 'other',
        'subcategory' => null,
        'note' => '',
        'split_mode' => 'equal',
        'expense_date' => $row['expense_date'] ?? null,
        'created_at' => $row['created_at'] ?? null,
        'receipt_path' => null,
        'receipt_url' => null,
        'receipt_thumb_url' => null,
        'paid_by_id' => $payerId,
        'paid_by_nickname' => $payerName,
        'participants' => [[
            'id' => $payerId,
            'nickname' => $payerName,
            'owed' => $amount,
            'split_value' => null,
        ]],
        'is_personal' => true,
        'locked' => true,
    ];
    if (array_key_exists('from_quick_split', $row)) {
        $locked['from_quick_split'] = false;
    }
    return $locked;
}

/**
 * Adds `is_personal` and `locked` to expense rows (with `paid_by_id`), and replaces the rows
 * the viewer may not open with their locked form.
 *
 * @param array<int, array<string, mixed>> $rows
 */
function apply_personal_expense_visibility(PDO $pdo, int $tripId, int $viewerId, array &$rows): void
{
    $guestIds = null;
    foreach ($rows as &$row) {
        $isPersonal = (int) ($row['is_personal'] ?? 0) === 1 || ($row['is_personal'] ?? null) === true;
        $row['is_personal'] = $isPersonal;
        $row['locked'] = false;
        if (!$isPersonal) {
            continue;
        }
        $guestIds ??= trip_guest_ids_for_actor($pdo, $tripId, $viewerId);
        if (!expense_personal_visible_to((int) ($row['paid_by_id'] ?? 0), $viewerId, $guestIds)) {
            $row = lock_personal_expense_row($row);
        }
    }
    unset($row);
}

/** 403 when the expense is personal and the viewer is not its payer. */
function assert_personal_expense_open(PDO $pdo, int $tripId, int $expenseId, int $viewerId): void
{
    if (!expenses_personal_column_available($pdo)) {
        return;
    }
    $stmt = $pdo->prepare(
        'SELECT paid_by, is_personal FROM ' . table_name('expenses') . ' WHERE id = :id AND trip_id = :trip_id LIMIT 1'
    );
    $stmt->execute(['id' => $expenseId, 'trip_id' => $tripId]);
    $row = $stmt->fetch();
    if (!$row || (int) ($row['is_personal'] ?? 0) !== 1) {
        return;
    }
    if (!expense_personal_visible_to((int) $row['paid_by'], $viewerId, trip_guest_ids_for_actor($pdo, $tripId, $viewerId))) {
        json_out(['ok' => false, 'error' => 'Personal expense is locked.'], 403);
    }
}

/** What others see of an `expense.*` activity event of a personal expense. */
function lock_personal_activity_payload(array $payload): array
{
    return [
        'amount_cents' => (int) ($payload['amount_cents'] ?? 0),
        'trip_currency_code' => (string) ($payload['trip_currency_code'] ?? ''),
        'is_personal' => true,
    ];
}

/** The viewer's own personal expenses in a trip, in trip cents. */
function personal_expense_total_cents(PDO $pdo, int $tripId, int $userId): int
{
    if (!expenses_personal_column_available($pdo)) {
        return 0;
    }
    $stmt = $pdo->prepare(
        'SELECT COALESCE(SUM(CAST(ROUND(amount * 100) AS SIGNED)), 0) FROM ' . table_name('expenses') . '
         WHERE trip_id = :trip_id AND paid_by = :user_id AND is_personal = 1'
    );
    $stmt->execute(['trip_id' => $tripId, 'user_id' => $userId]);
    return (int) $stmt->fetchColumn();
}
