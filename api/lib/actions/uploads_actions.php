<?php
declare(strict_types=1);

function upload_receipt_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $trip = get_current_trip($pdo, $me, false);
    $tripId = $trip ? (int) $trip['id'] : 0;
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'upload_ip',
        client_ip_address(),
        RATE_LIMIT_UPLOAD_IP_MAX,
        RATE_LIMIT_UPLOAD_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'upload_user',
        (string) $userId,
        RATE_LIMIT_UPLOAD_USER_MAX,
        RATE_LIMIT_UPLOAD_WINDOW_SEC
    );

    if (!isset($_FILES['receipt']) || !is_array($_FILES['receipt'])) {
        json_out(['ok' => false, 'error' => 'Missing receipt file.'], 400);
    }
    $validated = validate_uploaded_image_file(
        $_FILES['receipt'],
        RECEIPTS_MAX_BYTES,
        'File size must be up to 8 MB.'
    );
    $size = (int) $validated['size'];

    enforce_upload_daily_quota(
        $pdo,
        'user',
        $userId,
        $size,
        UPLOAD_USER_MAX_FILES_PER_DAY,
        UPLOAD_USER_MAX_BYTES_PER_DAY
    );
    if ($tripId > 0) {
        enforce_upload_daily_quota(
            $pdo,
            'trip',
            $tripId,
            $size,
            UPLOAD_TRIP_MAX_FILES_PER_DAY,
            UPLOAD_TRIP_MAX_BYTES_PER_DAY
        );
    }
    $stored = store_uploaded_image_as_webp(
        (string) $validated['tmp'],
        RECEIPTS_REL_DIR,
        'ensure_receipts_dir',
        (string) $validated['mime']
    );
    $relativePath = (string) $stored['path'];
    $storedSize = (int) $stored['size'];

    json_out([
        'ok' => true,
        'receipt_path' => $relativePath,
        'receipt_url' => receipt_public_url($relativePath),
        'receipt_thumb_url' => receipt_thumb_public_url($relativePath),
        'size' => $storedSize > 0 ? $storedSize : $size,
    ]);
}

function upload_trip_image_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    if (!trips_image_column_available($pdo)) {
        json_out(['ok' => false, 'error' => 'Trip image support is not enabled on server yet. Run migration first.'], 409);
    }
    $trip = get_current_trip($pdo, $me, true);
    $tripId = (int) ($trip['id'] ?? 0);
    $userId = (int) ($me['id'] ?? 0);
    $creatorId = (int) ($trip['created_by'] ?? 0);
    if ($creatorId <= 0 || $creatorId !== $userId) {
        json_out(['ok' => false, 'error' => 'Only trip creator can upload trip image.'], 403);
    }

    enforce_rate_limit(
        $pdo,
        'upload_ip',
        client_ip_address(),
        RATE_LIMIT_UPLOAD_IP_MAX,
        RATE_LIMIT_UPLOAD_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'upload_user',
        (string) $userId,
        RATE_LIMIT_UPLOAD_USER_MAX,
        RATE_LIMIT_UPLOAD_WINDOW_SEC
    );

    if (!isset($_FILES['trip_image']) || !is_array($_FILES['trip_image'])) {
        json_out(['ok' => false, 'error' => 'Missing trip image file.'], 400);
    }

    $validated = validate_uploaded_image_file(
        $_FILES['trip_image'],
        TRIP_IMAGES_MAX_BYTES,
        'Trip image size must be up to 8 MB.'
    );
    $sourceSize = (int) $validated['size'];

    enforce_upload_daily_quota(
        $pdo,
        'user',
        $userId,
        $sourceSize,
        UPLOAD_USER_MAX_FILES_PER_DAY,
        UPLOAD_USER_MAX_BYTES_PER_DAY
    );
    enforce_upload_daily_quota(
        $pdo,
        'trip',
        $tripId,
        $sourceSize,
        UPLOAD_TRIP_MAX_FILES_PER_DAY,
        UPLOAD_TRIP_MAX_BYTES_PER_DAY
    );

    $stored = store_uploaded_image_as_webp(
        (string) $validated['tmp'],
        TRIP_IMAGES_REL_DIR,
        'ensure_trip_images_dir',
        (string) $validated['mime']
    );
    $tripImagePath = (string) $stored['path'];
    $storedSize = (int) $stored['size'];

    json_out([
        'ok' => true,
        'image_path' => $tripImagePath,
        'image_url' => trip_image_public_url($tripImagePath),
        'image_thumb_url' => trip_image_thumb_public_url($tripImagePath),
        'size' => $storedSize > 0 ? $storedSize : $sourceSize,
    ]);
}

function upload_avatar_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);

    enforce_rate_limit(
        $pdo,
        'upload_ip',
        client_ip_address(),
        RATE_LIMIT_UPLOAD_IP_MAX,
        RATE_LIMIT_UPLOAD_WINDOW_SEC
    );
    enforce_rate_limit(
        $pdo,
        'upload_user',
        (string) $userId,
        RATE_LIMIT_UPLOAD_USER_MAX,
        RATE_LIMIT_UPLOAD_WINDOW_SEC
    );

    if (!isset($_FILES['avatar']) || !is_array($_FILES['avatar'])) {
        json_out(['ok' => false, 'error' => 'Missing avatar file.'], 400);
    }

    $validated = validate_uploaded_image_file(
        $_FILES['avatar'],
        AVATARS_MAX_BYTES,
        'Avatar size must be up to 5 MB.'
    );
    $sourceSize = (int) $validated['size'];

    enforce_upload_daily_quota(
        $pdo,
        'user',
        $userId,
        $sourceSize,
        UPLOAD_USER_MAX_FILES_PER_DAY,
        UPLOAD_USER_MAX_BYTES_PER_DAY
    );

    $stored = store_uploaded_image_as_webp(
        (string) $validated['tmp'],
        AVATARS_REL_DIR,
        'ensure_avatars_dir',
        (string) $validated['mime']
    );
    $avatarPath = (string) $stored['path'];
    $storedSize = (int) $stored['size'];

    $fresh = fetch_me_row_by_id($pdo, $userId);
    if (!$fresh) {
        delete_avatar_file($avatarPath);
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }

    $oldAvatarPath = trim((string) ($fresh['avatar_path'] ?? ''));

    $usersTable = table_name('users');
    $update = $pdo->prepare(
        'UPDATE ' . $usersTable . '
         SET avatar_path = :avatar_path
         WHERE id = :id'
    );
    $update->execute([
        'avatar_path' => $avatarPath,
        'id' => $userId,
    ]);

    if ($oldAvatarPath !== '' && $oldAvatarPath !== $avatarPath) {
        delete_avatar_file($oldAvatarPath);
    }

    $next = fetch_me_row_by_id($pdo, $userId);
    if (!$next) {
        json_out(['ok' => false, 'error' => 'Failed to resolve updated user.'], 500);
    }

    json_out([
        'ok' => true,
        'avatar_path' => $avatarPath,
        'avatar_url' => avatar_public_url($avatarPath),
        'avatar_thumb_url' => avatar_thumb_public_url($avatarPath),
        'size' => $storedSize > 0 ? $storedSize : $sourceSize,
        'me' => build_me_payload($next),
    ]);
}

function remove_avatar_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $userId = (int) ($me['id'] ?? 0);

    $fresh = fetch_me_row_by_id($pdo, $userId);
    if (!$fresh) {
        json_out(['ok' => false, 'error' => 'Failed to resolve user.'], 500);
    }
    $oldAvatarPath = trim((string) ($fresh['avatar_path'] ?? ''));

    $usersTable = table_name('users');
    $update = $pdo->prepare(
        'UPDATE ' . $usersTable . '
         SET avatar_path = NULL
         WHERE id = :id'
    );
    $update->execute(['id' => $userId]);

    if ($oldAvatarPath !== '') {
        delete_avatar_file($oldAvatarPath);
    }

    $next = fetch_me_row_by_id($pdo, $userId);
    if (!$next) {
        json_out(['ok' => false, 'error' => 'Failed to resolve updated user.'], 500);
    }

    json_out([
        'ok' => true,
        'me' => build_me_payload($next),
    ]);
}
