<?php
declare(strict_types=1);

load_env_file(__DIR__ . '/../.env');
load_env_file(__DIR__ . '/.env');

define('DB_HOST', env_string('TRIP_DB_HOST', 'localhost'));
define('DB_NAME', env_string('TRIP_DB_NAME', ''));
define('DB_USER', env_string('TRIP_DB_USER', ''));
define('DB_PASS', env_string('TRIP_DB_PASS', ''));
define('APP_DEBUG', env_bool('TRIP_APP_DEBUG', false));
define('TRUST_PROXY_HEADERS', env_bool('TRIP_TRUST_PROXY_HEADERS', false));
define('PUBLIC_BASE_URL', env_string('TRIP_PUBLIC_BASE_URL', ''));
define('API_MAX_JSON_BYTES', env_int('TRIP_API_MAX_JSON_BYTES', 65_536)); // 64 KB
define('DB_TABLE_PREFIX', env_string('TRIP_DB_TABLE_PREFIX', 'trip_'));
define('ADMIN_KEY', env_string('TRIP_ADMIN_KEY', ''));
define('RECEIPTS_REL_DIR', env_string('TRIP_RECEIPTS_REL_DIR', 'uploads/receipts'));
define('RECEIPTS_MAX_BYTES', env_int('TRIP_RECEIPTS_MAX_BYTES', 8_388_608)); // 8 MB
define('AVATARS_REL_DIR', env_string('TRIP_AVATARS_REL_DIR', 'uploads/avatars'));
define('AVATARS_MAX_BYTES', env_int('TRIP_AVATARS_MAX_BYTES', 5_242_880)); // 5 MB
define('TRIP_IMAGES_REL_DIR', env_string('TRIP_IMAGES_REL_DIR', 'uploads/trips'));
define('TRIP_IMAGES_MAX_BYTES', env_int('TRIP_IMAGES_MAX_BYTES', 8_388_608)); // 8 MB
define('FEEDBACK_REL_DIR', env_string('TRIP_FEEDBACK_REL_DIR', 'uploads/feedback'));
define('FEEDBACK_MAX_BYTES', env_int('TRIP_FEEDBACK_MAX_BYTES', 8_388_608)); // 8 MB
define('UPLOAD_IMAGE_WEBP_QUALITY', env_int('TRIP_UPLOAD_IMAGE_WEBP_QUALITY', 84));
define('UPLOAD_IMAGE_THUMB_MAX_SIDE', env_int('TRIP_UPLOAD_IMAGE_THUMB_MAX_SIDE', 420));
define('UPLOAD_IMAGE_THUMB_WEBP_QUALITY', env_int('TRIP_UPLOAD_IMAGE_THUMB_WEBP_QUALITY', 76));
define('CLASS_UPLOAD_REL_PATH', env_string('TRIP_CLASS_UPLOAD_REL_PATH', 'api/lib/verot/class.upload.php'));
define('API_ERROR_LOG_REL_PATH', env_string('TRIP_API_ERROR_LOG_REL_PATH', 'logs/api-error.log'));

define('PUSH_ENABLED', env_bool('TRIP_PUSH_ENABLED', false));
define('PUSH_FCM_SERVER_KEY', env_string('TRIP_PUSH_FCM_SERVER_KEY', ''));
define('PUSH_APNS_ENABLED', env_bool('TRIP_PUSH_APNS_ENABLED', false));
define('PUSH_APNS_TEAM_ID', env_string('TRIP_PUSH_APNS_TEAM_ID', ''));
define('PUSH_APNS_KEY_ID', env_string('TRIP_PUSH_APNS_KEY_ID', ''));
define('PUSH_APNS_BUNDLE_ID', env_string('TRIP_PUSH_APNS_BUNDLE_ID', ''));
define('PUSH_APNS_PRIVATE_KEY_REL_PATH', env_string('TRIP_PUSH_APNS_PRIVATE_KEY_REL_PATH', ''));
define('PUSH_APNS_USE_SANDBOX', env_bool('TRIP_PUSH_APNS_USE_SANDBOX', false));
define('PUSH_TIMEOUT_SEC', env_int('TRIP_PUSH_TIMEOUT_SEC', 8));
define('PUSH_MAX_TOKENS_PER_USER', env_int('TRIP_PUSH_MAX_TOKENS_PER_USER', 5));
define('PUSH_QUEUE_BATCH_LIMIT', env_int('TRIP_PUSH_QUEUE_BATCH_LIMIT', 100));

define('SETTLEMENT_REMINDER_ENABLED', env_bool('TRIP_SETTLEMENT_REMINDER_ENABLED', false));
define('SETTLEMENT_REMINDER_INTERVAL_MIN', env_int('TRIP_SETTLEMENT_REMINDER_INTERVAL_MIN', 720));
define('SETTLEMENT_REMINDER_MIN_AGE_MIN', env_int('TRIP_SETTLEMENT_REMINDER_MIN_AGE_MIN', 180));
define('SETTLEMENT_REMINDER_BATCH_LIMIT', env_int('TRIP_SETTLEMENT_REMINDER_BATCH_LIMIT', 120));

define('RATE_LIMIT_REGISTER_IP_MAX', env_int('TRIP_RATE_LIMIT_REGISTER_IP_MAX', 40));
define('RATE_LIMIT_REGISTER_TOKEN_MAX', env_int('TRIP_RATE_LIMIT_REGISTER_TOKEN_MAX', 15));
define('RATE_LIMIT_REGISTER_PROOF_IP_MAX', env_int('TRIP_RATE_LIMIT_REGISTER_PROOF_IP_MAX', 120));
define('RATE_LIMIT_REGISTER_PROOF_TOKEN_MAX', env_int('TRIP_RATE_LIMIT_REGISTER_PROOF_TOKEN_MAX', 80));
define('RATE_LIMIT_LOGIN_IP_MAX', env_int('TRIP_RATE_LIMIT_LOGIN_IP_MAX', 60));
define('RATE_LIMIT_LOGIN_EMAIL_MAX', env_int('TRIP_RATE_LIMIT_LOGIN_EMAIL_MAX', 20));
define('RATE_LIMIT_REFRESH_IP_MAX', env_int('TRIP_RATE_LIMIT_REFRESH_IP_MAX', 120));
define('RATE_LIMIT_REFRESH_TOKEN_MAX', env_int('TRIP_RATE_LIMIT_REFRESH_TOKEN_MAX', 80));
define('RATE_LIMIT_UPLOAD_IP_MAX', env_int('TRIP_RATE_LIMIT_UPLOAD_IP_MAX', 80));
define('RATE_LIMIT_UPLOAD_USER_MAX', env_int('TRIP_RATE_LIMIT_UPLOAD_USER_MAX', 40));
define('RATE_LIMIT_SEARCH_IP_MAX', env_int('TRIP_RATE_LIMIT_SEARCH_IP_MAX', 180));
define('RATE_LIMIT_SEARCH_USER_MAX', env_int('TRIP_RATE_LIMIT_SEARCH_USER_MAX', 120));
define('RATE_LIMIT_FRIENDS_INVITE_IP_MAX', env_int('TRIP_RATE_LIMIT_FRIENDS_INVITE_IP_MAX', 80));
define('RATE_LIMIT_FRIENDS_INVITE_USER_MAX', env_int('TRIP_RATE_LIMIT_FRIENDS_INVITE_USER_MAX', 60));
define('RATE_LIMIT_TRIP_WRITE_IP_MAX', env_int('TRIP_RATE_LIMIT_TRIP_WRITE_IP_MAX', 80));
define('RATE_LIMIT_TRIP_WRITE_USER_MAX', env_int('TRIP_RATE_LIMIT_TRIP_WRITE_USER_MAX', 60));
define('RATE_LIMIT_EXPENSE_WRITE_IP_MAX', env_int('TRIP_RATE_LIMIT_EXPENSE_WRITE_IP_MAX', 240));
define('RATE_LIMIT_EXPENSE_WRITE_USER_MAX', env_int('TRIP_RATE_LIMIT_EXPENSE_WRITE_USER_MAX', 180));
define('RATE_LIMIT_FEEDBACK_IP_MAX', env_int('TRIP_RATE_LIMIT_FEEDBACK_IP_MAX', 40));
define('RATE_LIMIT_FEEDBACK_USER_MAX', env_int('TRIP_RATE_LIMIT_FEEDBACK_USER_MAX', 30));
define('RATE_LIMIT_ADMIN_AUTH_IP_MAX', env_int('TRIP_RATE_LIMIT_ADMIN_AUTH_IP_MAX', 60));

define('RATE_LIMIT_REGISTER_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_REGISTER_WINDOW_SEC', 3600));
define('RATE_LIMIT_LOGIN_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_LOGIN_WINDOW_SEC', 3600));
define('RATE_LIMIT_REFRESH_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_REFRESH_WINDOW_SEC', 3600));
define('RATE_LIMIT_UPLOAD_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_UPLOAD_WINDOW_SEC', 600));
define('RATE_LIMIT_SEARCH_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_SEARCH_WINDOW_SEC', 600));
define('RATE_LIMIT_MUTATION_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_MUTATION_WINDOW_SEC', 3600));
define('RATE_LIMIT_ADMIN_WINDOW_SEC', env_int('TRIP_RATE_LIMIT_ADMIN_WINDOW_SEC', 900));

define('REGISTER_PROOF_SECRET', env_string('TRIP_REGISTER_PROOF_SECRET', ''));
define('REGISTER_PROOF_MAX_AGE_SEC', env_int('TRIP_REGISTER_PROOF_MAX_AGE_SEC', 900));
define('AUTH_ACCESS_TOKEN_SECRET', env_string('TRIP_AUTH_ACCESS_TOKEN_SECRET', ''));
define('AUTH_ACCESS_TOKEN_TTL_SEC', env_int('TRIP_AUTH_ACCESS_TOKEN_TTL_SEC', 900));
define('AUTH_REFRESH_TOKEN_TTL_SEC', env_int('TRIP_AUTH_REFRESH_TOKEN_TTL_SEC', 2_592_000));

define('UPLOAD_USER_MAX_FILES_PER_DAY', env_int('TRIP_UPLOAD_USER_MAX_FILES_PER_DAY', 60));
define('UPLOAD_USER_MAX_BYTES_PER_DAY', env_int('TRIP_UPLOAD_USER_MAX_BYTES_PER_DAY', 251_658_240)); // 240 MB
define('UPLOAD_TRIP_MAX_FILES_PER_DAY', env_int('TRIP_UPLOAD_TRIP_MAX_FILES_PER_DAY', 300));
define('UPLOAD_TRIP_MAX_BYTES_PER_DAY', env_int('TRIP_UPLOAD_TRIP_MAX_BYTES_PER_DAY', 1_073_741_824)); // 1 GB

function load_env_file(string $path): void
{
    if (!is_file($path) || !is_readable($path)) {
        return;
    }

    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    if (!is_array($lines)) {
        return;
    }

    foreach ($lines as $rawLine) {
        $line = trim($rawLine);
        if ($line === '' || strpos($line, '#') === 0) {
            continue;
        }

        $pos = strpos($line, '=');
        if ($pos === false || $pos < 1) {
            continue;
        }

        $key = trim(substr($line, 0, $pos));
        if (!preg_match('/^[A-Z0-9_]+$/', $key)) {
            continue;
        }

        $value = trim(substr($line, $pos + 1));
        if (
            (substr($value, 0, 1) === '"' && substr($value, -1) === '"') ||
            (substr($value, 0, 1) === '\'' && substr($value, -1) === '\'')
        ) {
            $value = substr($value, 1, -1);
        }

        if (!array_key_exists($key, $_ENV)) {
            $_ENV[$key] = $value;
        }
        if (!array_key_exists($key, $_SERVER)) {
            $_SERVER[$key] = $value;
        }
        if (getenv($key) === false) {
            putenv($key . '=' . $value);
        }
    }
}

function env_string(string $key, string $default = ''): string
{
    $raw = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    if ($raw === false || $raw === null) {
        return $default;
    }
    $value = trim((string) $raw);
    return $value !== '' ? $value : $default;
}

function env_bool(string $key, bool $default = false): bool
{
    $raw = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    if ($raw === false || $raw === null) {
        return $default;
    }
    $value = strtolower(trim((string) $raw));
    if (in_array($value, ['1', 'true', 'yes', 'on'], true)) {
        return true;
    }
    if (in_array($value, ['0', 'false', 'no', 'off'], true)) {
        return false;
    }
    return $default;
}

function env_int(string $key, int $default = 0): int
{
    $raw = $_ENV[$key] ?? $_SERVER[$key] ?? getenv($key);
    if ($raw === false || $raw === null) {
        return $default;
    }
    if (!is_numeric($raw)) {
        return $default;
    }
    return (int) $raw;
}

function db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) {
        return $pdo;
    }

    if (DB_NAME === '' || DB_USER === '') {
        throw new RuntimeException('Database is not configured. Set TRIP_DB_NAME and TRIP_DB_USER in .env.');
    }

    $dsn = sprintf('mysql:host=%s;dbname=%s;charset=utf8mb4', DB_HOST, DB_NAME);
    $pdo = new PDO($dsn, DB_USER, DB_PASS, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
        PDO::ATTR_EMULATE_PREPARES => false,
    ]);

    return $pdo;
}

function table_name(string $key): string
{
    $map = [
        'users' => DB_TABLE_PREFIX . 'users',
        'trips' => DB_TABLE_PREFIX . 'trips',
        'trip_members' => DB_TABLE_PREFIX . 'trip_members',
        'expenses' => DB_TABLE_PREFIX . 'expenses',
        'expense_participants' => DB_TABLE_PREFIX . 'expense_participants',
        'settlements' => DB_TABLE_PREFIX . 'settlements',
        'notifications' => DB_TABLE_PREFIX . 'notifications',
        'feedback' => DB_TABLE_PREFIX . 'feedback',
        'feedback_status_history' => DB_TABLE_PREFIX . 'feedback_status_history',
        'random_orders' => DB_TABLE_PREFIX . 'random_orders',
        'random_order_members' => DB_TABLE_PREFIX . 'random_order_members',
        'random_draw_state' => DB_TABLE_PREFIX . 'random_draw_state',
        'friends' => DB_TABLE_PREFIX . 'friends',
        'request_limits' => DB_TABLE_PREFIX . 'request_limits',
        'upload_daily_usage' => DB_TABLE_PREFIX . 'upload_daily_usage',
        'refresh_tokens' => DB_TABLE_PREFIX . 'refresh_tokens',
        'push_tokens' => DB_TABLE_PREFIX . 'user_push_tokens',
        'push_queue' => DB_TABLE_PREFIX . 'push_queue',
        'settlement_reminder_state' => DB_TABLE_PREFIX . 'settlement_reminder_state',
    ];

    $raw = $map[$key] ?? '';
    if ($raw === '' || !preg_match('/^[A-Za-z0-9_]+$/', $raw)) {
        throw new RuntimeException('Invalid table mapping for key: ' . $key);
    }

    return '`' . $raw . '`';
}

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
    $root = realpath(__DIR__ . '/..');
    if ($root === false) {
        throw new RuntimeException('Cannot resolve project root directory.');
    }
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

function json_out(array $payload, int $status = 200): void
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
    header('X-Request-Id: ' . request_id());
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: no-referrer');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
    header('Cross-Origin-Resource-Policy: same-origin');

    $isHttps = false;
    $https = strtolower(trim((string) ($_SERVER['HTTPS'] ?? '')));
    if ($https === 'on' || $https === '1') {
        $isHttps = true;
    }
    if (TRUST_PROXY_HEADERS) {
        $forwardedProto = strtolower(trim((string) ($_SERVER['HTTP_X_FORWARDED_PROTO'] ?? '')));
        if ($forwardedProto === 'https') {
            $isHttps = true;
        }
    }
    if ($isHttps) {
        header('Strict-Transport-Security: max-age=31536000; includeSubDomains');
    }

    $jsonFlags = JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES;
    if (defined('JSON_INVALID_UTF8_SUBSTITUTE')) {
        $jsonFlags |= JSON_INVALID_UTF8_SUBSTITUTE;
    }
    if (defined('JSON_PARTIAL_OUTPUT_ON_ERROR')) {
        $jsonFlags |= JSON_PARTIAL_OUTPUT_ON_ERROR;
    }

    $json = json_encode($payload, $jsonFlags);
    if (!is_string($json)) {
        if ($status < 500) {
            http_response_code(500);
        }
        $json = '{"ok":false,"error":"Response encoding failed."}';
    }

    echo $json;
    exit;
}

function max_json_body_bytes(): int
{
    $limit = (int) API_MAX_JSON_BYTES;
    if ($limit < 4_096) {
        return 4_096;
    }
    if ($limit > 1_048_576) {
        return 1_048_576;
    }
    return $limit;
}

function cache_last_json_body(array $payload): void
{
    $GLOBALS['trip_last_json_body'] = $payload;
}

function last_json_body(): array
{
    $value = $GLOBALS['trip_last_json_body'] ?? null;
    return is_array($value) ? $value : [];
}

function read_json(): array
{
    $contentLength = (int) ($_SERVER['CONTENT_LENGTH'] ?? 0);
    $maxBytes = max_json_body_bytes();
    if ($contentLength > $maxBytes) {
        json_out(['ok' => false, 'error' => 'Request body is too large.'], 413);
    }

    $raw = file_get_contents('php://input');
    if ($raw === false || $raw === '') {
        cache_last_json_body([]);
        return [];
    }
    if (strlen($raw) > $maxBytes) {
        json_out(['ok' => false, 'error' => 'Request body is too large.'], 413);
    }

    $decoded = json_decode($raw, true);
    if (!is_array($decoded)) {
        json_out(['ok' => false, 'error' => 'Invalid JSON body.'], 400);
    }

    cache_last_json_body($decoded);

    return $decoded;
}

function require_post(): void
{
    if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'POST') {
        json_out(['ok' => false, 'error' => 'Method not allowed.'], 405);
    }
}

function validate_token(string $token): string
{
    $token = strtolower(trim($token));
    if (!preg_match('/^[a-f0-9]{64}$/', $token)) {
        json_out(['ok' => false, 'error' => 'Missing or invalid device token.'], 401);
    }

    return $token;
}

function token_from_header(): string
{
    return validate_token((string) ($_SERVER['HTTP_X_DEVICE_TOKEN'] ?? ''));
}

function bearer_access_token_from_header(): string
{
    $raw = trim((string) ($_SERVER['HTTP_AUTHORIZATION'] ?? ''));
    if ($raw === '') {
        $raw = trim((string) ($_SERVER['REDIRECT_HTTP_AUTHORIZATION'] ?? ''));
    }
    if ($raw === '' || stripos($raw, 'Bearer ') !== 0) {
        return '';
    }

    return trim(substr($raw, 7));
}

function client_ip_address(): string
{
    $candidates = [];
    if (TRUST_PROXY_HEADERS) {
        $candidates[] = (string) ($_SERVER['HTTP_CF_CONNECTING_IP'] ?? '');
        $candidates[] = (string) ($_SERVER['HTTP_X_FORWARDED_FOR'] ?? '');
        $candidates[] = (string) ($_SERVER['HTTP_X_REAL_IP'] ?? '');
    }
    $candidates[] = (string) ($_SERVER['REMOTE_ADDR'] ?? '');

    foreach ($candidates as $candidate) {
        $raw = trim($candidate);
        if ($raw === '') {
            continue;
        }

        $first = trim(explode(',', $raw)[0]);
        if ($first !== '' && filter_var($first, FILTER_VALIDATE_IP)) {
            return $first;
        }
    }

    return '0.0.0.0';
}

function request_positive_int_field(string $key): ?int
{
    $body = last_json_body();
    $candidates = [
        $_GET[$key] ?? null,
        $_POST[$key] ?? null,
        $_REQUEST[$key] ?? null,
        $body[$key] ?? null,
    ];

    foreach ($candidates as $value) {
        if ($value === null || $value === '') {
            continue;
        }
        if (is_numeric($value)) {
            $parsed = (int) $value;
            if ($parsed > 0) {
                return $parsed;
            }
        }
    }

    return null;
}

function request_user_id_for_error_log(): ?int
{
    $accessToken = bearer_access_token_from_header();
    if ($accessToken !== '' && function_exists('resolve_user_id_from_access_token')) {
        $fromToken = (int) resolve_user_id_from_access_token($accessToken);
        if ($fromToken > 0) {
            return $fromToken;
        }
    }

    return request_positive_int_field('user_id');
}

function request_trip_id_for_error_log(): ?int
{
    return request_positive_int_field('trip_id');
}

function log_api_exception(
    Throwable $error,
    string $action = '',
    ?int $userId = null,
    ?int $tripId = null
): void {
    try {
        $resolvedAction = trim($action);
        if ($resolvedAction === '') {
            $resolvedAction = trim((string) ($_GET['action'] ?? ''));
        }

        $resolvedUserId = $userId ?? request_user_id_for_error_log();
        $resolvedTripId = $tripId ?? request_trip_id_for_error_log();
        $entry = [
            'ts_utc' => gmdate('c'),
            'level' => 'error',
            'request_id' => request_id(),
            'action' => $resolvedAction !== '' ? $resolvedAction : null,
            'user_id' => $resolvedUserId,
            'trip_id' => $resolvedTripId,
            'error' => trim($error->getMessage()) !== ''
                ? trim($error->getMessage())
                : 'Unknown exception',
            'type' => get_class($error),
            'code' => (int) $error->getCode(),
            'method' => (string) ($_SERVER['REQUEST_METHOD'] ?? ''),
            'path' => (string) ($_SERVER['REQUEST_URI'] ?? ''),
            'ip' => client_ip_address(),
        ];

        $path = api_error_log_path_abs();
        $dir = dirname($path);
        if (!is_dir($dir) && !mkdir($dir, 0755, true) && !is_dir($dir)) {
            return;
        }

        $line = json_encode($entry, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (!is_string($line) || $line === '') {
            return;
        }
        @file_put_contents($path, $line . PHP_EOL, FILE_APPEND | LOCK_EX);
    } catch (Throwable $loggingError) {
        // Never break API response flow because of logging.
    }
}

function is_missing_table_error(Throwable $error): bool
{
    if (!$error instanceof PDOException) {
        return false;
    }
    $message = strtolower($error->getMessage());
    return strpos($message, 'doesn\'t exist') !== false || strpos($message, 'no such table') !== false;
}

function enforce_rate_limit(
    PDO $pdo,
    string $scope,
    string $subject,
    int $maxHits,
    int $windowSeconds
): void {
    $scope = trim($scope);
    $subject = trim(strtolower($subject));
    if ($scope === '' || $subject === '' || $maxHits <= 0 || $windowSeconds <= 0) {
        return;
    }

    $windowStart = (int) (floor(time() / $windowSeconds) * $windowSeconds);
    $subjectHash = hash('sha256', $subject);
    $table = table_name('request_limits');

    try {
        $insert = $pdo->prepare(
            'INSERT INTO ' . $table . '
             (scope, subject_hash, window_start, hits)
             VALUES (:scope, :subject_hash, :window_start, 1)
             ON DUPLICATE KEY UPDATE
                hits = hits + 1,
                updated_at = CURRENT_TIMESTAMP'
        );
        $insert->execute([
            'scope' => $scope,
            'subject_hash' => $subjectHash,
            'window_start' => $windowStart,
        ]);

        $select = $pdo->prepare(
            'SELECT hits
             FROM ' . $table . '
             WHERE scope = :scope
               AND subject_hash = :subject_hash
               AND window_start = :window_start
             LIMIT 1'
        );
        $select->execute([
            'scope' => $scope,
            'subject_hash' => $subjectHash,
            'window_start' => $windowStart,
        ]);
        $hits = (int) ($select->fetchColumn() ?: 0);
        if ($hits > $maxHits) {
            json_out(['ok' => false, 'error' => 'Too many requests. Try again later.'], 429);
        }

        if (random_int(1, 200) === 1) {
            $cleanup = $pdo->prepare(
                'DELETE FROM ' . $table . '
                 WHERE updated_at < (CURRENT_TIMESTAMP - INTERVAL 3 DAY)'
            );
            $cleanup->execute();
        }
    } catch (Throwable $error) {
        if (is_missing_table_error($error)) {
            return;
        }
        throw $error;
    }
}

function enforce_upload_daily_quota(
    PDO $pdo,
    string $scope,
    int $scopeId,
    int $fileBytes,
    int $maxFilesPerDay,
    int $maxBytesPerDay
): void {
    $scope = strtolower(trim($scope));
    if (
        $scopeId <= 0 ||
        $fileBytes <= 0 ||
        $maxFilesPerDay <= 0 ||
        $maxBytesPerDay <= 0 ||
        !in_array($scope, ['user', 'trip'], true)
    ) {
        return;
    }

    $dayUtc = gmdate('Y-m-d');
    $table = table_name('upload_daily_usage');

    try {
        $seed = $pdo->prepare(
            'INSERT INTO ' . $table . '
             (scope, scope_id, day_utc, files_count, total_bytes)
             VALUES (:scope, :scope_id, :day_utc, 0, 0)
             ON DUPLICATE KEY UPDATE updated_at = CURRENT_TIMESTAMP'
        );
        $seed->execute([
            'scope' => $scope,
            'scope_id' => $scopeId,
            'day_utc' => $dayUtc,
        ]);

        $bump = $pdo->prepare(
            'UPDATE ' . $table . '
             SET files_count = files_count + 1,
                 total_bytes = total_bytes + :file_bytes_inc,
                 updated_at = CURRENT_TIMESTAMP
             WHERE scope = :scope
               AND scope_id = :scope_id
               AND day_utc = :day_utc
               AND files_count < :max_files
               AND (total_bytes + :file_bytes_limit) <= :max_bytes'
        );
        $bump->execute([
            'file_bytes_inc' => $fileBytes,
            'file_bytes_limit' => $fileBytes,
            'scope' => $scope,
            'scope_id' => $scopeId,
            'day_utc' => $dayUtc,
            'max_files' => $maxFilesPerDay,
            'max_bytes' => $maxBytesPerDay,
        ]);

        if ((int) $bump->rowCount() < 1) {
            json_out(['ok' => false, 'error' => 'Upload daily quota exceeded.'], 429);
        }

        if (random_int(1, 200) === 1) {
            $cleanup = $pdo->prepare(
                'DELETE FROM ' . $table . '
                 WHERE day_utc < (UTC_DATE() - INTERVAL 7 DAY)'
            );
            $cleanup->execute();
        }
    } catch (Throwable $error) {
        if (is_missing_table_error($error)) {
            return;
        }
        throw $error;
    }
}

function require_admin(): void
{
    if (ADMIN_KEY === '' || ADMIN_KEY === 'CHANGE_ME_STRONG_ADMIN_KEY') {
        json_out(['ok' => false, 'error' => 'Admin key is not configured.'], 503);
    }

    try {
        enforce_rate_limit(
            db(),
            'admin_auth_ip',
            client_ip_address(),
            RATE_LIMIT_ADMIN_AUTH_IP_MAX,
            RATE_LIMIT_ADMIN_WINDOW_SEC
        );
    } catch (Throwable $error) {
        if (!is_missing_table_error($error)) {
            throw $error;
        }
    }

    $provided = trim((string) ($_SERVER['HTTP_X_ADMIN_KEY'] ?? ''));
    if ($provided === '' || !hash_equals(ADMIN_KEY, $provided)) {
        json_out(['ok' => false, 'error' => 'Invalid admin key.'], 401);
    }
}

function get_me(): array
{
    $pdo = db();
    $accessToken = bearer_access_token_from_header();
    if ($accessToken === '' || !function_exists('resolve_user_id_from_access_token')) {
        json_out(['ok' => false, 'error' => 'Missing or invalid access token.'], 401);
    }

    $userId = (int) resolve_user_id_from_access_token($accessToken);
    if ($userId <= 0) {
        json_out(['ok' => false, 'error' => 'Missing or invalid access token.'], 401);
    }

    $row = function_exists('fetch_me_row_by_id') ? fetch_me_row_by_id($pdo, $userId) : null;
    if (!$row) {
        json_out(['ok' => false, 'error' => 'User not found.'], 401);
    }

    return [
        'id' => (int) ($row['id'] ?? 0),
        'nickname' => (string) ($row['nickname'] ?? ''),
    ];
}

function validate_nickname(string $nickname): string
{
    $nickname = trim(preg_replace('/\s+/', ' ', $nickname) ?? '');
    if (str_length($nickname) < 2 || str_length($nickname) > 32) {
        json_out(['ok' => false, 'error' => 'Nickname must be 2-32 chars.'], 400);
    }

    if (!preg_match('/^[\p{L}\p{N} ._\-]+$/u', $nickname)) {
        json_out(['ok' => false, 'error' => 'Nickname has unsupported characters.'], 400);
    }
    ensure_text_has_no_links($nickname, 'Nickname');

    return $nickname;
}

function ensure_text_has_no_links(string $value, string $fieldLabel): void
{
    $value = trim($value);
    if ($value === '') {
        return;
    }

    if (preg_match('/https?:\/\/|www\./i', $value)) {
        json_out(['ok' => false, 'error' => $fieldLabel . ' must not contain links.'], 400);
    }
}

function validate_date_iso(string $value): string
{
    $value = trim($value);
    if (!preg_match('/^\d{4}-\d{2}-\d{2}$/', $value)) {
        json_out(['ok' => false, 'error' => 'Date must be YYYY-MM-DD.'], 400);
    }

    $dt = DateTime::createFromFormat('Y-m-d', $value);
    if (!$dt || $dt->format('Y-m-d') !== $value) {
        json_out(['ok' => false, 'error' => 'Date is invalid.'], 400);
    }

    return $value;
}

function validate_amount_cents($value): int
{
    if (is_string($value)) {
        $value = str_replace(',', '.', trim($value));
    }

    if (!is_numeric($value)) {
        json_out(['ok' => false, 'error' => 'Amount must be numeric.'], 400);
    }

    $amount = (float) $value;
    if ($amount <= 0 || $amount > 99999999) {
        json_out(['ok' => false, 'error' => 'Amount out of range.'], 400);
    }

    return (int) round($amount * 100);
}

function cents_to_decimal(int $cents): string
{
    return number_format($cents / 100, 2, '.', '');
}

function str_length(string $value): int
{
    if (function_exists('mb_strlen')) {
        return (int) mb_strlen($value);
    }
    return strlen($value);
}

function cents_to_float(int $cents): float
{
    return (float) cents_to_decimal($cents);
}

function decimal_to_cents($value): int
{
    return (int) round(((float) $value) * 100);
}

function normalize_user_ids(array $ids): array
{
    $out = [];
    foreach ($ids as $id) {
        $intId = (int) $id;
        if ($intId > 0) {
            $out[$intId] = $intId;
        }
    }
    return array_values($out);
}

function require_valid_user_ids(PDO $pdo, array $ids, bool $requireAtLeastOne = true): array
{
    $ids = normalize_user_ids($ids);
    if ($requireAtLeastOne && count($ids) < 1) {
        json_out(['ok' => false, 'error' => 'Pick at least one user.'], 400);
    }
    if (!$ids) {
        return [];
    }

    $placeholders = implode(',', array_fill(0, count($ids), '?'));
    $stmt = $pdo->prepare('SELECT id FROM ' . table_name('users') . " WHERE id IN ($placeholders)");
    $stmt->execute($ids);
    $existing = array_map('intval', array_column($stmt->fetchAll(), 'id'));
    sort($existing);
    $copy = $ids;
    sort($copy);

    if ($existing !== $copy) {
        json_out(['ok' => false, 'error' => 'Some selected users do not exist.'], 400);
    }

    return $ids;
}

function all_registered_user_ids(PDO $pdo): array
{
    $usersTable = table_name('users');
    $rows = $pdo->query('SELECT id FROM ' . $usersTable . ' ORDER BY created_at ASC, id ASC')->fetchAll();
    $ids = array_map(static fn(array $row): int => (int) $row['id'], $rows);
    $ids = normalize_user_ids($ids);
    if (count($ids) < 1) {
        json_out(['ok' => false, 'error' => 'No users in group yet.'], 400);
    }
    return $ids;
}

function secure_shuffle(array $items): array
{
    $count = count($items);
    if ($count <= 1) {
        return $items;
    }

    for ($i = $count - 1; $i > 0; $i--) {
        $j = random_int(0, $i);
        $tmp = $items[$i];
        $items[$i] = $items[$j];
        $items[$j] = $tmp;
    }

    return $items;
}
