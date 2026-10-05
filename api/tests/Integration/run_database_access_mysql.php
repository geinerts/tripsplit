<?php
declare(strict_types=1);

require __DIR__ . '/../Fixtures/isolated_mysql.php';
isolated_test_mysql();
require __DIR__ . '/../../../scripts/lib/database_access.php';

$admin = new PDO('mysql:host=mysql;charset=utf8mb4', 'root', 'isolated-test-root-not-production', [
    PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
]);
$schema = 'splyto_access_test';
$admin->exec('DROP DATABASE IF EXISTS ' . $schema);
$admin->exec('CREATE DATABASE ' . $schema);
$connections = [];
foreach (database_identity_privileges() as $role => $grants) {
    $user = 'access_' . $role;
    $admin->exec("DROP USER IF EXISTS '{$user}'@'%'");
    $admin->exec("CREATE USER '{$user}'@'%' IDENTIFIED BY 'isolated-access-only'");
    $admin->exec('GRANT ' . implode(', ', $grants) . " ON {$schema}.* TO '{$user}'@'%'");
    $connections[$role] = new PDO('mysql:host=mysql;dbname=' . $schema, $user, 'isolated-access-only', [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION,
    ]);
}
$assertions = 0;
function access_check(bool $ok, string $message): void
{
    global $assertions;
    if (!$ok) { throw new RuntimeException($message); }
    $assertions++;
}
function denied(PDO $pdo, string $sql): void
{
    try { $pdo->exec($sql); } catch (PDOException $error) {
        access_check(in_array((int) ($error->errorInfo[1] ?? 0), [1044, 1142, 1143, 1227], true),
            'Expected a permission denial, not another SQL failure');
        return;
    }
    throw new RuntimeException('Unexpectedly permitted: ' . $sql);
}
$migrator = $connections['migrator'];
$runtime = $connections['runtime'];
$backup = $connections['backup'];
$migrator->exec('CREATE TABLE example (id INT PRIMARY KEY, amount INT) ENGINE=InnoDB');
$migrator->exec('ALTER TABLE example ADD COLUMN note VARCHAR(100) NULL');
$migrator->exec('CREATE INDEX amount_index ON example(amount)');
$migrator->exec('CREATE TABLE child (id INT PRIMARY KEY, parent_id INT, FOREIGN KEY(parent_id) REFERENCES example(id))');
$runtime->beginTransaction();
$runtime->exec('INSERT INTO example VALUES (1, 50, NULL)');
$runtime->exec('UPDATE example SET amount=60 WHERE id=1');
access_check((int) $runtime->query('SELECT amount FROM example WHERE id=1 FOR UPDATE')->fetchColumn() === 60, 'Runtime DML');
$runtime->exec('DELETE FROM example WHERE id=1');
$runtime->rollBack();
$migrator->exec('INSERT INTO example VALUES (2, 70, NULL)');
access_check((int) $backup->query('SELECT amount FROM example WHERE id=2')->fetchColumn() === 70, 'Backup reads data');
$backup->exec('START TRANSACTION WITH CONSISTENT SNAPSHOT');
$backup->query('SHOW CREATE TABLE example')->fetchAll();
$backup->exec('ROLLBACK');
foreach ([$runtime, $backup] as $pdo) {
    foreach (['CREATE TABLE forbidden (id INT)', 'ALTER TABLE example ADD COLUMN forbidden INT',
        'DROP TABLE example', 'TRUNCATE TABLE example', 'CREATE INDEX forbidden_idx ON example(amount)'] as $sql) {
        denied($pdo, $sql);
    }
}
foreach (['INSERT INTO example VALUES (3, 80, NULL)', 'UPDATE example SET amount=80 WHERE id=2',
    'DELETE FROM example WHERE id=2'] as $sql) { denied($backup, $sql); }
foreach ($connections as $pdo) {
    denied($pdo, 'SELECT * FROM mysql.user');
    denied($pdo, "CREATE USER 'forbidden_user'@'localhost'");
    denied($pdo, "GRANT SELECT ON {$schema}.* TO 'access_backup'@'%'");
}

// Run the actual CLI with operator credentials while runtime settings remain DML-only.
$dir = sys_get_temp_dir() . '/splyto-access-' . bin2hex(random_bytes(6));
mkdir($dir, 0700);
$credentials = $dir . '/migrations.cnf';
file_put_contents($credentials, "[client]\nhost=mysql\nuser=access_migrator\npassword=isolated-access-only\n");
chmod($credentials, 0600);
mkdir($dir . '/sql', 0700);
file_put_contents($dir . '/sql/001-test.sql', 'CREATE TABLE trip_migration_probe (id INT PRIMARY KEY); INSERT INTO trip_migration_probe VALUES (1);');
$env = array_merge(getenv(), ['TRIP_DB_HOST' => 'mysql', 'TRIP_DB_NAME' => $schema,
    'TRIP_DB_USER' => 'access_runtime', 'TRIP_DB_PASS' => 'isolated-access-only',
    'TRIP_MIGRATION_CREDENTIALS_FILE' => $credentials]);
$run = static function (array $args, array $env): int {
    $process = proc_open(array_merge([PHP_BINARY, '/workspace/scripts/run_migrations.php'], $args),
        [STDIN, STDOUT, STDERR], $pipes, null, $env);
    return is_resource($process) ? proc_close($process) : -1;
};
try {
    access_check($run(['--migrations-dir=' . $dir . '/sql', '--dry-run'], $env) === 0, 'Fresh schema dry-run');
    access_check((int) $admin->query("SELECT COUNT(*) FROM information_schema.TABLES WHERE TABLE_SCHEMA='{$schema}' AND TABLE_NAME='trip_schema_migrations'")->fetchColumn() === 0,
        'Dry-run must not create tables');
    access_check($run(['--migrations-dir=' . $dir . '/sql'], $env) === 0, 'Actual migrator applies');
    access_check($run(['--migrations-dir=' . $dir . '/sql', '--dry-run'], $env) === 0, 'Actual migrator dry-run');
    access_check((int) $backup->query('SELECT COUNT(*) FROM trip_schema_migrations')->fetchColumn() === 1, 'Migration recorded');
    // GET_LOCK is available to read-only backup and excludes the migrator.
    $lock = 'trip_schema_migrations_' . substr(hash('sha256', 'mysql:' . $schema . ':trip_'), 0, 20);
    access_check((int) $backup->query('SELECT GET_LOCK(' . $backup->quote($lock) . ', 0)')->fetchColumn() === 1, 'Backup lock');
    access_check($run(['--migrations-dir=' . $dir . '/sql', '--lock-timeout-sec=1'], $env) !== 0, 'Migration blocked by backup');
    $backup->query('SELECT RELEASE_LOCK(' . $backup->quote($lock) . ')');
    $env['TRIP_MIGRATION_CREDENTIALS_FILE'] = $dir . '/missing';
    access_check($run(['--migrations-dir=' . $dir . '/sql'], $env) !== 0, 'Missing operator credentials fail closed');
    $env['TRIP_MIGRATION_CREDENTIALS_FILE'] = $credentials;
    file_put_contents($credentials, "[client]\nhost=mysql\nuser=access_runtime\npassword=isolated-access-only\n");
    access_check($run(['--migrations-dir=' . $dir . '/sql'], $env) !== 0, 'Runtime credentials rejected as operator credentials');
} finally {
    unlink($credentials);
    unlink($dir . '/sql/001-test.sql');
    rmdir($dir . '/sql');
    rmdir($dir);
}
echo "Database identity isolation: {$assertions} assertions PASS\n";
