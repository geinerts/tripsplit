<?php
declare(strict_types=1);

function register_user_push_token(
    PDO $pdo,
    int $userId,
    string $token,
    string $platform,
    string $provider,
    string $deviceUid = '',
    string $appBundle = '',
    string $localeCode = 'en'
): void {
    if ($userId <= 0) {
        throw new RuntimeException('Invalid push token user.');
    }
    if (!push_tokens_table_available($pdo)) {
        throw new RuntimeException('Push token table is not available.');
    }

    $pushTokensTable = table_name('push_tokens');
    $params = [
        'user_id' => $userId,
        'provider' => $provider,
        'platform' => $platform,
        'push_token' => $token,
        'device_uid' => $deviceUid,
        'app_bundle' => $appBundle,
    ];
    $locale = normalize_push_locale_code($localeCode);

    if (push_tokens_locale_column_available($pdo)) {
        $stmt = $pdo->prepare(
            'INSERT INTO ' . $pushTokensTable . '
             (user_id, provider, platform, push_token, device_uid, app_bundle, locale, is_active, last_seen_at)
             VALUES (:user_id, :provider, :platform, :push_token, :device_uid, :app_bundle, :locale, 1, CURRENT_TIMESTAMP)
             ON DUPLICATE KEY UPDATE
                user_id = VALUES(user_id),
                provider = VALUES(provider),
                platform = VALUES(platform),
                device_uid = CASE WHEN VALUES(device_uid) <> "" THEN VALUES(device_uid) ELSE device_uid END,
                app_bundle = CASE WHEN VALUES(app_bundle) <> "" THEN VALUES(app_bundle) ELSE app_bundle END,
                locale = VALUES(locale),
                is_active = 1,
                last_seen_at = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP'
        );
        $params['locale'] = $locale;
        $stmt->execute($params);
    } else {
        $stmt = $pdo->prepare(
            'INSERT INTO ' . $pushTokensTable . '
             (user_id, provider, platform, push_token, device_uid, app_bundle, is_active, last_seen_at)
             VALUES (:user_id, :provider, :platform, :push_token, :device_uid, :app_bundle, 1, CURRENT_TIMESTAMP)
             ON DUPLICATE KEY UPDATE
                user_id = VALUES(user_id),
                provider = VALUES(provider),
                platform = VALUES(platform),
                device_uid = CASE WHEN VALUES(device_uid) <> "" THEN VALUES(device_uid) ELSE device_uid END,
                app_bundle = CASE WHEN VALUES(app_bundle) <> "" THEN VALUES(app_bundle) ELSE app_bundle END,
                is_active = 1,
                last_seen_at = CURRENT_TIMESTAMP,
                updated_at = CURRENT_TIMESTAMP'
        );
        $stmt->execute($params);
    }

    push_deactivate_superseded_device_tokens($pdo, $userId, $token, $platform, $deviceUid);
    push_trim_user_tokens($pdo, $userId, $token);
}

function push_deactivate_superseded_device_tokens(
    PDO $pdo,
    int $userId,
    string $keepToken,
    string $platform,
    string $deviceUid = ''
): void {
    if ($userId <= 0 || $keepToken === '' || !push_tokens_table_available($pdo)) {
        return;
    }

    $platform = normalize_push_platform($platform);
    if ($platform === '') {
        return;
    }

    $deviceUid = trim($deviceUid);
    if ($deviceUid === '') {
        return;
    }

    $where = [
        'user_id = :user_id',
        'platform = :platform',
        'push_token <> :keep_token',
        'is_active = 1',
    ];
    $params = [
        'user_id' => $userId,
        'platform' => $platform,
        'keep_token' => $keepToken,
        'device_uid' => $deviceUid,
    ];
    $where[] = 'device_uid = :device_uid';

    $stmt = $pdo->prepare(
        'UPDATE ' . table_name('push_tokens') . '
         SET is_active = 0,
             updated_at = CURRENT_TIMESTAMP
         WHERE ' . implode(' AND ', $where)
    );
    $stmt->execute($params);
}

function unregister_user_push_token(PDO $pdo, int $userId, string $token): int
{
    if ($userId <= 0 || $token === '' || !push_tokens_table_available($pdo)) {
        return 0;
    }

    $pushTokensTable = table_name('push_tokens');
    $stmt = $pdo->prepare(
        'UPDATE ' . $pushTokensTable . '
         SET is_active = 0,
             updated_at = CURRENT_TIMESTAMP
         WHERE user_id = :user_id
           AND push_token = :push_token
           AND is_active = 1'
    );
    $stmt->execute([
        'user_id' => $userId,
        'push_token' => $token,
    ]);

    return (int) $stmt->rowCount();
}

function push_trim_user_tokens(PDO $pdo, int $userId, string $keepToken = ''): void
{
    if ($userId <= 0 || !push_tokens_table_available($pdo)) {
        return;
    }

    $limit = push_max_tokens_per_user();
    if ($limit < 1) {
        return;
    }

    $pushTokensTable = table_name('push_tokens');
    $idsStmt = $pdo->prepare(
        'SELECT id
         FROM ' . $pushTokensTable . '
         WHERE user_id = :user_id
           AND is_active = 1
         ORDER BY last_seen_at DESC, id DESC'
    );
    $idsStmt->execute(['user_id' => $userId]);
    $rows = $idsStmt->fetchAll();
    if (count($rows) <= $limit) {
        return;
    }

    $keepSet = [];
    if ($keepToken !== '') {
        $tokenStmt = $pdo->prepare(
            'SELECT id
             FROM ' . $pushTokensTable . '
             WHERE user_id = :user_id
               AND push_token = :push_token
             LIMIT 1'
        );
        $tokenStmt->execute([
            'user_id' => $userId,
            'push_token' => $keepToken,
        ]);
        $keepId = (int) ($tokenStmt->fetchColumn() ?: 0);
        if ($keepId > 0) {
            $keepSet[$keepId] = true;
        }
    }

    $activeIds = [];
    foreach ($rows as $row) {
        $tokenId = (int) ($row['id'] ?? 0);
        if ($tokenId > 0) {
            $activeIds[] = $tokenId;
        }
    }
    if (!$activeIds) {
        return;
    }

    $kept = count($keepSet);
    $toDeactivate = [];
    foreach ($activeIds as $tokenId) {
        if (isset($keepSet[$tokenId])) {
            continue;
        }
        if ($kept < $limit) {
            $kept++;
            continue;
        }
        $toDeactivate[] = $tokenId;
    }

    if (!$toDeactivate) {
        return;
    }

    $placeholders = implode(',', array_fill(0, count($toDeactivate), '?'));
    $params = $toDeactivate;
    $sql = 'UPDATE ' . $pushTokensTable . '
            SET is_active = 0,
                updated_at = CURRENT_TIMESTAMP
            WHERE id IN (' . $placeholders . ')';
    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
}
