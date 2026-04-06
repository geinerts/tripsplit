<?php
declare(strict_types=1);

function receipts_dir_abs(): string
{
    return upload_dir_abs(RECEIPTS_REL_DIR);
}

function avatars_dir_abs(): string
{
    return upload_dir_abs(AVATARS_REL_DIR);
}

function trip_images_dir_abs(): string
{
    return upload_dir_abs(TRIP_IMAGES_REL_DIR);
}

function feedback_dir_abs(): string
{
    return upload_dir_abs(FEEDBACK_REL_DIR);
}

function upload_dir_abs(string $relativeDir): string
{
    $clean = sanitize_upload_relative_dir($relativeDir);
    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $clean);
}

function sanitize_upload_relative_dir(string $relativeDir): string
{
    $clean = trim(str_replace('\\', '/', $relativeDir), '/');
    if (
        $clean === '' ||
        strpos($clean, '..') !== false ||
        !preg_match('#^[A-Za-z0-9._/-]+$#', $clean)
    ) {
        throw new RuntimeException('Invalid upload relative directory.');
    }
    return $clean;
}

function class_upload_file_abs(): string
{
    $rel = trim(str_replace('\\', '/', CLASS_UPLOAD_REL_PATH));
    $rel = ltrim($rel, '/');
    if ($rel === '' || strpos($rel, '..') !== false) {
        return '';
    }

    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $rel);
}

function load_class_upload_library(): bool
{
    static $loaded = null;
    if ($loaded !== null) {
        return $loaded;
    }

    $candidates = [];
    $configured = class_upload_file_abs();
    if ($configured !== '') {
        $candidates[] = $configured;
    }
    $candidates[] = project_root_abs() . DIRECTORY_SEPARATOR . 'api' . DIRECTORY_SEPARATOR . 'lib' . DIRECTORY_SEPARATOR . 'verot' . DIRECTORY_SEPARATOR . 'class.upload.php';
    $candidates[] = project_root_abs() . DIRECTORY_SEPARATOR . 'api' . DIRECTORY_SEPARATOR . 'lib' . DIRECTORY_SEPARATOR . 'class.upload.php';

    foreach ($candidates as $path) {
        if (is_file($path) && is_readable($path)) {
            require_once $path;
            break;
        }
    }

    $loaded = class_exists('upload', false) ||
        class_exists('Upload', false) ||
        class_exists('Verot\\Upload\\Upload', false);
    return $loaded;
}

function class_upload_instantiate_handle(array $uploadLikeArray)
{
    if (class_exists('upload', false)) {
        return new upload($uploadLikeArray);
    }
    if (class_exists('Upload', false)) {
        return new Upload($uploadLikeArray);
    }
    if (class_exists('Verot\\Upload\\Upload', false)) {
        $className = 'Verot\\Upload\\Upload';
        return new $className($uploadLikeArray);
    }
    return null;
}

function mime_to_extension(string $mime): string
{
    $map = [
        'image/jpeg' => 'jpg',
        'image/jpg' => 'jpg',
        'image/png' => 'png',
        'image/webp' => 'webp',
        'image/heic' => 'heic',
        'image/heif' => 'heif',
    ];
    return $map[strtolower(trim($mime))] ?? 'jpg';
}

function project_root_abs(): string
{
    static $root = null;
    if (is_string($root) && $root !== '') {
        return $root;
    }

    $candidates = [
        realpath(__DIR__ . '/../..'),
        realpath(__DIR__ . '/..'),
    ];

    foreach ($candidates as $candidate) {
        if (!is_string($candidate) || $candidate === '') {
            continue;
        }
        $apiEntry = $candidate . DIRECTORY_SEPARATOR . 'api' . DIRECTORY_SEPARATOR . 'api.php';
        if (is_file($apiEntry)) {
            $root = $candidate;
            return $root;
        }
    }

    $fallback = realpath(__DIR__ . '/../..');
    if ($fallback === false) {
        throw new RuntimeException('Cannot resolve project root directory.');
    }
    $root = $fallback;
    return $root;
}

function api_error_log_path_abs(): string
{
    $relative = trim(str_replace('\\', '/', (string) API_ERROR_LOG_REL_PATH));
    if ($relative === '' || strpos($relative, '..') !== false) {
        $relative = 'logs/api-error.log';
    }
    $relative = ltrim($relative, '/');
    if ($relative === '') {
        $relative = 'logs/api-error.log';
    }

    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
}

function sanitize_request_id(string $raw): string
{
    $value = trim($raw);
    if ($value === '') {
        return '';
    }
    if (strlen($value) > 80) {
        $value = substr($value, 0, 80);
    }
    if (!preg_match('/^[A-Za-z0-9._:-]{8,80}$/', $value)) {
        return '';
    }
    return $value;
}

function generate_request_id(): string
{
    try {
        return bin2hex(random_bytes(12));
    } catch (Throwable $error) {
        $fallback = uniqid('req_', true);
        return preg_replace('/[^A-Za-z0-9._:-]/', '', $fallback) ?: 'req_fallback';
    }
}

function bootstrap_request_id(): string
{
    $candidate = sanitize_request_id((string) ($_SERVER['HTTP_X_REQUEST_ID'] ?? ''));
    if ($candidate === '') {
        $candidate = sanitize_request_id((string) ($_SERVER['HTTP_X_CLIENT_REQUEST_ID'] ?? ''));
    }
    if ($candidate === '') {
        $candidate = generate_request_id();
    }
    $GLOBALS['trip_request_id'] = $candidate;
    $_SERVER['HTTP_X_REQUEST_ID'] = $candidate;
    return $candidate;
}

function request_id(): string
{
    $current = $GLOBALS['trip_request_id'] ?? null;
    if (is_string($current) && $current !== '') {
        return $current;
    }
    return bootstrap_request_id();
}

function ensure_receipts_dir(): void
{
    ensure_upload_dir_abs(receipts_dir_abs(), 'Unable to create receipts directory.');
}

function ensure_avatars_dir(): void
{
    ensure_upload_dir_abs(avatars_dir_abs(), 'Unable to create avatars directory.');
}

function ensure_trip_images_dir(): void
{
    ensure_upload_dir_abs(trip_images_dir_abs(), 'Unable to create trip images directory.');
}

function ensure_feedback_dir(): void
{
    ensure_upload_dir_abs(feedback_dir_abs(), 'Unable to create feedback upload directory.');
}

function ensure_upload_dir_abs(string $dir, string $errorMessage): void
{
    if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
        throw new RuntimeException($errorMessage);
    }
}

function project_base_path(): string
{
    $dir = str_replace('\\', '/', dirname((string) ($_SERVER['SCRIPT_NAME'] ?? '/api/api.php')));
    $dir = rtrim($dir, '/');
    if (substr($dir, -4) === '/api') {
        $dir = substr($dir, 0, -4);
    }
    return $dir === '' ? '/' : $dir;
}

function receipt_public_url(?string $receiptPath): ?string
{
    return project_public_url($receiptPath);
}

function avatar_public_url(?string $avatarPath): ?string
{
    return project_public_url($avatarPath);
}

function trip_image_public_url(?string $tripImagePath): ?string
{
    return project_public_url($tripImagePath);
}

function feedback_public_url(?string $feedbackPath): ?string
{
    return project_public_url($feedbackPath);
}

function receipt_thumb_public_url(?string $receiptPath): ?string
{
    return upload_thumb_public_url($receiptPath, 'receipt_public_url');
}

function avatar_thumb_public_url(?string $avatarPath): ?string
{
    return upload_thumb_public_url($avatarPath, 'avatar_public_url');
}

function trip_image_thumb_public_url(?string $tripImagePath): ?string
{
    return upload_thumb_public_url($tripImagePath, 'trip_image_public_url');
}

function feedback_thumb_public_url(?string $feedbackPath): ?string
{
    return upload_thumb_public_url($feedbackPath, 'feedback_public_url');
}

function upload_thumb_public_url(?string $relativePath, callable $fallbackUrlResolver): ?string
{
    if (!$relativePath) {
        return null;
    }
    $normalized = ltrim(str_replace('\\', '/', trim($relativePath)), '/');
    if ($normalized === '') {
        return null;
    }
    $thumbRelative = upload_thumb_relative_path($normalized);
    if ($thumbRelative === null || !upload_relative_file_exists($thumbRelative)) {
        return $fallbackUrlResolver($normalized);
    }
    return project_public_url($thumbRelative);
}

function upload_relative_file_exists(string $relativePath): bool
{
    static $cache = [];
    $normalized = ltrim(str_replace('\\', '/', trim($relativePath)), '/');
    if ($normalized === '') {
        return false;
    }
    if (array_key_exists($normalized, $cache)) {
        return $cache[$normalized];
    }

    $absolute = upload_relative_path_to_abs($normalized);
    $exists = is_string($absolute) && $absolute !== '' && is_file($absolute);
    $cache[$normalized] = $exists;
    return $exists;
}

function public_base_url(): string
{
    static $cached = null;
    if (is_string($cached)) {
        return $cached;
    }

    $configured = rtrim(trim((string) PUBLIC_BASE_URL), '/');
    if (
        $configured !== '' &&
        filter_var($configured, FILTER_VALIDATE_URL) &&
        preg_match('#^https?://#i', $configured)
    ) {
        $cached = $configured;
        return $cached;
    }

    $host = trim((string) ($_SERVER['HTTP_HOST'] ?? ''));
    if ($host === '' || !preg_match('/^[A-Za-z0-9.-]+(?::\d{1,5})?$/', $host)) {
        $cached = '';
        return $cached;
    }

    $scheme = 'https';
    $https = strtolower(trim((string) ($_SERVER['HTTPS'] ?? '')));
    if ($https === 'off' || $https === '0') {
        $scheme = 'http';
    } elseif ($https === 'on' || $https === '1') {
        $scheme = 'https';
    }

    $requestScheme = strtolower(trim((string) ($_SERVER['REQUEST_SCHEME'] ?? '')));
    if ($requestScheme === 'http' || $requestScheme === 'https') {
        $scheme = $requestScheme;
    }

    if (TRUST_PROXY_HEADERS) {
        $forwardedProto = strtolower(trim((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')));
        if ($forwardedProto === 'http' || $forwardedProto === 'https') {
            $scheme = $forwardedProto;
        }
    }

    $cached = $scheme . '://' . $host;
    return $cached;
}

function project_public_url(?string $relativePath): ?string
{
    if (!$relativePath) {
        return null;
    }

    $relativePath = ltrim(str_replace('\\', '/', trim($relativePath)), '/');
    if ($relativePath === '') {
        return null;
    }

    $base = project_base_path();
    $relativeUrl = ($base === '/' ? '' : $base) . '/' . $relativePath;

    $baseUrl = public_base_url();
    if ($baseUrl !== '') {
        return $baseUrl . $relativeUrl;
    }

    return $relativeUrl;
}

function upload_relative_path_to_abs(string $relativePath): ?string
{
    $normalized = ltrim(str_replace('\\', '/', trim($relativePath)), '/');
    if ($normalized === '' || strpos($normalized, '..') !== false) {
        return null;
    }
    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $normalized);
}

function upload_thumb_relative_path(string $relativePath): ?string
{
    $normalized = ltrim(str_replace('\\', '/', trim($relativePath)), '/');
    if ($normalized === '') {
        return null;
    }
    $extension = strtolower(pathinfo($normalized, PATHINFO_EXTENSION));
    if ($extension === '') {
        return null;
    }
    $body = substr($normalized, 0, -1 * (strlen($extension) + 1));
    if ($body === '' || substr($body, -6) === '_thumb') {
        return null;
    }
    return $body . '_thumb.' . $extension;
}

function normalize_receipt_path(string $path, bool $allowEmpty = true): string
{
    return normalize_upload_path($path, RECEIPTS_REL_DIR, 'Receipt path', $allowEmpty);
}

function normalize_avatar_path(string $path, bool $allowEmpty = true): string
{
    return normalize_upload_path($path, AVATARS_REL_DIR, 'Avatar path', $allowEmpty);
}

function normalize_trip_image_path(string $path, bool $allowEmpty = true): string
{
    return normalize_upload_path($path, TRIP_IMAGES_REL_DIR, 'Trip image path', $allowEmpty);
}

function normalize_feedback_path(string $path, bool $allowEmpty = true): string
{
    return normalize_upload_path($path, FEEDBACK_REL_DIR, 'Feedback screenshot path', $allowEmpty);
}

function normalize_upload_path(
    string $path,
    string $relativeDir,
    string $label,
    bool $allowEmpty = true
): string {
    $path = str_replace('\\', '/', trim($path));
    $path = ltrim($path, '/');
    if ($path === '') {
        if ($allowEmpty) {
            return '';
        }
        json_out(['ok' => false, 'error' => $label . ' is required.'], 400);
    }

    $cleanRelativeDir = sanitize_upload_relative_dir($relativeDir);
    if (!preg_match('#^' . preg_quote($cleanRelativeDir, '#') . '/[A-Za-z0-9._-]+$#', $path)) {
        json_out(['ok' => false, 'error' => $label . ' is invalid.'], 400);
    }

    return $path;
}

function delete_receipt_file(?string $receiptPath): void
{
    delete_upload_file($receiptPath, 'normalize_receipt_path', receipts_dir_abs());
}

function delete_avatar_file(?string $avatarPath): void
{
    delete_upload_file($avatarPath, 'normalize_avatar_path', avatars_dir_abs());
}

function delete_trip_image_file(?string $tripImagePath): void
{
    delete_upload_file($tripImagePath, 'normalize_trip_image_path', trip_images_dir_abs());
}

function delete_feedback_file(?string $feedbackPath): void
{
    delete_upload_file($feedbackPath, 'normalize_feedback_path', feedback_dir_abs());
}

function delete_upload_file(
    ?string $relativePath,
    callable $normalizePath,
    string $baseDir
): void {
    if (!$relativePath) {
        return;
    }

    $normalized = $normalizePath($relativePath, true);
    if ($normalized === '') {
        return;
    }

    $base = realpath($baseDir);
    if ($base === false) {
        return;
    }

    $target = project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $normalized);
    if (strpos($target, $base) !== 0) {
        return;
    }

    if (is_file($target)) {
        @unlink($target);
    }

    $thumbRelative = upload_thumb_relative_path($normalized);
    if ($thumbRelative !== null) {
        $thumbTarget = upload_relative_path_to_abs($thumbRelative);
        if (is_string($thumbTarget) && $thumbTarget !== '' && is_file($thumbTarget)) {
            @unlink($thumbTarget);
        }
    }
}

function upload_image_webp_quality(): int
{
    $quality = UPLOAD_IMAGE_WEBP_QUALITY;
    if ($quality < 10) {
        return 10;
    }
    if ($quality > 100) {
        return 100;
    }
    return $quality;
}

function upload_image_thumb_max_side(): int
{
    $maxSide = (int) UPLOAD_IMAGE_THUMB_MAX_SIDE;
    if ($maxSide < 96) {
        return 96;
    }
    if ($maxSide > 1200) {
        return 1200;
    }
    return $maxSide;
}

function upload_image_thumb_webp_quality(): int
{
    $quality = (int) UPLOAD_IMAGE_THUMB_WEBP_QUALITY;
    if ($quality < 10) {
        return 10;
    }
    if ($quality > 100) {
        return 100;
    }
    return $quality;
}

function decode_image_from_upload(string $tmpFile)
{
    $raw = @file_get_contents($tmpFile);
    if (!is_string($raw) || $raw === '') {
        return null;
    }

    $image = @imagecreatefromstring($raw);
    if ($image === false) {
        return null;
    }
    return $image;
}

function create_webp_thumbnail(string $sourceFile, string $targetFile): bool
{
    if (!is_file($sourceFile)) {
        return false;
    }

    $maxSide = upload_image_thumb_max_side();
    $quality = upload_image_thumb_webp_quality();

    if (function_exists('imagewebp')) {
        $source = decode_image_from_upload($sourceFile);
        if ($source !== null) {
            $sourceWidth = (int) @imagesx($source);
            $sourceHeight = (int) @imagesy($source);
            if ($sourceWidth > 0 && $sourceHeight > 0) {
                $ratio = min($maxSide / $sourceWidth, $maxSide / $sourceHeight, 1.0);
                $targetWidth = max(1, (int) floor($sourceWidth * $ratio));
                $targetHeight = max(1, (int) floor($sourceHeight * $ratio));
                $canvas = @imagecreatetruecolor($targetWidth, $targetHeight);
                if ($canvas !== false) {
                    @imagealphablending($canvas, false);
                    @imagesavealpha($canvas, true);
                    @imagecopyresampled(
                        $canvas,
                        $source,
                        0,
                        0,
                        0,
                        0,
                        $targetWidth,
                        $targetHeight,
                        $sourceWidth,
                        $sourceHeight
                    );
                    $ok = @imagewebp($canvas, $targetFile, $quality);
                    @imagedestroy($canvas);
                    @imagedestroy($source);
                    if ($ok && is_file($targetFile)) {
                        return true;
                    }
                }
            }
            @imagedestroy($source);
        }
    }

    if (extension_loaded('imagick')) {
        try {
            $imagick = new Imagick();
            $imagick->readImage($sourceFile);
            $imagick->thumbnailImage($maxSide, $maxSide, true, true);
            $imagick->setImageFormat('webp');
            $imagick->setImageCompressionQuality($quality);
            $ok = $imagick->writeImage($targetFile);
            $imagick->clear();
            $imagick->destroy();
            if ($ok && is_file($targetFile)) {
                return true;
            }
        } catch (Throwable $error) {
            return false;
        }
    }

    return false;
}

function generate_upload_thumbnail(string $relativePath): ?array
{
    $normalized = ltrim(str_replace('\\', '/', trim($relativePath)), '/');
    if ($normalized === '') {
        return null;
    }

    $sourceFile = upload_relative_path_to_abs($normalized);
    $thumbRelativePath = upload_thumb_relative_path($normalized);
    if ($sourceFile === null || $thumbRelativePath === null) {
        return null;
    }
    $targetFile = upload_relative_path_to_abs($thumbRelativePath);
    if ($targetFile === null) {
        return null;
    }

    if (!create_webp_thumbnail($sourceFile, $targetFile)) {
        return null;
    }

    return [
        'path' => $thumbRelativePath,
        'size' => (int) (@filesize($targetFile) ?: 0),
    ];
}

function convert_uploaded_image_to_webp_via_class_upload(
    string $tmpFile,
    string $targetFile,
    string $sourceMime = ''
): bool {
    if (!load_class_upload_library()) {
        return false;
    }

    $targetDir = dirname($targetFile);
    $targetBody = pathinfo($targetFile, PATHINFO_FILENAME);
    $tmpExt = pathinfo($tmpFile, PATHINFO_EXTENSION);
    if ($tmpExt === '') {
        $tmpExt = mime_to_extension($sourceMime);
    }
    $sourceName = 'upload.' . strtolower($tmpExt);
    $type = trim($sourceMime) !== '' ? trim($sourceMime) : 'application/octet-stream';

    try {
        $handle = class_upload_instantiate_handle([
            'name' => $sourceName,
            'tmp_name' => $tmpFile,
            'type' => $type,
            'size' => (int) (@filesize($tmpFile) ?: 0),
            'error' => 0,
        ]);
    } catch (Throwable $error) {
        return false;
    }

    if ($handle === null || !isset($handle->uploaded) || $handle->uploaded !== true) {
        return false;
    }

    $quality = upload_image_webp_quality();
    try {
        $handle->file_safe_name = true;
        $handle->file_auto_rename = false;
        $handle->file_overwrite = true;
        $handle->file_new_name_body = $targetBody;
        $handle->image_convert = 'webp';
        if (property_exists($handle, 'image_webp_quality')) {
            $handle->image_webp_quality = $quality;
        }
        if (property_exists($handle, 'jpeg_quality')) {
            $handle->jpeg_quality = $quality;
        }

        $handle->process($targetDir);
        $ok = isset($handle->processed) && $handle->processed === true;
    } catch (Throwable $error) {
        $ok = false;
    }

    if (!$ok) {
        // Keep original tmp file intact so GD/Imagick fallback can still run.
        return false;
    }

    if (method_exists($handle, 'clean')) {
        try {
            $handle->clean();
        } catch (Throwable $error) {
            // Ignore cleanup failures after successful conversion.
        }
    }

    if (is_file($targetFile)) {
        return true;
    }
    $alternate = $targetDir . DIRECTORY_SEPARATOR . $targetBody . '.webp';
    if (is_file($alternate) && $alternate !== $targetFile) {
        return @rename($alternate, $targetFile) && is_file($targetFile);
    }

    return false;
}

function convert_uploaded_image_to_webp(
    string $tmpFile,
    string $targetFile,
    string $sourceMime = ''
): bool
{
    if (convert_uploaded_image_to_webp_via_class_upload($tmpFile, $targetFile, $sourceMime)) {
        return true;
    }

    $quality = upload_image_webp_quality();

    if (function_exists('imagewebp')) {
        $image = decode_image_from_upload($tmpFile);
        if ($image !== null) {
            if (function_exists('imagepalettetotruecolor')) {
                @imagepalettetotruecolor($image);
            }
            @imagealphablending($image, true);
            @imagesavealpha($image, true);
            $ok = @imagewebp($image, $targetFile, $quality);
            @imagedestroy($image);
            if ($ok && is_file($targetFile)) {
                return true;
            }
        }
    }

    if (extension_loaded('imagick')) {
        try {
            $imagick = new Imagick();
            $imagick->readImage($tmpFile);
            $imagick->setImageFormat('webp');
            $imagick->setImageCompressionQuality($quality);
            $ok = $imagick->writeImage($targetFile);
            $imagick->clear();
            $imagick->destroy();
            if ($ok && is_file($targetFile)) {
                return true;
            }
        } catch (Throwable $error) {
            return false;
        }
    }

    return false;
}

function uploaded_file_error_message(int $error): string
{
    $errors = [
        UPLOAD_ERR_INI_SIZE => 'File is too large.',
        UPLOAD_ERR_FORM_SIZE => 'File is too large.',
        UPLOAD_ERR_PARTIAL => 'File upload failed.',
        UPLOAD_ERR_NO_FILE => 'No file uploaded.',
        UPLOAD_ERR_NO_TMP_DIR => 'Server upload directory missing.',
        UPLOAD_ERR_CANT_WRITE => 'Server cannot write uploaded file.',
        UPLOAD_ERR_EXTENSION => 'Upload blocked by extension.',
    ];
    return $errors[$error] ?? 'Upload error.';
}

function validate_uploaded_image_file(
    array $file,
    int $maxBytes,
    string $tooLargeMessage
): array {
    $error = (int) ($file['error'] ?? UPLOAD_ERR_NO_FILE);
    if ($error !== UPLOAD_ERR_OK) {
        json_out(['ok' => false, 'error' => uploaded_file_error_message($error)], 400);
    }

    $size = (int) ($file['size'] ?? 0);
    if ($size <= 0 || $size > $maxBytes) {
        json_out(['ok' => false, 'error' => $tooLargeMessage], 400);
    }

    $tmp = (string) ($file['tmp_name'] ?? '');
    if ($tmp === '' || !is_uploaded_file($tmp)) {
        json_out(['ok' => false, 'error' => 'Uploaded file is invalid.'], 400);
    }

    $mime = (string) (new finfo(FILEINFO_MIME_TYPE))->file($tmp);
    $allowed = [
        'image/jpeg' => true,
        'image/jpg' => true,
        'image/png' => true,
        'image/webp' => true,
        'image/heic' => true,
        'image/heif' => true,
    ];
    if (!isset($allowed[$mime])) {
        json_out([
            'ok' => false,
            'error' => 'Only image files are allowed (JPG/PNG/WEBP/HEIC).',
        ], 400);
    }

    return [
        'tmp' => $tmp,
        'size' => $size,
        'mime' => $mime,
    ];
}

function store_uploaded_image_as_webp(
    string $tmpFile,
    string $relativeDir,
    callable $ensureDir,
    string $sourceMime = ''
): array {
    $normalizedMime = strtolower(trim($sourceMime));
    if (
        ($normalizedMime === 'image/heic' || $normalizedMime === 'image/heif') &&
        !extension_loaded('imagick')
    ) {
        json_out([
            'ok' => false,
            'error' => 'HEIC/HEIF is not supported on server. Please upload JPG or PNG.',
        ], 400);
    }

    $ensureDir();

    $cleanRelativeDir = sanitize_upload_relative_dir($relativeDir);
    $name = gmdate('Ymd_His') . '_' . bin2hex(random_bytes(8)) . '.webp';
    $relativePath = $cleanRelativeDir . '/' . $name;
    $target = project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relativePath);

    $storedOk = false;
    if (!convert_uploaded_image_to_webp($tmpFile, $target, $sourceMime)) {
        if ($sourceMime === 'image/webp' && @move_uploaded_file($tmpFile, $target)) {
            $storedOk = true;
        } else {
            json_out(['ok' => false, 'error' => 'Server cannot convert image to WEBP.'], 500);
        }
    } else {
        $storedOk = true;
    }
    if (!$storedOk) {
        json_out(['ok' => false, 'error' => 'Server cannot store image.'], 500);
    }

    $thumb = generate_upload_thumbnail($relativePath);

    return [
        'path' => $relativePath,
        'size' => (int) (@filesize($target) ?: 0),
        'thumb_path' => is_array($thumb) ? ($thumb['path'] ?? null) : null,
        'thumb_size' => is_array($thumb) ? (int) ($thumb['size'] ?? 0) : 0,
    ];
}

