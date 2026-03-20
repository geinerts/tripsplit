<?php
declare(strict_types=1);

function settlement_reminders_enabled(): bool
{
    return (bool) SETTLEMENT_REMINDER_ENABLED;
}

function settlement_reminder_interval_minutes(): int
{
    $minutes = (int) SETTLEMENT_REMINDER_INTERVAL_MIN;
    if ($minutes < 5) {
        return 5;
    }
    if ($minutes > 10_080) {
        return 10_080;
    }
    return $minutes;
}

function settlement_reminder_min_age_minutes(): int
{
    $minutes = (int) SETTLEMENT_REMINDER_MIN_AGE_MIN;
    if ($minutes < 5) {
        return 5;
    }
    if ($minutes > 10_080) {
        return 10_080;
    }
    return $minutes;
}

function settlement_reminder_limit_default(): int
{
    $limit = (int) SETTLEMENT_REMINDER_BATCH_LIMIT;
    if ($limit < 1) {
        return 1;
    }
    if ($limit > 500) {
        return 500;
    }
    return $limit;
}

function settlement_reminder_state_table_available(PDO $pdo): bool
{
    static $cache = null;
    if (is_bool($cache)) {
        return $cache;
    }

    try {
        $rawTable = trim(table_name('settlement_reminder_state'), '`');
        if ($rawTable === '' || !preg_match('/^[A-Za-z0-9_]+$/', $rawTable)) {
            $cache = false;
            return $cache;
        }
        $stmt = $pdo->prepare(
            'SELECT COUNT(1)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => $rawTable]);
        $cache = ((int) ($stmt->fetchColumn() ?: 0)) >= 1;
    } catch (Throwable $error) {
        $cache = false;
    }

    return $cache;
}

function settlement_status_for_reminder(string $status): string
{
    $raw = strtolower(trim($status));
    if ($raw !== 'pending' && $raw !== 'sent' && $raw !== 'confirmed') {
        return '';
    }
    $normalized = $raw;
    if ($normalized === 'pending' || $normalized === 'sent') {
        return $normalized;
    }
    return '';
}

function settlement_reminder_base_time(array $row): int
{
    $status = settlement_status_for_reminder((string) ($row['status'] ?? ''));
    $baseRaw = '';
    if ($status === 'sent') {
        $baseRaw = (string) (
            $row['marked_sent_at'] ??
            $row['updated_at'] ??
            $row['created_at'] ??
            ''
        );
    } else {
        $baseRaw = (string) (
            $row['updated_at'] ??
            $row['created_at'] ??
            ''
        );
    }

    return parse_utc_datetime_to_ts($baseRaw);
}

function settlement_reminder_last_time(array $row): int
{
    $raw = (string) ($row['last_reminded_at'] ?? '');
    return parse_utc_datetime_to_ts($raw);
}

function parse_utc_datetime_to_ts(string $raw): int
{
    $trimmed = trim($raw);
    if ($trimmed === '') {
        return 0;
    }

    $utcTs = strtotime($trimmed . ' UTC');
    if (is_int($utcTs) && $utcTs > 0) {
        return $utcTs;
    }
    $fallback = strtotime($trimmed);
    if (is_int($fallback) && $fallback > 0) {
        return $fallback;
    }
    return 0;
}

function settlement_reminder_is_due(array $row, int $nowTs, int $minAgeMinutes, int $intervalMinutes): bool
{
    $status = settlement_status_for_reminder((string) ($row['status'] ?? ''));
    if ($status === '') {
        return false;
    }

    $baseTs = settlement_reminder_base_time($row);
    if ($baseTs <= 0) {
        return false;
    }
    if (($nowTs - $baseTs) < ($minAgeMinutes * 60)) {
        return false;
    }

    $lastReminderTs = settlement_reminder_last_time($row);
    if ($lastReminderTs > 0 && ($nowTs - $lastReminderTs) < ($intervalMinutes * 60)) {
        return false;
    }

    return true;
}

function build_settlement_reminder_notification(array $row): ?array
{
    $status = settlement_status_for_reminder((string) ($row['status'] ?? ''));
    if ($status === '') {
        return null;
    }

    $tripId = (int) ($row['trip_id'] ?? 0);
    $settlementId = (int) ($row['id'] ?? 0);
    $amountCents = (int) ($row['amount_cents'] ?? 0);
    $fromUserId = (int) ($row['from_user_id'] ?? 0);
    $toUserId = (int) ($row['to_user_id'] ?? 0);
    if ($tripId <= 0 || $settlementId <= 0 || $amountCents <= 0 || $fromUserId <= 0 || $toUserId <= 0) {
        return null;
    }

    $tripName = trim((string) ($row['trip_name'] ?? ''));
    if ($tripName === '') {
        $tripName = 'Trip';
    }
    $fromName = trim((string) ($row['from_nickname'] ?? ''));
    if ($fromName === '') {
        $fromName = 'Payer';
    }
    $toName = trim((string) ($row['to_nickname'] ?? ''));
    if ($toName === '') {
        $toName = 'Receiver';
    }
    $amount = '€' . cents_to_decimal($amountCents);

    if ($status === 'pending') {
        return [
            'trip_id' => $tripId,
            'settlement_id' => $settlementId,
            'settlement_status' => $status,
            'target_user_id' => $fromUserId,
            'type' => 'settlement_auto_reminder',
            'title' => 'Payment reminder',
            'body' => 'Reminder: please mark ' . $amount . ' as sent to ' . $toName . ' in "' . $tripName . '".',
            'payload' => [
                'trip_id' => $tripId,
                'settlement_id' => $settlementId,
                'from_user_id' => $fromUserId,
                'to_user_id' => $toUserId,
                'amount_cents' => $amountCents,
                'status' => $status,
                'kind' => 'pending_payment',
                'automatic' => true,
            ],
        ];
    }

    return [
        'trip_id' => $tripId,
        'settlement_id' => $settlementId,
        'settlement_status' => $status,
        'target_user_id' => $toUserId,
        'type' => 'settlement_auto_reminder',
        'title' => 'Confirmation reminder',
        'body' => 'Reminder: please confirm receiving ' . $amount . ' from ' . $fromName . ' in "' . $tripName . '".',
        'payload' => [
            'trip_id' => $tripId,
            'settlement_id' => $settlementId,
            'from_user_id' => $fromUserId,
            'to_user_id' => $toUserId,
            'amount_cents' => $amountCents,
            'status' => $status,
            'kind' => 'confirm_receipt',
            'automatic' => true,
        ],
    ];
}

function settlement_reminder_touch_state(PDO $pdo, int $settlementId, int $tripId, string $status): void
{
    if ($settlementId <= 0 || $tripId <= 0) {
        return;
    }
    $normalizedStatus = settlement_status_for_reminder($status);
    if ($normalizedStatus === '' || !settlement_reminder_state_table_available($pdo)) {
        return;
    }

    $table = table_name('settlement_reminder_state');
    $stmt = $pdo->prepare(
        'INSERT INTO ' . $table . '
         (settlement_id, trip_id, settlement_status, last_reminded_at, reminder_count)
         VALUES (:settlement_id, :trip_id, :settlement_status, UTC_TIMESTAMP(), 1)
         ON DUPLICATE KEY UPDATE
            trip_id = VALUES(trip_id),
            last_reminded_at = UTC_TIMESTAMP(),
            reminder_count = reminder_count + 1,
            updated_at = CURRENT_TIMESTAMP'
    );
    $stmt->execute([
        'settlement_id' => $settlementId,
        'trip_id' => $tripId,
        'settlement_status' => $normalizedStatus,
    ]);
}

function process_auto_settlement_reminders(PDO $pdo, array $options = []): array
{
    $limit = isset($options['limit']) && is_numeric($options['limit'])
        ? (int) $options['limit']
        : settlement_reminder_limit_default();
    if ($limit < 1) {
        $limit = 1;
    } elseif ($limit > 500) {
        $limit = 500;
    }

    $dryRun = !empty($options['dry_run']);
    $intervalMinutes = settlement_reminder_interval_minutes();
    $minAgeMinutes = settlement_reminder_min_age_minutes();

    $result = [
        'enabled' => settlement_reminders_enabled(),
        'table_available' => settlement_reminder_state_table_available($pdo),
        'dry_run' => $dryRun,
        'limit' => $limit,
        'interval_minutes' => $intervalMinutes,
        'min_age_minutes' => $minAgeMinutes,
        'picked' => 0,
        'due' => 0,
        'sent' => 0,
        'skipped' => 0,
        'errors' => 0,
        'rows' => [],
    ];

    if (!$result['enabled'] || !$result['table_available']) {
        return $result;
    }

    $settlementsTable = table_name('settlements');
    $tripsTable = table_name('trips');
    $usersTable = table_name('users');
    $stateTable = table_name('settlement_reminder_state');

    $stmt = $pdo->query(
        'SELECT
            s.id,
            s.trip_id,
            s.from_user_id,
            s.to_user_id,
            s.amount_cents,
            s.status,
            s.created_at,
            s.updated_at,
            s.marked_sent_at,
            t.name AS trip_name,
            uf.nickname AS from_nickname,
            ut.nickname AS to_nickname,
            rs.last_reminded_at,
            rs.reminder_count
         FROM ' . $settlementsTable . ' s
         JOIN ' . $tripsTable . ' t ON t.id = s.trip_id
         JOIN ' . $usersTable . ' uf ON uf.id = s.from_user_id
         JOIN ' . $usersTable . ' ut ON ut.id = s.to_user_id
         LEFT JOIN ' . $stateTable . ' rs
           ON rs.settlement_id = s.id
          AND rs.settlement_status = s.status
         WHERE t.status = "settling"
           AND s.status IN ("pending", "sent")
         ORDER BY COALESCE(rs.last_reminded_at, "1970-01-01 00:00:00") ASC, s.id ASC
         LIMIT ' . $limit
    );
    $rows = $stmt->fetchAll();
    $result['picked'] = count($rows);
    if (!$rows) {
        return $result;
    }

    $nowTs = time();
    foreach ($rows as $row) {
        $rowStatus = settlement_status_for_reminder((string) ($row['status'] ?? ''));
        if ($rowStatus === '') {
            $result['skipped']++;
            continue;
        }

        if (!settlement_reminder_is_due($row, $nowTs, $minAgeMinutes, $intervalMinutes)) {
            $result['skipped']++;
            continue;
        }
        $result['due']++;

        $notification = build_settlement_reminder_notification($row);
        if (!is_array($notification)) {
            $result['skipped']++;
            continue;
        }

        if ($dryRun) {
            $result['rows'][] = [
                'settlement_id' => (int) ($row['id'] ?? 0),
                'trip_id' => (int) ($row['trip_id'] ?? 0),
                'status' => $rowStatus,
                'target_user_id' => (int) ($notification['target_user_id'] ?? 0),
                'title' => (string) ($notification['title'] ?? ''),
            ];
            continue;
        }

        $pdo->beginTransaction();
        try {
            $lockStmt = $pdo->prepare(
                'SELECT
                    s.id,
                    s.trip_id,
                    s.from_user_id,
                    s.to_user_id,
                    s.amount_cents,
                    s.status,
                    s.created_at,
                    s.updated_at,
                    s.marked_sent_at,
                    t.name AS trip_name,
                    uf.nickname AS from_nickname,
                    ut.nickname AS to_nickname
                 FROM ' . $settlementsTable . ' s
                 JOIN ' . $tripsTable . ' t ON t.id = s.trip_id
                 JOIN ' . $usersTable . ' uf ON uf.id = s.from_user_id
                 JOIN ' . $usersTable . ' ut ON ut.id = s.to_user_id
                 WHERE s.id = :settlement_id
                   AND t.status = "settling"
                 LIMIT 1
                 FOR UPDATE'
            );
            $lockStmt->execute(['settlement_id' => (int) $row['id']]);
            $current = $lockStmt->fetch();
            if (!is_array($current)) {
                $pdo->rollBack();
                $result['skipped']++;
                continue;
            }

            $currentStatus = settlement_status_for_reminder((string) ($current['status'] ?? ''));
            if ($currentStatus === '') {
                $pdo->rollBack();
                $result['skipped']++;
                continue;
            }

            $stateStmt = $pdo->prepare(
                'SELECT last_reminded_at
                 FROM ' . $stateTable . '
                 WHERE settlement_id = :settlement_id
                   AND settlement_status = :settlement_status
                 LIMIT 1
                 FOR UPDATE'
            );
            $stateStmt->execute([
                'settlement_id' => (int) $current['id'],
                'settlement_status' => $currentStatus,
            ]);
            $stateRow = $stateStmt->fetch();
            if (is_array($stateRow)) {
                $current['last_reminded_at'] = $stateRow['last_reminded_at'] ?? null;
            } else {
                $current['last_reminded_at'] = null;
            }

            if (!settlement_reminder_is_due($current, time(), $minAgeMinutes, $intervalMinutes)) {
                $pdo->rollBack();
                $result['skipped']++;
                continue;
            }

            $currentNotification = build_settlement_reminder_notification($current);
            if (!is_array($currentNotification)) {
                $pdo->rollBack();
                $result['skipped']++;
                continue;
            }

            create_user_notification(
                $pdo,
                (int) ($currentNotification['trip_id'] ?? 0),
                (int) ($currentNotification['target_user_id'] ?? 0),
                (string) ($currentNotification['type'] ?? 'settlement_auto_reminder'),
                (string) ($currentNotification['title'] ?? 'Settlement reminder'),
                (string) ($currentNotification['body'] ?? ''),
                (array) ($currentNotification['payload'] ?? [])
            );
            settlement_reminder_touch_state(
                $pdo,
                (int) ($current['id'] ?? 0),
                (int) ($current['trip_id'] ?? 0),
                $currentStatus
            );

            $pdo->commit();
            $result['sent']++;
        } catch (Throwable $error) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            log_api_exception($error, 'process_auto_settlement_reminders');
            $result['errors']++;
        }
    }

    return $result;
}
