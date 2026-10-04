<?php
declare(strict_types=1);

require_once __DIR__ . '/config.php';

function private_media_not_found(): void
{
    http_response_code(404);
    header('Content-Type: text/plain; charset=utf-8');
    header('Cache-Control: no-store, private, max-age=0');
    header('X-Content-Type-Options: nosniff');
    header('X-Frame-Options: DENY');
    header('Referrer-Policy: no-referrer');
    echo 'Not found.';
    exit;
}

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') !== 'GET') {
    private_media_not_found();
}

$path = $_GET['path'] ?? null;
$expires = $_GET['expires'] ?? null;
$signature = $_GET['signature'] ?? null;
if (!is_string($path) || !is_string($expires) || !is_string($signature)) {
    private_media_not_found();
}
$path = trim($path);
$expiresAt = filter_var($expires, FILTER_VALIDATE_INT);
$signature = strtolower(trim($signature));
if ($path === '' || !is_int($expiresAt)) {
    private_media_not_found();
}

try {
    $path = normalize_private_receipt_path($path);
    $valid = $path !== null && private_receipt_request_is_valid($path, $expiresAt, $signature);
} catch (Throwable $error) {
    error_log('Private receipt validation unavailable.');
    private_media_not_found();
}
if (!$valid) {
    private_media_not_found();
}

$absolutePath = upload_relative_path_to_abs($path);
$receiptsRoot = realpath(receipts_dir_abs());
$resolvedPath = is_string($absolutePath) ? realpath($absolutePath) : false;
if (
    !is_string($receiptsRoot) ||
    !is_string($resolvedPath) ||
    !is_file($resolvedPath) ||
    !str_starts_with($resolvedPath, rtrim($receiptsRoot, DIRECTORY_SEPARATOR) . DIRECTORY_SEPARATOR)
) {
    private_media_not_found();
}

$mime = (new finfo(FILEINFO_MIME_TYPE))->file($resolvedPath);
if (!is_string($mime) || !in_array($mime, ['image/webp', 'image/jpeg', 'image/png'], true)) {
    private_media_not_found();
}

header('Content-Type: ' . $mime);
header('Content-Length: ' . (string) filesize($resolvedPath));
header('Content-Disposition: inline; filename="receipt.' . ($mime === 'image/webp' ? 'webp' : ($mime === 'image/png' ? 'png' : 'jpg')) . '"');
header('Cache-Control: no-store, private, max-age=0');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: no-referrer');
header("Content-Security-Policy: default-src 'none'; frame-ancestors 'none'; sandbox");
header('Cross-Origin-Resource-Policy: same-site');
readfile($resolvedPath);
