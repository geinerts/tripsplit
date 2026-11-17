#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';
require __DIR__ . '/../api/lib/bootstrap.php';
require_once __DIR__ . '/../api/lib/helpers/helper_ops_status.php';

$options = ['dry_run' => false, 'limit' => 200];
foreach (array_slice($argv, 1) as $arg) {
    if ($arg === '--dry-run') {
        $options['dry_run'] = true;
    } elseif (str_starts_with($arg, '--limit=') && ctype_digit(substr($arg, 8))) {
        $options['limit'] = max(1, min(500, (int) substr($arg, 8)));
    } elseif ($arg === '--help' || $arg === '-h') {
        echo "Usage: php scripts/run_trip_start_reminders.php [--dry-run] [--limit=200]\n";
        exit(0);
    } else {
        fwrite(STDERR, 'Unknown option: ' . $arg . "\n");
        exit(1);
    }
}

$result = process_trip_start_reminders(db(), $options);
if (!$result['dry_run']) {
    ops_heartbeat('trip_start_reminders', $result['errors'] === 0, $result);
}
echo "Trip start reminders for {$result['date']}\n";
foreach (['dry_run', 'dates_available', 'trips', 'sent', 'skipped', 'errors'] as $key) {
    $value = $result[$key];
    echo '  ' . $key . ': ' . (is_bool($value) ? ($value ? 'yes' : 'no') : (string) $value) . "\n";
}
foreach ($result['rows'] as $row) {
    echo '  - trip_id=' . $row['trip_id'] . ' user_id=' . $row['user_id'] . ' ' . $row['body'] . "\n";
}
