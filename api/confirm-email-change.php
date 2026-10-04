<?php
declare(strict_types=1);
require_once __DIR__ . '/web_security_headers.php';
http_response_code(410);
header('Cache-Control: no-store');
?>
<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<meta name="referrer" content="no-referrer"><title>Email changes unavailable | Splyto</title></head>
<body><main><h1>Email changes are unavailable</h1>
<p>This link can no longer change your Splyto email address.</p></main></body></html>
