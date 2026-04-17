<?php
declare(strict_types=1);

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
        $tokenLocale = normalize_push_locale_code((string) ($tokenRow['locale'] ?? ''));
        $localized = push_localize_notification_for_locale($notification, $tokenLocale);
        $localizedNotification = $notification;
        $localizedNotification['title'] = (string) ($localized['title'] ?? ($notification['title'] ?? ''));
        $localizedNotification['body'] = (string) ($localized['body'] ?? ($notification['body'] ?? ''));

        $provider = normalize_push_provider(
            (string) ($tokenRow['provider'] ?? ''),
            normalize_push_platform((string) ($tokenRow['platform'] ?? ''))
        );
        $sendResult = [];
        if ($provider === 'apns') {
            $sendResult = push_send_apns($tokenRow, $localizedNotification);
        } elseif ($provider === 'fcm') {
            $sendResult = push_send_fcm($tokenRow, $localizedNotification);
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
    $localeSelect = push_tokens_locale_column_available($pdo)
        ? 'locale'
        : '\'en\' AS locale';
    $stmt = $pdo->prepare(
        'SELECT id, user_id, provider, platform, push_token, device_uid, app_bundle, ' . $localeSelect . ', last_seen_at
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
