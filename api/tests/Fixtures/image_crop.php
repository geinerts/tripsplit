<?php
declare(strict_types=1);
// CLI only: in-memory database and synthetic images in unique temporary directories.
require __DIR__ . '/trip_invitations.php';

$withStorage = ($argv[1] ?? '') !== 'no_storage';
$root = dirname(__DIR__, 3);
$run = bin2hex(random_bytes(8));
$originals = sys_get_temp_dir() . '/splyto-originals-' . $run;
if ($withStorage) {
    define('IMAGE_ORIGINALS_DIR', $originals);
}
define('TRIP_IMAGES_REL_DIR', 'output/tests/crop-trips-' . $run);
define('AVATARS_REL_DIR', 'output/tests/crop-avatars-' . $run);
define('UPLOAD_IMAGE_WEBP_QUALITY', 84);
define('UPLOAD_IMAGE_THUMB_MAX_SIDE', 420);
define('UPLOAD_IMAGE_THUMB_WEBP_QUALITY', 76);
define('RATE_LIMIT_UPLOAD_USER_MAX', 100);
define('RATE_LIMIT_UPLOAD_WINDOW_SEC', 60);
define('UPLOAD_USER_MAX_FILES_PER_DAY', 100);
define('UPLOAD_USER_MAX_BYTES_PER_DAY', 100_000_000);
function auth_access_token_secret(): string { return 'synthetic-crop-test-key'; }
function build_me_payload(array $row, PDO $pdo): array { return ['id' => (int) $row['id'], 'avatar' => $row['avatar_path']]; }
function enforce_upload_daily_quota(...$args): void {}

require __DIR__ . '/../../config/config_uploads.php';
require_once __DIR__ . '/../../lib/helpers/helper_trip_image_ownership.php';
require __DIR__ . '/../../lib/actions/travel_places_actions.php';
require __DIR__ . '/../../lib/actions/image_crop_actions.php';

$pdo = invitation_test_setup(false);
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN image_path TEXT');
$pdo->exec('CREATE TABLE trip_travel_places (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL,
 place_key TEXT NOT NULL, city TEXT, region TEXT, country TEXT, country_code TEXT, latitude REAL, longitude REAL,
 visited_on TEXT, trip_id INTEGER, source_key TEXT DEFAULT "manual", trip_name TEXT, title TEXT DEFAULT "",
 photo_data BLOB, photo_source TEXT, photo_version INTEGER DEFAULT 0, UNIQUE(user_id,place_key,visited_on,source_key))');
$pdo->exec('INSERT INTO trip_trips(id,name,created_by,currency_code) VALUES (1,"Lisbon",1,"EUR"),(2,"Shared",1,"EUR")');
$pdo->exec("INSERT INTO trip_trip_members VALUES (1,1,'owner'),(1,2,'member'),(2,1,'owner')");

/** Left half red, right half blue, so a crop can be checked by colour. */
function crop_test_image(int $width = 1600, int $height = 1200): GdImage {
    $image = imagecreatetruecolor($width, $height);
    imagefilledrectangle($image, 0, 0, (int) ($width / 2), $height, imagecolorallocate($image, 255, 0, 0));
    imagefilledrectangle($image, (int) ($width / 2) + 1, 0, $width, $height, imagecolorallocate($image, 0, 0, 255));
    return $image;
}
function crop_test_webp(string $relative, int $width = 1600, int $height = 1200): void {
    $absolute = upload_relative_path_to_abs($relative);
    if (!is_dir(dirname($absolute))) mkdir(dirname($absolute), 0700, true);
    imagewebp(crop_test_image($width, $height), $absolute, 90);
    generate_upload_thumbnail($relative);
}
function crop_test_centre_is_blue(string $bytes): bool {
    $image = imagecreatefromstring($bytes);
    $rgb = imagecolorsforindex($image, imagecolorat($image, (int) (imagesx($image) / 2), (int) (imagesy($image) / 2)));
    return $rgb['blue'] > 200 && $rgb['red'] < 60;
}
/** A JPEG carrying an EXIF-style segment that must not survive. */
function crop_test_jpeg_with_metadata(string $file): void {
    ob_start();
    imagejpeg(crop_test_image(), null, 90);
    $jpeg = (string) ob_get_clean();
    $payload = "Exif\0\0GPSSECRET";
    file_put_contents($file, substr($jpeg, 0, 2) . "\xFF\xE1" . pack('n', strlen($payload) + 2) . $payload . substr($jpeg, 2));
}
function crop_call(string $handler, int $user, array $body = [], array $query = [], ?int $trip = null): array {
    $_GET = $query;
    unset($_SERVER['HTTP_X_TRIP_ID']);
    if ($trip !== null) $_SERVER['HTTP_X_TRIP_ID'] = (string) $trip;
    return invitation_call($handler, $user, $body);
}

// 16:9 frame over the right half of a 4:3 image.
$rightHalf = ['x' => 0.5, 'y' => 0.2, 'width' => 0.5, 'height' => 0.5 * (1600 / 1200) * (9 / 16)];
$r = ['storage' => $withStorage];

// Trip cover without an original.
$legacy = TRIP_IMAGES_REL_DIR . '/legacy.webp';
crop_test_webp($legacy);
$pdo->prepare('UPDATE trip_trips SET image_path=:path WHERE id=1')->execute(['path' => $legacy]);
$r['member_source'] = crop_call('image_crop_source_action', 2, [], ['kind' => 'trip'], 1)['status'];
$r['outsider_source'] = crop_call('image_crop_source_action', 3, [], ['kind' => 'trip'], 1)['status'];
$r['invalid_kind'] = crop_call('image_crop_source_action', 1, [], ['kind' => 'expense'])['status'];
$source = crop_call('image_crop_source_action', 1, [], ['kind' => 'trip'], 1);
$r['legacy_source'] = ['status' => $source['status'], 'has_original' => $source['body']['has_original'],
    'revision_ok' => $source['body']['revision'] === $legacy, 'crop' => $source['body']['crop']];

// Rejected requests change nothing.
$update = ['kind' => 'trip', 'crop' => $rightHalf, 'revision' => $legacy];
$r['member_update'] = crop_call('update_image_crop_action', 2, $update, [], 1)['status'];
foreach ([['x' => -0.1], ['x' => 0.9], ['width' => 0.2], ['height' => 0.1], ['x' => 'a'], ['width' => INF]] as $bad) {
    $r['bad_crops'][] = crop_call('update_image_crop_action', 1, ['crop' => array_replace($rightHalf, $bad)] + $update, [], 1)['status'];
}
$r['bad_tiny'] = crop_call('update_image_crop_action', 1, ['crop' => ['x' => 0, 'y' => 0, 'width' => 0.1, 'height' => 0.1 * (1600 / 1200) * (9 / 16)]] + $update, [], 1)['status'];
$stale = crop_call('update_image_crop_action', 1, ['revision' => 'uploads/trips/other.webp'] + $update, [], 1);
$r['stale'] = ['status' => $stale['status'], 'code' => $stale['body']['code'] ?? null];
$r['unchanged_after_rejects'] = $pdo->query('SELECT image_path FROM trip_trips WHERE id=1')->fetchColumn() === $legacy;

// First edit of a cover without an original.
$saved = crop_call('update_image_crop_action', 1, $update, [], 1);
$path = (string) ($saved['body']['image_path'] ?? '');
$r['legacy_update'] = [
    'status' => $saved['status'],
    'new_path' => $path !== $legacy && $path !== '',
    'row_updated' => $pdo->query('SELECT image_path FROM trip_trips WHERE id=1')->fetchColumn() === $path,
    'old_removed' => !is_file(upload_relative_path_to_abs($legacy)),
    'thumb_exists' => is_file(upload_relative_path_to_abs(upload_thumb_relative_path($path))),
    'crop_applied' => crop_test_centre_is_blue((string) file_get_contents(upload_relative_path_to_abs($path))),
    'has_original' => $saved['body']['has_original'],
];
$r['no_source_in_response'] = !array_key_exists('image_base64', $saved['body'])
    && !str_contains(json_encode($saved['body'], JSON_THROW_ON_ERROR), 'originals');
$reopened = crop_call('image_crop_source_action', 1, [], ['kind' => 'trip'], 1);
$r['legacy_reopened'] = ['has_original' => $reopened['body']['has_original'], 'crop' => $reopened['body']['crop']];

// An uploaded original keeps the whole image, its crop, and no metadata.
$file = tempnam(sys_get_temp_dir(), 'crop');
crop_test_jpeg_with_metadata($file);
$r['metadata_present_in_upload'] = str_contains((string) file_get_contents($file), 'GPSSECRET');
$prepared = image_source_prepare($file, json_encode($rightHalf, JSON_THROW_ON_ERROR), 'trip');
$withOriginal = TRIP_IMAGES_REL_DIR . '/original.webp';
crop_test_webp($withOriginal, 800, 450);
$pdo->prepare('UPDATE trip_trips SET image_path=:path WHERE id=1')->execute(['path' => $withOriginal]);
$key = image_source_key('trip', $withOriginal);
$r['source_saved'] = image_source_save($prepared['image'], $prepared['crop'], $key);
if (!$withStorage) {
    // Without storage the cover remains editable from the displayed file; nothing else differs.
    @unlink($file);
    array_map('unlink', glob($root . '/' . TRIP_IMAGES_REL_DIR . '/*') ?: []);
    @rmdir($root . '/' . TRIP_IMAGES_REL_DIR);
    echo json_encode($r, JSON_THROW_ON_ERROR);
    exit(0);
}
$source = crop_call('image_crop_source_action', 1, [], ['kind' => 'trip'], 1);
$r['original_source'] = ['has_original' => $source['body']['has_original'], 'width' => $source['body']['width'],
    'height' => $source['body']['height'], 'crop' => $source['body']['crop']];
$paths = image_source_paths($key);
$r['metadata_removed'] = $paths !== null && !str_contains((string) file_get_contents($paths['image']), 'GPSSECRET');
$r['source_mode'] = $paths !== null ? substr(sprintf('%o', fileperms($paths['image'])), -3) : null;

// Moving the crop works from the original, not the smaller displayed file.
$left = ['x' => 0.0, 'y' => 0.1, 'width' => 0.5, 'height' => $rightHalf['height']];
$saved = crop_call('update_image_crop_action', 1, ['kind' => 'trip', 'crop' => $left, 'revision' => $withOriginal], [], 1);
$next = (string) ($saved['body']['image_path'] ?? '');
$reopened = crop_call('image_crop_source_action', 1, [], ['kind' => 'trip'], 1);
$size = @getimagesize((string) upload_relative_path_to_abs($next));
$r['original_update'] = [
    'status' => $saved['status'],
    'has_original' => $saved['body']['has_original'] ?? null,
    'width' => $size[0] ?? 0,
    'saved_crop' => $reopened['body']['crop'] ?? null,
    'old_source_removed' => $paths !== null && !is_file($paths['image']),
    'old_file_removed' => !is_file(upload_relative_path_to_abs($withOriginal)),
];

// A path shared with another trip keeps its file and source until nothing refers to it.
$shared = TRIP_IMAGES_REL_DIR . '/shared.webp';
crop_test_webp($shared);
$pdo->prepare('UPDATE trip_trips SET image_path=:path WHERE id IN (1,2)')->execute(['path' => $shared]);
$sharedKey = image_source_key('trip', $shared);
image_source_save(crop_test_image(), $rightHalf, $sharedKey);
$saved = crop_call('update_image_crop_action', 1, ['kind' => 'trip', 'crop' => $left, 'revision' => $shared], [], 1);
$r['shared'] = [
    'status' => $saved['status'],
    'other_trip_kept' => $pdo->query('SELECT image_path FROM trip_trips WHERE id=2')->fetchColumn() === $shared,
    'file_kept' => is_file(upload_relative_path_to_abs($shared)),
    'source_kept' => image_source_read($sharedKey) !== null,
];
delete_trip_image_file($shared);
$r['source_removed_with_file'] = image_source_read($sharedKey) === null;

// Profile photo.
$r['no_avatar'] = crop_call('image_crop_source_action', 1, [], ['kind' => 'avatar'])['status'];
$avatar = AVATARS_REL_DIR . '/me.webp';
crop_test_webp($avatar, 1200, 1200);
$pdo->prepare('UPDATE trip_users SET avatar_path=:path WHERE id=1')->execute(['path' => $avatar]);
$square = ['x' => 0.5, 'y' => 0.25, 'width' => 0.5, 'height' => 0.5];
$r['avatar_wrong_shape'] = crop_call('update_image_crop_action', 1, ['kind' => 'avatar', 'crop' => $rightHalf, 'revision' => $avatar])['status'];
$saved = crop_call('update_image_crop_action', 1, ['kind' => 'avatar', 'crop' => $square, 'revision' => $avatar]);
$nextAvatar = (string) ($saved['body']['avatar_path'] ?? '');
$avatarSize = @getimagesize((string) upload_relative_path_to_abs($nextAvatar));
$r['avatar'] = [
    'status' => $saved['status'],
    'width' => $avatarSize[0] ?? 0,
    'height' => $avatarSize[1] ?? 0,
    'me_updated' => ($saved['body']['me']['avatar'] ?? null) === $nextAvatar,
    'old_removed' => !is_file(upload_relative_path_to_abs($avatar)),
    'other_user_unchanged' => $pdo->query('SELECT avatar_path FROM trip_users WHERE id=2')->fetchColumn() === null,
];
$avatarKey = image_source_key('avatar', $nextAvatar);
$r['avatar_source_exists'] = image_source_read($avatarKey) !== null;
delete_avatar_file($nextAvatar);
$r['avatar_source_removed'] = image_source_read($avatarKey) === null;

// Visit photo.
ob_start();
imagewebp(crop_test_image(768, 432), null, 80);
$photo = (string) ob_get_clean();
$insert = $pdo->prepare('INSERT INTO trip_travel_places(user_id,place_key,city,region,country,country_code,latitude,longitude,
 visited_on,photo_data,photo_source,photo_version) VALUES (1,:key,"Lisbon","Lisbon","Portugal","PT",38.7,-9.1,"2026-10-01",:photo,"trip",1)');
$insert->bindValue(':key', 'visit-a');
$insert->bindValue(':photo', $photo, PDO::PARAM_LOB);
$insert->execute();
$visit = (int) $pdo->lastInsertId();
$r['visit_foreign'] = crop_call('image_crop_source_action', 2, [], ['kind' => 'travel', 'id' => $visit])['status'];
$r['visit_invalid'] = crop_call('image_crop_source_action', 1, [], ['kind' => 'travel', 'id' => 'x'])['status'];
$source = crop_call('image_crop_source_action', 1, [], ['kind' => 'travel', 'id' => $visit]);
$r['visit_source'] = ['status' => $source['status'], 'has_original' => $source['body']['has_original'], 'revision' => $source['body']['revision']];
$zoom = ['x' => 0.5, 'y' => 0.25, 'width' => 0.5, 'height' => 0.5];
$r['visit_foreign_update'] = crop_call('update_image_crop_action', 2, ['kind' => 'travel', 'id' => $visit, 'crop' => $zoom, 'revision' => 'v1'])['status'];
$r['visit_stale'] = crop_call('update_image_crop_action', 1, ['kind' => 'travel', 'id' => $visit, 'crop' => $zoom, 'revision' => 'v0'])['status'];
$saved = crop_call('update_image_crop_action', 1, ['kind' => 'travel', 'id' => $visit, 'crop' => $zoom, 'revision' => 'v1']);
$row = $pdo->query('SELECT photo_data, photo_version, photo_source FROM trip_travel_places WHERE id=' . $visit)->fetch();
$visitImage = imagecreatefromstring((string) $row['photo_data']);
$r['visit_update'] = [
    'status' => $saved['status'],
    'version' => (int) $row['photo_version'],
    'source_label_kept' => $row['photo_source'],
    'width' => imagesx($visitImage),
    'crop_applied' => crop_test_centre_is_blue((string) $row['photo_data']),
    'has_original' => $saved['body']['has_original'],
    'place_returned' => (int) ($saved['body']['place']['id'] ?? 0) === $visit,
];
$visitKey = image_source_key('travel', (string) $visit);
$r['visit_source_after_edit'] = image_source_read($visitKey)['has_original'] ?? null;

// Saving the same visit again never touches its source; replacing the photo removes it.
$place = ['city' => 'Lisbon', 'region' => 'Lisbon', 'country' => 'Portugal', 'country_code' => 'PT',
    'latitude' => 38.7223, 'longitude' => -9.1393, 'visited_on' => '2026-10-05'];
$first = invitation_call('save_travel_place_action', 1, $place);
$firstId = (int) $first['body']['place']['id'];
$firstKey = image_source_key('travel', (string) $firstId);
image_source_save(crop_test_image(), $rightHalf, $firstKey);
invitation_call('save_travel_place_action', 1, $place + ['title' => 'x']);
$r['repeat_save_keeps_source'] = image_source_read($firstKey) !== null;
invitation_call('save_travel_place_action', 1, ['id' => $firstId, 'remove_photo' => true] + $place);
$r['removed_photo_removes_source'] = image_source_read($firstKey) === null;

image_source_save(crop_test_image(), $rightHalf, $firstKey);
invitation_call('delete_travel_place_action', 1, ['id' => $firstId]);
$r['deleted_visit_removes_source'] = image_source_read($firstKey) === null;
delete_user_travel_places($pdo, 1);
$r['deleted_account_removes_source'] = image_source_read($visitKey) === null;

// Weekly cleanup removes only old originals that nothing refers to.
$orphanKey = image_source_key('trip', TRIP_IMAGES_REL_DIR . '/never-attached.webp');
$recentKey = image_source_key('trip', TRIP_IMAGES_REL_DIR . '/just-uploaded.webp');
$usedPath = (string) $pdo->query('SELECT image_path FROM trip_trips WHERE id=1')->fetchColumn();
$usedKey = image_source_key('trip', $usedPath);
image_source_save(crop_test_image(), $rightHalf, $orphanKey);
image_source_save(crop_test_image(), $rightHalf, $recentKey);
image_source_save(crop_test_image(), $rightHalf, $usedKey);
$old = time() - 8 * 86400;
touch(image_source_paths($orphanKey)['meta'], $old);
touch(image_source_paths($usedKey)['meta'], $old);
$r['orphans'] = image_originals_orphans($pdo);
$r['orphan_expected'] = $orphanKey;
foreach ([$orphanKey, $recentKey, $usedKey] as $cleanupKey) image_source_delete($cleanupKey);

// Only the original bytes are kept, and only under the configured directory.
$r['invalid_key_rejected'] = false;
try { image_source_key('trip', '../../escape/.webp'); } catch (InvalidArgumentException) { $r['invalid_key_rejected'] = true; }

@unlink($file);
foreach ([TRIP_IMAGES_REL_DIR, AVATARS_REL_DIR] as $dir) {
    array_map('unlink', glob($root . '/' . $dir . '/*') ?: []);
    @rmdir($root . '/' . $dir);
}
if ($withStorage) {
    $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($originals, FilesystemIterator::SKIP_DOTS), RecursiveIteratorIterator::CHILD_FIRST);
    $r['leftover_files'] = 0;
    foreach ($iterator as $item) {
        if ($item->isFile()) { $r['leftover_files']++; unlink($item->getPathname()); } else { rmdir($item->getPathname()); }
    }
    rmdir($originals);
}
echo json_encode($r, JSON_THROW_ON_ERROR);
