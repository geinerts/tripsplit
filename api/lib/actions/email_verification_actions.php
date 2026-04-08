<?php
declare(strict_types=1);

function email_verification_token_is_well_formed(string $token): bool
{
    return (bool) preg_match('/^[a-f0-9]{64}$/', strtolower(trim($token)));
}

function create_email_verification_token(PDO $pdo, int $userId, string $email): array
{
    if ($userId <= 0) {
        throw new RuntimeException('Invalid user id for email verification token.');
    }
    $email = strtolower(trim($email));
    if ($email === '') {
        throw new RuntimeException('Invalid email for email verification token.');
    }

    ensure_email_verification_tokens_table_available($pdo);
    $table = table_name('email_verification_tokens');

    $pdo->prepare(
        'UPDATE ' . $table . '
         SET used_at = COALESCE(used_at, UTC_TIMESTAMP())
         WHERE user_id = :user_id
           AND email = :email
           AND used_at IS NULL
           AND expires_at > UTC_TIMESTAMP()'
    )->execute([
        'user_id' => $userId,
        'email' => $email,
    ]);

    $token = bin2hex(random_bytes(32));
    $tokenHash = hash('sha256', $token);
    $expiresAt = gmdate('Y-m-d H:i:s', time() + email_verification_token_ttl_seconds());

    $pdo->prepare(
        'INSERT INTO ' . $table . ' (user_id, email, token_hash, expires_at)
         VALUES (:user_id, :email, :token_hash, :expires_at)'
    )->execute([
        'user_id' => $userId,
        'email' => $email,
        'token_hash' => $tokenHash,
        'expires_at' => $expiresAt,
    ]);

    return [
        'token' => $token,
        'expires_at' => $expiresAt,
    ];
}

function send_email_verification_link_for_user(PDO $pdo, array $user, bool $suppressSendErrors = false): bool
{
    if (!email_verification_required()) {
        return true;
    }

    $status = user_account_status($user);
    if ($status === 'deleted') {
        return false;
    }
    if (!user_has_email_credentials($user) || !user_requires_email_verification($user)) {
        return true;
    }
    if (!email_verification_tokens_table_available($pdo)) {
        if ($suppressSendErrors) {
            return false;
        }
        ensure_email_verification_tokens_table_available($pdo);
        return false;
    }

    $userId = (int) ($user['id'] ?? 0);
    $email = strtolower(trim((string) ($user['email'] ?? '')));
    if ($userId <= 0 || $email === '') {
        return false;
    }

    $tokenMeta = create_email_verification_token($pdo, $userId, $email);
    $plainToken = (string) ($tokenMeta['token'] ?? '');
    if ($plainToken === '') {
        return false;
    }

    $firstName = trim((string) ($user['first_name'] ?? ''));
    if ($firstName === '') {
        $firstName = trim((string) ($user['nickname'] ?? 'there'));
    }

    $verifyUrl = app_base_url() . '/api/verify-email.php?token=' . urlencode($plainToken);
    $html = build_email_verification_email($verifyUrl, $firstName, email_verification_grace_days());
    $sent = send_email_via_resend($email, 'Verify your Splyto email', $html);
    if (!$sent && !$suppressSendErrors) {
        json_out([
            'ok' => false,
            'error' => 'Could not send verification email right now. Please try again later.',
        ], 503);
    }

    return $sent;
}

function request_email_verification_link_action(): void
{
    require_post();
    $body = read_json();
    $email = strtolower(trim((string) ($body['email'] ?? '')));
    if ($email === '' || !filter_var($email, FILTER_VALIDATE_EMAIL)) {
        json_out(['ok' => false, 'error' => 'Email is invalid.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'email_verify_link_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'email_verify_link_email',
        $email,
        RATE_LIMIT_LOGIN_EMAIL_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );

    if (!email_verification_required()) {
        json_out(['ok' => true]);
    }
    if (!users_email_verified_at_column_available($pdo) || !email_verification_tokens_table_available($pdo)) {
        json_out(['ok' => true]);
    }

    $usersTable = table_name('users');
    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, '
        : 'NULL AS first_name, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, email, credentials_required, ' . $nameSelect . $accountSelect . '
            nickname
         FROM ' . $usersTable . '
         WHERE email = :email
         LIMIT 1'
    );
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();
    if (!$user) {
        json_out(['ok' => true]);
    }
    if (!user_has_email_credentials((array) $user) || !user_requires_email_verification((array) $user)) {
        json_out(['ok' => true]);
    }
    if (user_account_status((array) $user) === 'deleted') {
        json_out(['ok' => true]);
    }

    send_email_verification_link_for_user($pdo, (array) $user, true);
    json_out(['ok' => true]);
}

function confirm_email_verification_action(): void
{
    require_post();
    $body = read_json();
    $token = strtolower(trim((string) ($body['token'] ?? '')));
    if (!email_verification_token_is_well_formed($token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired verification link.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'confirm_email_verify_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );

    if (!email_verification_required()) {
        json_out(['ok' => true]);
    }
    if (!users_email_verified_at_column_available($pdo) || !email_verification_tokens_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Email verification is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $tokensTable = table_name('email_verification_tokens');
    $usersTable = table_name('users');
    $tokenHash = hash('sha256', $token);

    $pdo->beginTransaction();
    try {
        $tokenStmt = $pdo->prepare(
            'SELECT id, user_id, email
             FROM ' . $tokensTable . '
             WHERE token_hash = :token_hash
               AND used_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             LIMIT 1
             FOR UPDATE'
        );
        $tokenStmt->execute(['token_hash' => $tokenHash]);
        $tokenRow = $tokenStmt->fetch();
        if (!$tokenRow) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired verification link.'], 400);
        }

        $tokenId = (int) ($tokenRow['id'] ?? 0);
        $userId = (int) ($tokenRow['user_id'] ?? 0);
        $tokenEmail = strtolower(trim((string) ($tokenRow['email'] ?? '')));
        if ($tokenId <= 0 || $userId <= 0 || $tokenEmail === '') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid verification token state.'], 400);
        }

        $accountSelect = users_account_status_select_sql($pdo);
        $userStmt = $pdo->prepare(
            'SELECT id, email, credentials_required, ' . $accountSelect . '
                nickname
             FROM ' . $usersTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $userStmt->execute(['id' => $userId]);
        $user = $userStmt->fetch();
        if (!$user) {
            $pdo->prepare(
                'UPDATE ' . $tokensTable . '
                 SET used_at = UTC_TIMESTAMP()
                 WHERE id = :id'
            )->execute(['id' => $tokenId]);
            $pdo->commit();
            json_out(['ok' => false, 'error' => 'Invalid or expired verification link.'], 400);
        }

        if (user_account_status((array) $user) === 'deleted') {
            $pdo->prepare(
                'UPDATE ' . $tokensTable . '
                 SET used_at = UTC_TIMESTAMP()
                 WHERE id = :id'
            )->execute(['id' => $tokenId]);
            $pdo->commit();
            json_out(user_account_block_error_payload((array) $user), 403);
        }

        $currentEmail = strtolower(trim((string) ($user['email'] ?? '')));
        if ($currentEmail === '' || $currentEmail !== $tokenEmail) {
            $pdo->prepare(
                'UPDATE ' . $tokensTable . '
                 SET used_at = UTC_TIMESTAMP()
                 WHERE id = :id'
            )->execute(['id' => $tokenId]);
            $pdo->commit();
            json_out(['ok' => false, 'error' => 'Invalid or expired verification link.'], 400);
        }

        $setDeactivatedAt = users_deactivated_at_column_available($pdo)
            ? ', deactivated_at = NULL'
            : '';
        $setDeletedAt = users_deleted_at_column_available($pdo)
            ? ', deleted_at = NULL'
            : '';

        $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET email_verified_at = COALESCE(email_verified_at, UTC_TIMESTAMP()),
                 account_status = "active"' . $setDeactivatedAt . $setDeletedAt . '
             WHERE id = :id'
        )->execute(['id' => $userId]);

        $pdo->prepare(
            'UPDATE ' . $tokensTable . '
             SET used_at = UTC_TIMESTAMP()
             WHERE id = :id'
        )->execute(['id' => $tokenId]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out(['ok' => true, 'status' => 'verified']);
}
