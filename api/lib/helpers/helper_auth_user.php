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

function users_payment_columns_available(PDO $pdo): bool
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
               AND column_name IN (
                 \'bank_country_code\',
                 \'bank_account_holder\',
                 \'bank_account_number\',
                 \'bank_iban\',
                 \'bank_bic\',
                 \'bank_sort_code\',
                 \'bank_routing_number\',
                 \'revolut_handle\',
                 \'paypal_me_link\'
               )'
        );
        $stmt->execute(['table_name' => $usersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 9;
    } catch (Throwable $error) {
        $cached = false;
    }

    return $cached;
}

function users_preferred_currency_column_available(PDO $pdo): bool
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
               AND column_name = \'preferred_currency_code\''
        );
        $stmt->execute(['table_name' => $usersTable]);
        $cached = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
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

function normalize_me_profile_text_value($value): ?string
{
    $trimmed = trim((string) ($value ?? ''));
    return $trimmed !== '' ? $trimmed : null;
}

function normalize_me_country_code($value): ?string
{
    $trimmed = strtoupper(trim((string) ($value ?? '')));
    if ($trimmed === '') {
        return null;
    }
    return preg_match('/^[A-Z]{2}$/', $trimmed) ? $trimmed : null;
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
    $accountStatus = user_account_status($user);
    $emailVerified = user_email_is_verified($user);
    $emailVerificationRequired = user_has_email_credentials($user) && !$emailVerified;
    $bankCountryCode = normalize_me_country_code($user['bank_country_code'] ?? null);
    $bankAccountHolder = normalize_me_profile_text_value($user['bank_account_holder'] ?? null);
    if ($bankAccountHolder === null) {
        $bankAccountHolder = combine_full_name($firstName, $lastName);
    }
    $bankAccountNumber = normalize_me_profile_text_value($user['bank_account_number'] ?? null);
    $bankIban = normalize_me_profile_text_value($user['bank_iban'] ?? null);
    $bankBic = normalize_me_profile_text_value($user['bank_bic'] ?? null);
    $bankSortCode = normalize_me_profile_text_value($user['bank_sort_code'] ?? null);
    $bankRoutingNumber = normalize_me_profile_text_value($user['bank_routing_number'] ?? null);
    $revolutHandle = normalize_me_profile_text_value($user['revolut_handle'] ?? null);
    $paypalMeLink = normalize_me_profile_text_value($user['paypal_me_link'] ?? null);
    $preferredCurrencyCode = normalize_currency_code_or_default(
        $user['preferred_currency_code'] ?? null
    );

    return [
        'id' => (int) $user['id'],
        'first_name' => $firstName,
        'last_name' => $lastName,
        'full_name' => combine_full_name($firstName, $lastName),
        'display_name' => me_display_name($user),
        // Backward-compatible field: now mirrors display_name.
        'nickname' => me_display_name($user),
        'email' => $email !== '' ? $email : null,
        'email_verified' => $emailVerified,
        'email_verification_required' => $emailVerificationRequired,
        'needs_credentials' => $needsCredentials,
        'account_status' => $accountStatus,
        'deactivated_at' => $accountStatus === 'active'
            ? null
            : (($user['deactivated_at'] ?? null) ?: null),
        'deleted_at' => $accountStatus === 'deleted'
            ? (($user['deleted_at'] ?? null) ?: null)
            : null,
        'bank_country_code' => $bankCountryCode,
        'bank_account_holder' => $bankAccountHolder,
        'bank_account_number' => $bankAccountNumber,
        'bank_iban' => $bankIban,
        'bank_bic' => $bankBic,
        'bank_sort_code' => $bankSortCode,
        'bank_routing_number' => $bankRoutingNumber,
        'revolut_handle' => $revolutHandle,
        'paypal_me_link' => $paypalMeLink,
        'preferred_currency_code' => $preferredCurrencyCode,
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
    $paymentSelect = users_payment_columns_available($pdo)
        ? 'bank_country_code, bank_account_holder, bank_account_number, bank_iban, bank_bic, bank_sort_code, bank_routing_number, revolut_handle, paypal_me_link, '
        : 'NULL AS bank_country_code, NULL AS bank_account_holder, NULL AS bank_account_number, NULL AS bank_iban, NULL AS bank_bic, NULL AS bank_sort_code, NULL AS bank_routing_number, NULL AS revolut_handle, NULL AS paypal_me_link, ';
    $preferredCurrencySelect = users_preferred_currency_column_available($pdo)
        ? 'preferred_currency_code, '
        : '\'' . default_trip_currency_code() . '\' AS preferred_currency_code, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . $accountSelect . 'nickname, email, password_hash, credentials_required, ' . $paymentSelect . $preferredCurrencySelect . 'avatar_path
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
    $paymentSelect = users_payment_columns_available($pdo)
        ? 'bank_country_code, bank_account_holder, bank_account_number, bank_iban, bank_bic, bank_sort_code, bank_routing_number, revolut_handle, paypal_me_link, '
        : 'NULL AS bank_country_code, NULL AS bank_account_holder, NULL AS bank_account_number, NULL AS bank_iban, NULL AS bank_bic, NULL AS bank_sort_code, NULL AS bank_routing_number, NULL AS revolut_handle, NULL AS paypal_me_link, ';
    $preferredCurrencySelect = users_preferred_currency_column_available($pdo)
        ? 'preferred_currency_code, '
        : '\'' . default_trip_currency_code() . '\' AS preferred_currency_code, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . $accountSelect . 'nickname, email, password_hash, credentials_required, ' . $paymentSelect . $preferredCurrencySelect . 'avatar_path
         FROM ' . $usersTable . '
         WHERE id = :id
         LIMIT 1'
    );
    $stmt->execute(['id' => $userId]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}
