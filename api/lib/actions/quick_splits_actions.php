<?php
declare(strict_types=1);

// Quick splits: one bill shared between people without a trip. See docs/api/quick-splits.md.

require_once __DIR__ . '/../helpers/helper_expense_subcategory.php';
require_once __DIR__ . '/../helpers/helper_receipt_ownership.php';
require_once __DIR__ . '/../helpers/helper_quick_split_share.php';
require_once __DIR__ . '/../helpers/helper_trip_guests.php';

const QUICK_SPLIT_MAX_PEOPLE = 50;

function quick_splits_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }
    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1) FROM information_schema.tables
             WHERE table_schema = DATABASE() AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => trim(table_name('quick_splits'), '`')]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cached = false;
    }
    return $cached;
}

/** @return array{0: PDO, 1: array, 2: array} */
function quick_split_request(bool $write): array
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    if (!quick_splits_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Quick splits are not available yet.'], 409);
    }
    if ($write) {
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
            (string) ((int) $me['id']),
            RATE_LIMIT_EXPENSE_WRITE_USER_MAX,
            RATE_LIMIT_MUTATION_WINDOW_SEC
        );
    }
    return [$pdo, $me, $body];
}

/**
 * Validates `people`. Each person gets a synthetic id (1, 2, ...) used by the split math.
 *
 * @return array<string, array{sid:int, user_id:?int, name:string}>
 */
function quick_split_parse_people(PDO $pdo, int $meId, array $body): array
{
    $raw = $body['people'] ?? null;
    if (!is_array($raw) || count($raw) < 2) {
        json_out(['ok' => false, 'error' => 'Add at least two people.'], 400);
    }
    if (count($raw) > QUICK_SPLIT_MAX_PEOPLE) {
        json_out(['ok' => false, 'error' => 'Too many people.'], 400);
    }

    $people = [];
    $accounts = [];
    foreach (array_values($raw) as $index => $person) {
        if (!is_array($person)) {
            json_out(['ok' => false, 'error' => 'Invalid people payload.'], 400);
        }
        $key = is_scalar($person['key'] ?? null) ? trim((string) $person['key']) : '';
        if ($key === '' || str_length($key) > 16) {
            json_out(['ok' => false, 'error' => 'Each person needs a key.'], 400);
        }
        if (isset($people[$key])) {
            json_out(['ok' => false, 'error' => 'People keys must be unique.'], 400);
        }
        $userId = (int) ($person['user_id'] ?? 0);
        if ($userId > 0) {
            if (isset($accounts[$userId])) {
                json_out(['ok' => false, 'error' => 'Each person can be added once.'], 400);
            }
            $accounts[$userId] = $key;
            $people[$key] = ['sid' => $index + 1, 'user_id' => $userId, 'name' => ''];
            continue;
        }
        $people[$key] = [
            'sid' => $index + 1,
            'user_id' => null,
            'name' => normalize_trip_guest_name($person['name'] ?? ''),
        ];
    }
    if (!isset($accounts[$meId])) {
        json_out(['ok' => false, 'error' => 'You must be part of the quick split.'], 400);
    }

    $others = array_values(array_filter(array_keys($accounts), static fn (int $id): bool => $id !== $meId));
    $names = quick_split_friend_names($pdo, $meId, $others);
    foreach ($others as $userId) {
        if (!isset($names[$userId])) {
            json_out(['ok' => false, 'error' => 'You can only add friends.'], 403);
        }
    }
    $names[$meId] = quick_split_user_name($pdo, $meId);
    foreach ($accounts as $userId => $key) {
        $people[$key]['name'] = mb_substr($names[$userId] ?? '', 0, 32);
    }
    return $people;
}

/** @return array<int, string> accepted, active friends among $ids with their nicknames */
function quick_split_friend_names(PDO $pdo, int $meId, array $ids): array
{
    if ($ids === []) {
        return [];
    }
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $pdo->prepare(
        'SELECT u.id, u.nickname FROM ' . table_name('friends') . ' f
         JOIN ' . table_name('users') . ' u
           ON u.id = CASE WHEN f.user_a_id = ? THEN f.user_b_id ELSE f.user_a_id END
         WHERE (f.user_a_id = ? OR f.user_b_id = ?) AND f.status = "accepted"
           AND u.account_status = "active" AND u.guest_trip_id IS NULL
           AND u.id IN (' . $placeholders . ')'
    );
    $stmt->execute(array_merge([$meId, $meId, $meId], array_map('intval', $ids)));
    $out = [];
    foreach ($stmt->fetchAll() as $row) {
        $out[(int) $row['id']] = trim((string) $row['nickname']);
    }
    return $out;
}

function quick_split_user_name(PDO $pdo, int $userId): string
{
    $stmt = $pdo->prepare('SELECT nickname FROM ' . table_name('users') . ' WHERE id = :id');
    $stmt->execute(['id' => $userId]);
    return trim((string) ($stmt->fetchColumn() ?: ''));
}

/** @param array<string, array{sid:int}> $people */
function quick_split_sid(array $people, mixed $key): int
{
    $key = is_scalar($key) ? trim((string) $key) : '';
    if (!isset($people[$key])) {
        json_out(['ok' => false, 'error' => 'Unknown person.'], 400);
    }
    return (int) $people[$key]['sid'];
}

/** Validates the whole body of add/update. */
function quick_split_parse(PDO $pdo, int $meId, array $body): array
{
    $people = quick_split_parse_people($pdo, $meId, $body);
    $currency = normalize_currency_code($body['currency_code'] ?? '');
    $amountCents = validate_amount_cents($body['amount'] ?? null);
    $category = normalize_expense_category($body['category'] ?? '');
    $subcategory = normalize_expense_subcategory($body['subcategory'] ?? null);
    $note = trim((string) ($body['note'] ?? ''));
    if (str_length($note) > 255) {
        json_out(['ok' => false, 'error' => 'Note is too long.'], 400);
    }
    ensure_text_has_no_links($note, 'Note');
    $date = validate_date_iso((string) ($body['date'] ?? date('Y-m-d')));
    $receiptPath = normalize_receipt_path((string) ($body['receipt_path'] ?? ''), true);
    $payerSid = quick_split_sid($people, $body['paid_by'] ?? null);
    $splitMode = normalize_expense_split_mode($body['split_mode'] ?? 'equal');

    $itemized = null;
    $participants = [];
    $splits = [];
    if ($splitMode === 'itemized') {
        $rawItems = $body['items'] ?? null;
        $translated = ['items' => [], 'extra_amount' => $body['extra_amount'] ?? 0];
        if (is_array($rawItems)) {
            foreach ($rawItems as $item) {
                if (!is_array($item)) {
                    json_out(['ok' => false, 'error' => 'Invalid items payload.'], 400);
                }
                $ids = [];
                foreach ((array) ($item['people'] ?? []) as $key) {
                    $ids[] = quick_split_sid($people, $key);
                }
                $translated['items'][] = [
                    'name' => $item['name'] ?? '',
                    'amount' => $item['amount'] ?? null,
                    'participant_ids' => $ids,
                ];
            }
        }
        $itemized = parse_expense_items($translated, $amountCents);
    } else {
        $rawParticipants = $body['participants'] ?? null;
        if (is_array($rawParticipants) && $rawParticipants !== []) {
            foreach ($rawParticipants as $key) {
                $participants[] = quick_split_sid($people, $key);
            }
        } else {
            $participants = array_map(static fn (array $p): int => (int) $p['sid'], array_values($people));
        }
        $rawSplits = $body['splits'] ?? [];
        if (!is_array($rawSplits)) {
            json_out(['ok' => false, 'error' => 'Invalid splits payload.'], 400);
        }
        foreach ($rawSplits as $split) {
            if (!is_array($split)) {
                json_out(['ok' => false, 'error' => 'Invalid split payload.'], 400);
            }
            $splits[] = ['user_id' => quick_split_sid($people, $split['person'] ?? null), 'value' => $split['value'] ?? null];
        }
    }

    $rows = build_expense_split_rows_with_currency_conversion(
        $amountCents,
        $amountCents,
        1.0,
        $participants,
        $splitMode,
        $splits,
        $currency,
        $currency,
        $itemized
    );
    $owed = [];
    foreach ($rows as $row) {
        $owed[(int) $row['user_id']] = [(int) $row['owed_cents'], (int) ($row['split_value'] ?? 0)];
    }

    return [
        'people' => $people,
        'payer_sid' => $payerSid,
        'owed' => $owed,
        'currency' => $currency,
        'amount_cents' => $amountCents,
        'category' => $category,
        'subcategory' => $subcategory,
        'note' => $note,
        'date' => $date,
        'receipt_path' => $receiptPath,
        'split_mode' => $splitMode,
        'itemized' => $itemized,
    ];
}

/** Writes people and items for a parsed quick split. */
function quick_split_save_children(PDO $pdo, int $quickSplitId, array $parsed): void
{
    $insertPerson = $pdo->prepare(
        'INSERT INTO ' . table_name('quick_split_people') . '
         (quick_split_id, position, user_id, name, is_payer, owed_cents, split_value)
         VALUES (:quick_split_id, :position, :user_id, :name, :is_payer, :owed_cents, :split_value)'
    );
    $personIds = [];
    foreach (array_values($parsed['people']) as $position => $person) {
        $sid = (int) $person['sid'];
        [$owedCents, $splitValue] = $parsed['owed'][$sid] ?? [0, 0];
        $insertPerson->execute([
            'quick_split_id' => $quickSplitId,
            'position' => $position,
            'user_id' => $person['user_id'],
            'name' => $person['name'],
            'is_payer' => $sid === $parsed['payer_sid'] ? 1 : 0,
            'owed_cents' => $owedCents,
            'split_value' => $splitValue,
        ]);
        $personIds[$sid] = (int) $pdo->lastInsertId();
    }

    $itemized = $parsed['itemized'];
    if ($itemized === null) {
        return;
    }
    $insertItem = $pdo->prepare(
        'INSERT INTO ' . table_name('quick_split_items') . ' (quick_split_id, position, name, amount_cents, is_extra)
         VALUES (:quick_split_id, :position, :name, :amount_cents, :is_extra)'
    );
    $insertItemPerson = $pdo->prepare(
        'INSERT INTO ' . table_name('quick_split_item_people') . ' (item_id, person_id) VALUES (:item_id, :person_id)'
    );
    foreach ($itemized['items'] as $position => $item) {
        $insertItem->execute([
            'quick_split_id' => $quickSplitId,
            'position' => (int) $position,
            'name' => $item['name'],
            'amount_cents' => $item['amount_cents'],
            'is_extra' => 0,
        ]);
        $itemId = (int) $pdo->lastInsertId();
        foreach ($item['participant_ids'] as $sid) {
            $insertItemPerson->execute(['item_id' => $itemId, 'person_id' => $personIds[(int) $sid]]);
        }
    }
    if ($itemized['extra_cents'] > 0) {
        $insertItem->execute([
            'quick_split_id' => $quickSplitId,
            'position' => count($itemized['items']),
            'name' => '',
            'amount_cents' => $itemized['extra_cents'],
            'is_extra' => 1,
        ]);
    }
}

function quick_split_delete_children(PDO $pdo, int $quickSplitId): void
{
    $items = table_name('quick_split_items');
    $pdo->prepare(
        'DELETE FROM ' . table_name('quick_split_item_people') . '
         WHERE item_id IN (SELECT id FROM ' . $items . ' WHERE quick_split_id = :id)'
    )->execute(['id' => $quickSplitId]);
    $pdo->prepare('DELETE FROM ' . $items . ' WHERE quick_split_id = :id')->execute(['id' => $quickSplitId]);
    $pdo->prepare('DELETE FROM ' . table_name('quick_split_people') . ' WHERE quick_split_id = :id')
        ->execute(['id' => $quickSplitId]);
}

/** Tells accounts in the quick split, other than the creator, that they were added. */
function quick_split_notify(PDO $pdo, int $quickSplitId, array $me, array $parsed, array $skipUserIds): void
{
    $name = trim((string) ($me['nickname'] ?? ''));
    $name = $name !== '' ? $name : 'Someone';
    $body = $parsed['note'] !== ''
        ? $name . ' added you to a quick split: ' . $parsed['note']
        : $name . ' added you to a quick split of '
            . format_cents_with_currency($parsed['amount_cents'], $parsed['currency']);
    foreach ($parsed['people'] as $person) {
        $userId = (int) ($person['user_id'] ?? 0);
        if ($userId <= 0 || $userId === (int) $me['id'] || in_array($userId, $skipUserIds, true)) {
            continue;
        }
        create_user_notification($pdo, 0, $userId, 'quick_split_added', 'Quick split', $body, [
            'quick_split_id' => $quickSplitId,
        ]);
    }
}

/** The quick split row, when the account created it or is in it. */
function quick_split_find_visible(PDO $pdo, int $quickSplitId, int $meId, bool $lock = false): ?array
{
    if ($quickSplitId <= 0) {
        return null;
    }
    $stmt = $pdo->prepare(
        'SELECT * FROM ' . table_name('quick_splits') . ' qs
         WHERE qs.id = :id AND (qs.created_by = :me OR EXISTS (
             SELECT 1 FROM ' . table_name('quick_split_people') . ' p
             WHERE p.quick_split_id = qs.id AND p.user_id = :me_person))'
        . ($lock ? ' FOR UPDATE' : '')
    );
    $stmt->execute(['id' => $quickSplitId, 'me' => $meId, 'me_person' => $meId]);
    $row = $stmt->fetch();
    return $row ?: null;
}

/** The row the creator may change; stops with 403/404/409 otherwise. */
function quick_split_require_editable(PDO $pdo, int $quickSplitId, int $meId): array
{
    $row = quick_split_find_visible($pdo, $quickSplitId, $meId, true);
    if ($row === null) {
        json_out(['ok' => false, 'error' => 'Quick split not found.'], 404);
    }
    if ((int) $row['created_by'] !== $meId) {
        json_out(['ok' => false, 'error' => 'Only the creator can change this quick split.'], 403);
    }
    if ($row['moved_at'] !== null) {
        json_out(['ok' => false, 'error' => 'This quick split was added to a trip.'], 409);
    }
    return $row;
}

/**
 * People of these quick splits, keyed by quick split id.
 *
 * @return array<int, array<int, array<string, mixed>>>
 */
function quick_split_load_people(PDO $pdo, array $ids, int $meId): array
{
    if ($ids === []) {
        return [];
    }
    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $pdo->prepare(
        'SELECT p.id, p.quick_split_id, p.user_id, p.name, p.is_payer, p.owed_cents, p.split_value,
                u.nickname, u.avatar_path, u.account_status
         FROM ' . table_name('quick_split_people') . ' p
         LEFT JOIN ' . table_name('users') . ' u ON u.id = p.user_id
         WHERE p.quick_split_id IN (' . $placeholders . ')
         ORDER BY p.quick_split_id, p.position, p.id'
    );
    $stmt->execute(array_map('intval', $ids));
    $out = [];
    foreach ($stmt->fetchAll() as $row) {
        $userId = $row['user_id'] !== null ? (int) $row['user_id'] : null;
        $live = $userId !== null && (string) ($row['account_status'] ?? '') === 'active';
        $nickname = trim((string) ($row['nickname'] ?? ''));
        $avatarPath = trim((string) ($row['avatar_path'] ?? ''));
        $out[(int) $row['quick_split_id']][] = [
            'id' => (int) $row['id'],
            'user_id' => $userId,
            'name' => $live && $nickname !== '' ? $nickname : (string) $row['name'],
            'avatar_thumb_url' => $live && $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null,
            'is_me' => $userId === $meId,
            'is_payer' => (int) $row['is_payer'] === 1,
            'is_account' => $userId !== null,
            'amount' => cents_to_float((int) $row['owed_cents']),
            'split_value' => (int) $row['split_value'],
        ];
    }
    return $out;
}

/** A list row from the stored quick split and its people. */
function quick_split_summary(array $row, array $people, int $meId): array
{
    $myAmount = 0.0;
    $paidByMe = false;
    $payerName = '';
    $preview = [];
    foreach ($people as $person) {
        if ($person['is_me']) {
            $myAmount = $person['amount'];
            $paidByMe = $person['is_payer'];
        } elseif (count($preview) < 4) {
            $preview[] = ['name' => $person['name'], 'avatar_thumb_url' => $person['avatar_thumb_url']];
        }
        if ($person['is_payer']) {
            $payerName = $person['name'];
        }
    }
    $subcategory = $row['subcategory'] ?? null;
    return [
        'id' => (int) $row['id'],
        'note' => (string) $row['note'],
        'category' => (string) $row['category'],
        'subcategory' => $subcategory !== null && $subcategory !== '' ? (string) $subcategory : null,
        'date' => (string) $row['split_date'],
        'amount' => cents_to_float((int) $row['amount_cents']),
        'currency_code' => (string) $row['currency_code'],
        'people_count' => count($people),
        'my_amount' => $myAmount,
        'paid_by_me' => $paidByMe,
        'paid_by_name' => $payerName,
        'people_preview' => $preview,
        'has_receipt' => trim((string) ($row['receipt_path'] ?? '')) !== '',
        'can_edit' => (int) $row['created_by'] === $meId && $row['moved_at'] === null,
        'created_at' => $row['created_at'] ?? null,
        'updated_at' => $row['updated_at'] ?? null,
    ];
}

function quick_split_detail(PDO $pdo, array $row, int $meId): array
{
    $id = (int) $row['id'];
    $people = quick_split_load_people($pdo, [$id], $meId)[$id] ?? [];
    $out = quick_split_summary($row, $people, $meId);
    $out['split_mode'] = (string) $row['split_mode'];
    $out['created_by'] = (int) $row['created_by'];
    foreach ($people as &$person) {
        $person['split_value'] = expense_split_value_to_payload($out['split_mode'], (int) $person['split_value']);
    }
    unset($person);
    $out['people'] = $people;

    if ($out['split_mode'] === 'itemized') {
        $stmt = $pdo->prepare(
            'SELECT id, name, amount_cents, is_extra FROM ' . table_name('quick_split_items') . '
             WHERE quick_split_id = :id ORDER BY position, id'
        );
        $stmt->execute(['id' => $id]);
        $itemRows = $stmt->fetchAll();
        $stmt = $pdo->prepare(
            'SELECT ip.item_id, ip.person_id FROM ' . table_name('quick_split_item_people') . ' ip
             JOIN ' . table_name('quick_split_items') . ' i ON i.id = ip.item_id
             WHERE i.quick_split_id = :id ORDER BY ip.person_id'
        );
        $stmt->execute(['id' => $id]);
        $byItem = [];
        foreach ($stmt->fetchAll() as $link) {
            $byItem[(int) $link['item_id']][] = (int) $link['person_id'];
        }
        $items = [];
        $extra = 0;
        foreach ($itemRows as $item) {
            if ((int) $item['is_extra'] === 1) {
                $extra = (int) $item['amount_cents'];
                continue;
            }
            $items[] = [
                'name' => (string) $item['name'],
                'amount' => cents_to_float((int) $item['amount_cents']),
                'person_ids' => $byItem[(int) $item['id']] ?? [],
            ];
        }
        $out['items'] = $items;
        $out['extra_amount'] = cents_to_float($extra);
    }

    $receiptPath = trim((string) ($row['receipt_path'] ?? ''));
    $out['receipt_path'] = $out['can_edit'] && $receiptPath !== '' ? $receiptPath : null;
    $out['receipt_url'] = $receiptPath !== '' ? receipt_public_url($receiptPath) : null;
    $out['receipt_thumb_url'] = $receiptPath !== '' ? receipt_thumb_public_url($receiptPath) : null;
    if ((int) $row['created_by'] === $meId) {
        $share = $row['moved_at'] === null ? quick_split_share_active($pdo, $id) : null;
        $out['share'] = $share !== null ? quick_split_share_payload($share) : null;
    }
    $out['added_to_trip'] = $row['moved_at'] !== null
        ? ['trip_id' => (int) ($row['moved_trip_id'] ?? 0), 'expense_id' => (int) ($row['moved_expense_id'] ?? 0)]
        : null;
    return $out;
}

function quick_split_response(PDO $pdo, int $quickSplitId, int $meId): void
{
    $row = quick_split_find_visible($pdo, $quickSplitId, $meId);
    if ($row === null) {
        json_out(['ok' => false, 'error' => 'Quick split not found.'], 404);
    }
    json_out(['ok' => true, 'quick_split' => quick_split_detail($pdo, $row, $meId)]);
}

function quick_split_client_mutation_id(array $body): ?string
{
    $raw = $body['client_mutation_id'] ?? null;
    if ($raw === null || $raw === '') {
        return null;
    }
    $value = is_scalar($raw) ? trim((string) $raw) : '';
    if ($value === '' || strlen($value) > 96 || !preg_match('/^[A-Za-z0-9._:-]+$/', $value)) {
        json_out(['ok' => false, 'error' => 'Invalid client_mutation_id.'], 400);
    }
    return $value;
}

function add_quick_split_action(): void
{
    [$pdo, $me, $body] = quick_split_request(true);
    $meId = (int) $me['id'];
    $mutationId = quick_split_client_mutation_id($body);
    if ($mutationId !== null) {
        $stmt = $pdo->prepare(
            'SELECT id FROM ' . table_name('quick_splits') . ' WHERE created_by = :me AND client_mutation_id = :mid'
        );
        $stmt->execute(['me' => $meId, 'mid' => $mutationId]);
        $existing = (int) ($stmt->fetchColumn() ?: 0);
        if ($existing > 0) {
            quick_split_response($pdo, $existing, $meId);
        }
    }

    $parsed = quick_split_parse($pdo, $meId, $body);
    assert_receipt_attachment_owned($parsed['receipt_path'], $meId);

    $pdo->beginTransaction();
    try {
        $pdo->prepare(
            'INSERT INTO ' . table_name('quick_splits') . '
             (created_by, amount_cents, currency_code, category, subcategory, note, split_mode, split_date,
              receipt_path, client_mutation_id)
             VALUES (:created_by, :amount_cents, :currency_code, :category, :subcategory, :note, :split_mode,
              :split_date, :receipt_path, :client_mutation_id)'
        )->execute([
            'created_by' => $meId,
            'amount_cents' => $parsed['amount_cents'],
            'currency_code' => $parsed['currency'],
            'category' => $parsed['category'],
            'subcategory' => $parsed['subcategory'],
            'note' => $parsed['note'],
            'split_mode' => $parsed['split_mode'],
            'split_date' => $parsed['date'],
            'receipt_path' => $parsed['receipt_path'] !== '' ? $parsed['receipt_path'] : null,
            'client_mutation_id' => $mutationId,
        ]);
        $id = (int) $pdo->lastInsertId();
        quick_split_save_children($pdo, $id, $parsed);
        quick_split_notify($pdo, $id, $me, $parsed, []);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    app_event($pdo, $meId, 'quick_split.created', 'quick_split', $id, null, [
        'split_mode' => $parsed['split_mode'],
        'people_count' => count($parsed['people']),
        'currency_code' => $parsed['currency'],
    ]);
    quick_split_response($pdo, $id, $meId);
}

function update_quick_split_action(): void
{
    [$pdo, $me, $body] = quick_split_request(true);
    $meId = (int) $me['id'];
    $id = (int) ($body['id'] ?? 0);
    $parsed = quick_split_parse($pdo, $meId, $body);

    $oldReceipt = '';
    $pdo->beginTransaction();
    try {
        $row = quick_split_require_editable($pdo, $id, $meId);
        $oldReceipt = trim((string) ($row['receipt_path'] ?? ''));
        assert_receipt_attachment_owned($parsed['receipt_path'], $meId, $oldReceipt);

        $stmt = $pdo->prepare(
            'SELECT user_id FROM ' . table_name('quick_split_people') . ' WHERE quick_split_id = :id AND user_id IS NOT NULL'
        );
        $stmt->execute(['id' => $id]);
        $previousUsers = array_map('intval', $stmt->fetchAll(PDO::FETCH_COLUMN));

        $pdo->prepare(
            'UPDATE ' . table_name('quick_splits') . '
             SET amount_cents = :amount_cents, currency_code = :currency_code, category = :category,
                 subcategory = :subcategory, note = :note, split_mode = :split_mode, split_date = :split_date,
                 receipt_path = :receipt_path, updated_at = CURRENT_TIMESTAMP
             WHERE id = :id'
        )->execute([
            'amount_cents' => $parsed['amount_cents'],
            'currency_code' => $parsed['currency'],
            'category' => $parsed['category'],
            'subcategory' => $parsed['subcategory'],
            'note' => $parsed['note'],
            'split_mode' => $parsed['split_mode'],
            'split_date' => $parsed['date'],
            'receipt_path' => $parsed['receipt_path'] !== '' ? $parsed['receipt_path'] : null,
            'id' => $id,
        ]);
        quick_split_delete_children($pdo, $id);
        quick_split_save_children($pdo, $id, $parsed);
        quick_split_notify($pdo, $id, $me, $parsed, $previousUsers);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($oldReceipt !== '' && $oldReceipt !== $parsed['receipt_path']) {
        quick_split_delete_receipt($oldReceipt);
    }
    quick_split_response($pdo, $id, $meId);
}

function delete_quick_split_action(): void
{
    [$pdo, $me, $body] = quick_split_request(true);
    $meId = (int) $me['id'];
    $id = (int) ($body['id'] ?? 0);

    $pdo->beginTransaction();
    try {
        $row = quick_split_require_editable($pdo, $id, $meId);
        quick_split_delete_children($pdo, $id);
        quick_split_share_delete_for($pdo, $id);
        $pdo->prepare('DELETE FROM ' . table_name('quick_splits') . ' WHERE id = :id')->execute(['id' => $id]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    quick_split_delete_receipt(trim((string) ($row['receipt_path'] ?? '')));
    json_out(['ok' => true]);
}

function quick_split_delete_receipt(string $path): void
{
    if ($path === '') {
        return;
    }
    try {
        delete_receipt_file($path);
    } catch (Throwable $error) {
        error_log('Quick split receipt cleanup failed.');
    }
}

function list_quick_splits_action(): void
{
    [$pdo, $me, $body] = quick_split_request(false);
    $meId = (int) $me['id'];
    $limit = pagination_limit($body['limit'] ?? 30, 30, 100);
    $cursor = is_string($body['cursor'] ?? null) ? pagination_decode_cursor((string) $body['cursor']) : null;

    $sql = 'SELECT * FROM ' . table_name('quick_splits') . ' qs
            WHERE qs.moved_at IS NULL AND (qs.created_by = :me OR EXISTS (
                SELECT 1 FROM ' . table_name('quick_split_people') . ' p
                WHERE p.quick_split_id = qs.id AND p.user_id = :me_person))';
    $params = ['me' => $meId, 'me_person' => $meId];
    if (is_array($cursor) && isset($cursor['date'], $cursor['id'])) {
        $sql .= ' AND (qs.split_date < :cursor_date OR (qs.split_date = :cursor_date_eq AND qs.id < :cursor_id))';
        $params['cursor_date'] = (string) $cursor['date'];
        $params['cursor_date_eq'] = (string) $cursor['date'];
        $params['cursor_id'] = (int) $cursor['id'];
    }
    $sql .= ' ORDER BY qs.split_date DESC, qs.id DESC LIMIT ' . ($limit + 1);
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $rows = $stmt->fetchAll();
    $hasMore = count($rows) > $limit;
    if ($hasMore) {
        $rows = array_slice($rows, 0, $limit);
    }

    $people = quick_split_load_people($pdo, array_map(static fn (array $r): int => (int) $r['id'], $rows), $meId);
    $items = [];
    foreach ($rows as $row) {
        $items[] = quick_split_summary($row, $people[(int) $row['id']] ?? [], $meId);
    }
    $next = null;
    if ($hasMore && $rows !== []) {
        $last = $rows[count($rows) - 1];
        $next = pagination_encode_cursor(['date' => (string) $last['split_date'], 'id' => (int) $last['id']]);
    }
    json_out(['ok' => true, 'items' => $items, 'has_more' => $hasMore, 'next_cursor' => $next ?: null]);
}

function get_quick_split_action(): void
{
    [$pdo, $me, $body] = quick_split_request(false);
    quick_split_response($pdo, (int) ($body['id'] ?? 0), (int) $me['id']);
}

function move_quick_split_to_trip_action(): void
{
    [$pdo, $me, $body] = quick_split_request(true);
    $meId = (int) $me['id'];
    $id = (int) ($body['id'] ?? 0);
    $tripId = (int) ($body['trip_id'] ?? 0);
    $expenseId = (int) ($body['expense_id'] ?? 0);

    $pdo->beginTransaction();
    try {
        quick_split_require_editable($pdo, $id, $meId);
        $stmt = $pdo->prepare(
            'SELECT 1 FROM ' . table_name('trip_members') . ' WHERE trip_id = :trip AND user_id = :me'
        );
        $stmt->execute(['trip' => $tripId, 'me' => $meId]);
        if (!$stmt->fetchColumn()) {
            json_out(['ok' => false, 'error' => 'Trip not found.'], 404);
        }
        $stmt = $pdo->prepare(
            'SELECT 1 FROM ' . table_name('expenses') . ' WHERE id = :id AND trip_id = :trip'
        );
        $stmt->execute(['id' => $expenseId, 'trip' => $tripId]);
        if (!$stmt->fetchColumn()) {
            json_out(['ok' => false, 'error' => 'Expense not found.'], 404);
        }
        $pdo->prepare(
            'UPDATE ' . table_name('quick_splits') . '
             SET moved_trip_id = :trip, moved_expense_id = :expense, moved_at = CURRENT_TIMESTAMP
             WHERE id = :id'
        )->execute(['trip' => $tripId, 'expense' => $expenseId, 'id' => $id]);
        if (quick_split_shares_available($pdo)) {
            // The bill now lives in the trip; its public link ends.
            $pdo->prepare(
                'UPDATE ' . table_name('quick_split_shares') . '
                 SET revoked_at = :now WHERE quick_split_id = :id AND revoked_at IS NULL'
            )->execute(['now' => quick_split_share_now(), 'id' => $id]);
        }
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    json_out(['ok' => true]);
}

/**
 * Deletes the quick splits an account created, inside the account deletion transaction.
 *
 * @return array<int, string> receipt paths to remove once the deletion committed
 */
function delete_user_quick_splits(PDO $pdo, int $userId): array
{
    if (!quick_splits_available($pdo)) {
        return [];
    }
    $stmt = $pdo->prepare(
        'SELECT id, receipt_path, moved_at FROM ' . table_name('quick_splits') . ' WHERE created_by = :id'
    );
    $stmt->execute(['id' => $userId]);
    $receipts = [];
    foreach ($stmt->fetchAll() as $row) {
        quick_split_delete_children($pdo, (int) $row['id']);
        quick_split_share_delete_for($pdo, (int) $row['id']);
        $path = trim((string) ($row['receipt_path'] ?? ''));
        // After "Add to a trip" the photo belongs to the trip expense.
        if ($path !== '' && $row['moved_at'] === null) {
            $receipts[] = $path;
        }
    }
    $pdo->prepare('DELETE FROM ' . table_name('quick_splits') . ' WHERE created_by = :id')->execute(['id' => $userId]);
    return $receipts;
}

function quick_split_share_require_owner(PDO $pdo, int $quickSplitId, int $meId): array
{
    if (!quick_split_shares_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Share links are not available yet.'], 409);
    }
    $row = quick_split_find_visible($pdo, $quickSplitId, $meId, true);
    if ($row === null) {
        json_out(['ok' => false, 'error' => 'Quick split not found.'], 404);
    }
    if ((int) $row['created_by'] !== $meId) {
        json_out(['ok' => false, 'error' => 'Only the creator can share this quick split.'], 403);
    }
    if ($row['moved_at'] !== null) {
        json_out(['ok' => false, 'error' => 'This quick split was added to a trip.'], 409);
    }
    return $row;
}

function share_quick_split_action(): void
{
    [$pdo, $me, $body] = quick_split_request(true);
    $meId = (int) $me['id'];
    $id = (int) ($body['id'] ?? 0);

    $pdo->beginTransaction();
    try {
        $row = quick_split_share_require_owner($pdo, $id, $meId);
        $showReceipt = ($body['show_receipt'] ?? false) === true
            && trim((string) ($row['receipt_path'] ?? '')) !== '';
        $share = quick_split_share_active($pdo, $id, true);
        if ($share === null) {
            $share = quick_split_share_create($pdo, $id, $meId, $showReceipt);
        } elseif (((int) $share['show_receipt'] === 1) !== $showReceipt) {
            $pdo->prepare(
                'UPDATE ' . table_name('quick_split_shares') . ' SET show_receipt = :show WHERE id = :id'
            )->execute(['show' => $showReceipt ? 1 : 0, 'id' => (int) $share['id']]);
            $share['show_receipt'] = $showReceipt ? 1 : 0;
        }
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    json_out(['ok' => true, 'share' => quick_split_share_payload($share)]);
}

function revoke_quick_split_share_action(): void
{
    [$pdo, $me, $body] = quick_split_request(true);
    $meId = (int) $me['id'];
    $id = (int) ($body['id'] ?? 0);

    $pdo->beginTransaction();
    try {
        quick_split_share_require_owner($pdo, $id, $meId);
        $pdo->prepare(
            'UPDATE ' . table_name('quick_split_shares') . '
             SET revoked_at = :now WHERE quick_split_id = :id AND revoked_at IS NULL'
        )->execute(['now' => quick_split_share_now(), 'id' => $id]);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    json_out(['ok' => true]);
}
