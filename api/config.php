<?php
declare(strict_types=1);

require_once __DIR__ . '/config/config_env.php';

load_env_file(__DIR__ . '/../.env');
load_env_file(__DIR__ . '/.env');

require_once __DIR__ . '/config/config_constants.php';
require_once __DIR__ . '/config/config_db.php';
require_once __DIR__ . '/config/config_uploads.php';
require_once __DIR__ . '/config/config_http.php';
require_once __DIR__ . '/config/config_auth_logging_rate.php';
require_once __DIR__ . '/config/config_user_validation.php';
