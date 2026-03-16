<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';
require_once __DIR__ . '/lib/bootstrap.php';
bootstrap_request_id();

try {
    $action = (string) ($_GET['action'] ?? '');

    if (!dispatch_api_action($action)) {
        json_out(['ok' => false, 'error' => 'Unknown action.'], 404);
    }
} catch (Throwable $error) {
    log_api_exception($error, (string) ($action ?? ''));
    $message = APP_DEBUG ? $error->getMessage() : 'Server error.';
    json_out(['ok' => false, 'error' => $message], 500);
}
