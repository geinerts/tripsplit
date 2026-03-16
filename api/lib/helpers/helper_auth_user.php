<?php
declare(strict_types=1);

function users_name_columns_available(PDO $pdo): bool
{
    static $cached = null;
    if (is_bool($cached)) {
        return $cached;
    }

    $usersTable = DB_TABLE_PREFIX . 'users';
    if (!preg_match('/^[A-Za-z0-9_]+$/', $usersTable)) {
        $cached = false;
        return $cached;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.columns
             WHERE table_schema = DATABASE()
               AND table_name = :table_name
               AND column_name IN (\'first_name\', \'last_name\')'
        );
        $stmt->execute(['table_name' => $usersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 2;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function combine_full_name(?string $firstName, ?string $lastName): ?string
{
    $full = trim(trim((string) $firstName) . ' ' . trim((string) $lastName));
    return $full !== '' ? $full : null;
}

function normalize_me_name_value($value): ?string
{
    $trimmed = trim((string) ($value ?? ''));
    return $trimmed !== '' ? $trimmed : null;
}

function me_display_name(array $user): string
{
    $fullName = combine_full_name(
        normalize_me_name_value($user['first_name'] ?? null),
        normalize_me_name_value($user['last_name'] ?? null),
    );
    if ($fullName !== null) {
        return $fullName;
    }
    return (string) ($user['nickname'] ?? '');
}

function credential_password_algo()
{
    return defined('PASSWORD_ARGON2ID') ? PASSWORD_ARGON2ID : PASSWORD_BCRYPT;
}

function build_me_payload(array $user): array
{
    $email = trim((string) ($user['email'] ?? ''));
    $passwordHash = trim((string) ($user['password_hash'] ?? ''));
    $needsCredentials = ((int) ($user['credentials_required'] ?? 1) === 1) || $email === '' || $passwordHash === '';
    $avatarPath = trim((string) ($user['avatar_path'] ?? ''));
    $firstName = normalize_me_name_value($user['first_name'] ?? null);
    $lastName = normalize_me_name_value($user['last_name'] ?? null);

    return [
        'id' => (int) $user['id'],
        'first_name' => $firstName,
        'last_name' => $lastName,
        'full_name' => combine_full_name($firstName, $lastName),
        'display_name' => me_display_name($user),
        'nickname' => (string) ($user['nickname'] ?? ''),
        'email' => $email !== '' ? $email : null,
        'needs_credentials' => $needsCredentials,
        'avatar_url' => $avatarPath !== '' ? avatar_public_url($avatarPath) : null,
        'avatar_thumb_url' => $avatarPath !== '' ? avatar_thumb_public_url($avatarPath) : null,
    ];
}

function fetch_me_row_by_token(PDO $pdo, string $token): ?array
{
    $usersTable = table_name('users');
    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . 'nickname, email, password_hash, credentials_required, avatar_path
         FROM ' . $usersTable . '
         WHERE device_token = :token
         LIMIT 1'
    );
    $stmt->execute(['token' => $token]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}

function fetch_me_row_by_id(PDO $pdo, int $userId): ?array
{
    $usersTable = table_name('users');
    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . 'nickname, email, password_hash, credentials_required, avatar_path
         FROM ' . $usersTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $stmt->execute(['id' => $userId]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}
