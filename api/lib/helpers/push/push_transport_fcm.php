<?php
declare(strict_types=1);

function push_send_fcm(array $tokenRow, array $notification): array
{
    $serverKey = trim((string) PUSH_FCM_SERVER_KEY);
    if ($serverKey !== '') {
        return push_send_fcm_legacy($tokenRow, $notification, $serverKey);
    }
    return push_send_fcm_v1($tokenRow, $notification);
}

function push_send_fcm_legacy(array $tokenRow, array $notification, string $serverKey): array
{
    $token = trim((string) ($tokenRow['push_token'] ?? ''));
    if ($token === '') {
        return [
            'ok' => false,
            'permanent' => true,
            'error' => 'Empty FCM token.',
        ];
    }

    $dataPayload = push_fcm_data_payload($notification);
    $requestBody = [
        'to' => $token,
        'priority' => 'high',
        'data' => $dataPayload,
    ];
    $encodedBody = json_encode($requestBody, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($encodedBody) || $encodedBody === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM payload encoding failed.',
        ];
    }

    $ch = curl_init('https://fcm.googleapis.com/fcm/send');
    if (!is_resource($ch) && !($ch instanceof CurlHandle)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM curl init failed.',
        ];
    }

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $encodedBody,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => push_timeout_seconds(),
        CURLOPT_CONNECTTIMEOUT => push_timeout_seconds(),
        CURLOPT_HTTPHEADER => [
            'content-type: application/json',
            'authorization: key=' . $serverKey,
        ],
    ]);

    $responseRaw = curl_exec($ch);
    $curlError = curl_error($ch);
    $statusCode = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);

    if ($responseRaw === false) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM curl error: ' . ($curlError !== '' ? $curlError : 'unknown'),
        ];
    }

    if ($statusCode !== 200) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM HTTP ' . $statusCode,
        ];
    }

    $decoded = json_decode((string) $responseRaw, true);
    if (!is_array($decoded)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM invalid JSON response.',
        ];
    }

    $success = (int) ($decoded['success'] ?? 0);
    if ($success > 0) {
        return [
            'ok' => true,
            'permanent' => false,
            'error' => '',
        ];
    }

    $errorCode = '';
    if (isset($decoded['results'][0]) && is_array($decoded['results'][0])) {
        $errorCode = trim((string) ($decoded['results'][0]['error'] ?? ''));
    }
    if ($errorCode === '') {
        $errorCode = 'UnknownError';
    }
    $permanentCodes = ['NotRegistered', 'InvalidRegistration', 'MismatchSenderId'];

    return [
        'ok' => false,
        'permanent' => in_array($errorCode, $permanentCodes, true),
        'error' => 'FCM: ' . $errorCode,
    ];
}

function push_send_fcm_v1(array $tokenRow, array $notification): array
{
    $token = trim((string) ($tokenRow['push_token'] ?? ''));
    if ($token === '') {
        return [
            'ok' => false,
            'permanent' => true,
            'error' => 'Empty FCM token.',
        ];
    }

    $projectId = push_fcm_project_id();
    if ($projectId === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM project id is missing. Set TRIP_PUSH_FCM_PROJECT_ID or provide a valid service account json.',
        ];
    }

    $accessToken = push_fcm_v1_access_token();
    if ($accessToken === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM v1 access token is missing. Set TRIP_PUSH_FCM_SERVICE_ACCOUNT_REL_PATH (or TRIP_PUSH_FCM_SERVER_KEY for legacy).',
        ];
    }

    $dataPayload = push_fcm_data_payload($notification);
    $requestBody = [
        'message' => [
            'token' => $token,
            'data' => $dataPayload,
            'android' => [
                'priority' => 'HIGH',
            ],
        ],
    ];
    $encodedBody = json_encode($requestBody, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($encodedBody) || $encodedBody === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM v1 payload encoding failed.',
        ];
    }

    $endpoint = 'https://fcm.googleapis.com/v1/projects/' . rawurlencode($projectId) . '/messages:send';
    $ch = curl_init($endpoint);
    if (!is_resource($ch) && !($ch instanceof CurlHandle)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM v1 curl init failed.',
        ];
    }

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $encodedBody,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => push_timeout_seconds(),
        CURLOPT_CONNECTTIMEOUT => push_timeout_seconds(),
        CURLOPT_HTTPHEADER => [
            'Content-Type: application/json',
            'Authorization: Bearer ' . $accessToken,
        ],
    ]);

    $responseRaw = curl_exec($ch);
    $curlError = curl_error($ch);
    $statusCode = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);

    if ($responseRaw === false) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'FCM v1 curl error: ' . ($curlError !== '' ? $curlError : 'unknown'),
        ];
    }

    if ($statusCode >= 200 && $statusCode < 300) {
        return [
            'ok' => true,
            'permanent' => false,
            'error' => '',
        ];
    }

    $decoded = json_decode((string) $responseRaw, true);
    $status = '';
    $message = '';
    if (is_array($decoded) && isset($decoded['error']) && is_array($decoded['error'])) {
        $status = trim((string) ($decoded['error']['status'] ?? ''));
        $message = trim((string) ($decoded['error']['message'] ?? ''));
    }
    if ($status === '') {
        $status = 'HTTP_' . $statusCode;
    }
    $fcmErrorCode = push_fcm_v1_detail_error_code(is_array($decoded) ? $decoded : []);
    $isPermanent = push_fcm_v1_error_is_permanent($status, $message, $fcmErrorCode);

    $label = $status;
    if ($fcmErrorCode !== '') {
        $label .= ' (' . $fcmErrorCode . ')';
    }
    if ($message !== '') {
        $label .= ': ' . $message;
    }

    return [
        'ok' => false,
        'permanent' => $isPermanent,
        'error' => 'FCM v1: ' . $label,
    ];
}

function push_fcm_data_payload(array $notification): array
{
    $title = trim((string) ($notification['title'] ?? 'Notification'));
    $body = trim((string) ($notification['body'] ?? ''));
    $dataPayload = [
        'trip_id' => (string) ((int) ($notification['trip_id'] ?? 0)),
        'type' => trim((string) ($notification['type'] ?? 'info')),
        'title' => $title !== '' ? $title : 'Notification',
        'body' => $body,
    ];
    $rawPayload = $notification['payload'] ?? [];
    if (!is_array($rawPayload) || !$rawPayload) {
        return $dataPayload;
    }

    foreach ($rawPayload as $key => $value) {
        if (!is_string($key) || $key === '') {
            continue;
        }
        if (is_scalar($value) || $value === null) {
            $dataPayload[$key] = (string) $value;
            continue;
        }
        $encodedValue = json_encode($value, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
        if (is_string($encodedValue) && $encodedValue !== '') {
            $dataPayload[$key] = $encodedValue;
        }
    }

    return $dataPayload;
}

function push_fcm_service_account_abs(): string
{
    $relative = trim(str_replace('\\', '/', (string) PUSH_FCM_SERVICE_ACCOUNT_REL_PATH));
    $relative = ltrim($relative, '/');
    if ($relative === '' || strpos($relative, '..') !== false) {
        return '';
    }

    return project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
}

function push_fcm_service_account_data(): array
{
    static $cache = null;
    if (is_array($cache)) {
        return $cache;
    }

    $cache = [
        'ok' => false,
        'project_id' => '',
        'client_email' => '',
        'private_key' => '',
        'token_uri' => '',
    ];

    $path = push_fcm_service_account_abs();
    if ($path === '' || !is_file($path) || !is_readable($path)) {
        return $cache;
    }

    $json = file_get_contents($path);
    if (!is_string($json) || trim($json) === '') {
        return $cache;
    }

    $decoded = json_decode($json, true);
    if (!is_array($decoded)) {
        return $cache;
    }

    $projectId = trim((string) ($decoded['project_id'] ?? ''));
    $clientEmail = trim((string) ($decoded['client_email'] ?? ''));
    $privateKey = trim((string) ($decoded['private_key'] ?? ''));
    $tokenUri = trim((string) ($decoded['token_uri'] ?? 'https://oauth2.googleapis.com/token'));

    if ($clientEmail === '' || $privateKey === '' || $tokenUri === '') {
        return $cache;
    }

    $cache = [
        'ok' => true,
        'project_id' => $projectId,
        'client_email' => $clientEmail,
        'private_key' => $privateKey,
        'token_uri' => $tokenUri,
    ];

    return $cache;
}

function push_fcm_project_id(): string
{
    $projectId = trim((string) PUSH_FCM_PROJECT_ID);
    if ($projectId !== '') {
        return $projectId;
    }

    $serviceAccount = push_fcm_service_account_data();
    return trim((string) ($serviceAccount['project_id'] ?? ''));
}

function push_fcm_v1_access_token(): string
{
    static $cache = [
        'token' => '',
        'expires_at' => 0,
        'fingerprint' => '',
    ];

    $serviceAccount = push_fcm_service_account_data();
    if (!(bool) ($serviceAccount['ok'] ?? false)) {
        return '';
    }

    $clientEmail = (string) ($serviceAccount['client_email'] ?? '');
    $privateKey = (string) ($serviceAccount['private_key'] ?? '');
    $tokenUri = (string) ($serviceAccount['token_uri'] ?? '');
    if ($clientEmail === '' || $privateKey === '' || $tokenUri === '') {
        return '';
    }

    $fingerprint = hash('sha256', $clientEmail . "\n" . $privateKey . "\n" . $tokenUri);
    $now = time();
    if (
        (string) ($cache['fingerprint'] ?? '') === $fingerprint &&
        is_string($cache['token']) && $cache['token'] !== '' &&
        (int) ($cache['expires_at'] ?? 0) > ($now + 60)
    ) {
        return (string) $cache['token'];
    }

    $header = push_base64url_encode(json_encode([
        'alg' => 'RS256',
        'typ' => 'JWT',
    ], JSON_UNESCAPED_SLASHES));
    $claims = push_base64url_encode(json_encode([
        'iss' => $clientEmail,
        'sub' => $clientEmail,
        'aud' => $tokenUri,
        'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
        'iat' => $now,
        'exp' => $now + 3600,
    ], JSON_UNESCAPED_SLASHES));
    if ($header === '' || $claims === '') {
        return '';
    }

    $unsigned = $header . '.' . $claims;
    $keyResource = openssl_pkey_get_private($privateKey);
    if ($keyResource === false) {
        return '';
    }
    $signature = '';
    $signed = openssl_sign($unsigned, $signature, $keyResource, OPENSSL_ALGO_SHA256);
    if (is_resource($keyResource) || $keyResource instanceof OpenSSLAsymmetricKey) {
        openssl_free_key($keyResource);
    }
    if (!$signed || !is_string($signature) || $signature === '') {
        return '';
    }

    $assertion = $unsigned . '.' . push_base64url_encode($signature);
    $postBody = http_build_query([
        'grant_type' => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
        'assertion' => $assertion,
    ], '', '&');

    $ch = curl_init($tokenUri);
    if (!is_resource($ch) && !($ch instanceof CurlHandle)) {
        return '';
    }

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $postBody,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => push_timeout_seconds(),
        CURLOPT_CONNECTTIMEOUT => push_timeout_seconds(),
        CURLOPT_HTTPHEADER => [
            'content-type: application/x-www-form-urlencoded',
        ],
    ]);

    $responseRaw = curl_exec($ch);
    $statusCode = (int) curl_getinfo($ch, CURLINFO_RESPONSE_CODE);
    curl_close($ch);
    if ($responseRaw === false || $statusCode < 200 || $statusCode >= 300) {
        return '';
    }

    $decoded = json_decode((string) $responseRaw, true);
    if (!is_array($decoded)) {
        return '';
    }
    $token = trim((string) ($decoded['access_token'] ?? ''));
    if ($token === '') {
        return '';
    }

    $expiresIn = (int) ($decoded['expires_in'] ?? 3600);
    if ($expiresIn < 120) {
        $expiresIn = 120;
    }
    if ($expiresIn > 3600) {
        $expiresIn = 3600;
    }

    $cache = [
        'token' => $token,
        'expires_at' => $now + $expiresIn,
        'fingerprint' => $fingerprint,
    ];

    return $token;
}

function push_fcm_v1_detail_error_code(array $decoded): string
{
    $details = $decoded['error']['details'] ?? null;
    if (!is_array($details)) {
        return '';
    }

    foreach ($details as $row) {
        if (!is_array($row)) {
            continue;
        }
        $errorCode = trim((string) ($row['errorCode'] ?? ''));
        if ($errorCode !== '') {
            return strtoupper($errorCode);
        }
    }

    return '';
}

function push_fcm_v1_error_is_permanent(string $status, string $message, string $errorCode): bool
{
    $status = strtoupper(trim($status));
    $errorCode = strtoupper(trim($errorCode));
    $messageLower = strtolower(trim($message));

    $permanentErrorCodes = ['UNREGISTERED', 'SENDER_ID_MISMATCH', 'INVALID_ARGUMENT'];
    if ($errorCode !== '' && in_array($errorCode, $permanentErrorCodes, true)) {
        return true;
    }

    if ($status === 'INVALID_ARGUMENT') {
        if (
            strpos($messageLower, 'registration token') !== false ||
            strpos($messageLower, 'not registered') !== false ||
            strpos($messageLower, 'invalid argument') !== false
        ) {
            return true;
        }
    }

    if ($status === 'NOT_FOUND' && strpos($messageLower, 'registration token') !== false) {
        return true;
    }

    return false;
}
