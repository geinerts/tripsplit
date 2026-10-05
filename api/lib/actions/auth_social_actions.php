<?php
declare(strict_types=1);

function social_auth_random_device_token(): string
{
    return bin2hex(random_bytes(32));
}

function social_auth_placeholder_password_hash(): string
{
    $randomSecret = bin2hex(random_bytes(24));
    $hash = password_hash($randomSecret, credential_password_algo());
    if (!is_string($hash) || trim($hash) === '') {
        throw new RuntimeException('Failed to generate social password placeholder.');
    }
    return $hash;
}

function social_auth_normalize_name_part(string $raw, string $fallback): string
{
    $value = trim(preg_replace('/\s+/', ' ', $raw) ?? '');
    $value = preg_replace('/[^\p{L}\p{M}\' -]+/u', '', $value) ?? '';
    $value = trim(preg_replace('/\s+/', ' ', $value) ?? '');
    if (str_length($value) > 64) {
        $value = trim(safe_substr_for_name($value, 64));
    }
    if (str_length($value) < 2) {
        return $fallback;
    }
    if (!preg_match('/^[\p{L}][\p{L}\p{M}\' -]*$/u', $value)) {
        return $fallback;
    }
    return $value;
}

function social_auth_profile_names(string $provider, string $fullName, ?string $email): array
{
    $normalizedFullName = trim(preg_replace('/\s+/', ' ', $fullName) ?? '');
    if ($normalizedFullName === '') {
        $emailPrefix = '';
        if (is_string($email) && trim($email) !== '' && str_contains($email, '@')) {
            $emailPrefix = trim((string) explode('@', $email, 2)[0]);
        }
        $normalizedFullName = $emailPrefix !== '' ? $emailPrefix : ucfirst($provider) . ' user';
    }

    $parts = explode(' ', $normalizedFullName);
    $firstRaw = trim((string) ($parts[0] ?? ''));
    $lastRaw = trim((string) implode(' ', array_slice($parts, 1)));
    if ($lastRaw === '') {
        $lastRaw = 'User';
    }

    $firstName = social_auth_normalize_name_part($firstRaw, 'Trip');
    $lastName = social_auth_normalize_name_part($lastRaw, 'User');
    return [
        'first_name' => $firstName,
        'last_name' => $lastName,
        'nickname' => derive_legacy_nickname_from_names($firstName, $lastName),
    ];
}

function social_auth_select_user_by_id_for_update(PDO $pdo, int $userId, bool $nameColumnsAvailable): ?array
{
    if ($userId <= 0) {
        return null;
    }
    $usersTable = table_name('users');
    $nameSelect = $nameColumnsAvailable
        ? 'first_name, last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . $accountSelect . 'nickname, email, password_hash, credentials_required, avatar_path
         FROM ' . $usersTable . '
         WHERE id = :id
         LIMIT 1
         FOR UPDATE'
    );
    $stmt->execute(['id' => $userId]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}

function social_auth_select_user_by_email_for_update(PDO $pdo, string $email, bool $nameColumnsAvailable): ?array
{
    $normalizedEmail = strtolower(trim($email));
    if ($normalizedEmail === '') {
        return null;
    }
    $usersTable = table_name('users');
    $nameSelect = $nameColumnsAvailable
        ? 'first_name, last_name, '
        : 'NULL AS first_name, NULL AS last_name, ';
    $accountSelect = users_account_status_select_sql($pdo);
    $stmt = $pdo->prepare(
        'SELECT id, ' . $nameSelect . $accountSelect . 'nickname, email, password_hash, credentials_required, avatar_path
         FROM ' . $usersTable . '
         WHERE email = :email
         LIMIT 1
         FOR UPDATE'
    );
    $stmt->execute(['email' => $normalizedEmail]);
    $row = $stmt->fetch();
    return is_array($row) ? $row : null;
}

function social_auth_action(): void
{
    require_post();
    $body = read_json();
    $provider = social_auth_provider_from_value((string) ($body['provider'] ?? ''));
    $idToken = trim((string) ($body['id_token'] ?? ''));
    if ($idToken === '') {
        json_out(['ok' => false, 'error' => 'Missing social id token.'], 400);
    }
    $fullNameInput = trim((string) ($body['full_name'] ?? ''));
    $deviceToken = token_from_header();

    $claims = verify_social_id_token($provider, $idToken);
    $providerSubject = trim((string) ($claims['subject'] ?? ''));
    $providerEmail = strtolower(trim((string) ($claims['email'] ?? '')));
    $providerEmailVerified = ($claims['email_verified'] ?? false) === true;
    $providerPayloadJson = (string) ($claims['payload_json'] ?? '{}');
    if ($providerSubject === '') {
        json_out(['ok' => false, 'error' => 'Invalid social token subject.'], 401);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'social_auth_ip',
        client_ip_address(),
        RATE_LIMIT_LOGIN_IP_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'social_auth_subject',
        $provider . '|' . $providerSubject,
        RATE_LIMIT_LOGIN_EMAIL_MAX,
        RATE_LIMIT_LOGIN_WINDOW_SEC
    );

    if (!social_auth_identity_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Social auth is not enabled on server yet. Run migration first.',
        ], 409);
    }

    $identitiesTable = table_name('user_identities');
    $usersTable = table_name('users');
    $nameColumnsAvailable = users_name_columns_available($pdo);
    $userId = 0;
    $user = null;

    $pdo->beginTransaction();
    try {
        $identityId = 0;
        $identityStmt = $pdo->prepare(
            'SELECT id, user_id, provider_subject
             FROM ' . $identitiesTable . '
             WHERE provider = :provider
               AND provider_subject = :provider_subject
             LIMIT 1'
        );
        $identityStmt->execute([
            'provider' => $provider,
            'provider_subject' => $providerSubject,
        ]);
        $identity = $identityStmt->fetch();
        $identityId = (int) ($identity['id'] ?? 0);

        if ($identity) {
            // Older schemas use a case-insensitive subject index. Never authenticate an
            // opaque provider subject that only compares equal under that collation.
            if (!hash_equals((string) $identity['provider_subject'], $providerSubject)) {
                $pdo->rollBack();
                json_out(['ok' => false, 'code' => 'SOCIAL_IDENTITY_CONFLICT',
                    'error' => 'Social identity does not match the linked account.'], 409);
            }
            $userId = (int) ($identity['user_id'] ?? 0);
            $user = social_auth_select_user_by_id_for_update($pdo, $userId, $nameColumnsAvailable);
            if (!$user) {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Linked user not found.'], 409);
            }
            $identityCheck = $pdo->prepare('SELECT id FROM ' . $identitiesTable
                . ' WHERE id = :id AND user_id = :user_id FOR UPDATE');
            $identityCheck->execute(['id' => $identityId, 'user_id' => $userId]);
            if (!$identityCheck->fetchColumn()) {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Linked identity is unavailable.'], 409);
            }
        } else {
            // Email is not a provider identity. Linking an existing account needs its own
            // authenticated, reauthorized flow, even when this provider verified the email.
            if ($providerEmail === '' || !$providerEmailVerified) {
                $pdo->rollBack();
                json_out(['ok' => false, 'code' => 'SOCIAL_VERIFIED_EMAIL_REQUIRED',
                    'error' => 'A verified provider email is required to create a new account.'], 409);
            }
            $emailOwner = social_auth_select_user_by_email_for_update($pdo, $providerEmail, $nameColumnsAvailable);
            if ($emailOwner) {
                $pdo->rollBack();
                json_out(['ok' => false, 'code' => 'SOCIAL_LINK_REQUIRED',
                    'error' => 'Sign in using your existing sign-in method. This provider is not linked to your account.'], 409);
            }

            if (!$user) {
                $names = social_auth_profile_names($provider, $fullNameInput, $providerEmail !== '' ? $providerEmail : null);
                $initialEmail = $providerEmail !== '' ? $providerEmail : null;
                $emailVerifiedAt = $providerEmail !== '' ? gmdate('Y-m-d H:i:s') : null;
                $passwordHash = social_auth_placeholder_password_hash();
                $bootstrapToken = social_auth_random_device_token();

                if ($nameColumnsAvailable) {
                    $insert = $pdo->prepare(
                        'INSERT INTO ' . $usersTable . '
                         (first_name, last_name, nickname, email, password_hash, credentials_required, email_verified_at, device_token)
                         VALUES (:first_name, :last_name, :nickname, :email, :password_hash, 0, :email_verified_at, :device_token)'
                    );
                    $insert->execute([
                        'first_name' => $names['first_name'],
                        'last_name' => $names['last_name'],
                        'nickname' => $names['nickname'],
                        'email' => $initialEmail,
                        'password_hash' => $passwordHash,
                        'email_verified_at' => $emailVerifiedAt,
                        'device_token' => $bootstrapToken,
                    ]);
                } else {
                    $insert = $pdo->prepare(
                        'INSERT INTO ' . $usersTable . '
                         (nickname, email, password_hash, credentials_required, email_verified_at, device_token)
                         VALUES (:nickname, :email, :password_hash, 0, :email_verified_at, :device_token)'
                    );
                    $insert->execute([
                        'nickname' => $names['nickname'],
                        'email' => $initialEmail,
                        'password_hash' => $passwordHash,
                        'email_verified_at' => $emailVerifiedAt,
                        'device_token' => $bootstrapToken,
                    ]);
                }

                $userId = (int) $pdo->lastInsertId();
                $user = social_auth_select_user_by_id_for_update($pdo, $userId, $nameColumnsAvailable);
                if (!$user) {
                    $pdo->rollBack();
                    json_out(['ok' => false, 'error' => 'Failed to resolve social user.'], 500);
                }
            }
        }

        if (!user_account_is_active((array) $user)) {
            $pdo->rollBack();
            revoke_refresh_tokens_for_user($pdo, (int) ($user['id'] ?? 0));
            json_out(user_account_block_error_payload((array) $user), 403);
        }
        if (user_requires_email_verification($user)) {
            $pdo->rollBack();
            json_out(user_email_verification_block_error_payload($user), 403);
        }

        $resolvedUserId = (int) ($user['id'] ?? 0);
        if ($resolvedUserId <= 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Failed to resolve social user id.'], 500);
        }

        // One device token must map to one user. Re-assign conflicting user token first.
        $conflictStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $usersTable . '
             WHERE device_token = :device_token
               AND id <> :id
             LIMIT 1
             FOR UPDATE'
        );
        $conflictStmt->execute([
            'device_token' => $deviceToken,
            'id' => $resolvedUserId,
        ]);
        $conflictId = (int) ($conflictStmt->fetchColumn() ?: 0);
        if ($conflictId > 0) {
            $pdo->prepare(
                'UPDATE ' . $usersTable . '
                 SET device_token = :new_token
                 WHERE id = :id'
            )->execute([
                'new_token' => social_auth_random_device_token(),
                'id' => $conflictId,
            ]);
        }

        $userUpdateParts = ['device_token = :device_token'];
        $userUpdateParams = [
            'id' => $resolvedUserId,
            'device_token' => $deviceToken,
        ];

        $currentHash = trim((string) ($user['password_hash'] ?? ''));
        if ($currentHash === '') {
            $userUpdateParts[] = 'password_hash = :password_hash';
            $userUpdateParams['password_hash'] = social_auth_placeholder_password_hash();
        }
        if (((int) ($user['credentials_required'] ?? 1)) === 1) {
            $userUpdateParts[] = 'credentials_required = 0';
        }

        // Returning users are identified only by the stored (provider, subject) pair.
        // Provider email changes/missing claims must not change the Splyto email or its verification.

        if ($nameColumnsAvailable) {
            $currentFirstName = trim((string) ($user['first_name'] ?? ''));
            $currentLastName = trim((string) ($user['last_name'] ?? ''));
            if ($currentFirstName === '' || $currentLastName === '') {
                $names = social_auth_profile_names(
                    $provider,
                    $fullNameInput,
                    $providerEmail !== '' ? $providerEmail : null
                );
                if ($currentFirstName === '') {
                    $userUpdateParts[] = 'first_name = :first_name';
                    $userUpdateParams['first_name'] = $names['first_name'];
                }
                if ($currentLastName === '') {
                    $userUpdateParts[] = 'last_name = :last_name';
                    $userUpdateParams['last_name'] = $names['last_name'];
                }
                $userUpdateParts[] = 'nickname = :nickname';
                $userUpdateParams['nickname'] = $names['nickname'];
            }
        }

        $pdo->prepare(
            'UPDATE ' . $usersTable . '
             SET ' . implode(', ', $userUpdateParts) . '
             WHERE id = :id'
        )->execute($userUpdateParams);

        if ($identityId > 0) {
            $identityUpdate = $pdo->prepare(
                'UPDATE ' . $identitiesTable . '
                 SET email = :email,
                     email_verified = :email_verified,
                     payload_json = :payload_json,
                     last_login_at = UTC_TIMESTAMP()
                 WHERE id = :id
                   AND user_id = :user_id'
            );
            $identityUpdate->execute([
                'id' => $identityId,
                'user_id' => $resolvedUserId,
                'email' => $providerEmail !== '' ? $providerEmail : null,
                'email_verified' => $providerEmailVerified ? 1 : 0,
                'payload_json' => $providerPayloadJson,
            ]);
        } else {
            try {
                $identityInsert = $pdo->prepare(
                    'INSERT INTO ' . $identitiesTable . '
                     (user_id, provider, provider_subject, email, email_verified, payload_json, last_login_at)
                     VALUES (:user_id, :provider, :provider_subject, :email, :email_verified, :payload_json, UTC_TIMESTAMP())'
                );
                $identityInsert->execute([
                    'user_id' => $resolvedUserId,
                    'provider' => $provider,
                    'provider_subject' => $providerSubject,
                    'email' => $providerEmail !== '' ? $providerEmail : null,
                    'email_verified' => $providerEmailVerified ? 1 : 0,
                    'payload_json' => $providerPayloadJson,
                ]);
            } catch (PDOException $identityError) {
                $pdo->rollBack();
                if ((string) $identityError->getCode() !== '23000') {
                    throw $identityError;
                }
                json_out([
                    'ok' => false,
                    'code' => 'SOCIAL_AUTH_RETRY',
                    'error' => 'Social identity is already linked to another account.',
                ], 409);
            }
        }

        $userId = $resolvedUserId;
        $auth = issue_auth_payload($pdo, $userId);
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        if ($error instanceof PDOException && in_array((string) $error->getCode(), ['23000', '40001'], true)) {
            json_out(['ok' => false, 'code' => 'SOCIAL_AUTH_RETRY',
                'error' => 'Another sign-in is being processed. Please try again.'], 409);
        }
        throw $error;
    }

    $me = fetch_me_row_by_id($pdo, $userId);
    if (!$me) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }

    json_out([
        'ok' => true,
        'me' => build_me_payload((array) $me, $pdo),
        'auth' => $auth,
    ]);
}
