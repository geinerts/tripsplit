<?php
declare(strict_types=1);

function users_trip_payment_sharing_available(PDO $pdo): bool
{
    static $available = null;
    if ($available === null) {
        $stmt = $pdo->prepare('SELECT COUNT(*) FROM information_schema.columns
            WHERE table_schema = DATABASE() AND table_name = :table_name
              AND column_name = "share_payment_details_with_trips"');
        $stmt->execute(['table_name' => trim(table_name('users'), '`')]);
        $available = (int) $stmt->fetchColumn() === 1;
    }
    return $available;
}

function profile_payment_sharing_value($value): int
{
    if (!is_bool($value)) {
        json_out(['ok' => false, 'error' => 'Payment sharing must be a boolean.'], 400);
    }
    return $value ? 1 : 0;
}

function load_trip_member_payment_details(PDO $pdo, int $tripId, int $memberId, int $actorId): ?array
{
    // Only accepted membership rows confer access; pending invitations are never joined.
    // Read consent and both memberships in the same query. No owner/admin override.
    $stmt = $pdo->prepare('SELECT u.bank_account_holder, u.bank_iban, u.bank_bic,
            u.revolut_handle, u.revolut_me_link, u.paypal_me_link, u.wise_pay_link
        FROM ' . table_name('trip_members') . ' target
        JOIN ' . table_name('trips') . ' t ON t.id = target.trip_id
        JOIN ' . table_name('users') . ' u ON u.id = target.user_id
        JOIN ' . table_name('trip_members') . ' viewer ON viewer.trip_id = target.trip_id
        JOIN ' . table_name('users') . ' actor ON actor.id = viewer.user_id
        WHERE target.trip_id = :trip_id AND target.user_id = :member_id
          AND viewer.user_id = :actor_id
          AND u.share_payment_details_with_trips = 1
          AND u.account_status = "active" AND actor.account_status = "active"
        LIMIT 1');
    $stmt->execute(['trip_id' => $tripId, 'member_id' => $memberId, 'actor_id' => $actorId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return is_array($row) ? $row : null;
}

function trip_member_payment_details_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    if (!users_trip_payment_sharing_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Payment sharing is not available yet.'], 409);
    }
    $details = load_trip_member_payment_details($pdo, (int) $trip['id'], (int) ($body['user_id'] ?? 0), (int) $me['id']);
    if ($details === null) {
        json_out(['ok' => false, 'error' => 'Payment details are not shared or available.'], 404);
    }
    json_out(['ok' => true, 'payment_details' => $details]);
}
