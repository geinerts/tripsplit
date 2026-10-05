<?php
declare(strict_types=1);

function register_proof_secret(): string
{
    $configured = trim((string) REGISTER_PROOF_SECRET);
    if (strlen($configured) >= 32) {
        return $configured;
    }

    if (!APP_DEBUG) {
        throw new RuntimeException('TRIP_REGISTER_PROOF_SECRET must contain at least 32 characters.');
    }

    return hash('sha256', DB_NAME . '|' . DB_USER . '|' . DB_PASS . '|' . ADMIN_KEY . '|trip-register-proof');
}

function register_proof_max_age_seconds(): int
{
    $value = (int) REGISTER_PROOF_MAX_AGE_SEC;
    return $value > 30 ? $value : 900;
}

function create_register_proof_token(string $deviceToken): string
{
    $now = time();
    $payload = [
        'dt' => $deviceToken,
        'iat' => $now,
        'exp' => $now + register_proof_max_age_seconds(),
        'nonce' => bin2hex(random_bytes(12)),
    ];
    $json = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($json) || $json === '') {
        json_out(['ok' => false, 'error' => 'Failed to generate registration proof.'], 500);
    }
    $encodedPayload = base64url_encode($json);
    $signature = hash_hmac('sha256', $encodedPayload, register_proof_secret());
    return $encodedPayload . '.' . $signature;
}

function validate_register_proof_token(string $token, string $deviceToken): void
{
    $token = trim($token);
    if ($token === '') {
        json_out(['ok' => false, 'error' => 'Missing registration proof.'], 400);
    }

    $parts = explode('.', $token, 2);
    if (count($parts) !== 2) {
        json_out(['ok' => false, 'error' => 'Invalid registration proof.'], 400);
    }

    $encodedPayload = trim((string) $parts[0]);
    $signature = trim((string) $parts[1]);
    if ($encodedPayload === '' || !preg_match('/^[a-f0-9]{64}$/', $signature)) {
        json_out(['ok' => false, 'error' => 'Invalid registration proof.'], 400);
    }

    $expected = hash_hmac('sha256', $encodedPayload, register_proof_secret());
    if (!hash_equals($expected, $signature)) {
        json_out(['ok' => false, 'error' => 'Invalid registration proof.'], 400);
    }

    $decodedPayload = base64url_decode($encodedPayload);
    $payload = $decodedPayload !== null ? json_decode($decodedPayload, true) : null;
    if (!is_array($payload)) {
        json_out(['ok' => false, 'error' => 'Invalid registration proof.'], 400);
    }

    $proofToken = (string) ($payload['dt'] ?? '');
    $issuedAt = (int) ($payload['iat'] ?? 0);
    $expiresAt = (int) ($payload['exp'] ?? 0);
    $nonce = (string) ($payload['nonce'] ?? '');
    $now = time();

    if (
        !preg_match('/^[a-f0-9]{64}$/', $proofToken) ||
        !preg_match('/^[a-f0-9]{24}$/', $nonce) ||
        $proofToken !== $deviceToken ||
        $issuedAt <= 0 ||
        $expiresAt <= $issuedAt ||
        $issuedAt > ($now + 60) ||
        $now > $expiresAt
    ) {
        json_out(['ok' => false, 'error' => 'Registration proof expired.'], 400);
    }

    if (($expiresAt - $issuedAt) > register_proof_max_age_seconds()) {
        json_out(['ok' => false, 'error' => 'Invalid registration proof window.'], 400);
    }
}

function register_proof_action(): void
{
    $deviceToken = token_from_header();
    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'register_proof_ip',
        client_ip_address(),
        RATE_LIMIT_REGISTER_PROOF_IP_MAX,
        RATE_LIMIT_REGISTER_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'register_proof_token',
        $deviceToken,
        RATE_LIMIT_REGISTER_PROOF_TOKEN_MAX,
        RATE_LIMIT_REGISTER_WINDOW_SEC
    );

    json_out([
        'ok' => true,
        'register_proof' => create_register_proof_token($deviceToken),
        'expires_in_sec' => register_proof_max_age_seconds(),
    ]);
}


function register_action(): void
{
    require_post();
    $body = read_json();
    $firstName = validate_person_name((string) ($body['first_name'] ?? ''), 'First name');
    $lastName = validate_person_name((string) ($body['last_name'] ?? ''), 'Last name');
    $legacyNickname = derive_legacy_nickname_from_names($firstName, $lastName);
    $headerToken = (string) ($_SERVER['HTTP_X_DEVICE_TOKEN'] ?? '');
    $bodyToken = (string) ($body['device_token'] ?? '');
    $deviceToken = validate_token($headerToken !== '' ? $headerToken : $bodyToken);
    $registerProof = (string) ($body['register_proof'] ?? '');
    $honeypot = trim((string) ($body['website'] ?? ''));
    if ($honeypot !== '') {
        json_out(['ok' => false, 'error' => 'Registration blocked.'], 400);
    }
    validate_register_proof_token($registerProof, $deviceToken);

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'register_ip',
        client_ip_address(),
        RATE_LIMIT_REGISTER_IP_MAX,
        RATE_LIMIT_REGISTER_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'register_token',
        $deviceToken,
        RATE_LIMIT_REGISTER_TOKEN_MAX,
        RATE_LIMIT_REGISTER_WINDOW_SEC
    );
    $usersTable = table_name('users');
    $hasNameColumns = users_name_columns_available($pdo);
    $emailRaw = trim((string) ($body['email'] ?? ''));
    $passwordRaw = (string) ($body['password'] ?? '');
    $hasCredentials = ($emailRaw !== '' || $passwordRaw !== '');

    $values = ['nickname' => $legacyNickname, 'device_token' => $deviceToken];
    if ($hasNameColumns) {
        $values['first_name'] = $firstName;
        $values['last_name'] = $lastName;
    }

    if ($hasCredentials) {
        $email = validate_email_address($emailRaw);
        $password = validate_password_plain($passwordRaw);
        $passwordHash = password_hash($password, credential_password_algo());
        if (!is_string($passwordHash) || $passwordHash === '') {
            json_out(['ok' => false, 'error' => 'Failed to hash password.'], 500);
        }

        $values['email'] = $email;
        $values['password_hash'] = $passwordHash;
        $values['credentials_required'] = 0;
        $values['email_verified_at'] = null;
    }

    // Registration creates an identity; a device ID must never authenticate an old one.
    // Unique indexes arbitrate concurrent requests without updating the winning account.
    $columns = array_keys($values);
    try {
        $stmt = $pdo->prepare(
            'INSERT INTO ' . $usersTable . ' (' . implode(', ', $columns) . ')
             VALUES (:' . implode(', :', $columns) . ')'
        );
        $stmt->execute($values);
    } catch (PDOException $error) {
        if ((string) $error->getCode() !== '23000') {
            throw $error;
        }
        json_out([
            'ok' => false,
            'code' => 'REGISTRATION_CONFLICT',
            'error' => 'Registration conflicts with an existing account. Sign in or recover your account.',
        ], 409);
    }

    $newUserId = (int) $pdo->lastInsertId();
    $me = $newUserId > 0 ? fetch_me_row_by_id($pdo, $newUserId) : null;
    if (!$me) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }
    assert_user_account_is_active($me);

    // Auto-verify RFC 2606 reserved test addresses (e.g. @example.test).
    // These domains cannot receive real email; no verification needed.
    if ($hasCredentials && user_requires_email_verification((array) $me)) {
        $emailLower = strtolower(trim((string) ($me['email'] ?? '')));
        if (str_ends_with($emailLower, '@example.test')) {
            $pdo->prepare(
                'UPDATE ' . $usersTable . ' SET email_verified_at = NOW() WHERE id = :id'
            )->execute(['id' => (int) ($me['id'] ?? 0)]);
            $me = fetch_me_row_by_id($pdo, $newUserId);
        } else {
            send_email_verification_link_for_user($pdo, (array) $me);
            json_out([
                'ok' => true,
                'code' => 'EMAIL_VERIFICATION_REQUIRED',
                'email_verification_required' => true,
                'verification_email' => $emailLower,
                'message' => 'Verification email sent. Please verify your email before logging in.',
            ]);
        }
    }

    $newUserId = (int) ($me['id'] ?? 0);
    app_event($pdo, $newUserId, 'user.registered', 'user', $newUserId);
    json_out([
        'ok' => true,
        'me' => build_me_payload($me, $pdo),
        'auth' => issue_auth_payload($pdo, $newUserId),
    ]);
}

function login_action(): void
{
    require_post();
    $body = read_json();
    $email = validate_email_address((string) ($body['email'] ?? ''));
    $password = validate_password_for_login((string) ($body['password'] ?? ''));
    $deviceToken = token_from_header();

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'login_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'login_email',
        $email,
        RATE_LIMIT_LOGIN_EMAIL_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    $usersTable = table_name('users');
    $nameSelect = users_name_columns_available($pdo)
        ? 'first_name, last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $accountSelect = users_account_status_select_sql($pdo);

    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . $accountSelect . 'nickname, email, password_hash, credentials_required, avatar_path
         FROM ' . $usersTable . '
         WHERE email = :email
         LIMIT 1'
    );
    $stmt->execute(['email' => $email]);
    $user = $stmt->fetch();
    if (!$user) {
        json_out(['ok' => false, 'error' => 'Invalid email or password.'], 401);
    }

    $hash = (string) ($user['password_hash'] ?? '');
    if ($hash === '' || !password_verify($password, $hash)) {
        json_out(['ok' => false, 'error' => 'Invalid email or password.'], 401);
    }
    if (user_requires_email_verification((array) $user)) {
        if (user_account_status((array) $user) === 'deleted') {
            revoke_refresh_tokens_for_user($pdo, (int) ($user['id'] ?? 0));
            json_out(user_account_block_error_payload((array) $user), 403);
        }
        json_out(user_email_verification_block_error_payload((array) $user), 403);
    }
    if (!user_account_is_active((array) $user)) {
        revoke_refresh_tokens_for_user($pdo, (int) ($user['id'] ?? 0));
        json_out(user_account_block_error_payload((array) $user), 403);
    }

    $pdo->beginTransaction();
    try {
        $id = (int) $user['id'];
        $locked = lock_auth_user($pdo, $id);
        if (!$locked || strtolower((string) $locked['email']) !== $email
            || !password_verify($password, (string) $locked['password_hash'])) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Invalid email or password.'], 401);
        }
        if (!user_account_is_active($locked) || user_requires_email_verification($locked)) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Account is unavailable.'], 403);
        }
        $hash = (string) $locked['password_hash'];
        $conflictStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $usersTable . '
             WHERE device_token = :token AND id <> :id
             LIMIT 1
             FOR UPDATE'
        );
        $conflictStmt->execute([
            'token' => $deviceToken,
            'id' => $id,
        ]);
        $conflictId = (int) ($conflictStmt->fetchColumn() ?: 0);
        if ($conflictId > 0) {
            $reassign = $pdo->prepare(
                'UPDATE ' . $usersTable . '
                 SET device_token = :new_token
                 WHERE id = :id'
            );
            $reassign->execute([
                'new_token' => bin2hex(random_bytes(32)),
                'id' => $conflictId,
            ]);
        }

        $newHash = $hash;
        if (password_needs_rehash($hash, credential_password_algo())) {
            $rehash = password_hash($password, credential_password_algo());
            if (is_string($rehash) && $rehash !== '') {
                $newHash = $rehash;
            }
        }

        $update = $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET device_token = :device_token,
                 password_hash = :password_hash,
                 credentials_required = 0
             WHERE id = :id'
        );
        $update->execute([
            'device_token' => $deviceToken,
            'password_hash' => $newHash,
            'id' => $id,
        ]);

        $auth = issue_auth_payload($pdo, $id);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $me = fetch_me_row_by_id($pdo, (int) $user['id']);
    if (!$me) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }

    $loggedInUserId = (int) ($me['id'] ?? 0);
    app_event($pdo, $loggedInUserId, 'user.login', 'user', $loggedInUserId);
    json_out([
        'ok' => true,
        'me' => build_me_payload($me, $pdo),
        'auth' => $auth,
    ]);
}

function refresh_session_action(): void
{
    require_post();
    $body = read_json();
    $refreshToken = strtolower(trim((string) ($body['refresh_token'] ?? '')));
    if (!refresh_token_is_well_formed($refreshToken)) {
        json_out(['ok' => false, 'error' => 'Invalid refresh token.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'refresh_ip',
        client_ip_address(),
        RATE_LIMIT_REFRESH_IP_MAX,
        RATE_LIMIT_REFRESH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'refresh_token',
        $refreshToken,
        RATE_LIMIT_REFRESH_TOKEN_MAX,
        RATE_LIMIT_REFRESH_WINDOW_SEC
    );

    $rotated = rotate_refresh_token($pdo, $refreshToken);
    if (!is_array($rotated)) {
        json_out(['ok' => false, 'error' => 'Invalid refresh token.'], 401);
    }

    $userId = (int) ($rotated['user_id'] ?? 0);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Invalid refresh token user.'], 401);
    }

    $me = fetch_me_row_by_id($pdo, $userId);
    if (!$me) {
        revoke_refresh_tokens_for_user($pdo, $userId);
        json_out(['ok' => false, 'error' => 'User not found.'], 401);
    }
    if (user_requires_email_verification((array) $me)) {
        revoke_refresh_tokens_for_user($pdo, $userId);
        json_out(user_email_verification_block_error_payload((array) $me), 403);
    }
    if (!user_account_is_active((array) $me)) {
        revoke_refresh_tokens_for_user($pdo, $userId);
        json_out(user_account_block_error_payload((array) $me), 403);
    }

    json_out([
        'ok' => true,
        'me' => build_me_payload($me, $pdo),
        'auth' => (array) ($rotated['auth'] ?? []),
    ]);
}

function logout_session_action(): void
{
    require_post();
    $body = read_json();
    $refreshToken = strtolower(trim((string) ($body['refresh_token'] ?? '')));
    if (!refresh_token_is_well_formed($refreshToken)) {
        json_out(['ok' => true]);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'refresh_ip',
        client_ip_address(),
        RATE_LIMIT_REFRESH_IP_MAX,
        RATE_LIMIT_REFRESH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'refresh_token',
        $refreshToken,
        RATE_LIMIT_REFRESH_TOKEN_MAX,
        RATE_LIMIT_REFRESH_WINDOW_SEC
    );
    revoke_refresh_token($pdo, $refreshToken);

    // Always return the same response so this endpoint cannot reveal token validity.
    json_out(['ok' => true]);
}

function set_credentials_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $email = validate_email_address((string) ($body['email'] ?? ''));
    $password = validate_password_plain((string) ($body['password'] ?? ''));
    $pdo = db();
    $usersTable = table_name('users');
    $userId = (int) $me['id'];
    enforce_credential_change_rate_limits($pdo, $userId);
    ensure_refresh_tokens_table_available($pdo);
    if (!email_verification_required() || !users_email_verified_at_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Verified credential enrollment is unavailable.'], 503);
    }
    ensure_email_verification_tokens_table_available($pdo);

    try {
        $pdo->beginTransaction();
        $user = lock_credential_user($pdo, $userId);
        // Only a pristine guest can enroll. Social and partially initialized accounts fail closed.
        if ((int) $user['credentials_required'] !== 1
            || trim((string) $user['email']) !== ''
            || (string) $user['password_hash'] !== ''
            || !empty($user['email_verified_at'])) {
            reject_credential_change($pdo, 'CREDENTIALS_ALREADY_SET',
                'Use password change or account recovery for this account.', 409);
        }
        $passwordHash = password_hash($password, credential_password_algo());
        if (!is_string($passwordHash) || $passwordHash === '') {
            throw new RuntimeException('Failed to hash password.');
        }
        $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET email = :email, password_hash = :password_hash,
                 credentials_required = 0, email_verified_at = NULL
             WHERE id = :id'
        )->execute(['email' => $email, 'password_hash' => $passwordHash, 'id' => $userId]);
        revoke_refresh_tokens_for_user($pdo, $userId);
        $fresh = fetch_me_row_by_id($pdo, $userId);
        if (!$fresh) {
            throw new RuntimeException('Failed to resolve enrolled user.');
        }
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        if ($error instanceof PDOException && (string) $error->getCode() === '23000') {
            json_out(['ok' => false, 'code' => 'CREDENTIALS_CONFLICT',
                'error' => 'Credentials could not be saved. Use another email or account recovery.'], 409);
        }
        throw $error;
    }

    // Enrollment is committed even if mail delivery fails; the public resend flow remains usable.
    $sent = false;
    try {
        $sent = send_email_verification_link_for_user($pdo, $fresh, true);
    } catch (Throwable $error) {
        error_log('Credential enrollment verification delivery failed.');
    }
    json_out(['ok' => true, 'email_verification_required' => true,
        'verification_email_sent' => $sent,
        'message' => $sent
            ? 'Verify your email before logging in.'
            : 'Credentials saved. Request a verification email from the login screen.']);
}

function enforce_credential_change_rate_limits(PDO $pdo, int $userId): void
{
    enforce_rate_limit($pdo, 'credential_change_ip', client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX, RATE_LIMIT_LOGIN_WINDOW_SEC);
    enforce_rate_limit($pdo, 'credential_change_user', (string) $userId,
        RATE_LIMIT_LOGIN_EMAIL_MAX, RATE_LIMIT_LOGIN_WINDOW_SEC);
}

function reject_credential_change(PDO $pdo, string $code, string $message, int $status): void
{
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    json_out(['ok' => false, 'code' => $code, 'error' => $message], $status);
}

function lock_credential_user(PDO $pdo, int $userId): array
{
    $stmt = $pdo->prepare('SELECT id, email, password_hash, credentials_required, '
        . users_account_status_select_sql($pdo) . 'nickname FROM ' . table_name('users')
        . ' WHERE id = :id FOR UPDATE');
    $stmt->execute(['id' => $userId]);
    $user = $stmt->fetch();
    if (!$user || user_account_status($user) !== 'active') {
        reject_credential_change($pdo, 'ACCOUNT_UNAVAILABLE', 'Account is unavailable.', 403);
    }
    if (resolve_user_id_from_access_token(bearer_access_token_from_header(), $pdo) !== $userId) {
        reject_credential_change($pdo, 'SESSION_REVOKED', 'Please sign in again.', 401);
    }
    return $user;
}

function change_profile_password(PDO $pdo, int $userId, array $body): void
{
    // Keep credential mutations separate from ordinary profile writes, including legacy clients.
    if (array_diff(array_keys($body), ['email', 'password', 'current_password']) !== []
        || !isset($body['email'], $body['password'])) {
        json_out(['ok' => false, 'error' => 'Submit password changes separately with email and current password.'], 400);
    }
    enforce_credential_change_rate_limits($pdo, $userId);
    $email = validate_email_address((string) $body['email']);
    $password = validate_password_plain((string) $body['password']);
    $currentPassword = (string) ($body['current_password'] ?? '');
    if ($currentPassword === '' || strlen($currentPassword) > 4096) {
        json_out(['ok' => false, 'code' => 'REAUTHENTICATION_REQUIRED',
            'error' => 'Enter your current password or use password recovery.'], 403);
    }
    ensure_refresh_tokens_table_available($pdo);
    try {
        $pdo->beginTransaction();
        $user = lock_credential_user($pdo, $userId);
        if ((int) $user['credentials_required'] !== 0 || empty($user['email_verified_at'])
            || strtolower(trim((string) $user['email'])) !== $email) {
            reject_credential_change($pdo, 'VERIFIED_EMAIL_REQUIRED',
                'Use the verified email change or credential enrollment flow.', 409);
        }
        if (!password_verify($currentPassword, (string) $user['password_hash'])) {
            reject_credential_change($pdo, 'REAUTHENTICATION_REQUIRED',
                'Current password is incorrect. Use password recovery if needed.', 403);
        }
        $hash = password_hash($password, credential_password_algo());
        if (!is_string($hash) || $hash === '') {
            throw new RuntimeException('Failed to hash password.');
        }
        $pdo->prepare('UPDATE ' . table_name('users') . ' SET password_hash = :hash WHERE id = :id')
            ->execute(['hash' => $hash, 'id' => $userId]);
        revoke_refresh_tokens_for_user($pdo, $userId);
        $auth = issue_auth_payload($pdo, $userId);
        $fresh = fetch_me_row_by_id($pdo, $userId);
        if (!$fresh) {
            throw new RuntimeException('Failed to resolve user after password change.');
        }
        $payload = build_me_payload($fresh, $pdo);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }
    json_out(['ok' => true, 'me' => $payload, 'auth' => $auth]);
}

function normalize_profile_optional_short_text($value, string $fieldLabel, int $maxLength): ?string
{
    $normalized = trim(preg_replace('/\s+/', ' ', (string) ($value ?? '')) ?? '');
    if ($normalized === '') {
        return null;
    }
    if (str_length($normalized) > $maxLength) {
        json_out(['ok' => false, 'error' => $fieldLabel . ' is too long.'], 400);
    }
    return $normalized;
}

function normalize_profile_bank_country_code($value): ?string
{
    $normalized = strtoupper(trim((string) ($value ?? '')));
    if ($normalized === '') {
        return null;
    }
    if (!preg_match('/^[A-Z]{2}$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'Bank country must be a 2-letter country code.'], 400);
    }
    return $normalized;
}

function normalize_profile_bank_iban($value): ?string
{
    $normalized = strtoupper(preg_replace('/\s+/', '', trim((string) ($value ?? ''))) ?? '');
    if ($normalized === '') {
        return null;
    }
    if (!preg_match('/^[A-Z]{2}[A-Z0-9]{13,32}$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'IBAN format is invalid.'], 400);
    }
    return $normalized;
}

function normalize_profile_bank_bic($value): ?string
{
    $normalized = strtoupper(preg_replace('/\s+/', '', trim((string) ($value ?? ''))) ?? '');
    if ($normalized === '') {
        return null;
    }
    if (!preg_match('/^[A-Z0-9]{8}([A-Z0-9]{3})?$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'BIC/SWIFT format is invalid.'], 400);
    }
    return $normalized;
}

function normalize_profile_bank_account_number($value): ?string
{
    $normalized = trim(preg_replace('/\s+/', ' ', (string) ($value ?? '')) ?? '');
    if ($normalized === '') {
        return null;
    }
    if (str_length($normalized) > 64 || !preg_match('/^[A-Za-z0-9 .\-\/]{3,64}$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'Bank account number format is invalid.'], 400);
    }
    return $normalized;
}

function normalize_profile_bank_sort_code($value): ?string
{
    $normalized = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', (string) ($value ?? '')) ?? '');
    if ($normalized === '') {
        return null;
    }
    if (!preg_match('/^[A-Z0-9]{3,16}$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'Sort/branch code format is invalid.'], 400);
    }
    return $normalized;
}

function normalize_profile_bank_routing_number($value): ?string
{
    $normalized = strtoupper(preg_replace('/[^A-Za-z0-9]/', '', (string) ($value ?? '')) ?? '');
    if ($normalized === '') {
        return null;
    }
    if (!preg_match('/^[A-Z0-9]{3,16}$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'Routing number format is invalid.'], 400);
    }
    return $normalized;
}

function normalize_profile_revolut_handle($value): ?string
{
    $normalized = trim((string) ($value ?? ''));
    if ($normalized === '') {
        return null;
    }
    if (!preg_match('/^@?[A-Za-z0-9._-]{2,80}$/', $normalized)) {
        json_out(['ok' => false, 'error' => 'Revolut handle format is invalid.'], 400);
    }
    return strpos($normalized, '@') === 0 ? $normalized : '@' . $normalized;
}

function normalize_profile_revolut_me_link($value): ?string
{
    $normalized = trim((string) ($value ?? ''));
    if ($normalized === '') {
        return null;
    }

    if (str_length($normalized) > 255) {
        json_out(['ok' => false, 'error' => 'Revolut.me value is too long.'], 400);
    }

    if (preg_match('/^https?:\/\/(www\.)?revolut\.me\/(@?[A-Za-z0-9._-]{2,80})\/?$/i', $normalized, $match)) {
        return 'https://revolut.me/' . ltrim($match[2], '@');
    }
    if (preg_match('/^(www\.)?revolut\.me\/(@?[A-Za-z0-9._-]{2,80})\/?$/i', $normalized, $match)) {
        return 'https://revolut.me/' . ltrim($match[2], '@');
    }
    if (preg_match('/^@?[A-Za-z0-9._-]{2,80}$/', $normalized)) {
        return 'https://revolut.me/' . ltrim($normalized, '@');
    }

    json_out(['ok' => false, 'error' => 'Revolut.me value is invalid.'], 400);
    return null;
}

function normalize_profile_paypal_me_link($value): ?string
{
    $normalized = trim((string) ($value ?? ''));
    if ($normalized === '') {
        return null;
    }

    if (str_length($normalized) > 255) {
        json_out(['ok' => false, 'error' => 'PayPal.me value is too long.'], 400);
    }

    if (preg_match('/^https?:\/\/(www\.)?paypal\.me\/([A-Za-z0-9._-]{2,50})\/?$/i', $normalized, $match)) {
        return 'https://paypal.me/' . $match[2];
    }
    if (preg_match('/^(www\.)?paypal\.me\/([A-Za-z0-9._-]{2,50})\/?$/i', $normalized, $match)) {
        return 'https://paypal.me/' . $match[2];
    }
    if (preg_match('/^[A-Za-z0-9._-]{2,50}$/', $normalized)) {
        return 'https://paypal.me/' . $normalized;
    }

    json_out(['ok' => false, 'error' => 'PayPal.me value is invalid.'], 400);
    return null;
}

function normalize_profile_wise_pay_link($value): ?string
{
    $normalized = trim((string) ($value ?? ''));
    if ($normalized === '') {
        return null;
    }

    if (str_length($normalized) > 255) {
        json_out(['ok' => false, 'error' => 'Wise value is too long.'], 400);
    }

    if (preg_match('/^https?:\/\/(www\.)?wise\.com\/\S+$/i', $normalized)) {
        return preg_replace('/^http:\/\//i', 'https://', $normalized);
    }
    if (preg_match('/^(www\.)?wise\.com\/\S+$/i', $normalized)) {
        return 'https://' . ltrim($normalized, '/');
    }
    if (preg_match('/^pay\/me\/([A-Za-z0-9._-]{2,80})\/?$/i', $normalized, $match)) {
        return 'https://wise.com/pay/me/' . $match[1];
    }
    if (preg_match('/^[A-Za-z0-9._-]{2,80}$/', $normalized)) {
        return 'https://wise.com/pay/me/' . $normalized;
    }

    json_out(['ok' => false, 'error' => 'Wise value is invalid.'], 400);
    return null;
}

function normalize_profile_preferred_currency_code($value): string
{
    $code = normalize_currency_code($value);
    if (!currency_supported_by_fx_provider($code)) {
        json_out([
            'ok' => false,
            'error' => 'Preferred currency is not supported for overview conversion yet.',
        ], 400);
    }
    return $code;
}

function update_profile_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();

    $pdo = db();
    $usersTable = table_name('users');
    $userId = (int) $me['id'];
    if (array_key_exists('email', $body) || array_key_exists('password', $body)
        || array_key_exists('current_password', $body)) {
        change_profile_password($pdo, $userId, $body);
        return;
    }
    $nameColumnsAvailable = users_name_columns_available($pdo);
    $paymentColumnsAvailable = users_payment_columns_available($pdo);
    $revolutMeLinkColumnAvailable = users_revolut_me_link_column_available($pdo);
    $wisePayLinkColumnAvailable = users_wise_pay_link_column_available($pdo);
    $preferredCurrencyColumnAvailable = users_preferred_currency_column_available($pdo);

    $updateParts = [];
    $params = [
        'id' => $userId,
    ];

    $hasFirstName = array_key_exists('first_name', $body);
    $hasLastName = array_key_exists('last_name', $body);
    if ($hasFirstName xor $hasLastName) {
        json_out([
            'ok' => false,
            'error' => 'First name and last name must be provided together.',
        ], 400);
    }
    if (($hasFirstName || $hasLastName) && !$nameColumnsAvailable) {
        json_out([
            'ok' => false,
            'error' => 'Profile name update is not available yet.',
        ], 503);
    }
    if ($hasFirstName && $hasLastName) {
        $firstName = validate_person_name((string) ($body['first_name'] ?? ''), 'First name');
        $lastName = validate_person_name((string) ($body['last_name'] ?? ''), 'Last name');
        $legacyNickname = derive_legacy_nickname_from_names($firstName, $lastName);
        $updateParts[] = 'first_name = :first_name';
        $updateParts[] = 'last_name = :last_name';
        $updateParts[] = 'nickname = :nickname';
        $params['first_name'] = $firstName;
        $params['last_name'] = $lastName;
        $params['nickname'] = $legacyNickname;
    }

    $paymentFieldNormalizers = [
        'bank_country_code' => 'normalize_profile_bank_country_code',
        'bank_account_holder' => static function ($value): ?string {
            return normalize_profile_optional_short_text($value, 'Bank account holder', 120);
        },
        'bank_account_number' => 'normalize_profile_bank_account_number',
        'bank_iban' => 'normalize_profile_bank_iban',
        'bank_bic' => 'normalize_profile_bank_bic',
        'bank_sort_code' => 'normalize_profile_bank_sort_code',
        'bank_routing_number' => 'normalize_profile_bank_routing_number',
        'revolut_handle' => 'normalize_profile_revolut_handle',
        'paypal_me_link' => 'normalize_profile_paypal_me_link',
    ];
    if ($revolutMeLinkColumnAvailable) {
        $paymentFieldNormalizers['revolut_me_link'] = 'normalize_profile_revolut_me_link';
    }
    if ($wisePayLinkColumnAvailable) {
        $paymentFieldNormalizers['wise_pay_link'] = 'normalize_profile_wise_pay_link';
    }

    $paymentFieldWasProvided = false;
    foreach ($paymentFieldNormalizers as $field => $_normalizer) {
        if (array_key_exists($field, $body)) {
            $paymentFieldWasProvided = true;
            break;
        }
    }

    if ($paymentFieldWasProvided && !$paymentColumnsAvailable) {
        json_out([
            'ok' => false,
            'error' => 'Profile payment details are not available yet. Please run latest migration.',
        ], 503);
    }
    if (array_key_exists('revolut_me_link', $body) && !$revolutMeLinkColumnAvailable) {
        json_out([
            'ok' => false,
            'error' => 'Revolut.me profile link is not available yet. Please run latest migration.',
        ], 503);
    }
    if (array_key_exists('wise_pay_link', $body) && !$wisePayLinkColumnAvailable) {
        json_out([
            'ok' => false,
            'error' => 'Wise profile link is not available yet. Please run latest migration.',
        ], 503);
    }

    if ($paymentColumnsAvailable) {
        foreach ($paymentFieldNormalizers as $field => $normalizer) {
            if (!array_key_exists($field, $body)) {
                continue;
            }
            $normalizedValue = is_callable($normalizer)
                ? $normalizer($body[$field] ?? null)
                : null;
            $updateParts[] = $field . ' = :' . $field;
            $params[$field] = $normalizedValue;
        }

        $hasIban = array_key_exists('bank_iban', $body);
        $hasCountryCode = array_key_exists('bank_country_code', $body);
        if ($hasIban && !$hasCountryCode) {
            $normalizedIban = normalize_profile_bank_iban($body['bank_iban'] ?? null);
            $autoCountryCode = $normalizedIban !== null ? substr($normalizedIban, 0, 2) : null;
            $updateParts[] = 'bank_country_code = :bank_country_code';
            $params['bank_country_code'] = $autoCountryCode;
        }
    }

    $hasPreferredCurrencyCode = array_key_exists('preferred_currency_code', $body);
    if ($hasPreferredCurrencyCode && !$preferredCurrencyColumnAvailable) {
        json_out([
            'ok' => false,
            'error' => 'Profile preferred currency is not available yet. Please run latest migration.',
        ], 503);
    }
    if ($hasPreferredCurrencyCode) {
        $updateParts[] = 'preferred_currency_code = :preferred_currency_code';
        $params['preferred_currency_code'] = normalize_profile_preferred_currency_code(
            $body['preferred_currency_code'] ?? null
        );
    }

    if (!$updateParts) {
        json_out(['ok' => false, 'error' => 'No profile changes provided.'], 400);
    }

    $update = $pdo->prepare(
        'UPDATE ' . $usersTable . '
         SET ' . implode(', ', $updateParts) . '
         WHERE id = :id'
    );
    $update->execute($params);

    $fresh = fetch_me_row_by_id($pdo, $userId);
    if (!$fresh) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }

    json_out(['ok' => true, 'me' => build_me_payload($fresh, $pdo)]);
}

function me_action(): void
{
    $me = get_me();
    $pdo = db();
    $row = fetch_me_row_by_id($pdo, (int) $me['id']);
    if (!$row) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }
    json_out(['ok' => true, 'me' => build_me_payload($row, $pdo)]);
}
