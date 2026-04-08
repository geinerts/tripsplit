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
    $options = parse_email_verification_cleanup_cli_options($argv);
    $pdo = db();
    $result = process_unverified_account_deactivation($pdo, [
        'dry_run' => $options['dry_run'],
        'limit' => $options['limit'],
    ]);

    echo "Email verification cleanup\n";
    echo '  enabled: ' . (($result['enabled'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  table_ready: ' . (($result['table_ready'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  dry_run: ' . (($result['dry_run'] ?? false) ? 'yes' : 'no') . "\n";
    echo '  grace_days: ' . (int) ($result['grace_days'] ?? 0) . "\n";
    echo '  limit: ' . (int) ($result['limit'] ?? 0) . "\n";
    echo '  picked: ' . (int) ($result['picked'] ?? 0) . "\n";
    echo '  deactivated: ' . (int) ($result['deactivated'] ?? 0) . "\n";

    $userIds = $result['user_ids'] ?? [];
    if (is_array($userIds) && $userIds) {
        echo '  user_ids: ' . implode(',', array_map('intval', $userIds)) . "\n";
    }
}

function parse_email_verification_cleanup_cli_options(array $argv): array
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
            if ($limit < 1 || $limit > 2000) {
                throw new InvalidArgumentException('--limit must be between 1 and 2000.');
            }
            $result['limit'] = $limit;
            continue;
        }
        if ($arg === '--help' || $arg === '-h') {
            echo "Usage: php scripts/run_email_verification_cleanup.php [--dry-run] [--limit=300]\n";
            exit(0);
        }
        throw new InvalidArgumentException('Unknown option: ' . $arg);
    }

    return $result;
}
