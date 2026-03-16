<?php
declare(strict_types=1);

function auth_access_token_secret(): string
{
    $configured = trim((string) AUTH_ACCESS_TOKEN_SECRET);
    if ($configured !== '') {
        return $configured;
    }

    return hash('sha256', DB_NAME . '|' . DB_USER . '|' . DB_PASS . '|' . ADMIN_KEY . '|trip-access-token');
}

function auth_access_token_ttl_seconds(): int
{
    $ttl = (int) AUTH_ACCESS_TOKEN_TTL_SEC;
    if ($ttl < 60) {
        return 900;
    }
    if ($ttl > 86_400) {
        return 86_400;
    }
    return $ttl;
}

function auth_refresh_token_ttl_seconds(): int
{
    $ttl = (int) AUTH_REFRESH_TOKEN_TTL_SEC;
    if ($ttl < 3_600) {
        return 2_592_000;
    }
    if ($ttl > 31_536_000) {
        return 31_536_000;
    }
    return $ttl;
}

function create_access_token_for_user(int $userId): string
{
    if ($userId <= 0) {
        throw new RuntimeException('Invalid user id for access token.');
    }

    $now = time();
    $payload = [
        'typ' => 'access',
        'uid' => $userId,
        'iat' => $now,
        'exp' => $now + auth_access_token_ttl_seconds(),
        'jti' => bin2hex(random_bytes(8)),
    ];
    $json = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($json) || $json === '') {
        throw new RuntimeException('Failed to encode access token payload.');
    }

    $encoded = base64url_encode($json);
    $sig = hash_hmac('sha256', $encoded, auth_access_token_secret());
    return $encoded . '.' . $sig;
}

function resolve_user_id_from_access_token(string $token): int
{
    $parts = explode('.', trim($token), 2);
    if (count($parts) !== 2) {
        return 0;
    }

    $encodedPayload = trim((string) $parts[0]);
    $signature = trim((string) $parts[1]);
    if ($encodedPayload === '' || !preg_match('/^[a-f0-9]{64}$/', $signature)) {
        return 0;
    }

    $expected = hash_hmac('sha256', $encodedPayload, auth_access_token_secret());
    if (!hash_equals($expected, $signature)) {
        return 0;
    }

    $decodedPayload = base64url_decode($encodedPayload);
    $payload = $decodedPayload !== null ? json_decode($decodedPayload, true) : null;
    if (!is_array($payload)) {
        return 0;
    }

    $typ = (string) ($payload['typ'] ?? '');
    $userId = (int) ($payload['uid'] ?? 0);
    $issuedAt = (int) ($payload['iat'] ?? 0);
    $expiresAt = (int) ($payload['exp'] ?? 0);
    $jti = (string) ($payload['jti'] ?? '');
    $now = time();

    if (
        $typ !== 'access' ||
        $userId <= 0 ||
        $issuedAt <= 0 ||
        $expiresAt <= $issuedAt ||
        $issuedAt > ($now + 60) ||
        $now >= $expiresAt ||
        !preg_match('/^[a-f0-9]{16}$/', $jti)
    ) {
        return 0;
    }

    if (($expiresAt - $issuedAt) > auth_access_token_ttl_seconds()) {
        return 0;
    }

    return $userId;
}

function refresh_tokens_table_available(PDO $pdo): bool
{
    static $cache = null;
    if (is_bool($cache)) {
        return $cache;
    }

    $table = DB_TABLE_PREFIX . 'refresh_tokens';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $table)) {
        $cache = false;
        return $cache;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $table]);
        $cache = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cache = false;
    }

    return $cache;
}

function ensure_refresh_tokens_table_available(PDO $pdo): void
{
    if (!refresh_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Refresh token storage is not initialized. Run migration.',
        ], 503);
    }
}

function refresh_token_is_well_formed(string $token): bool
{
    $len = str_length($token);
    if ($len < 64 || $len > 200) {
        return false;
    }
    return (bool) preg_match('/^[a-f0-9]+$/', $token);
}

function create_refresh_token_row(PDO $pdo, int $userId): array
{
    if ($userId <= 0) {
        throw new RuntimeException('Invalid user id for refresh token.');
    }
    ensure_refresh_tokens_table_available($pdo);

    $plain = bin2hex(random_bytes(48));
    $hash = hash('sha256', $plain);
    $ttl = auth_refresh_token_ttl_seconds();
    $expiresAt = gmdate('Y-m-d H:i:s', time() + $ttl);
    $table = table_name('refresh_tokens');

    $insert = $pdo->prepare(
        'INSERT INTO ' . $table . '
         (user_id, token_hash, expires_at, user_agent, ip_address, last_used_at)
         VALUES (:user_id, :token_hash, :expires_at, :user_agent, :ip_address, CURRENT_TIMESTAMP)'
    );
    $insert->execute([
        'user_id' => $userId,
        'token_hash' => $hash,
        'expires_at' => $expiresAt,
        'user_agent' => trim(substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255)) ?: null,
        'ip_address' => client_ip_address(),
    ]);

    return [
        'refresh_token' => $plain,
        'refresh_expires_in_sec' => $ttl,
    ];
}

function issue_auth_payload(PDO $pdo, int $userId): array
{
    $accessToken = create_access_token_for_user($userId);
    $refresh = create_refresh_token_row($pdo, $userId);

    return [
        'token_type' => 'Bearer',
        'access_token' => $accessToken,
        'access_expires_in_sec' => auth_access_token_ttl_seconds(),
        'refresh_token' => (string) ($refresh['refresh_token'] ?? ''),
        'refresh_expires_in_sec' => (int) ($refresh['refresh_expires_in_sec'] ?? auth_refresh_token_ttl_seconds()),
    ];
}

function rotate_refresh_token(PDO $pdo, string $refreshToken): ?array
{
    $refreshToken = strtolower(trim($refreshToken));
    if (!refresh_token_is_well_formed($refreshToken)) {
        return null;
    }
    ensure_refresh_tokens_table_available($pdo);

    $table = table_name('refresh_tokens');
    $tokenHash = hash('sha256', $refreshToken);
    $now = gmdate('Y-m-d H:i:s');
    $ttl = auth_refresh_token_ttl_seconds();
    $nextToken = bin2hex(random_bytes(48));
    $nextHash = hash('sha256', $nextToken);
    $nextExpiresAt = gmdate('Y-m-d H:i:s', time() + $ttl);
    $userAgent = trim(substr((string) ($_SERVER['HTTP_USER_AGENT'] ?? ''), 0, 255));
    $ipAddress = client_ip_address();

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, user_id, expires_at, revoked_at
             FROM ' . $table . '
             WHERE token_hash = :token_hash
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute(['token_hash' => $tokenHash]);
        $row = $select->fetch();
        if (!$row) {
            $pdo->rollBack();
            return null;
        }

        $revokedAt = $row['revoked_at'] ?? null;
        $expiresAt = (string) ($row['expires_at'] ?? '');
        if ($revokedAt !== null || $expiresAt === '' || strtotime($expiresAt) <= time()) {
            $revoke = $pdo->prepare(
                'UPDATE ' . $table . '
                 SET revoked_at = COALESCE(revoked_at, :revoked_at),
                     last_used_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $revoke->execute([
                'revoked_at' => $now,
                'id' => (int) ($row['id'] ?? 0),
            ]);
            $pdo->commit();
            return null;
        }

        $userId = (int) ($row['user_id'] ?? 0);
        if ($userId <= 0) {
            $pdo->rollBack();
            return null;
        }

        $revokeCurrent = $pdo->prepare(
            'UPDATE ' . $table . '
             SET revoked_at = :revoked_at,
                 last_used_at = CURRENT_TIMESTAMP
             WHERE id = :id'
        );
        $revokeCurrent->execute([
            'revoked_at' => $now,
            'id' => (int) ($row['id'] ?? 0),
        ]);

        $insertNext = $pdo->prepare(
            'INSERT INTO ' . $table . '
             (user_id, token_hash, expires_at, user_agent, ip_address, last_used_at)
             VALUES (:user_id, :token_hash, :expires_at, :user_agent, :ip_address, CURRENT_TIMESTAMP)'
        );
        $insertNext->execute([
            'user_id' => $userId,
            'token_hash' => $nextHash,
            'expires_at' => $nextExpiresAt,
            'user_agent' => $userAgent !== '' ? $userAgent : null,
            'ip_address' => $ipAddress,
        ]);

        if (random_int(1, 80) === 1) {
            $cleanup = $pdo->prepare(
                'DELETE FROM ' . $table . '
                 WHERE (revoked_at IS NOT NULL AND revoked_at < (CURRENT_TIMESTAMP - INTERVAL 30 DAY))
                    OR (expires_at < (CURRENT_TIMESTAMP - INTERVAL 7 DAY))'
            );
            $cleanup->execute();
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    return [
        'user_id' => $userId,
        'auth' => [
            'token_type' => 'Bearer',
            'access_token' => create_access_token_for_user($userId),
            'access_expires_in_sec' => auth_access_token_ttl_seconds(),
            'refresh_token' => $nextToken,
            'refresh_expires_in_sec' => $ttl,
        ],
    ];
}
