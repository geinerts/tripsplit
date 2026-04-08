<?php
declare(strict_types=1);

function register_proof_secret(): string
{
    $configured = trim((string) REGISTER_PROOF_SECRET);
    if ($configured !== '') {
        return $configured;
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

    if ($hasCredentials) {
        $email = validate_email_address($emailRaw);
        $password = validate_password_plain($passwordRaw);
        $passwordHash = password_hash($password, credential_password_algo());
        if (!is_string($passwordHash) || $passwordHash === '') {
            json_out(['ok' => false, 'error' => 'Failed to hash password.'], 500);
        }

        $existsStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $usersTable . '
             WHERE email = :email AND device_token <> :device_token
             LIMIT 1'
        );
        $existsStmt->execute([
            'email' => $email,
            'device_token' => $deviceToken,
        ]);
        if ($existsStmt->fetch()) {
            json_out(['ok' => false, 'error' => 'Email is already used by another account.'], 409);
        }

        if ($hasNameColumns) {
            $stmt = $pdo->prepare(
                'INSERT INTO ' . $usersTable . ' (first_name, last_name, nickname, email, password_hash, credentials_required, email_verified_at, device_token)
                 VALUES (:first_name, :last_name, :nickname, :email, :password_hash, 0, NULL, :device_token)
                 ON DUPLICATE KEY UPDATE
                     first_name = VALUES(first_name),
                     last_name = VALUES(last_name),
                     nickname = VALUES(nickname),
                     email = VALUES(email),
                     password_hash = VALUES(password_hash),
                     credentials_required = 0,
                     email_verified_at = CASE
                         WHEN email <=> VALUES(email) THEN email_verified_at
                         ELSE NULL
                     END'
            );
            $stmt->execute([
                'first_name' => $firstName,
                'last_name' => $lastName,
                'nickname' => $legacyNickname,
                'email' => $email,
                'password_hash' => $passwordHash,
                'device_token' => $deviceToken,
            ]);
        } else {
            $stmt = $pdo->prepare(
                'INSERT INTO ' . $usersTable . ' (nickname, email, password_hash, credentials_required, email_verified_at, device_token)
                 VALUES (:nickname, :email, :password_hash, 0, NULL, :device_token)
                 ON DUPLICATE KEY UPDATE
                     nickname = VALUES(nickname),
                     email = VALUES(email),
                     password_hash = VALUES(password_hash),
                     credentials_required = 0,
                     email_verified_at = CASE
                         WHEN email <=> VALUES(email) THEN email_verified_at
                         ELSE NULL
                     END'
            );
            $stmt->execute([
                'nickname' => $legacyNickname,
                'email' => $email,
                'password_hash' => $passwordHash,
                'device_token' => $deviceToken,
            ]);
        }
    } else {
        if ($hasNameColumns) {
            $stmt = $pdo->prepare(
                'INSERT INTO ' . $usersTable . ' (first_name, last_name, nickname, device_token)
                 VALUES (:first_name, :last_name, :nickname, :device_token)
                 ON DUPLICATE KEY UPDATE
                     first_name = VALUES(first_name),
                     last_name = VALUES(last_name),
                     nickname = VALUES(nickname)'
            );
            $stmt->execute([
                'first_name' => $firstName,
                'last_name' => $lastName,
                'nickname' => $legacyNickname,
                'device_token' => $deviceToken,
            ]);
        } else {
            $stmt = $pdo->prepare(
                'INSERT INTO ' . $usersTable . ' (nickname, device_token)
                 VALUES (:nickname, :device_token)
                 ON DUPLICATE KEY UPDATE nickname = VALUES(nickname)'
            );
            $stmt->execute([
                'nickname' => $legacyNickname,
                'device_token' => $deviceToken,
            ]);
        }
    }

    $me = fetch_me_row_by_token($pdo, $deviceToken);
    if (!$me) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }
    assert_user_account_is_active($me);
    if ($hasCredentials && user_requires_email_verification((array) $me)) {
        send_email_verification_link_for_user($pdo, (array) $me);
        json_out([
            'ok' => true,
            'code' => 'EMAIL_VERIFICATION_REQUIRED',
            'email_verification_required' => true,
            'verification_email' => strtolower(trim((string) ($me['email'] ?? ''))),
            'message' => 'Verification email sent. Please verify your email before logging in.',
        ]);
    }

    json_out([
        'ok' => true,
        'me' => build_me_payload($me),
        'auth' => issue_auth_payload($pdo, (int) ($me['id'] ?? 0)),
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

    json_out([
        'ok' => true,
        'me' => build_me_payload($me),
        'auth' => issue_auth_payload($pdo, (int) ($me['id'] ?? 0)),
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
        'me' => build_me_payload($me),
        'auth' => (array) ($rotated['auth'] ?? []),
    ]);
}

function set_credentials_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $email = validate_email_address((string) ($body['email'] ?? ''));
    $password = validate_password_plain((string) ($body['password'] ?? ''));
    $passwordHash = password_hash($password, credential_password_algo());
    if (!is_string($passwordHash) || $passwordHash === '') {
        json_out(['ok' => false, 'error' => 'Failed to hash password.'], 500);
    }

    $pdo = db();
    $usersTable = table_name('users');

    $existsStmt = $pdo->prepare(
        'SELECT id
         FROM ' . $usersTable . '
         WHERE email = :email AND id <> :id
         LIMIT 1'
    );
    $existsStmt->execute([
        'email' => $email,
        'id' => (int) $me['id'],
    ]);
    if ($existsStmt->fetch()) {
        json_out(['ok' => false, 'error' => 'Email is already used by another account.'], 409);
    }

    $update = $pdo->prepare(
        'UPDATE ' . $usersTable . '
         SET email = :email,
             password_hash = :password_hash,
             credentials_required = 0,
             email_verified_at = COALESCE(email_verified_at, CURRENT_TIMESTAMP)
         WHERE id = :id'
    );
    $update->execute([
        'email' => $email,
        'password_hash' => $passwordHash,
        'id' => (int) $me['id'],
    ]);

    $fresh = fetch_me_row_by_id($pdo, (int) $me['id']);
    if (!$fresh) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }

    json_out(['ok' => true, 'me' => build_me_payload($fresh)]);
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

function update_profile_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();

    $pdo = db();
    $usersTable = table_name('users');
    $userId = (int) $me['id'];
    $nameColumnsAvailable = users_name_columns_available($pdo);
    $paymentColumnsAvailable = users_payment_columns_available($pdo);

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

    $hasEmail = array_key_exists('email', $body);
    $hasPassword = array_key_exists('password', $body);
    if ($hasEmail xor $hasPassword) {
        json_out([
            'ok' => false,
            'error' => 'Email and password must be provided together.',
        ], 400);
    }

    if ($hasEmail && $hasPassword) {
        $email = validate_email_address((string) ($body['email'] ?? ''));
        $password = validate_password_plain((string) ($body['password'] ?? ''));
        $passwordHash = password_hash($password, credential_password_algo());
        if (!is_string($passwordHash) || $passwordHash === '') {
            json_out(['ok' => false, 'error' => 'Failed to hash password.'], 500);
        }
        $currentEmail = strtolower(trim((string) ($me['email'] ?? '')));
        if ($currentEmail === '') {
            json_out([
                'ok' => false,
                'error' => 'Add email first before updating password.',
            ], 409);
        }
        if ($email !== $currentEmail) {
            json_out([
                'ok' => false,
                'error' => 'Email change now requires verification. Use request_email_change endpoint.',
            ], 409);
        }

        $updateParts[] = 'password_hash = :password_hash';
        $updateParts[] = 'credentials_required = 0';
        $updateParts[] = 'email_verified_at = COALESCE(email_verified_at, CURRENT_TIMESTAMP)';
        $params['password_hash'] = $passwordHash;
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

    json_out(['ok' => true, 'me' => build_me_payload($fresh)]);
}

function me_action(): void
{
    $me = get_me();
    $pdo = db();
    $row = fetch_me_row_by_id($pdo, (int) $me['id']);
    if (!$row) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }
    json_out(['ok' => true, 'me' => build_me_payload($row)]);
}
