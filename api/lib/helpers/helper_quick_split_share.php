<?php
declare(strict_types=1);

// Share links for quick splits: a public page anyone with the link can open.
// See docs/api/quick-split-share-links.md.

const QUICK_SPLIT_SHARE_TTL_SEC = 90 * 86_400;
const QUICK_SPLIT_SHARE_VIEW_IP_MAX = 120;
const QUICK_SPLIT_SHARE_VIEW_WINDOW_SEC = 600;

function quick_split_shares_available(PDO $pdo): bool
{
    // Only a found table is remembered, so the migration takes effect without a restart.
    static $found = [];
    $key = spl_object_id($pdo);
    if (isset($found[$key])) {
        return true;
    }
    try {
        $pdo->query('SELECT 1 FROM ' . table_name('quick_split_shares') . ' LIMIT 0');
    } catch (Throwable $error) {
        return false;
    }
    return $found[$key] = true;
}

function quick_split_share_key(): string
{
    return hash('sha256', 'quick-split-share|' . private_media_signing_secret(), true);
}

/** The link token for a stored salt: 22 URL-safe characters. */
function quick_split_share_token(string $salt): string
{
    $raw = substr(hash_hmac('sha256', $salt, quick_split_share_key(), true), 0, 16);
    return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
}

function quick_split_share_normalize_token(mixed $raw): ?string
{
    $token = is_string($raw) ? trim($raw) : '';
    return preg_match('/^[A-Za-z0-9_-]{22}$/D', $token) ? $token : null;
}

function quick_split_share_url(string $token): string
{
    return 'https://splyto.eu/split?code=' . rawurlencode($token);
}

function quick_split_share_now(?int $now = null): string
{
    return gmdate('Y-m-d H:i:s', $now ?? time());
}

/** The link that still works for this quick split, if any. */
function quick_split_share_active(PDO $pdo, int $quickSplitId, bool $lock = false): ?array
{
    if (!quick_split_shares_available($pdo)) {
        return null;
    }
    $stmt = $pdo->prepare(
        'SELECT * FROM ' . table_name('quick_split_shares') . '
         WHERE quick_split_id = :id AND revoked_at IS NULL AND expires_at > :now
         ORDER BY id DESC LIMIT 1' . ($lock ? ' FOR UPDATE' : '')
    );
    $stmt->execute(['id' => $quickSplitId, 'now' => quick_split_share_now()]);
    $row = $stmt->fetch();
    return $row ?: null;
}

/** `{url, expires_at, show_receipt}` as the app sees it. */
function quick_split_share_payload(array $share): array
{
    return [
        'url' => quick_split_share_url(quick_split_share_token((string) $share['token_salt'])),
        'expires_at' => gmdate('Y-m-d\TH:i:s\Z', (int) strtotime((string) $share['expires_at'] . ' UTC')),
        'show_receipt' => (int) $share['show_receipt'] === 1,
    ];
}

function quick_split_share_create(PDO $pdo, int $quickSplitId, int $userId, bool $showReceipt): array
{
    $salt = bin2hex(random_bytes(16));
    $pdo->prepare(
        'INSERT INTO ' . table_name('quick_split_shares') . '
         (quick_split_id, token_salt, token_hash, show_receipt, created_by, expires_at)
         VALUES (:qs, :salt, :hash, :show_receipt, :user, :expires)'
    )->execute([
        'qs' => $quickSplitId,
        'salt' => $salt,
        'hash' => hash('sha256', quick_split_share_token($salt)),
        'show_receipt' => $showReceipt ? 1 : 0,
        'user' => $userId,
        'expires' => quick_split_share_now(time() + QUICK_SPLIT_SHARE_TTL_SEC),
    ]);
    return quick_split_share_active($pdo, $quickSplitId) ?? throw new RuntimeException('Share link was not saved.');
}

function quick_split_share_delete_for(PDO $pdo, int $quickSplitId): void
{
    if (!quick_split_shares_available($pdo)) {
        return;
    }
    $pdo->prepare('DELETE FROM ' . table_name('quick_split_shares') . ' WHERE quick_split_id = :id')
        ->execute(['id' => $quickSplitId]);
}

/**
 * The quick split behind a link that still works: not revoked, not expired, not added to a
 * trip, made by an active account. Null in every other case, so callers answer the same way.
 *
 * @return array{share: array, quick_split: array}|null
 */
function quick_split_share_resolve(PDO $pdo, mixed $rawToken): ?array
{
    $token = quick_split_share_normalize_token($rawToken);
    if ($token === null || !quick_split_shares_available($pdo)) {
        return null;
    }
    $stmt = $pdo->prepare(
        'SELECT s.id AS share_id, s.token_salt, s.show_receipt, s.expires_at AS share_expires_at, qs.*
         FROM ' . table_name('quick_split_shares') . ' s
         JOIN ' . table_name('quick_splits') . ' qs ON qs.id = s.quick_split_id
         JOIN ' . table_name('users') . ' u ON u.id = qs.created_by
         WHERE s.token_hash = :hash AND s.revoked_at IS NULL AND s.expires_at > :now
           AND qs.moved_at IS NULL AND u.account_status = :active
         LIMIT 1'
    );
    $stmt->execute(['hash' => hash('sha256', $token), 'now' => quick_split_share_now(), 'active' => 'active']);
    $row = $stmt->fetch();
    if (!$row || !hash_equals(quick_split_share_token((string) $row['token_salt']), $token)) {
        return null;
    }
    return [
        'share' => ['id' => (int) $row['share_id'], 'show_receipt' => (int) $row['show_receipt'] === 1],
        'quick_split' => $row,
    ];
}

function quick_split_share_initials(string $name): string
{
    $parts = preg_split('/\s+/u', trim($name)) ?: [];
    $out = '';
    foreach ($parts as $part) {
        if ($part === '') {
            continue;
        }
        $out .= mb_strtoupper(mb_substr($part, 0, 1));
        if (mb_strlen($out) >= 2) {
            break;
        }
    }
    return $out !== '' ? $out : '?';
}

/**
 * What the public page shows: names and amounts only. No user ids, avatars or emails.
 * Person `id` is the quick split's own person row id (used by `?p=`).
 */
function quick_split_share_page_data(PDO $pdo, array $resolved): array
{
    $row = $resolved['quick_split'];
    $id = (int) $row['id'];
    $people = quick_split_load_people($pdo, [$id], 0)[$id] ?? [];
    $publicPeople = [];
    $payer = '';
    $sharer = '';
    foreach ($people as $person) {
        $name = trim((string) $person['name']) !== '' ? (string) $person['name'] : '?';
        if ($person['user_id'] === (int) $row['created_by']) {
            $sharer = $name;
        }
        $publicPeople[] = [
            'id' => (int) $person['id'],
            'name' => $name,
            'initials' => quick_split_share_initials($name),
            'amount_cents' => (int) round(((float) $person['amount']) * 100),
            'is_payer' => (bool) $person['is_payer'],
        ];
        if ($person['is_payer']) {
            $payer = $name;
        }
    }

    $items = [];
    $extraCents = 0;
    if ((string) $row['split_mode'] === 'itemized') {
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
        foreach ($itemRows as $item) {
            if ((int) $item['is_extra'] === 1) {
                $extraCents = (int) $item['amount_cents'];
                continue;
            }
            $items[] = [
                'name' => (string) $item['name'],
                'amount_cents' => (int) $item['amount_cents'],
                'person_ids' => $byItem[(int) $item['id']] ?? [],
            ];
        }
    }

    $receiptPath = trim((string) ($row['receipt_path'] ?? ''));
    return [
        'note' => trim((string) $row['note']),
        'category' => (string) $row['category'],
        'date' => (string) $row['split_date'],
        'amount_cents' => (int) $row['amount_cents'],
        'currency_code' => (string) $row['currency_code'],
        'split_mode' => (string) $row['split_mode'],
        'payer_name' => $payer,
        'sharer_name' => $sharer !== '' ? $sharer : $payer,
        'version' => substr(hash('sha256', (string) ($row['updated_at'] ?? '') . '|' . $resolved['share']['id']), 0, 12),
        'people' => $publicPeople,
        'items' => $items,
        'extra_cents' => $extraCents,
        'receipt_url' => $resolved['share']['show_receipt'] && $receiptPath !== ''
            ? receipt_public_url($receiptPath)
            : null,
    ];
}
