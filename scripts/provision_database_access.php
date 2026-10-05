#!/usr/bin/env php
<?php
declare(strict_types=1);

// One-time local VPS transition; never provision from an HTTP request or a migration.
if (PHP_SAPI !== 'cli' || !function_exists('posix_geteuid') || posix_geteuid() !== 0) {
    fwrite(STDERR, "Run as the local server administrator.\n");
    exit(1);
}
require __DIR__ . '/../api/config.php';
require_once __DIR__ . '/lib/database_access.php';

try {
    if (!in_array(DB_HOST, ['localhost', '127.0.0.1'], true) ||
        !preg_match('/^[A-Za-z0-9_]+$/D', DB_NAME) ||
        !preg_match('/^[A-Za-z0-9_]+$/D', DB_USER)) {
        throw new RuntimeException('Only a local database with simple identifiers is supported.');
    }
    $admin = new PDO('mysql:unix_socket=/var/run/mysqld/mysqld.sock;charset=utf8mb4', 'root', '', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
        PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    ]);
    $runtimeIdentity = db()->query('SELECT CURRENT_USER()')->fetchColumn();
    if ($runtimeIdentity !== DB_USER . '@localhost') {
        throw new RuntimeException('Unexpected runtime account host.');
    }
    $grantee = "'" . DB_USER . "'@'localhost'";
    $stmt = $admin->prepare('SELECT PRIVILEGE_TYPE FROM information_schema.SCHEMA_PRIVILEGES
        WHERE GRANTEE=? AND TABLE_SCHEMA=? AND IS_GRANTABLE=\'NO\'');
    $stmt->execute([$grantee, DB_NAME]);
    $existing = $stmt->fetchAll(PDO::FETCH_COLUMN);
    $roles = database_identity_privileges();
    if (array_diff($roles['runtime'], $existing)) {
        throw new RuntimeException('Runtime data grants are incomplete; refusing automatic transition.');
    }
    $checks = [
        ['SELECT COUNT(*) FROM information_schema.USER_PRIVILEGES WHERE GRANTEE=? AND PRIVILEGE_TYPE<>\'USAGE\'', [$grantee]],
        ['SELECT COUNT(*) FROM information_schema.SCHEMA_PRIVILEGES WHERE GRANTEE=? AND (TABLE_SCHEMA<>? OR IS_GRANTABLE=\'YES\')', [$grantee, DB_NAME]],
        ['SELECT COUNT(*) FROM information_schema.TABLE_PRIVILEGES WHERE GRANTEE=?', [$grantee]],
        ['SELECT COUNT(*) FROM information_schema.COLUMN_PRIVILEGES WHERE GRANTEE=?', [$grantee]],
        ['SELECT COUNT(*) FROM mysql.role_edges WHERE TO_USER=?', [DB_USER]],
        ['SELECT COUNT(*) FROM mysql.proxies_priv WHERE User=?', [DB_USER]],
        ['SELECT COUNT(*) FROM information_schema.ROUTINES WHERE ROUTINE_SCHEMA=?', [DB_NAME]],
        ['SELECT COUNT(*) FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA=?', [DB_NAME]],
        ['SELECT COUNT(*) FROM information_schema.EVENTS WHERE EVENT_SCHEMA=?', [DB_NAME]],
        ['SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA=? AND TABLE_TYPE=\'BASE TABLE\' AND ENGINE<>\'InnoDB\'', [DB_NAME]],
    ];
    foreach ($checks as [$sql, $params]) {
        $stmt = $admin->prepare($sql);
        $stmt->execute($params);
        if ((int) $stmt->fetchColumn() !== 0) {
            throw new RuntimeException('Unexpected grants or schema objects require manual review.');
        }
    }
    $accounts = ['migrator' => ['splyto_migrator', '/etc/splyto/migrations.cnf'],
        'backup' => ['splyto_backup', '/etc/splyto/backup.cnf']];
    foreach ($accounts as [$user, $file]) {
        $stmt = $admin->prepare('SELECT COUNT(*) FROM mysql.user WHERE User=?');
        $stmt->execute([$user]);
        if ((int) $stmt->fetchColumn() !== 0 || file_exists($file) || is_link($file)) {
            throw new RuntimeException('Operator identity already exists; inspect before re-running provisioning.');
        }
    }
    if (($argv[1] ?? '') !== '--apply') {
        echo "Preflight OK. Use --apply to create protected operator accounts and reduce runtime grants.\n";
        exit(0);
    }
    umask(0077);
    foreach ($accounts as $role => [$user, $file]) {
        $password = bin2hex(random_bytes(32));
        $handle = fopen($file, 'x');
        if ($handle === false) {
            throw new RuntimeException('Cannot exclusively create operator credentials.');
        }
        try {
            $content = "[client]\nhost=localhost\nuser={$user}\npassword={$password}\n";
            if (fwrite($handle, $content) !== strlen($content) || !fflush($handle)) {
                throw new RuntimeException('Cannot persist operator credentials.');
            }
        } finally {
            fclose($handle);
        }
        $account = $admin->quote($user) . "@'localhost'";
        $admin->exec('CREATE USER ' . $account . ' IDENTIFIED BY ' . $admin->quote($password));
        $admin->exec('GRANT ' . implode(', ', $roles[$role]) . ' ON `' . DB_NAME . '`.* TO ' . $account);
        operator_database_connection($file)->query('SELECT 1');
        echo "Verified separate {$role} connection.\n";
    }
    // Preserve DML throughout the transition; revoke only the excess schema privileges.
    $excess = array_diff($existing, $roles['runtime']);
    if ($excess) {
        $admin->exec('REVOKE ' . implode(', ', $excess) . ' ON `' . DB_NAME . '`.* FROM ' . $grantee);
    }
    echo "Runtime reduced to SELECT, INSERT, UPDATE, DELETE. No runtime password changed.\n";
} catch (Throwable $error) {
    // SQL exception text can contain the CREATE USER statement and its password.
    fwrite(STDERR, "Database privilege transition stopped. Inspect account/file state as administrator before retrying; credentials were not printed.\n");
    exit(1);
}
