<?php
declare(strict_types=1);

function send_friend_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $targetUserId = (int) ($body['user_id'] ?? 0);
    if ($targetUserId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_invite_ip',
        client_ip_address(),
        RATE_LIMIT_FRIENDS_INVITE_IP_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_invite_actor',
        (string) $meId,
        RATE_LIMIT_FRIENDS_INVITE_USER_MAX,
        RATE_LIMIT_MUTATION_WINDOW_SEC
    );

    [$userAId, $userBId] = friend_pair_ids($meId, $targetUserId);
    $targetUser = find_public_user_by_id($pdo, $targetUserId);
    if (!$targetUser) {
        json_out(['ok' => false, 'error' => 'User not found.'], 404);
    }

    $friendsTable = table_name('friends');
    $requestId = 0;
    $status = 'pending';
    $created = false;
    $autoAccepted = false;

    $pdo->beginTransaction();
    try {
        $existingStmt = $pdo->prepare(
            'SELECT id, requested_by, status
             FROM ' . $friendsTable . '
             WHERE user_a_id = :user_a_id
               AND user_b_id = :user_b_id
             LIMIT 1
             FOR UPDATE'
        );
        $existingStmt->execute([
            'user_a_id' => $userAId,
            'user_b_id' => $userBId,
        ]);
        $existing = $existingStmt->fetch();

        if (!$existing) {
            $insert = $pdo->prepare(
                'INSERT INTO ' . $friendsTable . '
                 (user_a_id, user_b_id, requested_by, status, responded_at)
                 VALUES (:user_a_id, :user_b_id, :requested_by, "pending", NULL)'
            );
            $insert->execute([
                'user_a_id' => $userAId,
                'user_b_id' => $userBId,
                'requested_by' => $meId,
            ]);
            $requestId = (int) $pdo->lastInsertId();
            $status = 'pending';
            $created = true;
        } else {
            $requestId = (int) ($existing['id'] ?? 0);
            $existingStatus = strtolower(trim((string) ($existing['status'] ?? '')));
            $existingRequestedBy = (int) ($existing['requested_by'] ?? 0);

            if ($existingStatus === 'accepted') {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Already friends.'], 409);
            }

            if ($existingStatus === 'pending' && $existingRequestedBy === $meId) {
                $pdo->rollBack();
                json_out(['ok' => false, 'error' => 'Invite already sent.'], 409);
            }

            if ($existingStatus === 'pending' && $existingRequestedBy !== $meId) {
                $update = $pdo->prepare(
                    'UPDATE ' . $friendsTable . '
                     SET status = "accepted",
                         responded_at = UTC_TIMESTAMP()
                     WHERE id = :id'
                );
                $update->execute(['id' => $requestId]);
                $status = 'accepted';
                $autoAccepted = true;
            } else {
                $update = $pdo->prepare(
                    'UPDATE ' . $friendsTable . '
                     SET requested_by = :requested_by,
                         status = "pending",
                         responded_at = NULL
                     WHERE id = :id'
                );
                $update->execute([
                    'requested_by' => $meId,
                    'id' => $requestId,
                ]);
                $status = 'pending';
            }
        }

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($autoAccepted && $requestId > 0) {
        $tripIdForNotification = resolve_notification_trip_id($pdo, $targetUserId, $meId);
        if ($tripIdForNotification > 0) {
            create_user_notification(
                $pdo,
                $tripIdForNotification,
                $targetUserId,
                'friend_invite_accepted',
                'Invite accepted',
                actor_display_name($me) . ' accepted your friend invite.',
                [
                    'request_id' => $requestId,
                    'from_user_id' => $meId,
                    'status' => 'accepted',
                ]
            );
        }
    }

    json_out([
        'ok' => true,
        'request_id' => $requestId,
        'status' => $status,
        'created' => $created,
        'auto_accepted' => $autoAccepted,
        'user' => friend_user_payload_from_row($targetUser),
    ]);
}

function respond_friend_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $requestId = (int) ($body['request_id'] ?? 0);
    if ($requestId <= 0) {
        json_out(['ok' => false, 'error' => 'request_id is required.'], 400);
    }
    $accept = (bool) ($body['accept'] ?? false);

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_respond_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_respond_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    $friendsTable = table_name('friends');
    $request = null;
    $otherUserId = 0;
    $nextStatus = $accept ? 'accepted' : 'rejected';

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, user_a_id, user_b_id, requested_by, status
             FROM ' . $friendsTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute(['id' => $requestId]);
        $request = $select->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Request not found.'], 404);
        }

        $currentStatus = strtolower(trim((string) ($request['status'] ?? '')));
        if ($currentStatus !== 'pending') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Request is no longer pending.'], 409);
        }

        $userAId = (int) ($request['user_a_id'] ?? 0);
        $userBId = (int) ($request['user_b_id'] ?? 0);
        $requestedBy = (int) ($request['requested_by'] ?? 0);
        if ($meId !== $userAId && $meId !== $userBId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Access denied for this request.'], 403);
        }
        if ($requestedBy === $meId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Cannot respond to your own invite.'], 403);
        }

        $otherUserId = $requestedBy;
        $update = $pdo->prepare(
            'UPDATE ' . $friendsTable . '
             SET status = :status,
                 responded_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $update->execute([
            'status' => $nextStatus,
            'id' => $requestId,
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    if ($otherUserId > 0 && $requestId > 0) {
        $tripIdForNotification = resolve_notification_trip_id($pdo, $otherUserId, $meId);
        if ($tripIdForNotification > 0) {
            $type = $accept ? 'friend_invite_accepted' : 'friend_invite_rejected';
            $title = $accept ? 'Invite accepted' : 'Invite declined';
            $bodyText = $accept
                ? actor_display_name($me) . ' accepted your friend invite.'
                : actor_display_name($me) . ' declined your friend invite.';
            create_user_notification(
                $pdo,
                $tripIdForNotification,
                $otherUserId,
                $type,
                $title,
                $bodyText,
                [
                    'request_id' => $requestId,
                    'from_user_id' => $meId,
                    'status' => $nextStatus,
                ]
            );
        }
    }

    $otherUser = find_public_user_by_id($pdo, $otherUserId);
    json_out([
        'ok' => true,
        'request_id' => $requestId,
        'status' => $nextStatus,
        'user' => $otherUser ? friend_user_payload_from_row($otherUser) : null,
    ]);
}

function cancel_friend_invite_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $requestId = (int) ($body['request_id'] ?? 0);
    if ($requestId <= 0) {
        json_out(['ok' => false, 'error' => 'request_id is required.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_cancel_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_cancel_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    $friendsTable = table_name('friends');
    $otherUserId = 0;

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, user_a_id, user_b_id, requested_by, status
             FROM ' . $friendsTable . '
             WHERE id = :id
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute(['id' => $requestId]);
        $request = $select->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Request not found.'], 404);
        }

        $userAId = (int) ($request['user_a_id'] ?? 0);
        $userBId = (int) ($request['user_b_id'] ?? 0);
        $requestedBy = (int) ($request['requested_by'] ?? 0);
        if ($meId !== $userAId && $meId !== $userBId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Access denied for this request.'], 403);
        }
        if ($requestedBy !== $meId) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only sender can cancel this invite.'], 403);
        }

        $currentStatus = strtolower(trim((string) ($request['status'] ?? '')));
        if ($currentStatus !== 'pending') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only pending invites can be cancelled.'], 409);
        }

        $otherUserId = $userAId === $meId ? $userBId : $userAId;
        $update = $pdo->prepare(
            'UPDATE ' . $friendsTable . '
             SET status = "rejected",
                 responded_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $update->execute(['id' => $requestId]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $otherUser = find_public_user_by_id($pdo, $otherUserId);
    json_out([
        'ok' => true,
        'request_id' => $requestId,
        'status' => 'rejected',
        'user' => $otherUser ? friend_user_payload_from_row($otherUser) : null,
    ]);
}

function remove_friend_action(): void
{
    require_post();
    $me = get_me();
    $body = read_json();
    $meId = (int) ($me['id'] ?? 0);
    $targetUserId = (int) ($body['user_id'] ?? 0);
    if ($targetUserId <= 0) {
        json_out(['ok' => false, 'error' => 'user_id is required.'], 400);
    }

    $pdo = db();
    enforce_rate_limit(
        $pdo,
        'friends_remove_ip',
        client_ip_address(),
        RATE_LIMIT_SEARCH_IP_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'friends_remove_actor',
        (string) $meId,
        RATE_LIMIT_SEARCH_USER_MAX,
        RATE_LIMIT_SEARCH_WINDOW_SEC
    );

    [$userAId, $userBId] = friend_pair_ids($meId, $targetUserId);
    $friendsTable = table_name('friends');

    $pdo->beginTransaction();
    try {
        $select = $pdo->prepare(
            'SELECT id, status
             FROM ' . $friendsTable . '
             WHERE user_a_id = :user_a_id
               AND user_b_id = :user_b_id
             LIMIT 1
             FOR UPDATE'
        );
        $select->execute([
            'user_a_id' => $userAId,
            'user_b_id' => $userBId,
        ]);
        $request = $select->fetch();
        if (!$request) {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Friendship not found.'], 404);
        }

        $currentStatus = strtolower(trim((string) ($request['status'] ?? '')));
        if ($currentStatus !== 'accepted') {
            $pdo->rollBack();
            json_out(['ok' => false, 'error' => 'Only accepted friends can be removed.'], 409);
        }

        $update = $pdo->prepare(
            'UPDATE ' . $friendsTable . '
             SET requested_by = :requested_by,
                 status = "rejected",
                 responded_at = UTC_TIMESTAMP()
             WHERE id = :id'
        );
        $update->execute([
            'requested_by' => $meId,
            'id' => (int) ($request['id'] ?? 0),
        ]);

        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) {
            $pdo->rollBack();
        }
        throw $error;
    }

    $targetUser = find_public_user_by_id($pdo, $targetUserId);
    json_out([
        'ok' => true,
        'user' => $targetUser ? friend_user_payload_from_row($targetUser) : null,
    ]);
}
