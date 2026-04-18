#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';

main($argv);

function main(array $argv): void
{
    $options = parse_migration_cli_options($argv);
    $migrationsDir = normalize_migrations_dir($options['migrations_dir']);
    $table = table_name('schema_migrations');
    $pdo = db();

    ensure_schema_migrations_table($pdo, $table);

    $allMigrations = list_migration_files($migrationsDir);
    if (!$allMigrations) {
        echo "No migration files found in: {$migrationsDir}\n";
        return;
    }

    if ($options['dry_run']) {
        $appliedMap = load_applied_migration_map($pdo, $table);
        [$pendingMigrations, $appliedCount] = resolve_pending_migrations(
            $allMigrations,
            $appliedMap
        );
        print_migration_plan(
            $allMigrations,
            $pendingMigrations,
            $appliedCount,
            $options['baseline'],
            true
        );
        return;
    }

    $lockName = migration_lock_name();
    if (!acquire_migration_lock($pdo, $lockName, $options['lock_timeout_sec'])) {
        throw new RuntimeException(
            'Could not acquire migration lock "' . $lockName . '". Another migration run may be in progress.'
        );
    }

    try {
        $appliedMap = load_applied_migration_map($pdo, $table);
        [$pendingMigrations, $appliedCount] = resolve_pending_migrations(
            $allMigrations,
            $appliedMap
        );
        print_migration_plan(
            $allMigrations,
            $pendingMigrations,
            $appliedCount,
            $options['baseline'],
            false
        );

        if (!$pendingMigrations) {
            echo "No pending migrations.\n";
            return;
        }

        if ($options['limit'] !== null) {
            $pendingMigrations = array_slice($pendingMigrations, 0, $options['limit']);
            echo 'Applying with --limit=' . $options['limit'] . "\n";
        }

        if ($options['baseline']) {
            baseline_pending_migrations($pdo, $table, $pendingMigrations);
            return;
        }

        apply_pending_migrations($pdo, $table, $pendingMigrations);
    } finally {
        release_migration_lock($pdo, $lockName);
    }
}

function parse_migration_cli_options(array $argv): array
{
    $result = [
        'dry_run' => false,
        'baseline' => false,
        'limit' => null,
        'migrations_dir' => __DIR__ . '/../sql/migrations',
        'lock_timeout_sec' => 20,
    ];

    foreach ($argv as $index => $arg) {
        if ($index === 0) {
            continue;
        }
        if ($arg === '--dry-run') {
            $result['dry_run'] = true;
            continue;
        }
        if ($arg === '--baseline') {
            $result['baseline'] = true;
            continue;
        }
        if (strpos($arg, '--limit=') === 0) {
            $raw = trim(substr($arg, strlen('--limit=')));
            if ($raw === '' || !ctype_digit($raw)) {
                throw new InvalidArgumentException('Invalid --limit value.');
            }
            $limit = (int) $raw;
            if ($limit < 1 || $limit > 5000) {
                throw new InvalidArgumentException('--limit must be between 1 and 5000.');
            }
            $result['limit'] = $limit;
            continue;
        }
        if (strpos($arg, '--migrations-dir=') === 0) {
            $raw = trim(substr($arg, strlen('--migrations-dir=')));
            if ($raw === '') {
                throw new InvalidArgumentException('Invalid --migrations-dir value.');
            }
            $result['migrations_dir'] = $raw;
            continue;
        }
        if (strpos($arg, '--lock-timeout-sec=') === 0) {
            $raw = trim(substr($arg, strlen('--lock-timeout-sec=')));
            if ($raw === '' || !ctype_digit($raw)) {
                throw new InvalidArgumentException('Invalid --lock-timeout-sec value.');
            }
            $timeout = (int) $raw;
            if ($timeout < 1 || $timeout > 120) {
                throw new InvalidArgumentException('--lock-timeout-sec must be between 1 and 120.');
            }
            $result['lock_timeout_sec'] = $timeout;
            continue;
        }
        if ($arg === '--help' || $arg === '-h') {
            print_migration_help();
            exit(0);
        }
        throw new InvalidArgumentException('Unknown option: ' . $arg);
    }

    if ($result['dry_run'] && $result['limit'] !== null) {
        throw new InvalidArgumentException('--limit cannot be used together with --dry-run.');
    }

    return $result;
}

function print_migration_help(): void
{
    echo "Usage: php scripts/run_migrations.php [options]\n";
    echo "\n";
    echo "Options:\n";
    echo "  --dry-run                 Show pending migrations without applying.\n";
    echo "  --baseline                Mark pending migrations as applied without executing SQL.\n";
    echo "  --limit=N                 Apply at most N pending migrations in this run.\n";
    echo "  --migrations-dir=PATH     Override migration directory path.\n";
    echo "  --lock-timeout-sec=N      DB lock timeout in seconds (1..120), default 20.\n";
    echo "  --help, -h                Show this help.\n";
    echo "\n";
    echo "Examples:\n";
    echo "  php scripts/run_migrations.php --dry-run\n";
    echo "  php scripts/run_migrations.php --baseline\n";
    echo "  php scripts/run_migrations.php\n";
}

function normalize_migrations_dir(string $rawPath): string
{
    $path = trim($rawPath);
    if ($path === '') {
        throw new InvalidArgumentException('Migrations directory cannot be empty.');
    }

    $resolved = realpath($path);
    if ($resolved === false || !is_dir($resolved)) {
        throw new RuntimeException('Migrations directory not found: ' . $path);
    }

    return $resolved;
}

function ensure_schema_migrations_table(PDO $pdo, string $quotedTableName): void
{
    $rawTableName = trim($quotedTableName, '`');
    if (!preg_match('/^[A-Za-z0-9_]+$/', $rawTableName)) {
        throw new RuntimeException('Invalid schema migrations table name.');
    }

    $sql = 'CREATE TABLE IF NOT EXISTS `' . $rawTableName . '` (
      id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
      migration_name VARCHAR(255) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
      checksum_sha256 CHAR(64) CHARACTER SET ascii COLLATE ascii_general_ci NOT NULL,
      execution_ms INT UNSIGNED NOT NULL DEFAULT 0,
      executed_by VARCHAR(120) NULL,
      applied_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
      PRIMARY KEY (id),
      UNIQUE KEY uq_' . $rawTableName . '_name (migration_name),
      KEY idx_' . $rawTableName . '_applied_at (applied_at, id)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci';

    $pdo->exec($sql);
}

function migration_lock_name(): string
{
    return 'trip_schema_migrations_' . substr(
        hash('sha256', DB_HOST . ':' . DB_NAME . ':' . DB_TABLE_PREFIX),
        0,
        20
    );
}

function acquire_migration_lock(PDO $pdo, string $lockName, int $timeoutSec): bool
{
    $stmt = $pdo->prepare('SELECT GET_LOCK(:lock_name, :timeout_sec)');
    $stmt->bindValue('lock_name', $lockName, PDO::PARAM_STR);
    $stmt->bindValue('timeout_sec', $timeoutSec, PDO::PARAM_INT);
    $stmt->execute();
    $value = $stmt->fetchColumn();
    return (int) $value === 1;
}

function release_migration_lock(PDO $pdo, string $lockName): void
{
    try {
        $stmt = $pdo->prepare('SELECT RELEASE_LOCK(:lock_name)');
        $stmt->execute(['lock_name' => $lockName]);
    } catch (Throwable $error) {
        // Ignore lock release failures so the script can finish gracefully.
    }
}

function list_migration_files(string $migrationsDir): array
{
    $pattern = $migrationsDir . DIRECTORY_SEPARATOR . '*.sql';
    $paths = glob($pattern);
    if (!is_array($paths)) {
        return [];
    }
    sort($paths, SORT_STRING);

    $result = [];
    foreach ($paths as $path) {
        if (!is_file($path) || !is_readable($path)) {
            continue;
        }
        $name = basename($path);
        $sql = (string) file_get_contents($path);
        $sql = preg_replace('/^\xEF\xBB\xBF/', '', $sql) ?? $sql; // Drop UTF-8 BOM if present.
        $checksum = hash('sha256', $sql);
        $result[] = [
            'name' => $name,
            'path' => $path,
            'sql' => $sql,
            'checksum' => $checksum,
        ];
    }

    return $result;
}

function load_applied_migration_map(PDO $pdo, string $table): array
{
    $stmt = $pdo->query(
        'SELECT migration_name, checksum_sha256, applied_at, execution_ms, executed_by
         FROM ' . $table . '
         ORDER BY migration_name ASC'
    );

    $rows = $stmt->fetchAll();
    $map = [];
    foreach ($rows as $row) {
        if (!is_array($row)) {
            continue;
        }
        $name = (string) ($row['migration_name'] ?? '');
        if ($name === '') {
            continue;
        }
        $map[$name] = [
            'checksum_sha256' => (string) ($row['checksum_sha256'] ?? ''),
            'applied_at' => (string) ($row['applied_at'] ?? ''),
            'execution_ms' => (int) ($row['execution_ms'] ?? 0),
            'executed_by' => (string) ($row['executed_by'] ?? ''),
        ];
    }
    return $map;
}

function resolve_pending_migrations(array $allMigrations, array $appliedMap): array
{
    $pending = [];
    $appliedCount = 0;

    foreach ($allMigrations as $migration) {
        $name = (string) ($migration['name'] ?? '');
        $checksum = (string) ($migration['checksum'] ?? '');
        if ($name === '' || $checksum === '') {
            continue;
        }

        if (!array_key_exists($name, $appliedMap)) {
            $pending[] = $migration;
            continue;
        }

        $appliedCount++;
        $appliedChecksum = (string) ($appliedMap[$name]['checksum_sha256'] ?? '');
        if ($appliedChecksum !== $checksum) {
            throw new RuntimeException(
                'Checksum mismatch for already applied migration "' . $name . "\".\n"
                . 'Expected: ' . $appliedChecksum . "\n"
                . 'Current:  ' . $checksum . "\n"
                . 'Do not edit old migrations; create a new migration file instead.'
            );
        }
    }

    return [$pending, $appliedCount];
}

function print_migration_plan(
    array $allMigrations,
    array $pendingMigrations,
    int $appliedCount,
    bool $baseline,
    bool $isDryRun
): void {
    echo "Migration runner\n";
    echo '  total_files: ' . count($allMigrations) . "\n";
    echo '  applied: ' . $appliedCount . "\n";
    echo '  pending: ' . count($pendingMigrations) . "\n";
    if ($baseline) {
        echo '  mode: baseline' . ($isDryRun ? ' (dry-run)' : '') . "\n";
    } else {
        echo '  mode: apply' . ($isDryRun ? ' (dry-run)' : '') . "\n";
    }

    if (!$pendingMigrations) {
        return;
    }

    echo "\nPending migrations:\n";
    foreach ($pendingMigrations as $migration) {
        echo '  - ' . (string) ($migration['name'] ?? 'unknown.sql') . "\n";
    }
    echo "\n";
}

function baseline_pending_migrations(PDO $pdo, string $table, array $pendingMigrations): void
{
    if (!$pendingMigrations) {
        echo "No pending migrations to baseline.\n";
        return;
    }

    $executedBy = migration_executed_by_label(true);
    foreach ($pendingMigrations as $migration) {
        $name = (string) ($migration['name'] ?? '');
        $checksum = (string) ($migration['checksum'] ?? '');
        if ($name === '' || $checksum === '') {
            continue;
        }

        record_applied_migration($pdo, $table, $name, $checksum, 0, $executedBy);
        echo 'BASELINED ' . $name . "\n";
    }

    echo "\nBaseline complete. Pending migrations marked as applied.\n";
}

function apply_pending_migrations(PDO $pdo, string $table, array $pendingMigrations): void
{
    $executedBy = migration_executed_by_label(false);
    foreach ($pendingMigrations as $migration) {
        $name = (string) ($migration['name'] ?? '');
        $sql = (string) ($migration['sql'] ?? '');
        $checksum = (string) ($migration['checksum'] ?? '');
        if ($name === '' || $checksum === '') {
            continue;
        }

        $statements = split_sql_statements($sql);
        $statementCount = count($statements);
        $startedAt = microtime(true);

        foreach ($statements as $statement) {
            $pdo->exec($statement);
        }

        $executionMs = (int) round((microtime(true) - $startedAt) * 1000);
        record_applied_migration($pdo, $table, $name, $checksum, $executionMs, $executedBy);

        echo 'APPLIED ' . $name
            . ' statements=' . $statementCount
            . ' execution_ms=' . $executionMs
            . "\n";
    }

    echo "\nMigration run complete.\n";
}

function record_applied_migration(
    PDO $pdo,
    string $table,
    string $name,
    string $checksum,
    int $executionMs,
    string $executedBy
): void {
    $stmt = $pdo->prepare(
        'INSERT INTO ' . $table . '
         (migration_name, checksum_sha256, execution_ms, executed_by)
         VALUES
         (:migration_name, :checksum_sha256, :execution_ms, :executed_by)'
    );
    $stmt->execute([
        'migration_name' => $name,
        'checksum_sha256' => $checksum,
        'execution_ms' => max(0, $executionMs),
        'executed_by' => $executedBy,
    ]);
}

function migration_executed_by_label(bool $isBaseline): string
{
    $user = trim((string) get_current_user());
    if ($user === '') {
        $user = 'unknown-user';
    }
    $host = trim((string) gethostname());
    if ($host === '') {
        $host = 'unknown-host';
    }

    $label = $user . '@' . $host;
    if ($isBaseline) {
        $label .= ':baseline';
    }
    if (strlen($label) > 120) {
        $label = substr($label, 0, 120);
    }

    return $label;
}

function split_sql_statements(string $sql): array
{
    $statements = [];
    $buffer = '';
    $length = strlen($sql);

    $inSingleQuote = false;
    $inDoubleQuote = false;
    $inBacktick = false;
    $inLineComment = false;
    $inBlockComment = false;

    for ($i = 0; $i < $length; $i++) {
        $char = $sql[$i];
        $next = $i + 1 < $length ? $sql[$i + 1] : '';

        if ($inLineComment) {
            $buffer .= $char;
            if ($char === "\n") {
                $inLineComment = false;
            }
            continue;
        }

        if ($inBlockComment) {
            if ($char === '*' && $next === '/') {
                $buffer .= '*/';
                $i++;
                $inBlockComment = false;
                continue;
            }
            $buffer .= $char;
            continue;
        }

        if (!$inSingleQuote && !$inDoubleQuote && !$inBacktick) {
            if ($char === '#') {
                $buffer .= $char;
                $inLineComment = true;
                continue;
            }
            if (
                $char === '-' &&
                $next === '-' &&
                ($i === 0 || ctype_space($sql[$i - 1]))
            ) {
                $buffer .= '--';
                $i++;
                $inLineComment = true;
                continue;
            }
            if ($char === '/' && $next === '*') {
                $buffer .= '/*';
                $i++;
                $inBlockComment = true;
                continue;
            }
            if ($char === ';') {
                $statement = trim($buffer);
                if ($statement !== '') {
                    $statements[] = $statement;
                }
                $buffer = '';
                continue;
            }
        }

        if ($char === '\'' && !$inDoubleQuote && !$inBacktick) {
            if ($inSingleQuote) {
                if ($next === '\'') {
                    $buffer .= '\'\'';
                    $i++;
                    continue;
                }
                if (!is_sql_quote_escaped($sql, $i)) {
                    $inSingleQuote = false;
                }
            } else {
                $inSingleQuote = true;
            }
            $buffer .= $char;
            continue;
        }

        if ($char === '"' && !$inSingleQuote && !$inBacktick) {
            if ($inDoubleQuote) {
                if ($next === '"') {
                    $buffer .= '""';
                    $i++;
                    continue;
                }
                if (!is_sql_quote_escaped($sql, $i)) {
                    $inDoubleQuote = false;
                }
            } else {
                $inDoubleQuote = true;
            }
            $buffer .= $char;
            continue;
        }

        if ($char === '`' && !$inSingleQuote && !$inDoubleQuote) {
            if ($inBacktick) {
                if ($next === '`') {
                    $buffer .= '``';
                    $i++;
                    continue;
                }
                $inBacktick = false;
            } else {
                $inBacktick = true;
            }
            $buffer .= $char;
            continue;
        }

        $buffer .= $char;
    }

    $tail = trim($buffer);
    if ($tail !== '') {
        $statements[] = $tail;
    }

    return $statements;
}

function is_sql_quote_escaped(string $sql, int $position): bool
{
    $slashCount = 0;
    for ($i = $position - 1; $i >= 0; $i--) {
        if ($sql[$i] !== '\\') {
            break;
        }
        $slashCount++;
    }
    return ($slashCount % 2) === 1;
}
