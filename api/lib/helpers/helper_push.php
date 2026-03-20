<?php
declare(strict_types=1);

function push_notifications_enabled(): bool
{
    return (bool) PUSH_ENABLED && extension_loaded('curl');
}

function push_delivery_limit(): int
{
    $limit = (int) PUSH_QUEUE_BATCH_LIMIT;
    if ($limit < 1) {
        return 1;
    }
    if ($limit > 500) {
        return 500;
    }
    return $limit;
}

function push_timeout_seconds(): int
{
    $timeout = (int) PUSH_TIMEOUT_SEC;
    if ($timeout < 2) {
        return 2;
    }
    if ($timeout > 20) {
        return 20;
    }
    return $timeout;
}

function push_max_tokens_per_user(): int
{
    $limit = (int) PUSH_MAX_TOKENS_PER_USER;
    if ($limit < 1) {
        return 1;
    }
    if ($limit > 20) {
        return 20;
    }
    return $limit;
}

function push_tokens_table_available(PDO $pdo): bool
{
    return push_table_available($pdo, 'push_tokens');
}

function push_queue_table_available(PDO $pdo): bool
{
    return push_table_available($pdo, 'push_queue');
}

function push_table_available(PDO $pdo, string $tableKey): bool
{
    static $cache = [];
    if (array_key_exists($tableKey, $cache)) {
        return $cache[$tableKey];
    }

    try {
        $rawTable = trim(table_name($tableKey), '`');
        if ($rawTable === '' || !preg_match('/^[A-Za-z0-9_]+$/', $rawTable)) {
            $cache[$tableKey] = false;
            return false;
        }
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $rawTable]);
        $cache[$tableKey] = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cache[$tableKey] = false;
    }

    return $cache[$tableKey];
}

function normalize_push_platform(string $platform): string
{
    $value = strtolower(trim($platform));
    if ($value === 'ios' || $value === 'android' || $value === 'web') {
        return $value;
    }
    return '';
}

function normalize_push_provider(?string $provider, string $platform = ''): string
{
    $value = strtolower(trim((string) $provider));
    if ($value === 'apns' || $value === 'fcm') {
        return $value;
    }

    if ($platform === 'ios') {
        return 'apns';
    }
    if ($platform === 'android' || $platform === 'web') {
        return 'fcm';
    }

    return '';
}

function normalize_push_token_value(string $token): string
{
    $value = trim($token);
    if ($value === '') {
        return '';
    }
    if (strlen($value) < 20 || strlen($value) > 4096) {
        return '';
    }
    if (!preg_match('/^[\x21-\x7E]+$/', $value)) {
        return '';
    }
    return $value;
}

function normalize_push_device_uid(?string $raw): string
{
    $value = trim((string) $raw);
    if ($value === '') {
        return '';
    }
    if (strlen($value) > 128) {
        $value = substr($value, 0, 128);
    }
    if (!preg_match('/^[A-Za-z0-9._:-]+$/', $value)) {
        return '';
    }
    return $value;
}

function normalize_push_app_bundle(?string $raw): string
{
    $value = trim((string) $raw);
    if ($value === '') {
        return '';
    }
    if (strlen($value) > 191) {
        $value = substr($value, 0, 191);
    }
    if (!preg_match('/^[A-Za-z0-9._-]+$/', $value)) {
        return '';
    }
    return $value;
}

function register_user_push_token(
    PDO $pdo,
    int $userId,
    string $token,
    string $platform,
    string $provider,
    string $deviceUid = '',
    string $appBundle = ''
): void {
    if ($userId <= 0) {
        throw new RuntimeException('Invalid push token user.');
    }
    if (!push_tokens_table_available($pdo)) {
        throw new RuntimeException('Push token table is not available.');
    }

    $pushTokensTable = table_name('push_tokens');
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
    $stmt->execute([
        'user_id' => $userId,
        'provider' => $provider,
        'platform' => $platform,
        'push_token' => $token,
        'device_uid' => $deviceUid,
        'app_bundle' => $appBundle,
    ]);

    push_trim_user_tokens($pdo, $userId, $token);
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

function queue_push_notification(
    PDO $pdo,
    int $userId,
    int $tripId,
    string $type,
    string $title,
    string $body,
    array $payload = [],
    ?int $notificationId = null
): void {
    if ($userId <= 0 || !push_notifications_enabled()) {
        return;
    }
    if (!push_queue_table_available($pdo)) {
        return;
    }

    $pushQueueTable = table_name('push_queue');
    $payloadJson = null;
    if ($payload) {
        $encoded = json_encode($payload, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (is_string($encoded) && $encoded !== '') {
            $payloadJson = $encoded;
        }
    }

    $stmt = $pdo->prepare(
        'INSERT INTO ' . $pushQueueTable . '
         (notification_id, user_id, trip_id, type, title, body, payload_json, status, attempts, next_attempt_at)
         VALUES (:notification_id, :user_id, :trip_id, :type, :title, :body, :payload_json, "pending", 0, UTC_TIMESTAMP())'
    );
    $stmt->execute([
        'notification_id' => $notificationId,
        'user_id' => $userId,
        'trip_id' => $tripId > 0 ? $tripId : null,
        'type' => trim($type) !== '' ? trim($type) : 'info',
        'title' => trim($title) !== '' ? trim($title) : 'Notification',
        'body' => trim($body),
        'payload_json' => $payloadJson,
    ]);
}

function process_push_queue(PDO $pdo, array $options = []): array
{
    $limit = isset($options['limit']) && is_numeric($options['limit'])
        ? (int) $options['limit']
        : push_delivery_limit();
    if ($limit < 1) {
        $limit = 1;
    } elseif ($limit > 500) {
        $limit = 500;
    }

    $dryRun = !empty($options['dry_run']);
    $result = [
        'enabled' => push_notifications_enabled(),
        'queue_table_available' => push_queue_table_available($pdo),
        'tokens_table_available' => push_tokens_table_available($pdo),
        'dry_run' => $dryRun,
        'picked' => 0,
        'sent' => 0,
        'failed' => 0,
        'requeued' => 0,
        'skipped' => 0,
        'rows' => [],
    ];

    if (!$result['enabled'] || !$result['queue_table_available'] || !$result['tokens_table_available']) {
        return $result;
    }

    $pushQueueTable = table_name('push_queue');
    $rowsStmt = $pdo->query(
        'SELECT id, user_id, trip_id, type, title, body, payload_json, attempts
         FROM ' . $pushQueueTable . '
         WHERE status = "pending"
           AND (next_attempt_at IS NULL OR next_attempt_at <= UTC_TIMESTAMP())
         ORDER BY id ASC
         LIMIT ' . $limit
    );
    $rows = $rowsStmt->fetchAll();
    $result['picked'] = count($rows);

    foreach ($rows as $row) {
        $queueId = (int) ($row['id'] ?? 0);
        $userId = (int) ($row['user_id'] ?? 0);
        if ($queueId <= 0 || $userId <= 0) {
            $result['skipped']++;
            continue;
        }

        if ($dryRun) {
            $result['rows'][] = [
                'queue_id' => $queueId,
                'user_id' => $userId,
                'type' => (string) ($row['type'] ?? 'info'),
                'attempts' => (int) ($row['attempts'] ?? 0),
            ];
            continue;
        }

        $claimStmt = $pdo->prepare(
            'UPDATE ' . $pushQueueTable . '
             SET status = "processing",
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = :id
               AND status = "pending"'
        );
        $claimStmt->execute(['id' => $queueId]);
        if ((int) $claimStmt->rowCount() < 1) {
            $result['skipped']++;
            continue;
        }

        $payload = [];
        $rawPayload = trim((string) ($row['payload_json'] ?? ''));
        if ($rawPayload !== '') {
            $decoded = json_decode($rawPayload, true);
            if (is_array($decoded)) {
                $payload = $decoded;
            }
        }

        $sendResult = push_send_to_user_tokens(
            $pdo,
            $userId,
            [
                'trip_id' => (int) ($row['trip_id'] ?? 0),
                'type' => (string) ($row['type'] ?? 'info'),
                'title' => (string) ($row['title'] ?? ''),
                'body' => (string) ($row['body'] ?? ''),
                'payload' => $payload,
            ]
        );

        if ((int) ($sendResult['success_count'] ?? 0) > 0) {
            $sentStmt = $pdo->prepare(
                'UPDATE ' . $pushQueueTable . '
                 SET status = "sent",
                     sent_at = CURRENT_TIMESTAMP,
                     last_error = NULL,
                     updated_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $sentStmt->execute(['id' => $queueId]);
            $result['sent']++;
            continue;
        }

        $nextAttempt = ((int) ($row['attempts'] ?? 0)) + 1;
        $errorText = trim((string) ($sendResult['error'] ?? 'Push delivery failed.'));
        if ($errorText === '') {
            $errorText = 'Push delivery failed.';
        }
        if (strlen($errorText) > 1000) {
            $errorText = substr($errorText, 0, 1000);
        }

        $permanentFailure = !empty($sendResult['permanent_failure']) || $nextAttempt >= 3;
        if ($permanentFailure) {
            $failedStmt = $pdo->prepare(
                'UPDATE ' . $pushQueueTable . '
                 SET status = "failed",
                     attempts = :attempts,
                     last_error = :last_error,
                     next_attempt_at = NULL,
                     updated_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $failedStmt->execute([
                'attempts' => $nextAttempt,
                'last_error' => $errorText,
                'id' => $queueId,
            ]);
            $result['failed']++;
            continue;
        }

        $retryMinutes = push_retry_minutes_for_attempt($nextAttempt);
        $nextAttemptAt = gmdate('Y-m-d H:i:s', time() + ($retryMinutes * 60));
        $retryStmt = $pdo->prepare(
            'UPDATE ' . $pushQueueTable . '
             SET status = "pending",
                 attempts = :attempts,
                 last_error = :last_error,
                 next_attempt_at = :next_attempt_at,
                 updated_at = CURRENT_TIMESTAMP
             WHERE id = :id'
        );
        $retryStmt->execute([
            'attempts' => $nextAttempt,
            'last_error' => $errorText,
            'next_attempt_at' => $nextAttemptAt,
            'id' => $queueId,
        ]);
        $result['requeued']++;
    }

    return $result;
}

function push_retry_minutes_for_attempt(int $attempt): int
{
    if ($attempt <= 1) {
        return 5;
    }
    if ($attempt === 2) {
        return 15;
    }
    return 30;
}

function push_send_to_user_tokens(PDO $pdo, int $userId, array $notification): array
{
    $tokens = load_active_push_tokens($pdo, $userId);
    if (!$tokens) {
        return [
            'success_count' => 0,
            'permanent_failure' => true,
            'error' => 'No active push tokens for user.',
        ];
    }

    $successCount = 0;
    $temporaryErrors = [];
    $permanentErrors = [];

    foreach ($tokens as $tokenRow) {
        $provider = normalize_push_provider(
            (string) ($tokenRow['provider'] ?? ''),
            normalize_push_platform((string) ($tokenRow['platform'] ?? ''))
        );
        $sendResult = [];
        if ($provider === 'apns') {
            $sendResult = push_send_apns($tokenRow, $notification);
        } elseif ($provider === 'fcm') {
            $sendResult = push_send_fcm($tokenRow, $notification);
        } else {
            $sendResult = [
                'ok' => false,
                'permanent' => true,
                'error' => 'Unsupported push provider.',
            ];
        }

        if (!empty($sendResult['ok'])) {
            $successCount++;
            continue;
        }

        $error = trim((string) ($sendResult['error'] ?? 'Push send failed.'));
        if ($error === '') {
            $error = 'Push send failed.';
        }
        if (!empty($sendResult['permanent'])) {
            $permanentErrors[] = $error;
            $tokenId = (int) ($tokenRow['id'] ?? 0);
            if ($tokenId > 0) {
                deactivate_push_token_by_id($pdo, $tokenId);
            }
        } else {
            $temporaryErrors[] = $error;
        }
    }

    if ($successCount > 0) {
        return [
            'success_count' => $successCount,
            'permanent_failure' => false,
            'error' => '',
        ];
    }

    $allErrors = array_merge($temporaryErrors, $permanentErrors);
    return [
        'success_count' => 0,
        'permanent_failure' => !$temporaryErrors,
        'error' => implode('; ', array_slice($allErrors, 0, 3)),
    ];
}

function load_active_push_tokens(PDO $pdo, int $userId): array
{
    if ($userId <= 0 || !push_tokens_table_available($pdo)) {
        return [];
    }

    $limit = push_max_tokens_per_user();
    $pushTokensTable = table_name('push_tokens');
    $stmt = $pdo->prepare(
        'SELECT id, user_id, provider, platform, push_token, device_uid, app_bundle, last_seen_at
         FROM ' . $pushTokensTable . '
         WHERE user_id = :user_id
           AND is_active = 1
         ORDER BY last_seen_at DESC, id DESC
         LIMIT ' . $limit
    );
    $stmt->execute(['user_id' => $userId]);

    return $stmt->fetchAll();
}

function deactivate_push_token_by_id(PDO $pdo, int $tokenId): void
{
    if ($tokenId <= 0 || !push_tokens_table_available($pdo)) {
        return;
    }
    $pushTokensTable = table_name('push_tokens');
    $stmt = $pdo->prepare(
        'UPDATE ' . $pushTokensTable . '
         SET is_active = 0,
             updated_at = CURRENT_TIMESTAMP
         WHERE id = :id'
    );
    $stmt->execute(['id' => $tokenId]);
}

function push_send_apns(array $tokenRow, array $notification): array
{
    if (!push_apns_enabled()) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs is not configured.',
        ];
    }

    $token = trim((string) ($tokenRow['push_token'] ?? ''));
    if ($token === '') {
        return [
            'ok' => false,
            'permanent' => true,
            'error' => 'Empty APNs token.',
        ];
    }

    $jwt = push_apns_jwt();
    if ($jwt === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs JWT generation failed.',
        ];
    }

    $topic = trim((string) ($tokenRow['app_bundle'] ?? ''));
    if ($topic === '') {
        $topic = trim((string) PUSH_APNS_BUNDLE_ID);
    }
    if ($topic === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs topic is missing.',
        ];
    }

    $endpointBase = PUSH_APNS_USE_SANDBOX
        ? 'https://api.sandbox.push.apple.com'
        : 'https://api.push.apple.com';
    $endpoint = $endpointBase . '/3/device/' . $token;

    $dataPayload = [
        'trip_id' => (int) ($notification['trip_id'] ?? 0),
        'type' => (string) ($notification['type'] ?? 'info'),
    ];
    $rawPayload = $notification['payload'] ?? [];
    if (is_array($rawPayload) && $rawPayload) {
        $dataPayload['payload'] = $rawPayload;
    }
    $body = [
        'aps' => [
            'alert' => [
                'title' => trim((string) ($notification['title'] ?? 'Notification')),
                'body' => trim((string) ($notification['body'] ?? '')),
            ],
            'sound' => 'default',
        ],
        'data' => $dataPayload,
    ];

    $encodedBody = json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($encodedBody) || $encodedBody === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs payload encoding failed.',
        ];
    }

    $ch = curl_init($endpoint);
    if (!is_resource($ch) && !($ch instanceof CurlHandle)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs curl init failed.',
        ];
    }

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $encodedBody,
        CURLOPT_HTTP_VERSION => defined('CURL_HTTP_VERSION_2_0')
            ? CURL_HTTP_VERSION_2_0
            : CURL_HTTP_VERSION_1_1,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => push_timeout_seconds(),
        CURLOPT_CONNECTTIMEOUT => push_timeout_seconds(),
        CURLOPT_HTTPHEADER => [
            'content-type: application/json',
            'authorization: bearer ' . $jwt,
            'apns-topic: ' . $topic,
            'apns-push-type: alert',
            'apns-priority: 10',
        ],
    ]);

    $responseRaw = curl_exec($ch);
    $curlError = curl_error($ch);
    $statusCode = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);

    if ($responseRaw === false) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs curl error: ' . ($curlError !== '' ? $curlError : 'unknown'),
        ];
    }

    if ($statusCode === 200) {
        return [
            'ok' => true,
            'permanent' => false,
            'error' => '',
        ];
    }

    $reason = '';
    $decoded = json_decode((string) $responseRaw, true);
    if (is_array($decoded)) {
        $reason = trim((string) ($decoded['reason'] ?? ''));
    }
    if ($reason === '') {
        $reason = 'HTTP ' . $statusCode;
    }

    $permanentReasons = [
        'BadDeviceToken',
        'Unregistered',
        'DeviceTokenNotForTopic',
        'TopicDisallowed',
    ];
    $isPermanent = in_array($reason, $permanentReasons, true);

    return [
        'ok' => false,
        'permanent' => $isPermanent,
        'error' => 'APNs: ' . $reason,
    ];
}

function push_send_fcm(array $tokenRow, array $notification): array
{
    $serverKey = trim((string) PUSH_FCM_SERVER_KEY);
    if ($serverKey === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM server key is missing.',
        ];
    }

    $token = trim((string) ($tokenRow['push_token'] ?? ''));
    if ($token === '') {
        return [
            'ok' => false,
            'permanent' => true,
            'error' => 'Empty FCM token.',
        ];
    }

    $dataPayload = [
        'trip_id' => (string) ((int) ($notification['trip_id'] ?? 0)),
        'type' => trim((string) ($notification['type'] ?? 'info')),
    ];
    $rawPayload = $notification['payload'] ?? [];
    if (is_array($rawPayload) && $rawPayload) {
        foreach ($rawPayload as $key => $value) {
            if (!is_string($key) || $key === '') {
                continue;
            }
            if (is_scalar($value) || $value === null) {
                $dataPayload[$key] = (string) $value;
            } else {
                $encodedValue = json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
                if (is_string($encodedValue) && $encodedValue !== '') {
                    $dataPayload[$key] = $encodedValue;
                }
            }
        }
    }

    $requestBody = [
        'to' => $token,
        'priority' => 'high',
        'notification' => [
            'title' => trim((string) ($notification['title'] ?? 'Notification')),
            'body' => trim((string) ($notification['body'] ?? '')),
            'sound' => 'default',
        ],
        'data' => $dataPayload,
    ];
    $encodedBody = json_encode($requestBody, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($encodedBody) || $encodedBody === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM payload encoding failed.',
        ];
    }

    $ch = curl_init('https://fcm.googleapis.com/fcm/send');
    if (!is_resource($ch) && !($ch instanceof CurlHandle)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM curl init failed.',
        ];
    }

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $encodedBody,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => push_timeout_seconds(),
        CURLOPT_CONNECTTIMEOUT => push_timeout_seconds(),
        CURLOPT_HTTPHEADER => [
            'content-type: application/json',
            'authorization: key=' . $serverKey,
        ],
    ]);

    $responseRaw = curl_exec($ch);
    $curlError = curl_error($ch);
    $statusCode = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);

    if ($responseRaw === false) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM curl error: ' . ($curlError !== '' ? $curlError : 'unknown'),
        ];
    }

    if ($statusCode !== 200) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM HTTP ' . $statusCode,
        ];
    }

    $decoded = json_decode((string) $responseRaw, true);
    if (!is_array($decoded)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM invalid JSON response.',
        ];
    }

    $success = (int) ($decoded['success'] ?? 0);
    if ($success > 0) {
        return [
            'ok' => true,
            'permanent' => false,
            'error' => '',
        ];
    }

    $errorCode = '';
    if (isset($decoded['results'][0]) && is_array($decoded['results'][0])) {
        $errorCode = trim((string) ($decoded['results'][0]['error'] ?? ''));
    }
    if ($errorCode === '') {
        $errorCode = 'UnknownError';
    }
    $permanentCodes = ['NotRegistered', 'InvalidRegistration', 'MismatchSenderId'];

    return [
        'ok' => false,
        'permanent' => in_array($errorCode, $permanentCodes, true),
        'error' => 'FCM: ' . $errorCode,
    ];
}

function push_apns_enabled(): bool
{
    if (!push_notifications_enabled() || !PUSH_APNS_ENABLED) {
        return false;
    }
    if (trim((string) PUSH_APNS_TEAM_ID) === '' || trim((string) PUSH_APNS_KEY_ID) === '') {
        return false;
    }
    if (trim((string) PUSH_APNS_PRIVATE_KEY_REL_PATH) === '') {
        return false;
    }
    $privateKeyPath = push_apns_private_key_abs();
    return $privateKeyPath !== '' && is_file($privateKeyPath) && is_readable($privateKeyPath);
}

function push_apns_private_key_abs(): string
{
    $relative = trim(str_replace('\\', '/', (string) PUSH_APNS_PRIVATE_KEY_REL_PATH));
    $relative = ltrim($relative, '/');
    if ($relative === '' || strpos($relative, '..') !== false) {
        return '';
    }

    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
}

function push_apns_jwt(): string
{
    static $cache = [
        'token' => '',
        'issued_at' => 0,
    ];

    $now = time();
    if (is_string($cache['token']) && $cache['token'] !== '' && ($now - (int) $cache['issued_at']) < 3000) {
        return $cache['token'];
    }

    $privateKeyPath = push_apns_private_key_abs();
    if ($privateKeyPath === '' || !is_file($privateKeyPath) || !is_readable($privateKeyPath)) {
        return '';
    }
    $privateKey = file_get_contents($privateKeyPath);
    if (!is_string($privateKey) || trim($privateKey) === '') {
        return '';
    }

    $header = push_base64url_encode(json_encode([
        'alg' => 'ES256',
        'kid' => trim((string) PUSH_APNS_KEY_ID),
    ], JSON_UNESCAPED_SLASHES));
    $claims = push_base64url_encode(json_encode([
        'iss' => trim((string) PUSH_APNS_TEAM_ID),
        'iat' => $now,
    ], JSON_UNESCAPED_SLASHES));
    if ($header === '' || $claims === '') {
        return '';
    }
    $unsigned = $header . '.' . $claims;

    $keyResource = openssl_pkey_get_private($privateKey);
    if ($keyResource === false) {
        return '';
    }

    $signature = '';
    $signed = openssl_sign($unsigned, $signature, $keyResource, 'sha256');
    if (is_resource($keyResource) || $keyResource instanceof OpenSSLAsymmetricKey) {
        openssl_free_key($keyResource);
    }
    if (!$signed || !is_string($signature) || $signature === '') {
        return '';
    }

    $jwt = $unsigned . '.' . push_base64url_encode($signature);
    $cache['token'] = $jwt;
    $cache['issued_at'] = $now;

    return $jwt;
}

function push_base64url_encode($raw): string
{
    if (!is_string($raw) || $raw === '') {
        return '';
    }
    return rtrim(strtr(base64_encode($raw), '+/', '-_'), '=');
}
