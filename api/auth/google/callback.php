<?php
declare(strict_types=1);

/**
 * Google OAuth callback — exchanges authorization code for id_token,
 * then redirects to the app via deep link.
 *
 * Flow:
 *   1. Google redirects here with ?code=...&state=...
 *   2. This endpoint exchanges the code for tokens (server-side, with client_secret)
 *   3. Redirects to splyto://auth/google?id_token=...&state=...
 */

require_once __DIR__ . '/../../config/config_env.php';

$code  = trim((string) ($_GET['code']  ?? ''));
$state = trim((string) ($_GET['state'] ?? ''));
$error = trim((string) ($_GET['error'] ?? ''));

$appScheme = 'splyto://auth/google';

if ($error !== '') {
    $params = http_build_query(['error' => $error, 'state' => $state]);
    header('Location: ' . $appScheme . '?' . $params, true, 302);
    exit;
}

if ($code === '') {
    $params = http_build_query(['error' => 'missing_code', 'state' => $state]);
    header('Location: ' . $appScheme . '?' . $params, true, 302);
    exit;
}

$clientId     = GOOGLE_WEB_CLIENT_ID;
$clientSecret = GOOGLE_WEB_CLIENT_SECRET;
$redirectUri  = GOOGLE_WEB_REDIRECT_URI;

$tokenPayload = http_build_query([
    'code'          => $code,
    'client_id'     => $clientId,
    'client_secret' => $clientSecret,
    'redirect_uri'  => $redirectUri,
    'grant_type'    => 'authorization_code',
]);

$ch = curl_init('https://oauth2.googleapis.com/token');
curl_setopt_array($ch, [
    CURLOPT_POST           => true,
    CURLOPT_POSTFIELDS     => $tokenPayload,
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_TIMEOUT        => 15,
    CURLOPT_HTTPHEADER     => ['Content-Type: application/x-www-form-urlencoded'],
]);
$response = curl_exec($ch);
$httpCode = (int) curl_getinfo($ch, CURLINFO_HTTP_CODE);
curl_close($ch);

if ($httpCode < 200 || $httpCode >= 300 || !is_string($response)) {
    $params = http_build_query(['error' => 'token_exchange_failed', 'state' => $state]);
    header('Location: ' . $appScheme . '?' . $params, true, 302);
    exit;
}

$tokenData = json_decode($response, true);
$idToken   = trim((string) ($tokenData['id_token'] ?? ''));

if ($idToken === '') {
    $params = http_build_query(['error' => 'no_id_token', 'state' => $state]);
    header('Location: ' . $appScheme . '?' . $params, true, 302);
    exit;
}

$params = http_build_query(['id_token' => $idToken, 'state' => $state]);
header('Location: ' . $appScheme . '?' . $params, true, 302);
exit;
