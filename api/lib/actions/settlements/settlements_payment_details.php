<?php
declare(strict_types=1);

function trip_payment_details_sharing_available(PDO $pdo): bool
{
    static $available = null;
    if ($available === null) {
        $stmt = $pdo->prepare(
            'SELECT COUNT(*) FROM information_schema.columns
             WHERE table_schema = DATABASE() AND table_name = :table_name
               AND column_name = "share_payment_details"'
        );
        $stmt->execute(['table_name' => DB_TABLE_PREFIX . 'payments']);
        $available = (int) $stmt->fetchColumn() === 1;
    }
    return $available;
}

function require_trip_payment_details_sharing(PDO $pdo): void
{
    if (!trip_payment_details_sharing_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Payment details sharing is not available yet.'], 409);
    }
}

function load_trip_payment_request_details(PDO $pdo, int $tripId, int $paymentId, int $actorId): ?array
{
    // Authorize and read in one statement. Membership, friendship or ownership
    // alone never grants access to somebody else's payment profile.
    $stmt = $pdo->prepare(
        'SELECT u.bank_account_holder, u.bank_iban, u.bank_bic,
                u.revolut_handle, u.revolut_me_link, u.paypal_me_link, u.wise_pay_link
         FROM ' . table_name('payments') . ' p
         JOIN ' . table_name('trips') . ' t ON t.id = p.trip_id
         JOIN ' . table_name('users') . ' u ON u.id = p.to_user_id
         JOIN ' . table_name('users') . ' payer ON payer.id = p.from_user_id
         JOIN ' . table_name('trip_members') . ' payee_member
           ON payee_member.trip_id = p.trip_id AND payee_member.user_id = p.to_user_id
         JOIN ' . table_name('trip_members') . ' payer_member
           ON payer_member.trip_id = p.trip_id AND payer_member.user_id = p.from_user_id
         WHERE p.id = :payment_id AND p.trip_id = :trip_id
           AND p.from_user_id = :actor_id AND p.from_user_id <> p.to_user_id
           AND p.requester_user_id = p.to_user_id AND p.share_payment_details = 1
           AND p.status = "requested" AND t.status = "active"
           AND u.account_status = "active" AND payer.account_status = "active"
         LIMIT 1'
    );
    $stmt->execute(['payment_id' => $paymentId, 'trip_id' => $tripId, 'actor_id' => $actorId]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return is_array($row) ? $row : null;
}

function trip_payment_request_details_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, true);
    require_trip_payment_details_sharing($pdo);
    $details = load_trip_payment_request_details(
        $pdo, (int) $trip['id'], (int) ($body['payment_id'] ?? 0), (int) $me['id']
    );
    if ($details === null) {
        json_out(['ok' => false, 'error' => 'Payment details are not available for this request.'], 404);
    }
    json_out(['ok' => true, 'payment_details' => $details]);
}
