<?php
declare(strict_types=1);

function email_change_token_is_well_formed(string $token): bool
{
    return (bool) preg_match('/^[a-f0-9]{64}$/', strtolower(trim($token)));
}

function create_email_change_request(PDO $pdo, int $userId, string $oldEmail, string $newEmail): array
{
    if ($userId <= 0) {
        throw new RuntimeException('Invalid user id for email change request.');
    }

    $oldEmail = strtolower(trim($oldEmail));
    $newEmail = strtolower(trim($newEmail));
    if ($oldEmail === '' || $newEmail === '') {
        throw new RuntimeException('Invalid email change request payload.');
    }

    ensure_email_change_requests_table_available($pdo);
    $table = table_name('email_change_requests');

    $verifyToken = bin2hex(random_bytes(32));
    $cancelToken = bin2hex(random_bytes(32));
    $verifyTokenHash = hash('sha256', $verifyToken);
    $cancelTokenHash = hash('sha256', $cancelToken);
    $expiresAt = gmdate('Y-m-d H:i:s', time() + email_change_token_ttl_seconds());

    $pdo->prepare(
        'INSERT INTO ' . $table . ' (
            user_id,
            old_email,
            new_email,
            verify_token_hash,
            cancel_token_hash,
            expires_at
         ) VALUES (
            :user_id,
            :old_email,
            :new_email,
            :verify_token_hash,
            :cancel_token_hash,
            :expires_at
         )'
    )->execute([
        'user_id' => $userId,
        'old_email' => $oldEmail,
        'new_email' => $newEmail,
        'verify_token_hash' => $verifyTokenHash,
        'cancel_token_hash' => $cancelTokenHash,
        'expires_at' => $expiresAt,
    ]);

    return [
        'id' => (int) $pdo->lastInsertId(),
        'verify_token' => $verifyToken,
        'cancel_token' => $cancelToken,
        'expires_at' => $expiresAt,
    ];
}

function cancel_email_change_request_by_id(PDO $pdo, int $requestId): void
{
    if ($requestId <= 0) {
        return;
    }

    $table = table_name('email_change_requests');
    $pdo->prepare(
        'UPDATE ' . $table . '
         SET cancelled_at = COALESCE(cancelled_at, UTC_TIMESTAMP()),
             consumed_at = COALESCE(consumed_at, UTC_TIMESTAMP())
         WHERE id = :id'
    )->execute(['id' => $requestId]);
}

function request_email_change_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();

    $newEmail = validate_email_address((string) ($body['new_email'] ?? ''));
    $currentPassword = trim((string) ($body['current_password'] ?? ''));
    if ($currentPassword === '') {
        json_out(['ok' => false, 'error' => 'Current password is required.'], 400);
    }

    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);
    enforce_rate_limit(
        $pdo,
        'email_change_request_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'email_change_request_user',
        (string) $userId,
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    if (!email_change_requests_table_available($pdo) || !users_email_verified_at_column_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Email change is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $usersTable = table_name('users');
    $requestsTable = table_name('email_change_requests');
    $requestId = 0;
    $oldEmail = '';
    $firstName = '';
    $expiresAt = '';
    $verifyToken = '';
    $cancelToken = '';

    $pdo->beginTransaction();
    try {
        $nameSelect = users_name_columns_available($pdo)
            ? 'first_name, '
            : 'NULL AS first_name, ';
        $accountSelect = users_account_status_select_sql($pdo);
        $userStmt = $pdo->prepare(
            'SELECT id, email, password_hash, credentials_required, ' . $nameSelect . $accountSelect . '
                nickname
             FROM ' . $usersTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $userStmt->execute(['id' => $userId]);
        $user = $userStmt->fetch();
        if (!$user) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'User not found.'], 404);
        }
        if (!user_account_is_active((array) $user)) {
            $pdo->rollBack();
            json_out(user_account_block_error_payload((array) $user), 403);
        }

        $oldEmail = strtolower(trim((string) ($user['email'] ?? '')));
        $passwordHash = (string) ($user['password_hash'] ?? '');
        $requiresCredentials = ((int) ($user['credentials_required'] ?? 1)) === 1;
        if ($oldEmail === '' || $requiresCredentials || $passwordHash === '') {
            $pdo->rollBack();
            json_out([
                'ok' => false,
                'error' => 'Add email and password first before changing email.',
            ], 409);
        }
        if (!password_verify($currentPassword, $passwordHash)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Current password is incorrect.'], 401);
        }
        if ($newEmail === $oldEmail) {
            $pdo->rollBack();
            json_out([
                'ok' => false,
                'error' => 'New email must be different from current email.',
            ], 400);
        }

        $existsStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $usersTable . '
             WHERE email = :email
               AND id <> :id
             LIMIT 1
             FOR UPDATE'
        );
        $existsStmt->execute([
            'email' => $newEmail,
            'id' => $userId,
        ]);
        if ($existsStmt->fetch()) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Email is already used by another account.'], 409);
        }

        $pendingStmt = $pdo->prepare(
            'SELECT id, user_id
             FROM ' . $requestsTable . '
             WHERE new_email = :new_email
               AND consumed_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             ORDER BY id DESC
             LIMIT 1
             FOR UPDATE'
        );
        $pendingStmt->execute(['new_email' => $newEmail]);
        $pending = $pendingStmt->fetch();
        if ($pending && (int) ($pending['user_id'] ?? 0) !== $userId) {
            $pdo->rollBack();
            json_out([
                'ok' => false,
                'error' => 'An email change is already pending for this email address.',
            ], 409);
        }

        $pdo->prepare(
            'UPDATE ' . $requestsTable . '
             SET cancelled_at = COALESCE(cancelled_at, UTC_TIMESTAMP()),
                 consumed_at = COALESCE(consumed_at, UTC_TIMESTAMP())
             WHERE user_id = :user_id
               AND consumed_at IS NULL
               AND expires_at > UTC_TIMESTAMP()'
        )->execute(['user_id' => $userId]);

        $tokenMeta = create_email_change_request($pdo, $userId, $oldEmail, $newEmail);
        $requestId = (int) ($tokenMeta['id'] ?? 0);
        $verifyToken = (string) ($tokenMeta['verify_token'] ?? '');
        $cancelToken = (string) ($tokenMeta['cancel_token'] ?? '');
        $expiresAt = (string) ($tokenMeta['expires_at'] ?? '');
        if (
            $requestId <= 0
            || $verifyToken === ''
            || $cancelToken === ''
            || $expiresAt === ''
        ) {
            throw new RuntimeException('Failed to create email change request.');
        }

        $firstName = trim((string) ($user['first_name'] ?? ''));
        if ($firstName === '') {
            $firstName = trim((string) ($user['nickname'] ?? 'there'));
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $cancelUrl = app_base_url() . '/api/cancel-email-change.php?token=' . urlencode($cancelToken);
    $verifyUrl = app_base_url() . '/api/confirm-email-change.php?token=' . urlencode($verifyToken);

    $cancelHtml = build_email_change_cancel_email($cancelUrl, $firstName, $newEmail);
    $sentCancel = send_email_via_resend(
        $oldEmail,
        'Email change requested for your Splyto account',
        $cancelHtml
    );
    if (!$sentCancel) {
        cancel_email_change_request_by_id($pdo, $requestId);
        json_out([
            'ok' => false,
            'error' => 'Could not send confirmation email right now. Please try again later.',
        ], 503);
    }

    $verifyHtml = build_email_change_verification_email($verifyUrl, $firstName, $newEmail);
    $sentVerify = send_email_via_resend(
        $newEmail,
        'Confirm your new Splyto email',
        $verifyHtml
    );
    if (!$sentVerify) {
        cancel_email_change_request_by_id($pdo, $requestId);
        json_out([
            'ok' => false,
            'error' => 'Could not send verification email right now. Please try again later.',
        ], 503);
    }

    json_out([
        'ok' => true,
        'pending_email' => $newEmail,
        'expires_at' => $expiresAt,
    ]);
}

function confirm_email_change_action(): void
{
    require_post();
    $body = read_json();
    $token = strtolower(trim((string) ($body['token'] ?? '')));
    if (!email_change_token_is_well_formed($token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired email change link.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'confirm_email_change_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    if (!email_change_requests_table_available($pdo) || !users_email_verified_at_column_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Email change is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $requestsTable = table_name('email_change_requests');
    $usersTable = table_name('users');
    $tokenHash = hash('sha256', $token);
    $userId = 0;

    $pdo->beginTransaction();
    try {
        $requestStmt = $pdo->prepare(
            'SELECT id, user_id, old_email, new_email
             FROM ' . $requestsTable . '
             WHERE verify_token_hash = :token_hash
               AND consumed_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             LIMIT 1
             FOR UPDATE'
        );
        $requestStmt->execute(['token_hash' => $tokenHash]);
        $request = $requestStmt->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired email change link.'], 400);
        }

        $requestId = (int) ($request['id'] ?? 0);
        $userId = (int) ($request['user_id'] ?? 0);
        $oldEmail = strtolower(trim((string) ($request['old_email'] ?? '')));
        $newEmail = strtolower(trim((string) ($request['new_email'] ?? '')));
        if ($requestId <= 0 || $userId <= 0 || $oldEmail === '' || $newEmail === '') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid email change token state.'], 400);
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
            cancel_email_change_request_by_id($pdo, $requestId);
            $pdo->commit();
            json_out(['ok' => false, 'error' => 'Invalid or expired email change link.'], 400);
        }

        if (!user_account_is_active((array) $user)) {
            cancel_email_change_request_by_id($pdo, $requestId);
            $pdo->commit();
            json_out(user_account_block_error_payload((array) $user), 403);
        }

        $currentEmail = strtolower(trim((string) ($user['email'] ?? '')));
        if ($currentEmail === '' || $currentEmail !== $oldEmail) {
            cancel_email_change_request_by_id($pdo, $requestId);
            $pdo->commit();
            json_out(['ok' => false, 'error' => 'Invalid or expired email change link.'], 400);
        }

        $existsStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $usersTable . '
             WHERE email = :email
               AND id <> :id
             LIMIT 1
             FOR UPDATE'
        );
        $existsStmt->execute([
            'email' => $newEmail,
            'id' => $userId,
        ]);
        if ($existsStmt->fetch()) {
            cancel_email_change_request_by_id($pdo, $requestId);
            $pdo->commit();
            json_out(['ok' => false, 'error' => 'Email is already used by another account.'], 409);
        }

        $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET email = :new_email,
                 email_verified_at = UTC_TIMESTAMP()
             WHERE id = :id'
        )->execute([
            'new_email' => $newEmail,
            'id' => $userId,
        ]);

        $pdo->prepare(
            'UPDATE ' . $requestsTable . '
             SET verified_at = UTC_TIMESTAMP(),
                 consumed_at = UTC_TIMESTAMP()
             WHERE id = :id'
        )->execute(['id' => $requestId]);

        $pdo->prepare(
            'UPDATE ' . $requestsTable . '
             SET cancelled_at = COALESCE(cancelled_at, UTC_TIMESTAMP()),
                 consumed_at = COALESCE(consumed_at, UTC_TIMESTAMP())
             WHERE user_id = :user_id
               AND id <> :id
               AND consumed_at IS NULL
               AND expires_at > UTC_TIMESTAMP()'
        )->execute([
            'user_id' => $userId,
            'id' => $requestId,
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $fresh = fetch_me_row_by_id($pdo, $userId);
    if (!$fresh) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }

    json_out([
        'ok' => true,
        'status' => 'email_changed',
        'me' => build_me_payload($fresh),
    ]);
}

function cancel_email_change_action(): void
{
    require_post();
    $body = read_json();
    $token = strtolower(trim((string) ($body['token'] ?? '')));
    if (!email_change_token_is_well_formed($token)) {
        json_out(['ok' => false, 'error' => 'Invalid or expired email change link.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'cancel_email_change_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    if (!email_change_requests_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Email change is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $requestsTable = table_name('email_change_requests');
    $tokenHash = hash('sha256', $token);

    $pdo->beginTransaction();
    try {
        $requestStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $requestsTable . '
             WHERE cancel_token_hash = :token_hash
               AND consumed_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             LIMIT 1
             FOR UPDATE'
        );
        $requestStmt->execute(['token_hash' => $tokenHash]);
        $request = $requestStmt->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid or expired email change link.'], 400);
        }

        $requestId = (int) ($request['id'] ?? 0);
        if ($requestId <= 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid email change token state.'], 400);
        }

        cancel_email_change_request_by_id($pdo, $requestId);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    json_out(['ok' => true, 'status' => 'cancelled']);
}
