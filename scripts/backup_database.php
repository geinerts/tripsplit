#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    exit(1);
}
require __DIR__ . '/../api/config.php';
require_once __DIR__ . '/lib/database_access.php';

try {
    $file = getenv('TRIP_BACKUP_CREDENTIALS_FILE') ?: '/etc/splyto/backup.cnf';
    $pdo = operator_database_connection($file);
    $stmt = $pdo->prepare('SELECT GET_LOCK(?, 20)');
    $stmt->execute([database_maintenance_lock_name()]);
    if ((int) $stmt->fetchColumn() !== 1) {
        throw new RuntimeException('Database maintenance is already running.');
    }
    try {
        // Current schema has no routines, triggers or events. The migrator cannot create them.
        // Keep GTID off and tablespaces excluded so no global administrative grants are needed.
        $process = proc_open(['mysqldump', '--defaults-file=' . $file,
            '--single-transaction', '--quick', '--no-tablespaces', '--set-gtid-purged=OFF',
            '--skip-triggers', '--skip-routines', '--skip-events', DB_NAME],
            [0 => ['file', '/dev/null', 'r'], 1 => STDOUT, 2 => STDERR], $pipes);
        if (!is_resource($process) || proc_close($process) !== 0) {
            throw new RuntimeException('Database export failed.');
        }
    } finally {
        $stmt = $pdo->prepare('SELECT RELEASE_LOCK(?)');
        $stmt->execute([database_maintenance_lock_name()]);
    }
} catch (Throwable $error) {
    fwrite(STDERR, "Database backup failed; check operator credentials, privileges and maintenance lock.\n");
    exit(1);
}
