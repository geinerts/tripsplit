<?php
declare(strict_types=1);

require_once __DIR__ . '/../../helpers/helper_trip_guests.php';

function settlement_row_to_payload(array $row, int $currentUserId, array $stats = [], array $guestIds = []): array
{
    $actsFor = static fn(int $id): bool => $currentUserId > 0 && ($id === $currentUserId || in_array($id, $guestIds, true));
    $fromUserId = (int) ($row['from_user_id'] ?? 0);
    $toUserId = (int) ($row['to_user_id'] ?? 0);
    $status = normalize_settlement_status($row['status'] ?? 'pending');

    $fromName = trim((string) ($row['from_nickname'] ?? ''));
    if ($fromName === '') {
        $fromName = (string) ($stats[$fromUserId]['nickname'] ?? ('User ' . $fromUserId));
    }

    $toName = trim((string) ($row['to_nickname'] ?? ''));
    if ($toName === '') {
        $toName = (string) ($stats[$toUserId]['nickname'] ?? ('User ' . $toUserId));
    }

    $amountCents = (int) ($row['amount_cents'] ?? 0);
    return [
        'id' => array_key_exists('id', $row) ? (int) $row['id'] : null,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
        'from' => $fromName,
        'to' => $toName,
        'amount' => cents_to_float($amountCents),
        'status' => $status,
        'created_at' => $row['created_at'] ?? null,
        'marked_sent_at' => $row['marked_sent_at'] ?? null,
        'confirmed_at' => $row['confirmed_at'] ?? null,
        'can_mark_sent' => $status === 'pending' && $actsFor($fromUserId),
        'can_confirm_received' => $status === 'sent' && $actsFor($toUserId),
        'can_cancel_sent' => $status === 'sent' && $actsFor($fromUserId),
        'can_report_not_received' => $status === 'sent' && $actsFor($toUserId),
        'is_confirmed' => $status === 'confirmed',
    ];
}

function load_trip_settlement_payload(PDO $pdo, int $tripId, int $currentUserId, array $stats): array
{
    $settlementsTable = table_name('settlements');
    $usersTable = table_name('users');
    $stmt = $pdo->prepare(
        'SELECT
            s.id,
            s.trip_id,
            s.from_user_id,
            s.to_user_id,
            s.amount_cents,
            s.status,
            s.created_at,
            s.marked_sent_at,
            s.confirmed_at,
            uf.nickname AS from_nickname,
            ut.nickname AS to_nickname
         FROM ' . $settlementsTable . ' s
         JOIN ' . $usersTable . ' uf ON uf.id = s.from_user_id
         JOIN ' . $usersTable . ' ut ON ut.id = s.to_user_id
         WHERE s.trip_id = :trip_id
         ORDER BY s.id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    $rows = $stmt->fetchAll();

    $guestIds = function_exists('trip_guest_ids_for_actor') ? trip_guest_ids_for_actor($pdo, $tripId, $currentUserId) : [];
    $settlements = [];
    $confirmedCount = 0;
    foreach ($rows as $row) {
        $item = settlement_row_to_payload($row, $currentUserId, $stats, $guestIds);
        if ($item['is_confirmed'] === true) {
            $confirmedCount++;
        }
        $settlements[] = $item;
    }

    $total = count($settlements);
    $remaining = max(0, $total - $confirmedCount);
    $allSettled = $total === 0 ? true : $remaining === 0;

    return [
        'settlements' => $settlements,
        'progress' => [
            'total' => $total,
            'confirmed' => $confirmedCount,
            'remaining' => $remaining,
            'all_settled' => $allSettled,
        ],
    ];
}
