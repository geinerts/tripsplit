<?php
declare(strict_types=1);

/**
 * Private uncropped sources for images whose crop can be edited later. They live
 * outside the web root, have no public URL and never appear in shared payloads.
 * See docs/api/image-crop-editing.md.
 */

const IMAGE_SOURCE_MAX_EDGE = 2048;
const IMAGE_SOURCE_MAX_PIXELS = 30_000_000;
const IMAGE_SOURCE_WEBP_QUALITY = 86;
const IMAGE_CROP_MIN_WIDTH = 320;
const IMAGE_CROP_RATIO_TOLERANCE = 0.01;

function image_crop_spec(string $kind): array
{
    return match ($kind) {
        'trip' => ['ratio' => 16 / 9, 'max_edge' => 2048],
        'avatar' => ['ratio' => 1.0, 'max_edge' => 1024],
        'travel' => ['ratio' => 16 / 9, 'max_edge' => 768],
        default => json_out(['ok' => false, 'error' => 'Invalid image kind.'], 400),
    };
}

function image_originals_dir(): ?string
{
    $dir = defined('IMAGE_ORIGINALS_DIR') ? trim((string) IMAGE_ORIGINALS_DIR) : '';
    if ($dir === '') {
        return null;
    }
    if (!is_dir($dir) && !@mkdir($dir, 0750, true) && !is_dir($dir)) {
        return null;
    }
    return is_writable($dir) ? rtrim($dir, '/\\') : null;
}

/** Key for a displayed file, such as uploads/trips/name.webp, or for a visit id. */
function image_source_key(string $kind, string $identifier): string
{
    $stem = $kind === 'travel' ? $identifier : pathinfo($identifier, PATHINFO_FILENAME);
    if (!preg_match('/^[A-Za-z0-9_-]+$/D', $stem)) {
        throw new InvalidArgumentException('Invalid image source identifier.');
    }
    return $kind . '/' . $stem;
}

function image_source_paths(string $key): ?array
{
    $dir = image_originals_dir();
    if ($dir === null) {
        return null;
    }
    $base = $dir . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $key);
    return ['image' => $base . '.webp', 'meta' => $base . '.json'];
}

function image_crop_parse(mixed $raw): array
{
    if (is_string($raw)) {
        $raw = json_decode($raw, true);
    }
    if (!is_array($raw)) {
        json_out(['ok' => false, 'error' => 'Invalid crop.'], 400);
    }
    $crop = [];
    foreach (['x', 'y', 'width', 'height'] as $field) {
        $value = $raw[$field] ?? null;
        if ((!is_int($value) && !is_float($value)) || !is_finite((float) $value)) {
            json_out(['ok' => false, 'error' => 'Invalid crop.'], 400);
        }
        $crop[$field] = (float) $value;
    }
    return $crop;
}

/** Validates a crop of fractions against an image and returns it in whole pixels. */
function image_crop_pixels(array $crop, int $width, int $height, float $ratio): array
{
    $edge = 0.0005;
    if ($width < 1 || $height < 1 || $crop['x'] < 0 || $crop['y'] < 0
        || $crop['width'] <= 0 || $crop['height'] <= 0
        || $crop['x'] + $crop['width'] > 1 + $edge || $crop['y'] + $crop['height'] > 1 + $edge) {
        json_out(['ok' => false, 'error' => 'Crop is outside the image.'], 400);
    }
    $cropWidth = $crop['width'] * $width;
    $cropHeight = $crop['height'] * $height;
    if (abs($cropWidth / $cropHeight / $ratio - 1) > IMAGE_CROP_RATIO_TOLERANCE) {
        json_out(['ok' => false, 'error' => 'Crop has the wrong shape.'], 400);
    }
    // A small saved image can still be used whole.
    if (round($cropWidth) < min(IMAGE_CROP_MIN_WIDTH, $width)) {
        json_out(['ok' => false, 'error' => 'Crop is too small.'], 400);
    }
    $x = (int) round($crop['x'] * $width);
    $y = (int) round($crop['y'] * $height);
    return [
        'x' => $x,
        'y' => $y,
        'width' => max(1, min((int) round($cropWidth), $width - $x)),
        'height' => max(1, min((int) round($cropHeight), $height - $y)),
    ];
}

/** The largest centred crop of the required shape, for an image without a saved crop. */
function image_crop_default(int $width, int $height, float $ratio): array
{
    $cropWidth = min($width, $height * $ratio);
    $cropHeight = $cropWidth / $ratio;
    return [
        'x' => ($width - $cropWidth) / 2 / $width,
        'y' => ($height - $cropHeight) / 2 / $height,
        'width' => $cropWidth / $width,
        'height' => $cropHeight / $height,
    ];
}

function image_resize(GdImage $image, int $maxEdge): GdImage
{
    $width = imagesx($image);
    $height = imagesy($image);
    $scale = min(1.0, $maxEdge / max($width, $height));
    $canvas = imagecreatetruecolor(max(1, (int) round($width * $scale)), max(1, (int) round($height * $scale)));
    imagealphablending($canvas, false);
    imagesavealpha($canvas, true);
    imagecopyresampled($canvas, $image, 0, 0, 0, 0, imagesx($canvas), imagesy($canvas), $width, $height);
    return $canvas;
}

function image_crop_render(GdImage $source, array $pixels, int $maxEdge): GdImage
{
    $canvas = imagecreatetruecolor($pixels['width'], $pixels['height']);
    imagealphablending($canvas, false);
    imagesavealpha($canvas, true);
    imagecopy($canvas, $source, 0, 0, $pixels['x'], $pixels['y'], $pixels['width'], $pixels['height']);
    return image_resize($canvas, $maxEdge);
}

/** Decodes an uploaded source and checks its crop before anything is stored. */
function image_source_prepare(string $file, mixed $rawCrop, string $kind): array
{
    $size = @getimagesize($file);
    if (!$size || $size[0] < 1 || $size[1] < 1 || $size[0] * $size[1] > IMAGE_SOURCE_MAX_PIXELS
        || !in_array($size['mime'], ['image/jpeg', 'image/png', 'image/webp'], true)) {
        json_out(['ok' => false, 'error' => 'Choose a smaller JPG, PNG or WebP image.'], 400);
    }
    $crop = image_crop_parse($rawCrop);
    image_crop_pixels($crop, $size[0], $size[1], image_crop_spec($kind)['ratio']);
    $image = decode_image_from_upload($file);
    if (!$image instanceof GdImage) {
        json_out(['ok' => false, 'error' => 'Invalid photo.'], 400);
    }
    return ['image' => $image, 'crop' => $crop];
}

/** Reads the optional source_image and crop fields of a multipart upload. */
function image_source_from_request(string $kind, int $maxBytes): ?array
{
    if (!isset($_FILES['source_image']) || !is_array($_FILES['source_image'])) {
        return null;
    }
    $validated = validate_uploaded_image_file($_FILES['source_image'], $maxBytes, 'Photo is too large.');
    $prepared = image_source_prepare((string) $validated['tmp'], $_POST['crop'] ?? null, $kind);
    $prepared['size'] = (int) $validated['size'];
    return $prepared;
}

/** Stores a re-encoded source without metadata. Returns false when storage is unavailable. */
function image_source_save(GdImage $image, array $crop, string $key, bool $hasOriginal = true): bool
{
    $paths = image_source_paths($key);
    if ($paths === null) {
        return false;
    }
    $dir = dirname($paths['image']);
    if (!is_dir($dir) && !@mkdir($dir, 0750, true) && !is_dir($dir)) {
        return false;
    }
    $scaled = image_resize($image, IMAGE_SOURCE_MAX_EDGE);
    $temporary = $paths['image'] . '.' . bin2hex(random_bytes(6)) . '.tmp';
    if (!@imagewebp($scaled, $temporary, IMAGE_SOURCE_WEBP_QUALITY) || !is_file($temporary)) {
        @unlink($temporary);
        return false;
    }
    @chmod($temporary, 0640);
    if (!@rename($temporary, $paths['image'])) {
        @unlink($temporary);
        return false;
    }
    return image_source_write_meta($key, $crop, imagesx($scaled), imagesy($scaled), $hasOriginal);
}

function image_source_write_meta(string $key, array $crop, int $width, int $height, bool $hasOriginal): bool
{
    $paths = image_source_paths($key);
    if ($paths === null) {
        return false;
    }
    $json = json_encode([
        'width' => $width,
        'height' => $height,
        'crop' => $crop,
        'has_original' => $hasOriginal,
    ], JSON_THROW_ON_ERROR);
    if (@file_put_contents($paths['meta'], $json, LOCK_EX) === false) {
        return false;
    }
    @chmod($paths['meta'], 0640);
    return true;
}

/** @return array{bytes: string, width: int, height: int, crop: array, has_original: bool}|null */
function image_source_read(string $key): ?array
{
    $paths = image_source_paths($key);
    if ($paths === null || !is_file($paths['image']) || !is_file($paths['meta'])) {
        return null;
    }
    $bytes = @file_get_contents($paths['image']);
    $meta = json_decode((string) @file_get_contents($paths['meta']), true);
    if (!is_string($bytes) || $bytes === '' || !is_array($meta) || !is_array($meta['crop'] ?? null)) {
        return null;
    }
    return [
        'bytes' => $bytes,
        'width' => (int) ($meta['width'] ?? 0),
        'height' => (int) ($meta['height'] ?? 0),
        'crop' => $meta['crop'],
        'has_original' => ($meta['has_original'] ?? false) === true,
    ];
}

function image_source_delete(string $key): void
{
    $paths = image_source_paths($key);
    if ($paths === null) {
        return;
    }
    foreach ($paths as $path) {
        if (is_file($path)) {
            @unlink($path);
        }
    }
}

/** Removes the source that belongs to a displayed file, when there is one. */
function image_source_delete_for_file(string $kind, ?string $relativePath): void
{
    if ($relativePath === null || trim($relativePath) === '') {
        return;
    }
    try {
        image_source_delete(image_source_key($kind, trim($relativePath)));
    } catch (InvalidArgumentException) {
        // Legacy names cannot have a source.
    }
}

/**
 * Keys of originals whose image no longer exists. New files are left alone, because a
 * cover is uploaded a moment before it is attached to its trip.
 *
 * @return list<string>
 */
function image_originals_orphans(PDO $pdo, int $minimumAgeSeconds = 604800): array
{
    $dir = image_originals_dir();
    if ($dir === null) {
        return [];
    }
    $checks = [
        'trip' => ['SELECT 1 FROM ' . table_name('trips') . ' WHERE image_path = :value LIMIT 1',
            static fn (string $stem): string => TRIP_IMAGES_REL_DIR . '/' . $stem . '.webp'],
        'avatar' => ['SELECT 1 FROM ' . table_name('users') . ' WHERE avatar_path = :value LIMIT 1',
            static fn (string $stem): string => AVATARS_REL_DIR . '/' . $stem . '.webp'],
        'travel' => ['SELECT 1 FROM ' . table_name('travel_places') . ' WHERE id = :value AND photo_data IS NOT NULL LIMIT 1',
            static fn (string $stem): string => $stem],
    ];
    $orphans = [];
    foreach ($checks as $kind => [$query, $value]) {
        $statement = $pdo->prepare($query);
        foreach (glob($dir . '/' . $kind . '/*.json') ?: [] as $meta) {
            if (time() - (int) filemtime($meta) < $minimumAgeSeconds) {
                continue;
            }
            $stem = pathinfo($meta, PATHINFO_FILENAME);
            $statement->execute(['value' => $value($stem)]);
            if (!$statement->fetchColumn()) {
                $orphans[] = $kind . '/' . $stem;
            }
            $statement->closeCursor();
        }
    }
    return $orphans;
}
