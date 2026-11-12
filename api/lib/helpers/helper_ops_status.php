<?php
declare(strict_types=1);

// Scheduled jobs leave a small heartbeat file after each run; the admin panel's
// System page reads them. Files contain only times, counts and an ok flag.
// The directory is owned by www-data so PHP-FPM can read what root cron jobs write.

function ops_status_dir(): string
{
    $configured = function_exists('env_string') ? trim(env_string('TRIP_OPS_STATUS_DIR', '')) : '';
    return rtrim($configured !== '' ? $configured : '/var/lib/splyto/status', '/');
}

/** Job catalogue: label and the age after which a missing heartbeat counts as stale. */
function ops_status_jobs(): array
{
    return [
        'push_delivery' => ['label' => 'Push delivery', 'schedule' => 'every minute', 'max_age' => 5 * 60],
        'settlement_reminders' => ['label' => 'Settlement reminders', 'schedule' => 'every 5 minutes', 'max_age' => 20 * 60],
        'email_verification_cleanup' => ['label' => 'Unverified account cleanup', 'schedule' => 'every 10 minutes', 'max_age' => 40 * 60],
        'trip_report_delivery' => ['label' => 'Trip report emails', 'schedule' => 'every minute', 'max_age' => 5 * 60],
        'live_location_cleanup' => ['label' => 'Live location cleanup', 'schedule' => 'every minute', 'max_age' => 5 * 60],
        'backup' => ['label' => 'Database & files backup', 'schedule' => 'daily 03:20 UTC', 'max_age' => 26 * 3600],
        'backup_restore_check' => ['label' => 'Backup restore test', 'schedule' => 'weekly, Sunday', 'max_age' => 8 * 86400],
        'image_originals_cleanup' => ['label' => 'Image originals cleanup', 'schedule' => 'weekly, Sunday', 'max_age' => 8 * 86400],
    ];
}

/** Records one run. Never throws: monitoring must not break the job itself. */
function ops_heartbeat(string $job, bool $ok = true, array $details = [], ?string $dir = null): void
{
    if (!preg_match('/^[a-z_]{1,64}$/', $job)) {
        return;
    }
    try {
        $dir ??= ops_status_dir();
        if (!is_dir($dir) && !@mkdir($dir, 0750, true) && !is_dir($dir)) {
            return;
        }
        $runningAsRoot = function_exists('posix_geteuid') && posix_geteuid() === 0;
        if ($runningAsRoot) {
            @chown($dir, 'www-data');
            @chgrp($dir, 'www-data');
        }
        $clean = [];
        foreach ($details as $key => $value) {
            if (is_string($key) && preg_match('/^[a-z_]{1,32}$/', $key) && (is_int($value) || is_bool($value))) {
                $clean[$key] = $value;
            }
        }
        $payload = json_encode(['job' => $job, 'ok' => $ok, 'at' => gmdate('Y-m-d\TH:i:s\Z'), 'details' => $clean],
            JSON_THROW_ON_ERROR);
        $file = $dir . '/' . $job . '.json';
        $tmp = $file . '.' . bin2hex(random_bytes(4)) . '.tmp';
        if (@file_put_contents($tmp, $payload) === false) {
            return;
        }
        @chmod($tmp, 0640);
        if ($runningAsRoot) {
            @chown($tmp, 'www-data');
            @chgrp($tmp, 'www-data');
        }
        if (!@rename($tmp, $file)) {
            @unlink($tmp);
        }
    } catch (Throwable $error) {
        error_log('ops heartbeat failed for ' . $job);
    }
}

/** State per job: ok, failed (last run reported failure), stale (too old) or unknown (never seen). */
function ops_status_read(int $now, ?string $dir = null): array
{
    $dir ??= ops_status_dir();
    $jobs = [];
    foreach (ops_status_jobs() as $job => $meta) {
        $entry = ['job' => $job, 'label' => $meta['label'], 'schedule' => $meta['schedule'],
            'state' => 'unknown', 'last_run' => null, 'age_seconds' => null, 'details' => []];
        $raw = @file_get_contents($dir . '/' . $job . '.json');
        $data = is_string($raw) ? json_decode($raw, true) : null;
        $at = is_array($data) ? strtotime((string) ($data['at'] ?? '')) : false;
        if ($at !== false && $at !== null) {
            $age = max(0, $now - $at);
            $entry['last_run'] = gmdate('Y-m-d H:i:s', $at);
            $entry['age_seconds'] = $age;
            $entry['details'] = is_array($data['details'] ?? null) ? $data['details'] : [];
            $entry['state'] = ($data['ok'] ?? false) !== true ? 'failed' : ($age > $meta['max_age'] ? 'stale' : 'ok');
        }
        $jobs[] = $entry;
    }
    return $jobs;
}

/** Disk, database size, versions and the deployed commit. */
function ops_system_snapshot(PDO $pdo, string $appRoot): array
{
    $total = @disk_total_space($appRoot);
    $free = @disk_free_space($appRoot);
    $dbBytes = null;
    try {
        $stmt = $pdo->query('SELECT SUM(data_length + index_length) FROM information_schema.tables WHERE table_schema = DATABASE()');
        $dbBytes = (int) $stmt->fetchColumn();
    } catch (Throwable $error) {
        $dbBytes = null;
    }
    $mysql = null;
    try {
        $mysql = (string) $pdo->query('SELECT VERSION()')->fetchColumn();
    } catch (Throwable $error) {
        $mysql = null;
    }
    return [
        'disk_total_bytes' => is_float($total) ? (int) $total : null,
        'disk_free_bytes' => is_float($free) ? (int) $free : null,
        'database_bytes' => $dbBytes,
        'php_version' => PHP_VERSION,
        'mysql_version' => $mysql,
        'commit' => ops_deployed_commit($appRoot),
    ];
}

function ops_deployed_commit(string $appRoot): ?string
{
    $head = @file_get_contents($appRoot . '/.git/HEAD');
    if (!is_string($head)) {
        return null;
    }
    $head = trim($head);
    if (preg_match('/^[0-9a-f]{40}$/', $head)) {
        return substr($head, 0, 7);
    }
    if (!preg_match('#^ref: (refs/heads/[A-Za-z0-9._/-]+)$#', $head, $m)) {
        return null;
    }
    $ref = @file_get_contents($appRoot . '/.git/' . $m[1]);
    if (is_string($ref) && preg_match('/^[0-9a-f]{40}/', trim($ref))) {
        return substr(trim($ref), 0, 7);
    }
    $packed = @file_get_contents($appRoot . '/.git/packed-refs');
    if (is_string($packed) && preg_match('/^([0-9a-f]{40}) ' . preg_quote($m[1], '/') . '$/m', $packed, $p)) {
        return substr($p[1], 0, 7);
    }
    return null;
}
