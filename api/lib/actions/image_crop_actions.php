<?php
declare(strict_types=1);
require_once __DIR__ . '/../helpers/helper_image_originals.php';
require_once __DIR__ . '/../helpers/helper_travel_places.php';

/** Finds the image and checks the caller may edit it. Other members never reach a source. */
function image_crop_target(PDO $pdo, array $me, string $kind, mixed $placeId): array
{
    $userId = (int) ($me['id'] ?? 0);
    if ($kind === 'trip') {
        if (!trips_image_column_available($pdo)) {
            json_out(['ok' => false, 'error' => 'Trip image support is not enabled on server yet.'], 409);
        }
        $trip = get_current_trip($pdo, $me, true);
        require_trip_permission($pdo, $trip, $userId, 'update_details', 'Only trip owner or admin can edit trip image.');
        $path = trim((string) ($trip['image_path'] ?? ''));
        if ($path === '') {
            json_out(['ok' => false, 'error' => 'Image not found.'], 404);
        }
        return ['kind' => $kind, 'id' => (int) $trip['id'], 'revision' => $path, 'path' => normalize_trip_image_path($path, false)];
    }
    if ($kind === 'avatar') {
        $user = fetch_me_row_by_id($pdo, $userId);
        $path = trim((string) ($user['avatar_path'] ?? ''));
        if ($path === '') {
            json_out(['ok' => false, 'error' => 'Image not found.'], 404);
        }
        return ['kind' => $kind, 'id' => $userId, 'revision' => $path, 'path' => normalize_avatar_path($path, false)];
    }
    if ($kind === 'travel') {
        require_travel_places_schema($pdo);
        $id = filter_var($placeId, FILTER_VALIDATE_INT);
        if (!$id || $id < 1) {
            json_out(['ok' => false, 'error' => 'Invalid visit.'], 400);
        }
        $stmt = $pdo->prepare('SELECT photo_data, photo_version FROM ' . table_name('travel_places')
            . ' WHERE id = :id AND user_id = :user');
        $stmt->execute(['id' => $id, 'user' => $userId]);
        $row = $stmt->fetch();
        if (!$row || $row['photo_data'] === null) {
            json_out(['ok' => false, 'error' => 'Image not found.'], 404);
        }
        return ['kind' => $kind, 'id' => (int) $id, 'revision' => 'v' . (int) $row['photo_version'], 'bytes' => (string) $row['photo_data']];
    }
    image_crop_spec($kind);
    return [];
}

function image_crop_target_key(array $target): string
{
    return image_source_key($target['kind'], $target['kind'] === 'travel' ? (string) $target['id'] : $target['path']);
}

/**
 * The saved original, or the displayed image when none exists. Earlier uploads and
 * visits copied from a trip can only be zoomed: the discarded parts no longer exist.
 */
function image_crop_load_source(array $target): array
{
    $source = image_source_read(image_crop_target_key($target));
    if ($source !== null) {
        return $source;
    }
    $bytes = $target['bytes'] ?? null;
    if ($bytes === null) {
        $absolute = upload_relative_path_to_abs($target['path']);
        $bytes = $absolute !== null && is_file($absolute) ? (string) @file_get_contents($absolute) : '';
    }
    $size = $bytes !== '' ? @getimagesizefromstring($bytes) : false;
    if (!$size || $size[0] < 1 || $size[1] < 1) {
        json_out(['ok' => false, 'error' => 'Image not found.'], 404);
    }
    return [
        'bytes' => $bytes,
        'width' => (int) $size[0],
        'height' => (int) $size[1],
        'crop' => image_crop_default((int) $size[0], (int) $size[1], image_crop_spec($target['kind'])['ratio']),
        'has_original' => false,
    ];
}

function image_crop_source_action(): void
{
    $me = get_me();
    $pdo = db();
    $kind = (string) ($_GET['kind'] ?? '');
    image_crop_spec($kind);
    enforce_rate_limit($pdo, 'image_crop_user', (string) $me['id'], 60, 900);
    $target = image_crop_target($pdo, $me, $kind, $_GET['id'] ?? null);
    $source = image_crop_load_source($target);
    if (!headers_sent()) {
        header('Cache-Control: private, no-store');
    }
    json_out([
        'ok' => true,
        'image_base64' => base64_encode($source['bytes']),
        'width' => $source['width'],
        'height' => $source['height'],
        'crop' => $source['crop'],
        'has_original' => $source['has_original'],
        'revision' => $target['revision'],
    ]);
}

function update_image_crop_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    $body = read_json();
    $kind = (string) ($body['kind'] ?? '');
    $spec = image_crop_spec($kind);
    $crop = image_crop_parse($body['crop'] ?? null);
    $revision = $body['revision'] ?? null;
    if (!is_string($revision) || $revision === '') {
        json_out(['ok' => false, 'error' => 'Invalid image revision.'], 400);
    }
    enforce_rate_limit($pdo, 'image_crop_user', (string) $me['id'], 60, 900);
    $target = image_crop_target($pdo, $me, $kind, $body['id'] ?? null);
    if (!hash_equals($target['revision'], $revision)) {
        image_crop_conflict();
    }
    $source = image_crop_load_source($target);
    $image = @imagecreatefromstring($source['bytes']);
    if (!$image instanceof GdImage) {
        json_out(['ok' => false, 'error' => 'Invalid photo.'], 400);
    }
    $pixels = image_crop_pixels($crop, imagesx($image), imagesy($image), $spec['ratio']);
    $result = image_crop_render($image, $pixels, $spec['max_edge']);
    match ($kind) {
        'trip' => image_crop_apply_trip($pdo, $me, $target, $result, $image, $crop, $source),
        'avatar' => image_crop_apply_avatar($pdo, $target, $result, $image, $crop, $source),
        'travel' => image_crop_apply_travel($pdo, $target, $result, $image, $crop, $source),
    };
}

function image_crop_conflict(): void
{
    json_out(['ok' => false, 'error' => 'This image changed. Open it again.', 'code' => 'image_changed'], 409);
}

/** Writes a new displayed file, so Cloudflare cannot serve the previous crop. */
function image_crop_store_display(GdImage $result, string $relativeDir, callable $ensureDir): array
{
    $ensureDir();
    $relativePath = sanitize_upload_relative_dir($relativeDir) . '/' . gmdate('Ymd_His') . '_' . bin2hex(random_bytes(8)) . '.webp';
    $absolute = upload_relative_path_to_abs($relativePath);
    if ($absolute === null || !@imagewebp($result, $absolute, upload_image_webp_quality()) || !is_file($absolute)) {
        json_out(['ok' => false, 'error' => 'Server cannot store image.'], 500);
    }
    @chmod($absolute, 0640);
    $thumb = generate_upload_thumbnail($relativePath);
    return [
        'path' => $relativePath,
        'size' => (int) (@filesize($absolute) ?: 0),
        'thumb_path' => is_array($thumb) ? ($thumb['path'] ?? null) : null,
    ];
}

function image_crop_apply_trip(PDO $pdo, array $me, array $target, GdImage $result, GdImage $image, array $crop, array $source): void
{
    $stored = image_crop_store_display($result, TRIP_IMAGES_REL_DIR, 'ensure_trip_images_dir');
    $path = bind_stored_trip_image_to_owner($stored, $target['id'], (int) $me['id']);
    $update = $pdo->prepare('UPDATE ' . table_name('trips')
        . ' SET image_path = :next WHERE id = :id AND image_path = :current');
    $update->execute(['next' => $path, 'id' => $target['id'], 'current' => $target['revision']]);
    if ($update->rowCount() !== 1) {
        delete_trip_image_file($path);
        image_crop_conflict();
    }
    image_source_save($image, $crop, image_source_key('trip', $path), $source['has_original']);
    delete_unreferenced_trip_image($pdo, $target['revision']);
    json_out([
        'ok' => true,
        'image_path' => $path,
        'image_url' => trip_image_public_url($path),
        'image_thumb_url' => trip_image_thumb_public_url($path),
        'has_original' => $source['has_original'],
    ]);
}

function image_crop_apply_avatar(PDO $pdo, array $target, GdImage $result, GdImage $image, array $crop, array $source): void
{
    $stored = image_crop_store_display($result, AVATARS_REL_DIR, 'ensure_avatars_dir');
    $path = (string) $stored['path'];
    $update = $pdo->prepare('UPDATE ' . table_name('users')
        . ' SET avatar_path = :next WHERE id = :id AND avatar_path = :current');
    $update->execute(['next' => $path, 'id' => $target['id'], 'current' => $target['revision']]);
    if ($update->rowCount() !== 1) {
        delete_avatar_file($path);
        image_crop_conflict();
    }
    image_source_save($image, $crop, image_source_key('avatar', $path), $source['has_original']);
    delete_avatar_file($target['revision']);
    $next = fetch_me_row_by_id($pdo, $target['id']);
    if (!$next) {
        json_out(['ok' => false, 'error' => 'Failed to resolve updated user.'], 500);
    }
    json_out([
        'ok' => true,
        'avatar_path' => $path,
        'avatar_url' => avatar_public_url($path),
        'avatar_thumb_url' => avatar_thumb_public_url($path),
        'has_original' => $source['has_original'],
        'me' => build_me_payload($next, $pdo),
    ]);
}

function image_crop_apply_travel(PDO $pdo, array $target, GdImage $result, GdImage $image, array $crop, array $source): void
{
    ob_start();
    imagewebp($result, null, 78);
    $encoded = (string) ob_get_clean();
    if ($encoded === '' || strlen($encoded) > 262144) {
        json_out(['ok' => false, 'error' => 'Photo is too large.'], 400);
    }
    $table = table_name('travel_places');
    $update = $pdo->prepare('UPDATE ' . $table . ' SET photo_data = :photo, photo_version = photo_version + 1
        WHERE id = :id AND user_id = :user AND photo_version = :version');
    $update->bindValue(':photo', $encoded, PDO::PARAM_LOB);
    $update->bindValue(':id', $target['id'], PDO::PARAM_INT);
    $update->bindValue(':user', (int) get_me()['id'], PDO::PARAM_INT);
    $update->bindValue(':version', (int) substr($target['revision'], 1), PDO::PARAM_INT);
    $update->execute();
    if ($update->rowCount() !== 1) {
        image_crop_conflict();
    }
    $key = image_source_key('travel', (string) $target['id']);
    if (image_source_read($key) !== null) {
        image_source_write_meta($key, $crop, imagesx($image), imagesy($image), $source['has_original']);
    } else {
        image_source_save($image, $crop, $key, false);
    }
    $select = $pdo->prepare(travel_places_select($pdo) . ' WHERE p.id = :id AND p.user_id = :user');
    $select->execute(['id' => $target['id'], 'user' => (int) get_me()['id']]);
    json_out([
        'ok' => true,
        'has_original' => $source['has_original'],
        'place' => travel_place_payload($select->fetch()),
    ]);
}

/** A visit's photo is saved through save_travel_place; this adds its private original. */
function upload_travel_photo_source_action(): void
{
    require_post();
    $me = get_me();
    $pdo = db();
    require_travel_places_schema($pdo);
    $userId = (int) $me['id'];
    $id = filter_var($_POST['id'] ?? null, FILTER_VALIDATE_INT);
    if (!$id || $id < 1) {
        json_out(['ok' => false, 'error' => 'Invalid visit.'], 400);
    }
    $stmt = $pdo->prepare('SELECT id FROM ' . table_name('travel_places') . ' WHERE id = :id AND user_id = :user');
    $stmt->execute(['id' => $id, 'user' => $userId]);
    if (!$stmt->fetchColumn()) {
        json_out(['ok' => false, 'error' => 'Visit not found.'], 404);
    }
    enforce_rate_limit($pdo, 'travel_photo_write_user', (string) $userId, 15, 900);
    enforce_rate_limit($pdo, 'upload_user', (string) $userId, RATE_LIMIT_UPLOAD_USER_MAX, RATE_LIMIT_UPLOAD_WINDOW_SEC);
    $source = image_source_from_request('travel', TRIP_IMAGES_MAX_BYTES);
    if ($source === null) {
        json_out(['ok' => false, 'error' => 'Missing photo.'], 400);
    }
    enforce_upload_daily_quota($pdo, 'user', $userId, $source['size'], UPLOAD_USER_MAX_FILES_PER_DAY, UPLOAD_USER_MAX_BYTES_PER_DAY);
    json_out([
        'ok' => true,
        'has_crop_source' => image_source_save($source['image'], $source['crop'], image_source_key('travel', (string) $id)),
    ]);
}
