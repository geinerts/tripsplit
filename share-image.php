<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';

if (!function_exists('imagecreatetruecolor')) {
    header('Content-Type: image/png');
    header('Cache-Control: public, max-age=60');
    echo base64_decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGOSHzRgAAAAABJRU5ErkJggg==');
    exit;
}

$type = strtolower(trim((string) ($_GET['type'] ?? '')));
if ($type === 'friend') {
    $token = share_normalize_friend_token(share_param(['code', 'friend_token', 'friend_code']));
    $friendUrl = share_absolute_url('/friend', $token !== null ? ['code' => $token] : []);
    $friendMeta = share_friend_meta($token);
    share_output_png(
        share_render_friend_qr_card($friendUrl, $friendMeta),
        (bool) ($friendMeta['valid'] ?? false) ? 300 : 60
    );
}

if ($type === 'trip' || $type === 'invite') {
    $rawInvite = share_param(['invite']);
    $inviteCode = share_normalize_invite_code($rawInvite);
    $tripMeta = share_trip_meta($inviteCode);
    $tripName = trim((string) ($tripMeta['trip_name'] ?? 'Splyto trip'));
    $imagePath = trim((string) ($tripMeta['image_path'] ?? ''));
    share_output_png(share_render_trip_card($tripName, $imagePath), (bool) ($tripMeta['valid'] ?? false) ? 300 : 60);
}

share_output_png(share_render_fallback_card('Splyto', 'Open the link in the app.'), 60);
