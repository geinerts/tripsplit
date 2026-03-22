<?php
declare(strict_types=1);

function push_send_apns(array $tokenRow, array $notification): array
{
    if (!push_apns_enabled()) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs is not configured.',
        ];
    }

    $token = trim((string) ($tokenRow['push_token'] ?? ''));
    if ($token === '') {
        return [
            'ok' => false,
            'permanent' => true,
            'error' => 'Empty APNs token.',
        ];
    }

    $jwt = push_apns_jwt();
    if ($jwt === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs JWT generation failed.',
        ];
    }

    $topic = trim((string) ($tokenRow['app_bundle'] ?? ''));
    if ($topic === '') {
        $topic = trim((string) PUSH_APNS_BUNDLE_ID);
    }
    if ($topic === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs topic is missing.',
        ];
    }

    $endpointBase = PUSH_APNS_USE_SANDBOX
        ? 'https://api.sandbox.push.apple.com'
        : 'https://api.push.apple.com';
    $endpoint = $endpointBase . '/3/device/' . $token;

    $dataPayload = [
        'trip_id' => (int) ($notification['trip_id'] ?? 0),
        'type' => (string) ($notification['type'] ?? 'info'),
    ];
    $rawPayload = $notification['payload'] ?? [];
    if (is_array($rawPayload) && $rawPayload) {
        $dataPayload['payload'] = $rawPayload;
    }
    $body = [
        'aps' => [
            'alert' => [
                'title' => trim((string) ($notification['title'] ?? 'Notification')),
                'body' => trim((string) ($notification['body'] ?? '')),
            ],
            'sound' => 'default',
        ],
        'data' => $dataPayload,
    ];

    $encodedBody = json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    if (!is_string($encodedBody) || $encodedBody === '') {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs payload encoding failed.',
        ];
    }

    $ch = curl_init($endpoint);
    if (!is_resource($ch) && !($ch instanceof CurlHandle)) {
        return [
            'ok' => false,
            'permanent' => false,
            'error' => 'APNs curl init failed.',
        ];
    }

    curl_setopt_array($ch, [
        CURLOPT_POST => true,
        CURLOPT_POSTFIELDS => $encodedBody,
        CURLOPT_HTTP_VERSION => defined('CURL_HTTP_VERSION_2_0')
            ? CURL_HTTP_VERSION_2_0
            : CURL_HTTP_VERSION_1_1,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_TIMEOUT => push_timeout_seconds(),
        CURLOPT_CONNECTTIMEOUT => push_timeout_seconds(),
        CURLOPT_HTTPHEADER => [
            'content-type: application/json',
            'authorization: bearer ' . $jwt,
            'apns-topic: ' . $topic,
            'apns-push-type: alert',
            'apns-priority: 10',
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
            'error' => 'APNs curl error: ' . ($curlError !== '' ? $curlError : 'unknown'),
        ];
    }

    if ($statusCode === 200) {
        return [
            'ok' => true,
            'permanent' => false,
            'error' => '',
        ];
    }

    $reason = '';
    $decoded = json_decode((string) $responseRaw, true);
    if (is_array($decoded)) {
        $reason = trim((string) ($decoded['reason'] ?? ''));
    }
    if ($reason === '') {
        $reason = 'HTTP ' . $statusCode;
    }

    $permanentReasons = [
        'BadDeviceToken',
        'Unregistered',
        'DeviceTokenNotForTopic',
        'TopicDisallowed',
    ];
    $isPermanent = in_array($reason, $permanentReasons, true);

    return [
        'ok' => false,
        'permanent' => $isPermanent,
        'error' => 'APNs: ' . $reason,
    ];
}

