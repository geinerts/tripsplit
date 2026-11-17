<?php
declare(strict_types=1);

/**
 * "Trip starts tomorrow": one notification per active member of an active trip
 * whose start date is tomorrow (UTC). Running it again sends nothing twice,
 * because a member who already has this notification for the trip is skipped.
 */
function trip_start_reminder_type(): string
{
    return 'trip_starts_tomorrow';
}

function build_trip_start_reminder_text(string $tripName): array
{
    $name = trim($tripName) !== '' ? trim($tripName) : 'Your trip';
    return ['title' => 'Trip starts tomorrow', 'body' => '"' . $name . '" starts tomorrow.'];
}

function process_trip_start_reminders(PDO $pdo, array $options = []): array
{
    $limit = (int) ($options['limit'] ?? 200);
    $limit = max(1, min(500, $limit));
    $dryRun = !empty($options['dry_run']);
    $now = isset($options['now']) ? (int) $options['now'] : time();
    $tomorrow = gmdate('Y-m-d', $now + 86400);
    $result = [
        'dry_run' => $dryRun,
        'limit' => $limit,
        'date' => $tomorrow,
        'dates_available' => trips_date_range_columns_available($pdo),
        'trips' => 0,
        'sent' => 0,
        'skipped' => 0,
        'errors' => 0,
        'rows' => [],
    ];
    if (!$result['dates_available']) {
        return $result;
    }

    $type = trip_start_reminder_type();
    $trips = $pdo->prepare(
        'SELECT t.id, t.name FROM ' . table_name('trips') . ' t
         WHERE t.date_from = :tomorrow AND t.status = "active"
         ORDER BY t.id ASC LIMIT ' . $limit
    );
    $trips->execute(['tomorrow' => $tomorrow]);
    $members = $pdo->prepare(
        'SELECT m.user_id FROM ' . table_name('trip_members') . ' m
         JOIN ' . table_name('users') . ' u ON u.id = m.user_id AND u.account_status = "active"
         WHERE m.trip_id = :trip_id
         ORDER BY m.user_id ASC'
    );
    $already = $pdo->prepare(
        'SELECT COUNT(*) FROM ' . table_name('notifications') . '
         WHERE trip_id = :trip_id AND user_id = :user_id AND type = :type'
    );

    foreach ($trips->fetchAll() as $trip) {
        $tripId = (int) ($trip['id'] ?? 0);
        if ($tripId <= 0) {
            continue;
        }
        $result['trips']++;
        $text = build_trip_start_reminder_text((string) ($trip['name'] ?? ''));
        $members->execute(['trip_id' => $tripId]);
        foreach ($members->fetchAll(PDO::FETCH_COLUMN) as $memberId) {
            $userId = (int) $memberId;
            $already->execute(['trip_id' => $tripId, 'user_id' => $userId, 'type' => $type]);
            if ((int) $already->fetchColumn() > 0) {
                $result['skipped']++;
                continue;
            }
            if ($dryRun) {
                $result['rows'][] = ['trip_id' => $tripId, 'user_id' => $userId, 'body' => $text['body']];
                continue;
            }
            try {
                create_user_notification(
                    $pdo,
                    $tripId,
                    $userId,
                    $type,
                    $text['title'],
                    $text['body'],
                    ['trip_id' => $tripId, 'date_from' => $tomorrow]
                );
                $result['sent']++;
            } catch (Throwable $error) {
                $result['errors']++;
                if (function_exists('log_api_exception')) {
                    log_api_exception($error, 'process_trip_start_reminders');
                }
            }
        }
    }
    return $result;
}
