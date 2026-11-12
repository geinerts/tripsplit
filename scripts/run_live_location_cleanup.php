#!/usr/bin/env php
<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__.'/../api/config.php';
require __DIR__.'/../api/lib/helpers/helper_live_location.php';
require_once __DIR__ . '/../api/lib/helpers/helper_ops_status.php';
cleanup_live_locations(db());
ops_heartbeat('live_location_cleanup');
echo "Live-location cleanup complete.\n";
