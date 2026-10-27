<?php
declare(strict_types=1);

function trip_image_owned_upload_path(string $path, int $tripId, int $userId): string
{
    $path = normalize_trip_image_path($path, false);
    if ($tripId <= 0 || $userId <= 0 || pathinfo($path, PATHINFO_EXTENSION) !== 'webp') {
        throw new InvalidArgumentException('Invalid trip image owner or format.');
    }
    $stem = substr($path, 0, -5);
    $signature = hash_hmac('sha256', 'trip-image-upload|' . $tripId . '|' . $userId . '|' . $stem, auth_access_token_secret());
    return $stem . '_owner_' . $signature . '.webp';
}

function assert_trip_image_attachment_owned(string $path, int $tripId, int $userId, string $existingPath): void
{
    // Preserve existing covers, including legacy uploads and uploads before key rotation.
    if ($path === '' || ($existingPath !== '' && $path === $existingPath)) {
        return;
    }
    if (preg_match('/^(.*)_owner_([a-f0-9]{64})\.webp$/D', $path, $match)) {
        $expected = trip_image_owned_upload_path($match[1] . '.webp', $tripId, $userId);
        $absolute = upload_relative_path_to_abs($path);
        if (hash_equals($expected, $path) && $absolute !== null && is_file($absolute)) {
            return;
        }
    }
    json_out(['ok' => false, 'error' => 'Please upload this image again for this trip.'], 403);
}

function bind_stored_trip_image_to_owner(array $stored, int $tripId, int $userId): string
{
    $path = (string) $stored['path'];
    $ownedPath = trip_image_owned_upload_path($path, $tripId, $userId);
    $source = upload_relative_path_to_abs($path);
    $target = upload_relative_path_to_abs($ownedPath);
    if ($source === null || $target === null || !rename($source, $target)) {
        delete_trip_image_file($path);
        throw new RuntimeException('Could not secure trip image upload.');
    }
    $thumbPath = $stored['thumb_path'] ?? null;
    if (is_string($thumbPath) && $thumbPath !== '') {
        $thumbSource = upload_relative_path_to_abs($thumbPath);
        $thumbTargetPath = upload_thumb_relative_path($ownedPath);
        $thumbTarget = $thumbTargetPath !== null ? upload_relative_path_to_abs($thumbTargetPath) : null;
        if ($thumbSource === null || $thumbTarget === null || !rename($thumbSource, $thumbTarget)) {
            delete_trip_image_file($path);
            delete_trip_image_file($ownedPath);
            throw new RuntimeException('Could not secure trip image thumbnail.');
        }
    }
    return $ownedPath;
}

function delete_unreferenced_trip_image(PDO $pdo, string $path): void
{
    if ($path === '') {
        return;
    }
    $stmt = $pdo->prepare('SELECT 1 FROM ' . table_name('trips') . ' WHERE image_path = :path LIMIT 1');
    $stmt->execute(['path' => $path]);
    if (!$stmt->fetchColumn()) {
        delete_trip_image_file($path);
    }
}
