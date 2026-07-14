<?php
declare(strict_types=1);

function trip_payments_table_available(PDO $pdo): bool
{
    static $available = null;
    if ($available !== null) {
        return $available;
    }

    try {
        $stmt = $pdo->prepare(
            'SELECT COUNT(*)
             FROM information_schema.tables
             WHERE table_schema = DATABASE()
               AND table_name = :table_name'
        );
        $stmt->execute(['table_name' => DB_TABLE_PREFIX . 'payments']);
        $available = ((int) $stmt->fetchColumn()) > 0;
    } catch (Throwable $error) {
        $available = false;
    }

    return $available;
}

function ensure_trip_payments_table_available(PDO $pdo): void
{
    if (!trip_payments_table_available($pdo)) {
        json_out([
            'ok' => false,
            'error' => 'Trip payments are not enabled on server yet. Run migration first.',
        ], 409);
    }
}

function normalize_payment_status($status): string
{
    $normalized = strtolower(trim((string) $status));
    return in_array($normalized, ['requested', 'sent', 'confirmed', 'cancelled'], true)
        ? $normalized
        : 'sent';
}

function payment_status_reserves_balance($status): bool
{
    return in_array(normalize_payment_status($status), ['requested', 'sent'], true);
}

function trip_payment_action_is_allowed(
    string $mode,
    string $status,
    int $actorId,
    int $fromUserId,
    int $toUserId
): bool {
    $normalizedStatus = normalize_payment_status($status);
    return match ($mode) {
        'confirm' => $normalizedStatus === 'sent' && $actorId === $toUserId,
        'cancel' => $normalizedStatus === 'sent' && $actorId === $fromUserId,
        'not_received' => $normalizedStatus === 'sent' && $actorId === $toUserId,
        'request_sent' => $normalizedStatus === 'requested' && $actorId === $fromUserId,
        'request_cancel' => $normalizedStatus === 'requested' && $actorId === $toUserId,
        'request_decline' => $normalizedStatus === 'requested' && $actorId === $fromUserId,
        default => false,
    };
}

function load_trip_confirmed_payment_rows(PDO $pdo, int $tripId): array
{
    if ($tripId <= 0 || !trip_payments_table_available($pdo)) {
        return [];
    }

    $paymentsTable = table_name('payments');
    $stmt = $pdo->prepare(
        'SELECT from_user_id, to_user_id, amount_cents
         FROM ' . $paymentsTable . '
         WHERE trip_id = :trip_id
           AND status = "confirmed"
         ORDER BY id ASC'
    );
    $stmt->execute(['trip_id' => $tripId]);
    return $stmt->fetchAll();
}

function payment_row_to_payload(array $row, int $currentUserId): array
{
    $fromUserId = (int) ($row['from_user_id'] ?? 0);
    $toUserId = (int) ($row['to_user_id'] ?? 0);
    $status = normalize_payment_status($row['status'] ?? 'sent');
    $requesterUserId = (int) ($row['requester_user_id'] ?? 0);
    $fromName = trim((string) ($row['from_nickname'] ?? ''));
    if ($fromName === '') {
        $fromName = 'User ' . $fromUserId;
    }
    $toName = trim((string) ($row['to_nickname'] ?? ''));
    if ($toName === '') {
        $toName = 'User ' . $toUserId;
    }

    return [
        'id' => (int) ($row['id'] ?? 0),
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
        'from' => $fromName,
        'to' => $toName,
        'amount' => cents_to_float((int) ($row['amount_cents'] ?? 0)),
        'status' => $status,
        'note' => trim((string) ($row['note'] ?? '')),
        'requester_user_id' => $requesterUserId > 0 ? $requesterUserId : null,
        'requested_at' => $row['requested_at'] ?? null,
        'created_at' => $row['created_at'] ?? null,
        'marked_sent_at' => $row['marked_sent_at'] ?? null,
        'confirmed_at' => $row['confirmed_at'] ?? null,
        'cancelled_at' => $row['cancelled_at'] ?? null,
        'cancel_reason' => $row['cancel_reason'] ?? null,
        'can_mark_request_sent' => $status === 'requested' && $currentUserId > 0 && $currentUserId === $fromUserId,
        'can_cancel_request' => $status === 'requested' && $currentUserId > 0 && $currentUserId === $toUserId,
        'can_decline_request' => $status === 'requested' && $currentUserId > 0 && $currentUserId === $fromUserId,
        'can_confirm_received' => $status === 'sent' && $currentUserId > 0 && $currentUserId === $toUserId,
        'can_cancel_sent' => $status === 'sent' && $currentUserId > 0 && $currentUserId === $fromUserId,
        'can_report_not_received' => $status === 'sent' && $currentUserId > 0 && $currentUserId === $toUserId,
        'is_confirmed' => $status === 'confirmed',
    ];
}

function load_trip_payments_payload(PDO $pdo, int $tripId, int $currentUserId): array
{
    if ($tripId <= 0 || !trip_payments_table_available($pdo)) {
        return [];
    }

    $paymentsTable = table_name('payments');
    $usersTable = table_name('users');
    $stmt = $pdo->prepare(
        'SELECT
            p.id,
            p.trip_id,
            p.from_user_id,
            p.to_user_id,
            p.amount_cents,
            p.status,
            p.note,
            p.requester_user_id,
            p.requested_at,
            p.marked_sent_at,
            p.confirmed_at,
            p.cancelled_at,
            p.cancel_reason,
            p.created_at,
            uf.nickname AS from_nickname,
            ut.nickname AS to_nickname
         FROM ' . $paymentsTable . ' p
         JOIN ' . $usersTable . ' uf ON uf.id = p.from_user_id
         JOIN ' . $usersTable . ' ut ON ut.id = p.to_user_id
         WHERE p.trip_id = :trip_id
           AND p.status <> "cancelled"
         ORDER BY
            CASE
                WHEN p.status = "requested" THEN 0
                WHEN p.status = "sent" THEN 1
                ELSE 2
            END ASC,
            p.id DESC
         LIMIT 100'
    );
    $stmt->execute(['trip_id' => $tripId]);

    return array_map(
        static fn(array $row): array => payment_row_to_payload($row, $currentUserId),
        $stmt->fetchAll()
    );
}

function trip_payment_pending_pair_cents(
    PDO $pdo,
    int $tripId,
    int $fromUserId,
    int $toUserId
): int {
    if (!trip_payments_table_available($pdo)) {
        return 0;
    }

    $paymentsTable = table_name('payments');
    $stmt = $pdo->prepare(
        'SELECT COALESCE(SUM(amount_cents), 0)
         FROM ' . $paymentsTable . '
         WHERE trip_id = :trip_id
           AND from_user_id = :from_user_id
           AND to_user_id = :to_user_id
           AND status IN ("requested", "sent")'
    );
    $stmt->execute([
        'trip_id' => $tripId,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
    ]);
    return max(0, (int) ($stmt->fetchColumn() ?: 0));
}

function trip_pending_payments_count(PDO $pdo, int $tripId): int
{
    if ($tripId <= 0 || !trip_payments_table_available($pdo)) {
        return 0;
    }

    $paymentsTable = table_name('payments');
    $stmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $paymentsTable . '
         WHERE trip_id = :trip_id
           AND status IN ("requested", "sent")'
    );
    $stmt->execute(['trip_id' => $tripId]);
    return max(0, (int) ($stmt->fetchColumn() ?: 0));
}

function trip_payment_suggested_pair_cents(array $computed, int $fromUserId, int $toUserId): int
{
    $settlements = is_array($computed['recommended_settlements'] ?? null)
        ? $computed['recommended_settlements']
        : [];
    foreach ($settlements as $item) {
        if (
            (int) ($item['from_user_id'] ?? 0) === $fromUserId
            && (int) ($item['to_user_id'] ?? 0) === $toUserId
        ) {
            return max(0, (int) ($item['amount_cents'] ?? 0));
        }
    }
    return 0;
}

function trip_payment_member_name(PDO $pdo, int $tripId, int $userId): string
{
    $usersTable = table_name('users');
    $tripMembersTable = table_name('trip_members');
    $stmt = $pdo->prepare(
        'SELECT u.nickname
         FROM ' . $tripMembersTable . ' tm
         JOIN ' . $usersTable . ' u ON u.id = tm.user_id
         WHERE tm.trip_id = :trip_id
           AND tm.user_id = :user_id
         LIMIT 1'
    );
    $stmt->execute([
        'trip_id' => $tripId,
        'user_id' => $userId,
    ]);
    $name = trim((string) ($stmt->fetchColumn() ?: ''));
    return $name !== '' ? $name : 'Trip member';
}

function lock_trip_payment_scope(PDO $pdo, int $tripId): void
{
    $tripsTable = table_name('trips');
    $stmt = $pdo->prepare(
        'SELECT id
         FROM ' . $tripsTable . '
         WHERE id = :trip_id
         LIMIT 1
         FOR UPDATE'
    );
    $stmt->execute(['trip_id' => $tripId]);
    if ((int) ($stmt->fetchColumn() ?: 0) !== $tripId) {
        throw new RuntimeException('Trip not found while locking payment scope.');
    }
}

function create_trip_payment_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    ensure_trip_payments_table_available($pdo);

    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    if (normalize_trip_status($trip['status'] ?? 'active') !== 'active') {
        json_out(['ok' => false, 'error' => 'Payments can be recorded while the trip is active.'], 409);
    }
    $fromUserId = (int) ($me['id'] ?? 0);
    $clientMutationId = request_client_mutation_id();
    mutation_idempotency_try_replay(
        $pdo,
        $fromUserId,
        $tripId,
        'create_trip_payment',
        $clientMutationId
    );

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $toUserId = (int) ($body['to_user_id'] ?? 0);
    $amountCents = decimal_to_cents($body['amount'] ?? 0);
    $note = trim((string) ($body['note'] ?? ''));
    if (strlen($note) > 255) {
        $note = substr($note, 0, 255);
    }

    if ($fromUserId <= 0 || $toUserId <= 0 || $fromUserId === $toUserId) {
        json_out(['ok' => false, 'error' => 'Choose another trip member to pay.'], 400);
    }
    if ($amountCents <= 0) {
        json_out(['ok' => false, 'error' => 'Payment amount must be greater than zero.'], 400);
    }

    $tripMembersTable = table_name('trip_members');
    $memberStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id
           AND user_id IN (:from_user_id, :to_user_id)'
    );
    $memberStmt->execute([
        'trip_id' => $tripId,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
    ]);
    if ((int) ($memberStmt->fetchColumn() ?: 0) !== 2) {
        json_out(['ok' => false, 'error' => 'Both people must be trip members.'], 400);
    }

    $paymentsTable = table_name('payments');
    $tripsTable = table_name('trips');
    $paymentId = 0;
    $responsePayload = [];

    $pdo->beginTransaction();
    try {
        lock_trip_payment_scope($pdo, $tripId);
        $cached = mutation_idempotency_find_response(
            $pdo,
            $fromUserId,
            $tripId,
            'create_trip_payment',
            $clientMutationId,
            true
        );
        if ($cached !== null) {
            $pdo->rollBack();
            json_out($cached['payload'], $cached['status']);
        }
        $computed = compute_trip_balance_data($pdo, $tripId);
        $suggestedCents = trip_payment_suggested_pair_cents($computed, $fromUserId, $toUserId);
        $pendingCents = trip_payment_pending_pair_cents($pdo, $tripId, $fromUserId, $toUserId);
        $maxPayableCents = max(0, $suggestedCents - $pendingCents);
        if ($maxPayableCents <= 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'There is no outstanding balance to pay this member.'], 409);
        }
        if ($amountCents > $maxPayableCents) {
            $pdo->rollBack();
            json_out([
                'ok' => false,
                'error' => 'Payment is higher than the outstanding balance for this member.',
                'max_amount' => cents_to_float($maxPayableCents),
            ], 409);
        }

        $insert = $pdo->prepare(
            'INSERT INTO ' . $paymentsTable . '
                (trip_id, from_user_id, to_user_id, amount_cents, status, note, marked_sent_by, marked_sent_at)
             VALUES
                (:trip_id, :from_user_id, :to_user_id, :amount_cents, "sent", :note, :marked_sent_by, CURRENT_TIMESTAMP)'
        );
        $insert->execute([
            'trip_id' => $tripId,
            'from_user_id' => $fromUserId,
            'to_user_id' => $toUserId,
            'amount_cents' => $amountCents,
            'note' => $note !== '' ? $note : null,
            'marked_sent_by' => $fromUserId,
        ]);
        $paymentId = (int) $pdo->lastInsertId();

        $touchTrip = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET updated_at = CURRENT_TIMESTAMP
             WHERE id = :trip_id'
        );
        $touchTrip->execute(['trip_id' => $tripId]);

        $fromName = trip_payment_member_name($pdo, $tripId, $fromUserId);
        $amount = format_cents_with_currency($amountCents, trip_currency_code_from_trip($trip));
        create_user_notification(
            $pdo,
            $tripId,
            $toUserId,
            'payment_sent',
            'Payment marked as sent',
            $fromName . ' marked ' . $amount . ' as paid to you.',
            [
                'payment_id' => $paymentId,
                'from_user_id' => $fromUserId,
                'to_user_id' => $toUserId,
                'amount_cents' => $amountCents,
            ]
        );

        $responsePayload = [
            'ok' => true,
            'payment_id' => $paymentId,
            'payments' => load_trip_payments_payload($pdo, $tripId, $fromUserId),
        ];
        mutation_idempotency_store_response(
            $pdo,
            $fromUserId,
            $tripId,
            'create_trip_payment',
            $clientMutationId,
            $responsePayload
        );
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    app_event($pdo, $fromUserId, 'payment.marked_sent', 'payment', $paymentId, $tripId, [
        'payment_id' => $paymentId,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
        'amount_cents' => $amountCents,
        'status' => 'sent',
    ]);

    json_out($responsePayload);
}

function create_trip_payment_request_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $pdo = db();
    ensure_trip_payments_table_available($pdo);

    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    if (normalize_trip_status($trip['status'] ?? 'active') !== 'active') {
        json_out(['ok' => false, 'error' => 'Payment requests can be created while the trip is active.'], 409);
    }
    $toUserId = (int) ($me['id'] ?? 0);
    $clientMutationId = request_client_mutation_id();
    mutation_idempotency_try_replay(
        $pdo,
        $toUserId,
        $tripId,
        'create_trip_payment_request',
        $clientMutationId
    );

    enforce_rate_limit(
        $pdo,
        'trip_write_ip',
        client_ip_address(),
        RATE_LIMIT_TRIP_WRITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'trip_write_user',
        (string) ((int) ($me['id'] ?? 0)),
        RATE_LIMIT_TRIP_WRITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    $fromUserId = (int) ($body['from_user_id'] ?? 0);
    $amountCents = decimal_to_cents($body['amount'] ?? 0);
    $note = trim((string) ($body['note'] ?? ''));
    if (strlen($note) > 255) {
        $note = substr($note, 0, 255);
    }

    if ($fromUserId <= 0 || $toUserId <= 0 || $fromUserId === $toUserId) {
        json_out(['ok' => false, 'error' => 'Choose another trip member to request payment from.'], 400);
    }
    if ($amountCents <= 0) {
        json_out(['ok' => false, 'error' => 'Requested amount must be greater than zero.'], 400);
    }

    $tripMembersTable = table_name('trip_members');
    $memberStmt = $pdo->prepare(
        'SELECT COUNT(*)
         FROM ' . $tripMembersTable . '
         WHERE trip_id = :trip_id
           AND user_id IN (:from_user_id, :to_user_id)'
    );
    $memberStmt->execute([
        'trip_id' => $tripId,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
    ]);
    if ((int) ($memberStmt->fetchColumn() ?: 0) !== 2) {
        json_out(['ok' => false, 'error' => 'Both people must be trip members.'], 400);
    }

    $paymentsTable = table_name('payments');
    $tripsTable = table_name('trips');
    $paymentId = 0;
    $responsePayload = [];

    $pdo->beginTransaction();
    try {
        lock_trip_payment_scope($pdo, $tripId);
        $cached = mutation_idempotency_find_response(
            $pdo,
            $toUserId,
            $tripId,
            'create_trip_payment_request',
            $clientMutationId,
            true
        );
        if ($cached !== null) {
            $pdo->rollBack();
            json_out($cached['payload'], $cached['status']);
        }
        $computed = compute_trip_balance_data($pdo, $tripId);
        $suggestedCents = trip_payment_suggested_pair_cents($computed, $fromUserId, $toUserId);
        $reservedCents = trip_payment_pending_pair_cents($pdo, $tripId, $fromUserId, $toUserId);
        $maxRequestableCents = max(0, $suggestedCents - $reservedCents);
        if ($maxRequestableCents <= 0) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'There is no outstanding balance to request from this member.'], 409);
        }
        if ($amountCents > $maxRequestableCents) {
            $pdo->rollBack();
            json_out([
                'ok' => false,
                'error' => 'Payment request is higher than this member\'s outstanding balance.',
                'max_amount' => cents_to_float($maxRequestableCents),
            ], 409);
        }

        $insert = $pdo->prepare(
            'INSERT INTO ' . $paymentsTable . '
                (trip_id, from_user_id, to_user_id, amount_cents, status, note, requester_user_id, requested_at)
             VALUES
                (:trip_id, :from_user_id, :to_user_id, :amount_cents, "requested", :note, :requester_user_id, CURRENT_TIMESTAMP)'
        );
        $insert->execute([
            'trip_id' => $tripId,
            'from_user_id' => $fromUserId,
            'to_user_id' => $toUserId,
            'amount_cents' => $amountCents,
            'note' => $note !== '' ? $note : null,
            'requester_user_id' => $toUserId,
        ]);
        $paymentId = (int) $pdo->lastInsertId();

        $touchTrip = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET updated_at = CURRENT_TIMESTAMP
             WHERE id = :trip_id'
        );
        $touchTrip->execute(['trip_id' => $tripId]);

        $toName = trip_payment_member_name($pdo, $tripId, $toUserId);
        $amount = format_cents_with_currency($amountCents, trip_currency_code_from_trip($trip));
        create_user_notification(
            $pdo,
            $tripId,
            $fromUserId,
            'payment_requested',
            'Payment requested',
            $toName . ' requested ' . $amount . ' from you.',
            [
                'payment_id' => $paymentId,
                'from_user_id' => $fromUserId,
                'to_user_id' => $toUserId,
                'amount_cents' => $amountCents,
            ]
        );

        $responsePayload = [
            'ok' => true,
            'payment_id' => $paymentId,
            'payments' => load_trip_payments_payload($pdo, $tripId, $toUserId),
        ];
        mutation_idempotency_store_response(
            $pdo,
            $toUserId,
            $tripId,
            'create_trip_payment_request',
            $clientMutationId,
            $responsePayload
        );
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    app_event($pdo, $toUserId, 'payment.requested', 'payment', $paymentId, $tripId, [
        'payment_id' => $paymentId,
        'from_user_id' => $fromUserId,
        'to_user_id' => $toUserId,
        'amount_cents' => $amountCents,
        'status' => 'requested',
    ]);

    json_out($responsePayload);
}

function update_trip_payment_status_action(string $mode): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $paymentId = (int) ($body['payment_id'] ?? 0);
    if ($paymentId <= 0) {
        json_out(['ok' => false, 'error' => 'payment_id is required.'], 400);
    }

    $pdo = db();
    ensure_trip_payments_table_available($pdo);
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    if (normalize_trip_status($trip['status'] ?? 'active') === 'archived') {
        json_out(['ok' => false, 'error' => 'Archived trip payments cannot be changed.'], 409);
    }

    $paymentsTable = table_name('payments');
    $tripsTable = table_name('trips');
    $usersTable = table_name('users');
    $actorId = (int) ($me['id'] ?? 0);
    $row = null;
    $eventType = '';
    $notificationTarget = 0;
    $notificationType = '';
    $notificationTitle = '';
    $notificationBody = '';
    $changed = false;

    $pdo->beginTransaction();
    try {
        $stmt = $pdo->prepare(
            'SELECT
                p.id,
                p.trip_id,
                p.from_user_id,
                p.to_user_id,
                p.amount_cents,
                p.status,
                p.requester_user_id,
                uf.nickname AS from_nickname,
                ut.nickname AS to_nickname
             FROM ' . $paymentsTable . ' p
             JOIN ' . $usersTable . ' uf ON uf.id = p.from_user_id
             JOIN ' . $usersTable . ' ut ON ut.id = p.to_user_id
             WHERE p.id = :id
               AND p.trip_id = :trip_id
             LIMIT 1
             FOR UPDATE'
        );
        $stmt->execute([
            'id' => $paymentId,
            'trip_id' => $tripId,
        ]);
        $row = $stmt->fetch();
        if (!is_array($row)) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            json_out(['ok' => false, 'error' => 'Payment not found.'], 404);
        }

        $status = normalize_payment_status($row['status'] ?? 'sent');
        if ($status === 'confirmed') {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            json_out(['ok' => false, 'error' => 'Confirmed payment cannot be changed.'], 409);
        }
        if ($status === 'cancelled') {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            json_out(['ok' => false, 'error' => 'Payment was already cancelled.'], 409);
        }

        $fromUserId = (int) ($row['from_user_id'] ?? 0);
        $toUserId = (int) ($row['to_user_id'] ?? 0);
        $amountCents = (int) ($row['amount_cents'] ?? 0);
        $amount = format_cents_with_currency($amountCents, trip_currency_code_from_trip($trip));
        $fromName = trim((string) ($row['from_nickname'] ?? 'Trip member'));
        $toName = trim((string) ($row['to_nickname'] ?? 'Trip member'));

        if ($mode === 'confirm') {
            if ($status !== 'sent') {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only a sent payment can be confirmed.'], 409);
            }
            if (!trip_payment_action_is_allowed($mode, $status, $actorId, $fromUserId, $toUserId)) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only receiver can confirm this payment.'], 403);
            }
            $update = $pdo->prepare(
                'UPDATE ' . $paymentsTable . '
                 SET status = "confirmed",
                     confirmed_by = :user_id,
                     confirmed_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $update->execute(['user_id' => $actorId, 'id' => $paymentId]);
            $eventType = 'payment.confirmed';
            $notificationTarget = $fromUserId;
            $notificationType = 'payment_confirmed';
            $notificationTitle = 'Payment confirmed';
            $notificationBody = $toName . ' confirmed receiving ' . $amount . ' from you.';
            $changed = true;
        } elseif ($mode === 'cancel') {
            if ($status !== 'sent') {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only a sent payment can be cancelled.'], 409);
            }
            if (!trip_payment_action_is_allowed($mode, $status, $actorId, $fromUserId, $toUserId)) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only payer can cancel this payment.'], 403);
            }
            $update = $pdo->prepare(
                'UPDATE ' . $paymentsTable . '
                 SET status = "cancelled",
                     cancelled_by = :user_id,
                     cancelled_at = CURRENT_TIMESTAMP,
                     cancel_reason = "sender_cancelled"
                 WHERE id = :id'
            );
            $update->execute(['user_id' => $actorId, 'id' => $paymentId]);
            $eventType = 'payment.cancelled';
            $notificationTarget = $toUserId;
            $notificationType = 'payment_cancelled';
            $notificationTitle = 'Payment cancelled';
            $notificationBody = $fromName . ' cancelled the ' . $amount . ' payment mark.';
            $changed = true;
        } elseif ($mode === 'not_received') {
            if ($status !== 'sent') {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only a sent payment can be marked as not received.'], 409);
            }
            if (!trip_payment_action_is_allowed($mode, $status, $actorId, $fromUserId, $toUserId)) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only receiver can mark this payment as not received.'], 403);
            }
            $update = $pdo->prepare(
                'UPDATE ' . $paymentsTable . '
                 SET status = "cancelled",
                     cancelled_by = :user_id,
                     cancelled_at = CURRENT_TIMESTAMP,
                     cancel_reason = "not_received"
                 WHERE id = :id'
            );
            $update->execute(['user_id' => $actorId, 'id' => $paymentId]);
            $eventType = 'payment.not_received';
            $notificationTarget = $fromUserId;
            $notificationType = 'payment_not_received';
            $notificationTitle = 'Payment not received';
            $notificationBody = $toName . ' marked the ' . $amount . ' payment as not received.';
            $changed = true;
        } elseif ($mode === 'request_sent') {
            if (!trip_payment_action_is_allowed($mode, $status, $actorId, $fromUserId, $toUserId)) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only the requested payer can mark this request as paid.'], 403);
            }
            $update = $pdo->prepare(
                'UPDATE ' . $paymentsTable . '
                 SET status = "sent",
                     marked_sent_by = :user_id,
                     marked_sent_at = CURRENT_TIMESTAMP
                 WHERE id = :id'
            );
            $update->execute(['user_id' => $actorId, 'id' => $paymentId]);
            $eventType = 'payment.request_marked_sent';
            $notificationTarget = $toUserId;
            $notificationType = 'payment_request_sent';
            $notificationTitle = 'Requested payment sent';
            $notificationBody = $fromName . ' marked your ' . $amount . ' payment request as paid.';
            $changed = true;
        } elseif ($mode === 'request_cancel') {
            if (!trip_payment_action_is_allowed($mode, $status, $actorId, $fromUserId, $toUserId)) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only the requester can cancel this payment request.'], 403);
            }
            $update = $pdo->prepare(
                'UPDATE ' . $paymentsTable . '
                 SET status = "cancelled",
                     cancelled_by = :user_id,
                     cancelled_at = CURRENT_TIMESTAMP,
                     cancel_reason = "request_cancelled"
                 WHERE id = :id'
            );
            $update->execute(['user_id' => $actorId, 'id' => $paymentId]);
            $eventType = 'payment.request_cancelled';
            $notificationTarget = $fromUserId;
            $notificationType = 'payment_request_cancelled';
            $notificationTitle = 'Payment request cancelled';
            $notificationBody = $toName . ' cancelled the ' . $amount . ' payment request.';
            $changed = true;
        } elseif ($mode === 'request_decline') {
            if (!trip_payment_action_is_allowed($mode, $status, $actorId, $fromUserId, $toUserId)) {
                if ($pdo->inTransaction()) {
                    $pdo->rollBack();
                }
                json_out(['ok' => false, 'error' => 'Only the requested payer can decline this payment request.'], 403);
            }
            $update = $pdo->prepare(
                'UPDATE ' . $paymentsTable . '
                 SET status = "cancelled",
                     cancelled_by = :user_id,
                     cancelled_at = CURRENT_TIMESTAMP,
                     cancel_reason = "request_declined"
                 WHERE id = :id'
            );
            $update->execute(['user_id' => $actorId, 'id' => $paymentId]);
            $eventType = 'payment.request_declined';
            $notificationTarget = $toUserId;
            $notificationType = 'payment_request_declined';
            $notificationTitle = 'Payment request declined';
            $notificationBody = $fromName . ' declined your ' . $amount . ' payment request.';
            $changed = true;
        } else {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            json_out(['ok' => false, 'error' => 'Unsupported payment action.'], 400);
        }

        $touchTrip = $pdo->prepare(
            'UPDATE ' . $tripsTable . '
             SET updated_at = CURRENT_TIMESTAMP
             WHERE id = :trip_id'
        );
        $touchTrip->execute(['trip_id' => $tripId]);

        if ($changed && $notificationTarget > 0 && $notificationTarget !== $actorId) {
            create_user_notification(
                $pdo,
                $tripId,
                $notificationTarget,
                $notificationType,
                $notificationTitle,
                $notificationBody,
                [
                    'payment_id' => $paymentId,
                    'from_user_id' => $fromUserId,
                    'to_user_id' => $toUserId,
                    'amount_cents' => $amountCents,
                ]
            );
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if (is_array($row) && $changed) {
        app_event($pdo, $actorId, $eventType, 'payment', $paymentId, $tripId, [
            'payment_id' => $paymentId,
            'from_user_id' => (int) ($row['from_user_id'] ?? 0),
            'to_user_id' => (int) ($row['to_user_id'] ?? 0),
            'amount_cents' => (int) ($row['amount_cents'] ?? 0),
        ]);
    }

    json_out([
        'ok' => true,
        'payment_id' => $paymentId,
        'payments' => load_trip_payments_payload($pdo, $tripId, $actorId),
        'balances' => compute_trip_balance_data($pdo, $tripId)['balances'],
    ]);
}

function confirm_trip_payment_received_action(): void
{
    update_trip_payment_status_action('confirm');
}

function mark_trip_payment_request_sent_action(): void
{
    update_trip_payment_status_action('request_sent');
}

function cancel_trip_payment_request_action(): void
{
    update_trip_payment_status_action('request_cancel');
}

function decline_trip_payment_request_action(): void
{
    update_trip_payment_status_action('request_decline');
}

function cancel_trip_payment_sent_action(): void
{
    update_trip_payment_status_action('cancel');
}

function report_trip_payment_not_received_action(): void
{
    update_trip_payment_status_action('not_received');
}
