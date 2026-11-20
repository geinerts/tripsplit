#!/usr/bin/env php
<?php
declare(strict_types=1);

// Checks that the tables holding security limits exist. Run after every
// deploy or database restore; exits 1 if any is missing, because those
// actions (login, sign-up, uploads, ...) then answer 503 by design.
//   sudo -u www-data php /var/www/splyto/scripts/check_security_limits.php

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';
require __DIR__ . '/../api/lib/bootstrap.php';

$status = security_limit_storage_status(db());
$missing = array_keys(array_filter($status, static fn (bool $ok): bool => !$ok));
foreach ($status as $table => $ok) {
    echo str_pad($table, 22) . ($ok ? 'ok' : 'MISSING') . "\n";
}
if ($missing !== []) {
    fwrite(STDERR, "Security limits cannot work: run the migrations.\n");
    exit(1);
}
echo "Security limits: all tables present.\n";
