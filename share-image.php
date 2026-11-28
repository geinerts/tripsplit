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
    $isValid = (bool) ($tripMeta['valid'] ?? false);
    $tripName = $isValid ? trim((string) $tripMeta['trip_name']) : 'Splyto trip';
    $imagePath = $isValid ? trim((string) $tripMeta['image_path']) : '';
    $format = ($_GET['format'] ?? '') === 'jpeg' ? 'jpeg' : 'png';
    share_output_image(share_render_trip_card($tripName, $imagePath), 0, $format);
}

if ($type === 'quick_split') {
    require_once __DIR__ . '/api/lib/web/splyto_share_page_text.php';
    require_once __DIR__ . '/api/lib/web/splyto_split_page_text.php';
    require_once __DIR__ . '/api/lib/actions/quick_splits_actions.php';
    $bill = null;
    try {
        $pdo = db();
        if (rate_limit_try(
            $pdo,
            'quick_split_share_view',
            client_ip_address(),
            QUICK_SPLIT_SHARE_VIEW_IP_MAX,
            QUICK_SPLIT_SHARE_VIEW_WINDOW_SEC
        )) {
            $resolved = quick_split_share_resolve($pdo, share_param(['code']));
            $bill = $resolved !== null ? quick_split_share_page_data($pdo, $resolved) : null;
        }
    } catch (Throwable $error) {
        error_log('Quick split share image failed.');
    }
    if ($bill === null) {
        share_output_image(share_render_fallback_card('Splyto', 'Split bills with friends.'), 60, 'jpeg');
    }
    $language = 'en';
    $money = static fn (int $cents): string => splyto_split_money($cents, $bill['currency_code'], $language);
    $people = array_map(
        static fn (array $person): array => ['name' => $person['name'], 'amount' => $money($person['amount_cents'])],
        $bill['people']
    );
    // Not cached: the link can be stopped at any time, and the card shows names.
    share_output_image(share_render_quick_split_card([
        'title' => $bill['note'] !== '' ? $bill['note'] : splyto_split_text($language, 'title_fallback'),
        'total' => $money($bill['amount_cents']),
        'date' => splyto_split_date($bill['date'], $language),
        'people' => $people,
    ]), 0, 'jpeg');
}

share_output_png(share_render_fallback_card('Splyto', 'Open the link in the app.'), 60);
