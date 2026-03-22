<?php
declare(strict_types=1);

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

