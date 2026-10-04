<?php
declare(strict_types=1);

// Uses a synthetic image to verify the public nginx route without customer data.
if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}
require_once __DIR__ . '/../api/config.php';

function check_media_response(string $url, int $expectedStatus, ?string $expectedBody = null): void
{
    $curl = curl_init($url);
    curl_setopt_array($curl, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_CONNECTTIMEOUT => 10,
        CURLOPT_TIMEOUT => 25,
        CURLOPT_FOLLOWLOCATION => false,
    ]);
    $body = curl_exec($curl);
    $status = (int) curl_getinfo($curl, CURLINFO_RESPONSE_CODE);
    curl_close($curl);
    if ($status !== $expectedStatus || $body === false || ($expectedBody !== null && $body !== $expectedBody)) {
        throw new RuntimeException('Private media delivery check failed: expected HTTP ' . $expectedStatus . ', received ' . $status . '.');
    }
}

$relative = sanitize_upload_relative_dir(RECEIPTS_REL_DIR) . '/delivery-check-' . bin2hex(random_bytes(16)) . '.png';
$absolute = upload_relative_path_to_abs($relative);
$image = base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=', true);
$_SERVER['SCRIPT_NAME'] = '/api/receipt-media.php';
umask(0077);
$exitCode = 0;
try {
    if (!str_starts_with(public_base_url(), 'https://')) {
        throw new RuntimeException('Configure TRIP_PUBLIC_BASE_URL with the production HTTPS URL.');
    }
    ensure_receipts_dir();
    if (file_put_contents($absolute, $image, LOCK_EX) !== strlen($image)) {
        throw new RuntimeException('Could not create synthetic receipt.');
    }
    check_media_response((string) receipt_public_url($relative), 200, $image);
    check_media_response((string) project_public_url($relative), 404);
    check_media_response((string) project_public_url('api/receipt-media.php'), 404);
    echo "PASS signed image delivery, direct-file denial and unsigned-request denial.\n";
} catch (Throwable $error) {
    // Never log signed URLs, signatures or credential values.
    fwrite(STDERR, $error->getMessage() . "\n");
    $exitCode = 1;
} finally {
    if (is_string($absolute) && is_file($absolute)) {
        unlink($absolute);
    }
}
exit($exitCode);
