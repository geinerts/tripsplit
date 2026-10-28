#!/usr/bin/env php
<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../api/config.php';
require __DIR__.'/../api/lib/helpers/helper_live_location.php';
cleanup_live_locations(db());
echo "Live-location cleanup complete.\n";
