<?php
declare(strict_types=1);

function friend_link_token_ttl_seconds(): int
{
    return 15_552_000; // 180 days.
}

function friend_link_token_length(): int
{
    return 24;
}

function friend_link_tokens_table_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $table = trim(table_name('friend_link_tokens'), '`');
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

function ensure_friend_link_tokens_table_available(PDO $pdo): void
{
    if (friend_link_tokens_table_available($pdo)) {
        return;
    }
    json_out(['ok' => false, 'error' => 'Friend link storage is not initialized. Run migration.'], 503);
}

function create_friend_link_token(): string
{
    $alphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
    $maxIndex = strlen($alphabet) - 1;
    $token = '';
    for ($i = 0; $i < friend_link_token_length(); $i++) {
        $token .= $alphabet[random_int(0, $maxIndex)];
    }
    return $token;
}

function normalize_friend_link_token(string $raw): string
{
    $value = strtoupper(trim($raw));
    if ($value === '') {
        json_out(['ok' => false, 'error' => 'friend_token is required.'], 400);
    }

    if (str_contains($value, '://')) {
        $query = (string) parse_url($value, PHP_URL_QUERY);
        if ($query !== '') {
            $queryParams = [];
            parse_str($query, $queryParams);
            foreach (['code', 'friend_token', 'friend_code'] as $key) {
                $candidate = strtoupper(trim((string) ($queryParams[$key] ?? '')));
                if ($candidate !== '') {
                    $value = $candidate;
                    break;
                }
            }
        }
    }

    $value = (string) preg_replace('/[^A-Z0-9]/', '', $value);
    if (!preg_match('/^[A-Z0-9]{16,64}$/', $value)) {
        json_out(['ok' => false, 'error' => 'Invalid friend link.'], 400);
    }
    return $value;
}

function build_friend_link_url(string $token): string
{
    $base = trim((string) PUBLIC_BASE_URL);
    if ($base === '') {
        $base = 'https://splyto.eu';
    }
    $base = rtrim($base, '/');
    $base = preg_replace('#/api$#', '', $base) ?: $base;

    return $base . '/friend?code=' . rawurlencode($token);
}

function get_friend_link_action(): void
{
    require_post();
    $me = get_me();
    $meId = (int) ($me['id'] ?? 0);
    if ($meId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid session.'], 401);
    }

    $pdo = db();
    ensure_friend_link_tokens_table_available($pdo);
    enforce_rate_limit(
        $pdo,
        'friend_link_create_ip',
        client_ip_address(),
        RATE_LIMIT_FRIENDS_INVITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friend_link_create_actor',
        (string) $meId,
        RATE_LIMIT_FRIENDS_INVITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $tokensTable = table_name('friend_link_tokens');
    $expiresAt = gmdate('Y-m-d H:i:s', time() + friend_link_token_ttl_seconds());
    $token = '';

    for ($attempt = 0; $attempt < 8; $attempt++) {
        $candidate = create_friend_link_token();
        try {
            $pdo->prepare(
                'INSERT INTO ' . $tokensTable . ' (user_id, token_hash, expires_at)
                 VALUES (:user_id, :token_hash, :expires_at)'
            )->execute([
                'user_id' => $meId,
                'token_hash' => hash('sha256', $candidate),
                'expires_at' => $expiresAt,
            ]);
            $token = $candidate;
            break;
        } catch (Throwable $error) {
            $errorCode = (string) ($error->getCode() ?? '');
            if ($errorCode === '23000') {
                continue;
            }
            throw $error;
        }
    }

    if ($token === '') {
        json_out(['ok' => false, 'error' => 'Failed to generate friend link.'], 500);
    }

    json_out([
        'ok' => true,
        'friend_token' => $token,
        'friend_url' => build_friend_link_url($token),
        'expires_in_sec' => friend_link_token_ttl_seconds(),
        'expires_at' => $expiresAt,
    ]);
}

function resolve_friend_link_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $rawToken =
        (string) ($body['friend_token'] ?? $body['code'] ?? $body['friend_code'] ?? '');
    $token = normalize_friend_link_token($rawToken);

    $pdo = db();
    ensure_friend_link_tokens_table_available($pdo);
    enforce_rate_limit(
        $pdo,
        'friend_link_resolve_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friend_link_resolve_actor',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    $tokensTable = table_name('friend_link_tokens');
    $stmt = $pdo->prepare(
        'SELECT id, user_id
         FROM ' . $tokensTable . '
         WHERE token_hash = :token_hash
           AND revoked_at IS NULL
           AND expires_at > UTC_TIMESTAMP()
         LIMIT 1'
    );
    $stmt->execute(['token_hash' => hash('sha256', $token)]);
    $row = $stmt->fetch();
    if (!is_array($row)) {
        json_out(['ok' => false, 'error' => 'Friend link expired or invalid.'], 404);
    }

    $tokenId = (int) ($row['id'] ?? 0);
    $targetUserId = (int) ($row['user_id'] ?? 0);
    $targetUser = find_public_user_by_id($pdo, $targetUserId);
    if (!$targetUser) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    if ($tokenId > 0) {
        $pdo->prepare(
            'UPDATE ' . $tokensTable . '
             SET last_used_at = UTC_TIMESTAMP()
             WHERE id = :id'
        )->execute(['id' => $tokenId]);
    }

    json_out([
        'ok' => true,
        'user' => friend_user_payload_from_row($targetUser),
    ]);
}
