#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';
require __DIR__ . '/../api/lib/bootstrap.php';

main($argv);

function main(array $argv): void
{
    $options = parse_settlement_reminders_cli_options($argv);
    $pdo = db();
    $result = process_auto_settlement_reminders($pdo, [
        'limit' => $options['limit'],
        'dry_run' => $options['dry_run'],
    ]);

    echo "Auto settlement reminders\n";
    echo '  enabled: ' . (($result['enabled'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  table_available: ' . (($result['table_available'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  dry_run: ' . (($result['dry_run'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  limit: ' . (int) ($result['limit'] ?? 0) . "\n";
    echo '  interval_minutes: ' . (int) ($result['interval_minutes'] ?? 0) . "\n";
    echo '  min_age_minutes: ' . (int) ($result['min_age_minutes'] ?? 0) . "\n";
    echo '  picked: ' . (int) ($result['picked'] ?? 0) . "\n";
    echo '  due: ' . (int) ($result['due'] ?? 0) . "\n";
    echo '  sent: ' . (int) ($result['sent'] ?? 0) . "\n";
    echo '  skipped: ' . (int) ($result['skipped'] ?? 0) . "\n";
    echo '  errors: ' . (int) ($result['errors'] ?? 0) . "\n";

    $rows = $result['rows'] ?? [];
    if (is_array($rows) && $rows) {
        echo "\nRows:\n";
        foreach ($rows as $row) {
            if (!is_array($row)) {
                continue;
            }
            echo '  - settlement_id=' . (int) ($row['settlement_id'] ?? 0)
                . ' trip_id=' . (int) ($row['trip_id'] ?? 0)
                . ' status=' . (string) ($row['status'] ?? 'pending')
                . ' target_user_id=' . (int) ($row['target_user_id'] ?? 0)
                . ' title=' . (string) ($row['title'] ?? '')
                . "\n";
        }
    }
}

function parse_settlement_reminders_cli_options(array $argv): array
{
    $result = [
        'dry_run' => false,
        'limit' => null,
    ];

    foreach ($argv as $index => $arg) {
        if ($index === 0) {
            continue;
        }
        if ($arg === '--dry-run') {
            $result['dry_run'] = true;
            continue;
        }
        if (strpos($arg, '--limit=') === 0) {
            $raw = trim(substr($arg, strlen('--limit=')));
            if ($raw === '' || !ctype_digit($raw)) {
                throw new InvalidArgumentException('Invalid --limit value.');
            }
            $limit = (int) $raw;
            if ($limit < 1 || $limit > 500) {
                throw new InvalidArgumentException('--limit must be between 1 and 500.');
            }
            $result['limit'] = $limit;
            continue;
        }
        if ($arg === '--help' || $arg === '-h') {
            echo "Usage: php scripts/run_settlement_reminders.php [--dry-run] [--limit=100]\n";
            exit(0);
        }
        throw new InvalidArgumentException('Unknown option: ' . $arg);
    }

    return $result;
}
