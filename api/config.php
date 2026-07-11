<?php
declare(strict_types=1);

require_once __DIR__ . '/config/config_env.php';

// Production secrets live outside the web root. Local development continues
// to use the ignored project .env file when the system file is absent.
$configuredEnvFile = trim((string) getenv('TRIP_ENV_FILE'));
$envFiles = [
    $configuredEnvFile,
    '/etc/splyto/splyto.env',
    __DIR__ . '/../.env',
    __DIR__ . '/.env',
];

foreach (array_unique($envFiles) as $envFile) {
    if ($envFile !== '') {
        load_env_file($envFile);
    }
}

require_once __DIR__ . '/config/config_constants.php';
require_once __DIR__ . '/config/config_db.php';
require_once __DIR__ . '/config/config_uploads.php';
require_once __DIR__ . '/config/config_http.php';
require_once __DIR__ . '/config/config_auth_logging_rate.php';
require_once __DIR__ . '/config/config_user_validation.php';
