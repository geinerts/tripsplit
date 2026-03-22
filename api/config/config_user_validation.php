<?php
declare(strict_types=1);

function get_me(): array
{
    $pdo = db();
    $accessToken = bearer_access_token_from_header();
    if ($accessToken === '' || !function_exists('resolve_user_id_from_access_token')) {
        json_out(['ok' => false, 'error' => 'Missing or invalid access token.'], 401);
    }

    $userId = (int) resolve_user_id_from_access_token($accessToken);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Missing or invalid access token.'], 401);
    }

    $row = function_exists('fetch_me_row_by_id') ? fetch_me_row_by_id($pdo, $userId) : null;
    if (!$row) {
        json_out(['ok' => false, 'error' => 'User not found.'], 401);
    }

    return [
        'id' => (int) ($row['id'] ?? 0),
        'nickname' => (string) ($row['nickname'] ?? ''),
    ];
}

function validate_nickname(string $nickname): string
{
    $nickname = trim(preg_replace('/\s+/', ' ', $nickname) ?? '');
    if (str_length($nickname) < 2 || str_length($nickname) > 32) {
        json_out(['ok' => false, 'error' => 'Nickname must be 2-32 chars.'], 400);
    }

    if (!preg_match('/^[\p{L}\p{N} ._\-]+$/u', $nickname)) {
        json_out(['ok' => false, 'error' => 'Nickname has unsupported characters.'], 400);
    }
    ensure_text_has_no_links($nickname, 'Nickname');

    return $nickname;
}

function ensure_text_has_no_links(string $value, string $fieldLabel): void
{
    $value = trim($value);
    if ($value === '') {
        return;
    }

    if (preg_match('/https?:\/\/|www\./i', $value)) {
        json_out(['ok' => false, 'error' => $fieldLabel . ' must not contain links.'], 400);
    }
}

function validate_date_iso(string $value): string
{
    $value = trim($value);
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
        json_out(['ok' => false, 'error' => 'Date must be YYYY-MM-DD.'], 400);
    }

    $dt = DateTime::createFromFormat('Y-m-d', $value);
    if (!$dt || $dt->format('Y-m-d') !== $value) {
        json_out(['ok' => false, 'error' => 'Date is invalid.'], 400);
    }

    return $value;
}

function validate_amount_cents($value): int
{
    if (is_string($value)) {
        $value = str_replace(',', '.', trim($value));
    }

    if (!is_numeric($value)) {
        json_out(['ok' => false, 'error' => 'Amount must be numeric.'], 400);
    }

    $amount = (float) $value;
    if ($amount <= 0 || $amount > 99999999) {
        json_out(['ok' => false, 'error' => 'Amount out of range.'], 400);
    }

    return (int) round($amount * 100);
}

function cents_to_decimal(int $cents): string
{
    return number_format($cents / 100, 2, '.', '');
}

function str_length(string $value): int
{
    if (function_exists('mb_strlen')) {
        return (int) mb_strlen($value);
    }
    return strlen($value);
}

function cents_to_float(int $cents): float
{
    return (float) cents_to_decimal($cents);
}

function decimal_to_cents($value): int
{
    return (int) round(((float) $value) * 100);
}

function normalize_user_ids(array $ids): array
{
    $out = [];
    foreach ($ids as $id) {
        $intId = (int) $id;
        if ($intId > 0) {
            $out[$intId] = $intId;
        }
    }
    return array_values($out);
}

function require_valid_user_ids(PDO $pdo, array $ids, bool $requireAtLeastOne = true): array
{
    $ids = normalize_user_ids($ids);
    if ($requireAtLeastOne && count($ids) < 1) {
        json_out(['ok' => false, 'error' => 'Pick at least one user.'], 400);
    }
    if (!$ids) {
        return [];
    }

    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $pdo->prepare('SELECT id FROM ' . table_name('users') . " WHERE id IN ($placeholders)");
    $stmt->execute($ids);
    $existing = array_map('intval', array_column($stmt->fetchAll(), 'id'));
    sort($existing);
    $copy = $ids;
    sort($copy);

    if ($existing !== $copy) {
        json_out(['ok' => false, 'error' => 'Some selected users do not exist.'], 400);
    }

    return $ids;
}

function all_registered_user_ids(PDO $pdo): array
{
    $usersTable = table_name('users');
    $rows = $pdo->query('SELECT id FROM ' . $usersTable . ' ORDER BY created_at ASC, id ASC')->fetchAll();
    $ids = array_map(static fn(array $row): int => (int) $row['id'], $rows);
    $ids = normalize_user_ids($ids);
    if (count($ids) < 1) {
        json_out(['ok' => false, 'error' => 'No users in group yet.'], 400);
    }
    return $ids;
}

function secure_shuffle(array $items): array
{
    $count = count($items);
    if ($count <= 1) {
        return $items;
    }

    for ($i = $count - 1; $i > 0; $i--) {
        $j = random_int(0, $i);
        $tmp = $items[$i];
        $items[$i] = $items[$j];
        $items[$j] = $tmp;
    }

    return $items;
}
