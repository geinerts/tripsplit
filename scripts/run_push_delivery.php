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
    $options = parse_push_delivery_cli_options($argv);
    $pdo = db();
    $result = process_push_queue($pdo, [
        'limit' => $options['limit'],
        'dry_run' => $options['dry_run'],
    ]);

    echo "Push delivery\n";
    echo '  enabled: ' . (($result['enabled'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  queue_table_available: ' . (($result['queue_table_available'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  tokens_table_available: ' . (($result['tokens_table_available'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  dry_run: ' . (($result['dry_run'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  picked: ' . (int) ($result['picked'] ?? 0) . "\n";
    echo '  sent: ' . (int) ($result['sent'] ?? 0) . "\n";
    echo '  failed: ' . (int) ($result['failed'] ?? 0) . "\n";
    echo '  requeued: ' . (int) ($result['requeued'] ?? 0) . "\n";
    echo '  skipped: ' . (int) ($result['skipped'] ?? 0) . "\n";

    $rows = $result['rows'] ?? [];
    if (is_array($rows) && $rows) {
        echo "\nRows:\n";
        foreach ($rows as $row) {
            if (!is_array($row)) {
                continue;
            }
            echo '  - queue_id=' . (int) ($row['queue_id'] ?? 0)
                . ' user_id=' . (int) ($row['user_id'] ?? 0)
                . ' type=' . (string) ($row['type'] ?? 'info')
                . ' attempts=' . (int) ($row['attempts'] ?? 0)
                . "\n";
        }
    }
}

function parse_push_delivery_cli_options(array $argv): array
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
            echo "Usage: php scripts/run_push_delivery.php [--dry-run] [--limit=100]\n";
            exit(0);
        }
        throw new InvalidArgumentException('Unknown option: ' . $arg);
    }

    return $result;
}
