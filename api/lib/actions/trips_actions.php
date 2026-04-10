<?php
declare(strict_types=1);

function trip_invite_ttl_seconds(): int
{
    // 14 days by default for practical sharing.
    return 1_209_600;
}

function trip_invite_code_length(): int
{
    return 10;
}

function trip_invite_preview_ttl_seconds(): int
{
    // Short-lived confirmation token to bind preview -> join.
    return 180;
}

function trip_invite_preview_nonce_length(): int
{
    return 40;
}

function create_trip_invite_preview_nonce(): string
{
    // 20 bytes => 40 hex chars.
    return bin2hex(random_bytes(20));
}

function normalize_trip_invite_preview_nonce(string $raw): string
{
    $nonce = strtolower(trim($raw));
    if ($nonce === '') {
        json_out(['ok' => false, 'error' => 'preview_nonce is required.'], 400);
    }
    if (!preg_match('/^[a-f0-9]{' . trip_invite_preview_nonce_length() . '}$/', $nonce)) {
        json_out(['ok' => false, 'error' => 'Invalid preview_nonce.'], 400);
    }
    return $nonce;
}

function trip_invite_preview_tokens_table_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $table = trim(table_name('trip_invite_preview_tokens'), '`');
    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $table]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function create_trip_invite_code(): string
{
    $alphabet = 'abcdefghijklmnopqrstuvwxyz0123456789';
    $maxIndex = strlen($alphabet) - 1;
    $length = trip_invite_code_length();
    $code = '';
    for ($i = 0; $i < $length; $i++) {
        $code .= $alphabet[random_int(0, $maxIndex)];
    }
    return $code;
}

function normalize_trip_invite_code(string $raw): string
{
    $value = strtolower(trim($raw));
    if ($value === '') {
        json_out(['ok' => false, 'error' => 'invite_token is required.'], 400);
    }
    $value = trim(rawurldecode($value));

    if (str_contains($value, '://')) {
        $query = (string) parse_url($value, PHP_URL_QUERY);
        if ($query !== '') {
            $queryParams = [];
            parse_str($query, $queryParams);
            $candidate = strtolower(trim((string) ($queryParams['invite'] ?? '')));
            if ($candidate !== '') {
                $value = $candidate;
            }
        }
    }

    if (preg_match('/^[a-z0-9]{' . trip_invite_code_length() . '}$/', $value)) {
        return $value;
    }
    if (preg_match('/^[a-z0-9][a-z0-9-]*-([a-z0-9]{' . trip_invite_code_length() . '})$/', $value, $match)) {
        return (string) ($match[1] ?? '');
    }

    json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
}

function trip_invite_trip_slug(string $tripName): string
{
    $normalized = trim((string) preg_replace('/\s+/u', ' ', $tripName));
    if ($normalized === '') {
        return 'trip';
    }

    $ascii = $normalized;
    if (function_exists('iconv')) {
        $converted = @iconv('UTF-8', 'ASCII//TRANSLIT//IGNORE', $normalized);
        if (is_string($converted) && trim($converted) !== '') {
            $ascii = $converted;
        }
    }

    $slug = strtolower($ascii);
    $slug = (string) preg_replace('/[^a-z0-9]+/', '-', $slug);
    $slug = trim($slug, '-');
    if ($slug === '') {
        $slug = 'trip';
    }

    if (strlen($slug) > 40) {
        $slug = rtrim(substr($slug, 0, 40), '-');
    }
    return $slug !== '' ? $slug : 'trip';
}

function build_trip_invite_url(string $inviteCode, string $tripName = ''): string
{
    $base = trim((string) PUBLIC_BASE_URL);
    if ($base === '') {
        $base = 'https://splyto.egm.lv';
    }
    $base = rtrim($base, '/');
    $base = preg_replace('#/api$#', '', $base) ?: $base;

    $code = strtolower(trim($inviteCode));
    if (!preg_match('/^[a-z0-9]{' . trip_invite_code_length() . '}$/', $code)) {
        throw new RuntimeException('Invalid invite code.');
    }
    $tripTag = trip_invite_trip_slug($tripName) . '-' . $code;

    return $base . '/invite?invite=' . rawurlencode($tripTag);
}

function trip_user_paid_in_preferred_currency_cents(
    PDO $pdo,
    int $tripId,
    int $userId,
    string $tripCurrencyCode,
    string $preferredCurrencyCode
): ?int {
    if ($tripId <= 0 || $userId <= 0) {
        return null;
    }

    $expensesTable = table_name('expenses');
    $expenseCurrencyColumnsAvailable = expenses_currency_columns_available($pdo);
    $selectCurrencySql = $expenseCurrencyColumnsAvailable
        ? 'e.currency_code'
        : 'NULL AS currency_code';
    $selectSourceAmountSql = $expenseCurrencyColumnsAvailable
        ? 'e.source_amount'
        : 'e.amount AS source_amount';

    $stmt = $pdo->prepare(
        'SELECT
            e.amount,
            ' . $selectCurrencySql . ',
            ' . $selectSourceAmountSql . ',
            e.expense_date,
            e.created_at
         FROM ' . $expensesTable . ' e
         WHERE e.trip_id = :trip_id
           AND e.paid_by = :user_id'
    );
    $stmt->execute([
        'trip_id' => $tripId,
        'user_id' => $userId,
    ]);
    $rows = $stmt->fetchAll();
    if (!$rows) {
        return 0;
    }

    $tripCurrency = normalize_currency_code_or_default($tripCurrencyCode);
    $preferredCurrency = normalize_currency_code_or_default($preferredCurrencyCode);
    $totalCents = 0;

    foreach ($rows as $row) {
        $tripAmountCents = decimal_to_cents($row['amount'] ?? 0);
        if ($tripAmountCents <= 0) {
            continue;
        }

        $sourceAmountCents = decimal_to_cents($row['source_amount'] ?? 0);
        if ($sourceAmountCents <= 0) {
            $sourceAmountCents = $tripAmountCents;
        }
        $sourceCurrency = $expenseCurrencyColumnsAvailable
            ? normalize_currency_code_or_default($row['currency_code'] ?? $tripCurrency)
            : $tripCurrency;

        $expenseDate = trim((string) ($row['expense_date'] ?? ''));
        if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $expenseDate)) {
            $createdAt = trim((string) ($row['created_at'] ?? ''));
            $expenseDate = strlen($createdAt) >= 10 ? substr($createdAt, 0, 10) : date('Y-m-d');
        }

        $converted = convert_expense_amount_to_target_currency_cents(
            $sourceAmountCents,
            $sourceCurrency,
            $tripAmountCents,
            $tripCurrency,
            $expenseDate,
            $preferredCurrency
        );
        if (!is_int($converted)) {
            return null;
        }
        $totalCents += $converted;
    }

    return $totalCents;
}

function trips_action(): void
{
    $me = get_me();
    $pdo = db();
    $currentUserId = (int) ($me['id'] ?? 0);
    $freshMe = $currentUserId > 0 ? fetch_me_row_by_id($pdo, $currentUserId) : null;
    $preferredCurrencyCode = normalize_profile_currency_code_or_default(
        (is_array($freshMe) ? ($freshMe['preferred_currency_code'] ?? null) : null)
            ?? default_trip_currency_code()
    );
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $settlementsTable = table_name('settlements');
    $expensesTable = table_name('expenses');
    $participantsTable = table_name('expense_participants');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 't.image_path'
        : 'NULL AS image_path';
    $tripCurrencySelect = trips_currency_column_available($pdo)
        ? 't.currency_code'
        : '\'' . default_trip_currency_code() . '\' AS currency_code';
    $tripDateFromSelect = trips_date_range_columns_available($pdo)
        ? 't.date_from'
        : 'NULL AS date_from';
    $tripDateToSelect = trips_date_range_columns_available($pdo)
        ? 't.date_to'
        : 'NULL AS date_to';
    $tripImageGroupBy = trips_image_column_available($pdo)
        ? ', t.image_path'
        : '';
    $tripCurrencyGroupBy = trips_currency_column_available($pdo)
        ? ', t.currency_code'
        : '';
    $tripDateGroupBy = trips_date_range_columns_available($pdo)
        ? ', t.date_from, t.date_to'
        : '';

    $stmt = $pdo->prepare(
        'SELECT
            t.id,
            t.name,
            ' . $tripCurrencySelect . ',
            t.status,
            t.created_by,
            ' . $tripImageSelect . ',
            t.created_at,
            ' . $tripDateFromSelect . ',
            ' . $tripDateToSelect . ',
            t.ended_at,
            t.archived_at,
            (
              SELECT COUNT(*)
              FROM ' . $settlementsTable . ' s
              WHERE s.trip_id = t.id
            ) AS settlements_total,
            (
              SELECT COUNT(*)
              FROM ' . $settlementsTable . ' s
              WHERE s.trip_id = t.id
                AND s.status = "confirmed"
            ) AS settlements_confirmed,
            (
              SELECT COALESCE(SUM(CAST(ROUND(e.amount * 100) AS SIGNED)), 0)
              FROM ' . $expensesTable . ' e
              WHERE e.trip_id = t.id
            ) AS total_amount_cents,
            (
              SELECT COALESCE(SUM(CAST(ROUND(e2.amount * 100) AS SIGNED)), 0)
              FROM ' . $expensesTable . ' e2
              WHERE e2.trip_id = t.id
                AND e2.paid_by = tm.user_id
            ) AS my_paid_cents,
            (
              SELECT COALESCE(SUM(ep.owed_cents), 0)
              FROM ' . $participantsTable . ' ep
              JOIN ' . $expensesTable . ' e3 ON e3.id = ep.expense_id
              WHERE e3.trip_id = t.id
                AND ep.user_id = tm.user_id
            ) AS my_owed_cents,
            (
              SELECT COUNT(*)
              FROM ' . $tripMembersTable . ' tm2
              WHERE tm2.trip_id = t.id
            ) AS members_count
         FROM ' . $tripsTable . ' t
         JOIN ' . $tripMembersTable . ' tm ON tm.trip_id = t.id
         WHERE tm.user_id = :user_id
         GROUP BY
            t.id,
            tm.user_id,
            t.name,
            t.status,
            t.created_by,
            t.created_at,
            t.ended_at,
            t.archived_at' . $tripImageGroupBy . $tripCurrencyGroupBy . $tripDateGroupBy . '
         ORDER BY t.created_at DESC, t.id DESC'
    );
    $stmt->execute(['user_id' => $currentUserId]);
    $rows = $stmt->fetchAll();

    $activeTripId = null;
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $row['currency_code'] = normalize_currency_code(
            $row['currency_code'] ?? default_trip_currency_code()
        );
        $row['status'] = normalize_trip_status($row['status'] ?? 'active');
        $row['created_by'] = $row['created_by'] !== null ? (int) $row['created_by'] : null;
        $imagePath = trim((string) ($row['image_path'] ?? ''));
        $row['image_url'] = $imagePath !== '' ? trip_image_public_url($imagePath) : null;
        $row['image_thumb_url'] = $imagePath !== '' ? trip_image_thumb_public_url($imagePath) : null;
        unset($row['image_path']);
        $row['members_count'] = (int) $row['members_count'];
        $row['date_from'] = $row['date_from'] ?: null;
        $row['date_to'] = $row['date_to'] ?: null;
        $row['ended_at'] = $row['ended_at'] ?: null;
        $row['archived_at'] = $row['archived_at'] ?: null;
        $row['settlements_total'] = (int) ($row['settlements_total'] ?? 0);
        $row['settlements_confirmed'] = (int) ($row['settlements_confirmed'] ?? 0);
        $row['total_amount_cents'] = (int) ($row['total_amount_cents'] ?? 0);
        $row['my_paid_cents'] = (int) ($row['my_paid_cents'] ?? 0);
        $row['my_owed_cents'] = (int) ($row['my_owed_cents'] ?? 0);
        $row['settlements_pending'] = max(
            0,
            $row['settlements_total'] - $row['settlements_confirmed']
        );

        // Keep trips list math consistent with workspace balances math.
        $computed = compute_trip_balance_data($pdo, (int) $row['id']);
        $stats = $computed['stats'] ?? [];
        if (is_array($stats) && isset($stats[$currentUserId]) && is_array($stats[$currentUserId])) {
            $myStats = $stats[$currentUserId];
            $row['my_paid_cents'] = (int) ($myStats['paid_cents'] ?? 0);
            $row['my_owed_cents'] = (int) ($myStats['owed_cents'] ?? 0);
        }
        $row['preferred_currency_code'] = $preferredCurrencyCode;
        if ($row['my_paid_cents'] <= 0) {
            $row['my_paid_preferred_cents'] = 0;
        } elseif ($row['currency_code'] === $preferredCurrencyCode) {
            $row['my_paid_preferred_cents'] = $row['my_paid_cents'];
        } else {
            $row['my_paid_preferred_cents'] = trip_user_paid_in_preferred_currency_cents(
                $pdo,
                (int) $row['id'],
                $currentUserId,
                $row['currency_code'],
                $preferredCurrencyCode
            );
        }
        $row['my_balance_cents'] = $row['my_owed_cents'] - $row['my_paid_cents'];
        $row['all_settled'] = $row['settlements_total'] > 0 && $row['settlements_total'] === $row['settlements_confirmed'];
        $row['ready_to_settle'] = $row['status'] === 'settling' && $row['settlements_pending'] > 0;
        if ($activeTripId === null && $row['status'] === 'active') {
            $activeTripId = (int) $row['id'];
        }
    }
    unset($row);

    $activeTrip = get_current_trip($pdo, $me, false);
    json_out([
        'ok' => true,
        'trips' => $rows,
        'active_trip_id' => $activeTripId ?? ($activeTrip ? (int) $activeTrip['id'] : null),
    ]);
}

function all_users_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, false);
    if (!$trip) {
        json_out([
            'ok' => true,
            'trip' => null,
            'users' => [[
                'id' => (int) $me['id'],
                'nickname' => (string) ($me['nickname'] ?? ''),
            ]],
        ]);
    }

    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $readySelect = trip_members_ready_columns_available($pdo)
        ? 'tm.ready_to_settle, tm.ready_to_settle_at, '
        : '1 AS ready_to_settle, NULL AS ready_to_settle_at, ';
    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $readySelect . 'u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => (int) $trip['id']]);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $row['is_ready_to_settle'] = ((int) ($row['ready_to_settle'] ?? 0)) === 1;
        $row['ready_to_settle_at'] = $row['ready_to_settle_at'] ?: null;
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path'], $row['ready_to_settle']);
    }
    unset($row);
    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'users' => $rows,
    ]);
}


function create_trip_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripCurrencyColumnAvailable = trips_currency_column_available($pdo);
    $tripDateColumnsAvailable = trips_date_range_columns_available($pdo);

    $name = trim((string) ($body['name'] ?? ''));
    if (str_length($name) < 2 || str_length($name) > 120) {
        json_out(['ok' => false, 'error' => 'Trip name must be 2-120 chars.'], 400);
    }
    ensure_text_has_no_links($name, 'Trip name');
    $currencyCode = normalize_currency_code($body['currency_code'] ?? default_trip_currency_code());
    if (!$tripCurrencyColumnAvailable && $currencyCode !== default_trip_currency_code()) {
        json_out([
            'ok' => false,
            'error' => 'Trip currency support is not enabled on server yet. Run migration first.',
        ], 409);
    }
    $dateFromRaw = trim((string) ($body['date_from'] ?? ''));
    $dateToRaw = trim((string) ($body['date_to'] ?? ''));
    $hasDateFrom = $dateFromRaw !== '';
    $hasDateTo = $dateToRaw !== '';
    if ($hasDateFrom xor $hasDateTo) {
        json_out([
            'ok' => false,
            'error' => 'Trip period must include both date_from and date_to.',
        ], 400);
    }
    $dateFrom = null;
    $dateTo = null;
    if ($hasDateFrom && $hasDateTo) {
        $dateFrom = validate_date_iso($dateFromRaw);
        $dateTo = validate_date_iso($dateToRaw);
        if ($dateTo < $dateFrom) {
            json_out([
                'ok' => false,
                'error' => 'Trip end date must be on or after start date.',
            ], 400);
        }
    }
    if (($dateFrom !== null || $dateTo !== null) && !$tripDateColumnsAvailable) {
        json_out([
            'ok' => false,
            'error' => 'Trip date range support is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $meId = (int) ($me['id'] ?? 0);
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
        (string) $meId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $memberIds = require_valid_user_ids($pdo, (array) ($body['member_ids'] ?? []), false);
    $memberIds[] = $meId;
    $memberIds = normalize_user_ids($memberIds);
    if (count($memberIds) < 1) {
        json_out(['ok' => false, 'error' => 'Trip must include at least one member.'], 400);
    }
    $creatorId = (int) ($me['id'] ?? 0);
    $creatorName = trim((string) ($me['nickname'] ?? ''));
    if ($creatorName === '') {
        $creatorName = 'Trip member';
    }

    $pdo->beginTransaction();
    try {
        if ($tripCurrencyColumnAvailable) {
            if ($tripDateColumnsAvailable) {
                $insertTrip = $pdo->prepare(
                    'INSERT INTO ' . $tripsTable . ' (name, currency_code, created_by, date_from, date_to)
                     VALUES (:name, :currency_code, :created_by, :date_from, :date_to)'
                );
                $insertTrip->execute([
                    'name' => $name,
                    'currency_code' => $currencyCode,
                    'created_by' => $meId,
                    'date_from' => $dateFrom,
                    'date_to' => $dateTo,
                ]);
            } else {
                $insertTrip = $pdo->prepare(
                    'INSERT INTO ' . $tripsTable . ' (name, currency_code, created_by)
                     VALUES (:name, :currency_code, :created_by)'
                );
                $insertTrip->execute([
                    'name' => $name,
                    'currency_code' => $currencyCode,
                    'created_by' => $meId,
                ]);
            }
        } else {
            if ($tripDateColumnsAvailable) {
                $insertTrip = $pdo->prepare(
                    'INSERT INTO ' . $tripsTable . ' (name, created_by, date_from, date_to)
                     VALUES (:name, :created_by, :date_from, :date_to)'
                );
                $insertTrip->execute([
                    'name' => $name,
                    'created_by' => $meId,
                    'date_from' => $dateFrom,
                    'date_to' => $dateTo,
                ]);
            } else {
                $insertTrip = $pdo->prepare(
                    'INSERT INTO ' . $tripsTable . ' (name, created_by)
                     VALUES (:name, :created_by)'
                );
                $insertTrip->execute([
                    'name' => $name,
                    'created_by' => $meId,
                ]);
            }
        }
        $tripId = (int) $pdo->lastInsertId();

        $insertMember = $pdo->prepare(
            'INSERT INTO ' . $tripMembersTable . ' (trip_id, user_id)
             VALUES (:trip_id, :user_id)'
        );
        $notifyUserIds = [];
        foreach ($memberIds as $userId) {
            $insertMember->execute([
                'trip_id' => $tripId,
                'user_id' => (int) $userId,
            ]);
            if ((int) $userId !== $creatorId) {
                $notifyUserIds[] = (int) $userId;
            }
        }

        foreach ($notifyUserIds as $userId) {
            create_user_notification(
                $pdo,
                $tripId,
                $userId,
                'trip_added',
                'Added to trip',
                $creatorName . ' added you to trip "' . $name . '".',
                [
                    'trip_id' => $tripId,
                    'added_by_user_id' => $creatorId,
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

    json_out([
        'ok' => true,
        'trip' => [
            'id' => $tripId,
            'name' => $name,
            'currency_code' => $currencyCode,
            'status' => 'active',
            'created_by' => $meId,
            'date_from' => $dateFrom,
            'date_to' => $dateTo,
            'ended_at' => null,
            'archived_at' => null,
            'image_url' => null,
            'image_thumb_url' => null,
            'members_count' => count($memberIds),
        ],
    ]);
}

function update_trip_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageColumnAvailable = trips_image_column_available($pdo);
    $tripCurrencyColumnAvailable = trips_currency_column_available($pdo);

    $tripId = (int) ($body['id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Trip id is required.'], 400);
    }

    $trip = find_trip_for_user($pdo, (int) $me['id'], $tripId);
    if (!$trip) {
        json_out(['ok' => false, 'error' => 'Trip not found or access denied.'], 403);
    }
    $trip = normalize_trip_row($trip);

    $creatorId = (int) ($trip['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only trip creator can edit this trip.'], 403);
    }

    $hasName = array_key_exists('name', $body);
    $hasCurrencyCode = array_key_exists('currency_code', $body);
    $hasImagePath = array_key_exists('image_path', $body);
    $removeImage = (bool) ($body['remove_image'] ?? false);
    if (($hasImagePath || $removeImage) && !$tripImageColumnAvailable) {
        json_out(['ok' => false, 'error' => 'Trip image support is not enabled on server yet. Run migration first.'], 409);
    }
    if ($hasCurrencyCode && !$tripCurrencyColumnAvailable) {
        json_out(['ok' => false, 'error' => 'Trip currency support is not enabled on server yet. Run migration first.'], 409);
    }
    if (!$hasName && !$hasCurrencyCode && !$hasImagePath && !$removeImage) {
        json_out(['ok' => false, 'error' => 'No trip changes provided.'], 400);
    }

    $nextName = (string) ($trip['name'] ?? '');
    if ($hasName) {
        $name = trim((string) ($body['name'] ?? ''));
        if (str_length($name) < 2 || str_length($name) > 120) {
            json_out(['ok' => false, 'error' => 'Trip name must be 2-120 chars.'], 400);
        }
        ensure_text_has_no_links($name, 'Trip name');
        $nextName = $name;
    }
    $nextCurrencyCode = normalize_currency_code(
        $trip['currency_code'] ?? default_trip_currency_code()
    );
    if ($hasCurrencyCode) {
        $nextCurrencyCode = normalize_currency_code($body['currency_code'] ?? '');
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
        (string) ((int) $me['id']),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $oldImagePath = trim((string) ($trip['image_path'] ?? ''));
    $nextImagePath = $oldImagePath;
    if ($hasImagePath) {
        $incomingImagePath = normalize_trip_image_path((string) ($body['image_path'] ?? ''), true);
        if ($incomingImagePath !== '') {
            $nextImagePath = $incomingImagePath;
        }
    }
    if ($removeImage) {
        $nextImagePath = '';
    }

    if ($tripImageColumnAvailable && $tripCurrencyColumnAvailable) {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name,
                 currency_code = :currency_code,
                 image_path = :image_path
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'currency_code' => $nextCurrencyCode,
            'image_path' => $nextImagePath !== '' ? $nextImagePath : null,
            'id' => $tripId,
        ]);
    } elseif ($tripCurrencyColumnAvailable) {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name,
                 currency_code = :currency_code
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'currency_code' => $nextCurrencyCode,
            'id' => $tripId,
        ]);
    } elseif ($tripImageColumnAvailable) {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name,
                 image_path = :image_path
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'image_path' => $nextImagePath !== '' ? $nextImagePath : null,
            'id' => $tripId,
        ]);
    } else {
        $update = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET name = :name
             WHERE id = :id'
        );
        $update->execute([
            'name' => $nextName,
            'id' => $tripId,
        ]);
    }

    if ($tripImageColumnAvailable && $oldImagePath !== '' && $oldImagePath !== $nextImagePath) {
        delete_trip_image_file($oldImagePath);
    }

    $fresh = find_trip_for_user($pdo, (int) $me['id'], $tripId);
    if (!$fresh) {
        json_out(['ok' => false, 'error' => 'Trip not found after update.'], 404);
    }
    $fresh = normalize_trip_row($fresh);

    $countStmt = $pdo->prepare(
        'SELECT COUNT(*) AS c
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id'
    );
    $countStmt->execute(['trip_id' => $tripId]);
    $membersCount = (int) ($countStmt->fetchColumn() ?: 0);

    json_out([
        'ok' => true,
        'trip' => [
            'id' => (int) ($fresh['id'] ?? 0),
            'name' => (string) ($fresh['name'] ?? ''),
            'currency_code' => normalize_currency_code(
                $fresh['currency_code'] ?? default_trip_currency_code()
            ),
            'status' => normalize_trip_status($fresh['status'] ?? 'active'),
            'created_by' => array_key_exists('created_by', $fresh) && $fresh['created_by'] !== null
                ? (int) $fresh['created_by']
                : null,
            'date_from' => array_key_exists('date_from', $fresh) ? ($fresh['date_from'] ?: null) : null,
            'date_to' => array_key_exists('date_to', $fresh) ? ($fresh['date_to'] ?: null) : null,
            'ended_at' => array_key_exists('ended_at', $fresh) ? ($fresh['ended_at'] ?: null) : null,
            'archived_at' => array_key_exists('archived_at', $fresh) ? ($fresh['archived_at'] ?: null) : null,
            'image_url' => trim((string) ($fresh['image_path'] ?? '')) !== ''
                ? trip_image_public_url((string) $fresh['image_path'])
                : null,
            'image_thumb_url' => trim((string) ($fresh['image_path'] ?? '')) !== ''
                ? trip_image_thumb_public_url((string) $fresh['image_path'])
                : null,
            'members_count' => $membersCount,
        ],
    ]);
}

function delete_trip_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $tripsTable = table_name('trips');
    $expensesTable = table_name('expenses');

    $tripId = (int) ($body['id'] ?? 0);
    if ($tripId <= 0) {
        $tripId = parse_trip_id_from_request();
    }
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Trip id is required.'], 400);
    }

    $actorId = (int) ($me['id'] ?? 0);
    $trip = find_trip_for_user($pdo, $actorId, $tripId);
    if (!$trip) {
        json_out(['ok' => false, 'error' => 'Trip not found or access denied.'], 403);
    }
    $trip = normalize_trip_row($trip);

    $creatorId = (int) ($trip['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== $actorId) {
        json_out(['ok' => false, 'error' => 'Only trip creator can delete this trip.'], 403);
    }

    if (normalize_trip_status($trip['status'] ?? 'active') !== 'active') {
        json_out([
            'ok' => false,
            'error' => 'Only active trips can be deleted.',
        ], 409);
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
        (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $expensesCountStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $expensesTable . '
         WHERE trip_id = :trip_id'
    );
    $expensesCountStmt->execute(['trip_id' => $tripId]);
    $expensesCount = (int) ($expensesCountStmt->fetchColumn() ?: 0);
    if ($expensesCount > 0) {
        json_out([
            'ok' => false,
            'error' => 'Trip cannot be deleted because it already has expenses.',
        ], 409);
    }

    $delete = $pdo->prepare(
        'DELETE FROM ' . $tripsTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $delete->execute(['id' => $tripId]);
    if ((int) $delete->rowCount() < 1) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }

    $imagePath = trim((string) ($trip['image_path'] ?? ''));
    if ($imagePath !== '') {
        delete_trip_image_file($imagePath);
    }

    json_out([
        'ok' => true,
        'deleted' => true,
        'trip_id' => $tripId,
    ]);
}

function add_trip_members_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) $trip['id'];

    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 'image_path'
        : 'NULL AS image_path';
    $tripCurrencySelect = trips_currency_column_available($pdo)
        ? 'currency_code'
        : '\'' . default_trip_currency_code() . '\' AS currency_code';

    $metaStmt = $pdo->prepare(
        'SELECT id, name, ' . $tripCurrencySelect . ', status, created_by, ended_at, archived_at, ' . $tripImageSelect . '
         FROM ' . $tripsTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $metaStmt->execute(['id' => $tripId]);
    $tripMeta = $metaStmt->fetch();
    if (!$tripMeta) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }
    $tripMeta['status'] = normalize_trip_status($tripMeta['status'] ?? 'active');
    assert_trip_is_active($tripMeta);

    $creatorId = (int) ($tripMeta['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== (int) $me['id']) {
        json_out(['ok' => false, 'error' => 'Only trip creator can edit members.'], 403);
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
        (string) ((int) $me['id']),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $memberIds = require_valid_user_ids($pdo, (array) ($body['member_ids'] ?? []), true);
    $memberIds = normalize_user_ids($memberIds);
    if (count($memberIds) < 1) {
        json_out(['ok' => false, 'error' => 'Pick at least one user.'], 400);
    }
    $actorId = (int) ($me['id'] ?? 0);
    $actorName = trim((string) ($me['nickname'] ?? ''));
    if ($actorName === '') {
        $actorName = 'Trip member';
    }
    $tripName = trim((string) ($tripMeta['name'] ?? ''));

    $pdo->beginTransaction();
    $addedCount = 0;
    try {
        $insert = $pdo->prepare(
            'INSERT IGNORE INTO ' . $tripMembersTable . ' (trip_id, user_id)
             VALUES (:trip_id, :user_id)'
        );
        $addedUserIds = [];
        foreach ($memberIds as $userId) {
            $insert->execute([
                'trip_id' => $tripId,
                'user_id' => (int) $userId,
            ]);
            $rowCount = (int) $insert->rowCount();
            $addedCount += $rowCount;
            if ($rowCount > 0 && (int) $userId !== $actorId) {
                $addedUserIds[] = (int) $userId;
            }
        }

        $tripLabel = $tripName !== '' ? $tripName : ('Trip #' . $tripId);
        foreach ($addedUserIds as $userId) {
            create_user_notification(
                $pdo,
                $tripId,
                $userId,
                'trip_member_added',
                'Added to trip',
                $actorName . ' added you to trip "' . $tripLabel . '".',
                [
                    'trip_id' => $tripId,
                    'added_by_user_id' => $actorId,
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

    $countStmt = $pdo->prepare(
        'SELECT COUNT(*) AS c
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id'
    );
    $countStmt->execute(['trip_id' => $tripId]);
    $membersCount = (int) ($countStmt->fetchColumn() ?: 0);

    json_out([
        'ok' => true,
        'trip' => [
            'id' => $tripId,
            'name' => (string) ($tripMeta['name'] ?? ''),
            'currency_code' => normalize_currency_code(
                $tripMeta['currency_code'] ?? default_trip_currency_code()
            ),
            'status' => (string) ($tripMeta['status'] ?? 'active'),
            'created_by' => $creatorId,
            'ended_at' => $tripMeta['ended_at'] ?: null,
            'archived_at' => $tripMeta['archived_at'] ?: null,
            'image_url' => trim((string) ($tripMeta['image_path'] ?? '')) !== ''
                ? trip_image_public_url((string) $tripMeta['image_path'])
                : null,
            'image_thumb_url' => trim((string) ($tripMeta['image_path'] ?? '')) !== ''
                ? trip_image_thumb_public_url((string) $tripMeta['image_path'])
                : null,
            'members_count' => $membersCount,
        ],
        'added_count' => $addedCount,
    ]);
}

function create_trip_invite_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
    }

    $status = normalize_trip_status($trip['status'] ?? 'active');
    if ($status !== 'active') {
        json_out(['ok' => false, 'error' => 'Invite links are available only for active trips.'], 409);
    }

    $creatorId = (int) ($trip['created_by'] ?? 0);
    $actorId = (int) ($me['id'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== $actorId) {
        json_out(['ok' => false, 'error' => 'Only trip creator can generate invite links.'], 403);
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
        (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $tripInvitesTable = table_name('trip_invites');
    $expiresAtTs = time() + trip_invite_ttl_seconds();
    $expiresAt = gmdate('Y-m-d H:i:s', $expiresAtTs);

    $inviteCode = '';
    for ($attempt = 0; $attempt < 6; $attempt++) {
        $candidate = create_trip_invite_code();
        try {
            $pdo->prepare(
                'INSERT INTO ' . $tripInvitesTable . ' (trip_id, created_by, invite_code, expires_at)
                 VALUES (:trip_id, :created_by, :invite_code, :expires_at)'
            )->execute([
                'trip_id' => $tripId,
                'created_by' => $actorId,
                'invite_code' => $candidate,
                'expires_at' => $expiresAt,
            ]);

            // Keep a single currently active invite per trip to avoid stale links.
            $pdo->prepare(
                'UPDATE ' . $tripInvitesTable . '
                 SET revoked_at = NOW()
                 WHERE trip_id = :trip_id
                   AND invite_code <> :invite_code
                   AND revoked_at IS NULL
                   AND expires_at > NOW()'
            )->execute([
                'trip_id' => $tripId,
                'invite_code' => $candidate,
            ]);

            $inviteCode = $candidate;
            break;
        } catch (Throwable $error) {
            $errorCode = (string) ($error->getCode() ?? '');
            if ($errorCode === '23000') {
                continue;
            }
            throw $error;
        }
    }

    if ($inviteCode === '') {
        json_out(['ok' => false, 'error' => 'Failed to generate invite link.'], 500);
    }

    json_out([
        'ok' => true,
        'trip_id' => $tripId,
        'invite_token' => $inviteCode,
        'invite_url' => build_trip_invite_url($inviteCode, (string) ($trip['name'] ?? '')),
        'expires_in_sec' => trip_invite_ttl_seconds(),
        'expires_at' => $expiresAt,
    ]);
}

function preview_trip_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $inviteCode = normalize_trip_invite_code((string) ($body['invite_token'] ?? ''));

    $pdo = db();
    $actorId = (int) ($me['id'] ?? 0);
    if (!trip_invite_preview_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Invite confirmation is not enabled on server yet. Run migration first.',
        ], 409);
    }
    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripInvitesTable = table_name('trip_invites');
    $tripInvitePreviewTokensTable = table_name('trip_invite_preview_tokens');
    $usersTable = table_name('users');
    $usersNameColumnsAvailable = users_name_columns_available($pdo);
    $inviterNameSelect = $usersNameColumnsAvailable
        ? 'u.first_name AS inviter_first_name, u.last_name AS inviter_last_name,'
        : 'NULL AS inviter_first_name, NULL AS inviter_last_name,';

    $inviteStmt = $pdo->prepare(
        'SELECT
            i.trip_id,
            i.expires_at,
            i.revoked_at,
            t.name AS trip_name,
            t.status AS trip_status,
            t.created_by AS inviter_id,
            ' . $inviterNameSelect . '
            u.nickname AS inviter_nickname
         FROM ' . $tripInvitesTable . ' i
         JOIN ' . $tripsTable . ' t ON t.id = i.trip_id
         JOIN ' . $usersTable . ' u ON u.id = t.created_by
         WHERE i.invite_code = :invite_code
         LIMIT 1'
    );
    $inviteStmt->execute(['invite_code' => $inviteCode]);
    $invite = $inviteStmt->fetch();
    if (!$invite) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
    }

    $revokedAt = trim((string) ($invite['revoked_at'] ?? ''));
    if ($revokedAt !== '') {
        json_out(['ok' => false, 'error' => 'Invite token expired.'], 409);
    }
    $expiresAt = trim((string) ($invite['expires_at'] ?? ''));
    if ($expiresAt === '' || strtotime($expiresAt) === false || strtotime($expiresAt) < time()) {
        json_out(['ok' => false, 'error' => 'Invite token expired.'], 409);
    }

    $tripId = (int) ($invite['trip_id'] ?? 0);
    if ($tripId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
    }

    $status = normalize_trip_status($invite['trip_status'] ?? 'active');
    if ($status !== 'active') {
        json_out(['ok' => false, 'error' => 'Trip is closed.'], 409);
    }

    $memberStmt = $pdo->prepare(
        'SELECT 1
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id
           AND user_id = :user_id
         LIMIT 1'
    );
    $memberStmt->execute([
        'trip_id' => $tripId,
        'user_id' => $actorId,
    ]);
    $alreadyMember = (bool) $memberStmt->fetchColumn();

    $inviterDisplayName = me_display_name([
        'first_name' => $invite['inviter_first_name'] ?? null,
        'last_name' => $invite['inviter_last_name'] ?? null,
        'nickname' => $invite['inviter_nickname'] ?? '',
    ]);

    // Cleanup stale/used confirmation tokens for this user before issuing a new one.
    $pdo->prepare(
        'DELETE FROM ' . $tripInvitePreviewTokensTable . '
         WHERE user_id = :user_id
           AND (used_at IS NOT NULL OR expires_at <= UTC_TIMESTAMP())'
    )->execute([
        'user_id' => $actorId,
    ]);

    $previewNonce = '';
    $previewNonceExpiresAt = '';
    for ($attempt = 0; $attempt < 6; $attempt++) {
        $candidate = create_trip_invite_preview_nonce();
        $candidateHash = hash('sha256', $candidate);
        $candidateExpiresTs = min(
            strtotime($expiresAt) ?: (time() + trip_invite_preview_ttl_seconds()),
            time() + trip_invite_preview_ttl_seconds()
        );
        $candidateExpiresAt = gmdate('Y-m-d H:i:s', $candidateExpiresTs);
        try {
            $pdo->prepare(
                'INSERT INTO ' . $tripInvitePreviewTokensTable . '
                 (user_id, trip_id, invite_code, nonce_hash, expires_at)
                 VALUES (:user_id, :trip_id, :invite_code, :nonce_hash, :expires_at)'
            )->execute([
                'user_id' => $actorId,
                'trip_id' => $tripId,
                'invite_code' => $inviteCode,
                'nonce_hash' => $candidateHash,
                'expires_at' => $candidateExpiresAt,
            ]);
            $previewNonce = $candidate;
            $previewNonceExpiresAt = $candidateExpiresAt;
            break;
        } catch (Throwable $error) {
            $errorCode = (string) ($error->getCode() ?? '');
            if ($errorCode === '23000') {
                continue;
            }
            throw $error;
        }
    }
    if ($previewNonce === '' || $previewNonceExpiresAt === '') {
        json_out(['ok' => false, 'error' => 'Failed to create invite confirmation.'], 500);
    }

    json_out([
        'ok' => true,
        'invite' => [
            'invite_token' => $inviteCode,
            'preview_nonce' => $previewNonce,
            'preview_nonce_expires_at' => $previewNonceExpiresAt,
            'trip_id' => $tripId,
            'trip_name' => trim((string) ($invite['trip_name'] ?? '')) !== ''
                ? trim((string) ($invite['trip_name'] ?? ''))
                : 'Trip',
            'trip_status' => $status,
            'expires_at' => $expiresAt,
            'already_member' => $alreadyMember,
            'inviter' => [
                'id' => (int) ($invite['inviter_id'] ?? 0),
                'display_name' => trim($inviterDisplayName),
            ],
        ],
    ]);
}

function join_trip_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $inviteCode = normalize_trip_invite_code((string) ($body['invite_token'] ?? ''));
    $previewNonce = normalize_trip_invite_preview_nonce((string) ($body['preview_nonce'] ?? ''));
    $previewNonceHash = hash('sha256', $previewNonce);

    $pdo = db();
    $actorId = (int) ($me['id'] ?? 0);
    if (!trip_invite_preview_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Invite confirmation is not enabled on server yet. Run migration first.',
        ], 409);
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
        (string) $actorId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $tripsTable = table_name('trips');
    $tripMembersTable = table_name('trip_members');
    $tripInvitesTable = table_name('trip_invites');
    $tripInvitePreviewTokensTable = table_name('trip_invite_preview_tokens');
    $tripImageSelect = trips_image_column_available($pdo)
        ? 't.image_path'
        : 'NULL AS image_path';

    $pdo->beginTransaction();
    try {
        $previewStmt = $pdo->prepare(
            'SELECT id, trip_id, invite_code, expires_at, used_at
             FROM ' . $tripInvitePreviewTokensTable . '
             WHERE user_id = :user_id
               AND nonce_hash = :nonce_hash
             LIMIT 1
             FOR UPDATE'
        );
        $previewStmt->execute([
            'user_id' => $actorId,
            'nonce_hash' => $previewNonceHash,
        ]);
        $preview = $previewStmt->fetch();
        if (!$preview) {
            json_out([
                'ok' => false,
                'error' => 'Invite confirmation expired. Please open the invite link again.',
            ], 409);
        }
        $previewUsedAt = trim((string) ($preview['used_at'] ?? ''));
        $previewExpiresAt = trim((string) ($preview['expires_at'] ?? ''));
        if (
            $previewUsedAt !== '' ||
            $previewExpiresAt === '' ||
            strtotime($previewExpiresAt) === false ||
            strtotime($previewExpiresAt) < time()
        ) {
            json_out([
                'ok' => false,
                'error' => 'Invite confirmation expired. Please open the invite link again.',
            ], 409);
        }
        $previewInviteCode = strtolower(trim((string) ($preview['invite_code'] ?? '')));
        if ($previewInviteCode !== $inviteCode) {
            json_out([
                'ok' => false,
                'error' => 'Invite confirmation does not match this invite link.',
            ], 409);
        }

        $inviteStmt = $pdo->prepare(
            'SELECT trip_id, expires_at, revoked_at
             FROM ' . $tripInvitesTable . '
             WHERE invite_code = :invite_code
             LIMIT 1
             FOR UPDATE'
        );
        $inviteStmt->execute(['invite_code' => $inviteCode]);
        $invite = $inviteStmt->fetch();
        if (!$invite) {
            json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
        }

        $revokedAt = trim((string) ($invite['revoked_at'] ?? ''));
        if ($revokedAt !== '') {
            json_out(['ok' => false, 'error' => 'Invite token expired.'], 409);
        }
        $expiresAt = trim((string) ($invite['expires_at'] ?? ''));
        if ($expiresAt === '' || strtotime($expiresAt) === false || strtotime($expiresAt) < time()) {
            json_out(['ok' => false, 'error' => 'Invite token expired.'], 409);
        }
        $tripId = (int) ($invite['trip_id'] ?? 0);
        if ($tripId <= 0) {
            json_out(['ok' => false, 'error' => 'Invalid invite token.'], 400);
        }
        if ((int) ($preview['trip_id'] ?? 0) !== $tripId) {
            json_out([
                'ok' => false,
                'error' => 'Invite confirmation does not match this trip.',
            ], 409);
        }

        $tripStmt = $pdo->prepare(
            'SELECT
                t.id,
                t.name,
                t.status,
                t.created_by,
                t.ended_at,
                t.archived_at,
                ' . $tripImageSelect . '
             FROM ' . $tripsTable . ' t
             WHERE t.id = :trip_id
             LIMIT 1
             FOR UPDATE'
        );
        $tripStmt->execute(['trip_id' => $tripId]);
        $trip = $tripStmt->fetch();
        if (!$trip) {
            json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
        }

        $status = normalize_trip_status($trip['status'] ?? 'active');
        if ($status !== 'active') {
            json_out(['ok' => false, 'error' => 'Trip is closed.'], 409);
        }

        $memberStmt = $pdo->prepare(
            'SELECT user_id
             FROM ' . $tripMembersTable . '
             WHERE trip_id = :trip_id
               AND user_id = :user_id
             LIMIT 1'
        );
        $memberStmt->execute([
            'trip_id' => $tripId,
            'user_id' => $actorId,
        ]);
        $alreadyMember = (bool) $memberStmt->fetch();

        if (!$alreadyMember) {
            $insertMember = $pdo->prepare(
                'INSERT INTO ' . $tripMembersTable . ' (trip_id, user_id)
                 VALUES (:trip_id, :user_id)'
            );
            $insertMember->execute([
                'trip_id' => $tripId,
                'user_id' => $actorId,
            ]);
        }

        $pdo->prepare(
            'UPDATE ' . $tripInvitePreviewTokensTable . '
             SET used_at = UTC_TIMESTAMP()
             WHERE id = :id
               AND used_at IS NULL'
        )->execute([
            'id' => (int) ($preview['id'] ?? 0),
        ]);

        $pdo->commit();

        $freshTrip = find_trip_for_user($pdo, $actorId, $tripId);
        if (!$freshTrip) {
            json_out(['ok' => false, 'error' => 'Trip not found after join.'], 404);
        }

        json_out([
            'ok' => true,
            'already_member' => $alreadyMember,
            'trip' => build_trip_payload(normalize_trip_row($freshTrip)),
        ]);
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
}

function users_action(): void
{
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $nameSelect = users_name_columns_available($pdo)
        ? 'u.first_name, u.last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $readySelect = trip_members_ready_columns_available($pdo)
        ? 'tm.ready_to_settle, tm.ready_to_settle_at, '
        : '1 AS ready_to_settle, NULL AS ready_to_settle_at, ';

    $stmt = $pdo->prepare(
        'SELECT u.id, ' . $nameSelect . $readySelect . 'u.nickname, u.avatar_path
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
         ORDER BY tm.joined_at ASC, u.created_at ASC, u.id ASC'
    );
    $stmt->execute(['trip_id' => (int) $trip['id']]);
    $rows = $stmt->fetchAll();
    foreach ($rows as &$row) {
        $row['id'] = (int) $row['id'];
        $firstName = normalize_me_name_value($row['first_name'] ?? null);
        $lastName = normalize_me_name_value($row['last_name'] ?? null);
        $displayName = combine_full_name($firstName, $lastName);
        $row['first_name'] = $firstName;
        $row['last_name'] = $lastName;
        $row['display_name'] = $displayName !== null
            ? $displayName
            : trim((string) ($row['nickname'] ?? ''));
        $row['is_ready_to_settle'] = ((int) ($row['ready_to_settle'] ?? 0)) === 1;
        $row['ready_to_settle_at'] = $row['ready_to_settle_at'] ?: null;
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $row['avatar_url'] = $avatarPath !== '' ? avatar_public_url($avatarPath) : null;
        $row['avatar_thumb_url'] = $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null;
        unset($row['avatar_path'], $row['ready_to_settle']);
    }
    unset($row);

    json_out([
        'ok' => true,
        'trip' => build_trip_payload($trip),
        'users' => $rows,
    ]);
}
