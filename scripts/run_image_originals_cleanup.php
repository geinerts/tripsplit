#!/usr/bin/env php
<?php
declare(strict_types=1);

// Removes private image originals nothing refers to any more, such as covers uploaded
// but never attached to a trip. Dry run by default; pass --apply to delete.

if (PHP_SAPI !== 'cli') {
    fwrite(STDERR, "This script must be run from CLI.\n");
    exit(1);
}

require __DIR__ . '/../api/config.php';
require __DIR__ . '/../api/lib/bootstrap.php';

$apply = in_array('--apply', $argv, true);
$orphans = image_originals_orphans(db());
foreach ($orphans as $key) {
    if ($apply) {
        image_source_delete($key);
    }
}
echo 'Image originals cleanup: ' . ($apply ? 'removed ' : 'would remove ') . count($orphans) . "\n";
