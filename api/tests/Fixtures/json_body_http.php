<?php
declare(strict_types=1);

// Isolated HTTP parser probe: no application config, credentials or database.
define('API_MAX_JSON_BYTES', 65_536);
define('TRUST_PROXY_HEADERS', false);
function request_id(): string { return 'parser-test'; }
require __DIR__ . '/../../config/config_http.php';

if (isset($_GET['no_length'])) unset($_SERVER['CONTENT_LENGTH']);
$body = read_json(isset($_GET['photo']) ? 720_896 : null);
json_out(['ok' => true, 'bytes' => strlen($body['photo_base64'] ?? '')]);
