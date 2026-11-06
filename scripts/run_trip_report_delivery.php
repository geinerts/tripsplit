#!/usr/bin/env php
<?php
declare(strict_types=1);

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';
require __DIR__ . '/../api/lib/bootstrap.php';

$limit = 20;
foreach (array_slice($argv, 1) as $argument) {
    if (preg_match('/^--limit=(\d+)$/D', $argument, $match)) {
        $limit = max(1, min(200, (int) $match[1]));
    }
}

$result = process_trip_report_deliveries(
    db(),
    static fn(string $to, string $subject, string $html, array $attachments): bool
        => send_email_via_resend($to, $subject, $html, $attachments),
    'trip_report_render_pdf',
    $limit
);

echo 'Trip report delivery: ' . json_encode($result, JSON_THROW_ON_ERROR) . "\n";
