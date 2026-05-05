<?php
declare(strict_types=1);

function share_html(string $value): string
{
    return htmlspecialchars($value, ENT_QUOTES | ENT_SUBSTITUTE, 'UTF-8');
}

function share_public_origin(): string
{
    $origin = public_base_url();
    if ($origin === '') {
        $origin = rtrim(trim((string) PUBLIC_BASE_URL), '/');
    }
    if ($origin === '') {
        $origin = 'https://splyto.eu';
    }
    return preg_replace('#/api$#', '', rtrim($origin, '/')) ?: 'https://splyto.eu';
}

function share_absolute_url(string $path, array $query = []): string
{
    $path = '/' . ltrim($path, '/');
    $url = share_public_origin() . $path;
    if ($query) {
        $url .= '?' . http_build_query($query, '', '&', PHP_QUERY_RFC3986);
    }
    return $url;
}

function share_param(array $names): string
{
    foreach ($names as $name) {
        $value = $_GET[$name] ?? '';
        if (is_scalar($value) && trim((string) $value) !== '') {
            return trim((string) $value);
        }
    }
    return '';
}

function share_normalize_friend_token(string $raw): ?string
{
    $value = strtoupper(trim(rawurldecode($raw)));
    if ($value === '') {
        return null;
    }

    if (str_contains($value, '://')) {
        $query = (string) parse_url($value, PHP_URL_QUERY);
        if ($query !== '') {
            $queryParams = [];
            parse_str($query, $queryParams);
            foreach (['code', 'friend_token', 'friend_code'] as $key) {
                $candidate = strtoupper(trim((string) ($queryParams[$key] ?? '')));
                if ($candidate !== '') {
                    $value = $candidate;
                    break;
                }
            }
        }
    }

    $value = (string) preg_replace('/[^A-Z0-9]/', '', $value);
    return preg_match('/^[A-Z0-9]{16,64}$/', $value) ? $value : null;
}

function share_normalize_invite_code(string $raw): ?string
{
    $value = strtolower(trim(rawurldecode($raw)));
    if ($value === '') {
        return null;
    }

    if (str_contains($value, '://')) {
        $query = (string) parse_url($value, PHP_URL_QUERY);
        if ($query !== '') {
            $queryParams = [];
            parse_str($query, $queryParams);
            $candidate = strtolower(trim((string) ($queryParams['invite'] ?? '')));
            if ($candidate !== '') {
                $value = $candidate;
            }
        }
    }

    if (preg_match('/^[a-z0-9]{10}$/', $value)) {
        return $value;
    }
    if (preg_match('/^[a-z0-9][a-z0-9-]*-([a-z0-9]{10})$/', $value, $match)) {
        return (string) ($match[1] ?? '');
    }
    return null;
}

function share_trip_meta(?string $inviteCode): array
{
    $fallback = [
        'valid' => false,
        'trip_name' => 'Splyto trip',
        'image_path' => '',
        'expires_at' => '',
    ];
    if ($inviteCode === null || $inviteCode === '') {
        return $fallback;
    }

    try {
        $pdo = db();
        $tripsTable = table_name('trips');
        $tripInvitesTable = table_name('trip_invites');
        $tripImageSelect = trips_image_column_available($pdo)
            ? 't.image_path'
            : 'NULL AS image_path';
        $stmt = $pdo->prepare(
            'SELECT
                t.name AS trip_name,
                t.status AS trip_status,
                ' . $tripImageSelect . ',
                i.expires_at,
                i.revoked_at
             FROM ' . $tripInvitesTable . ' i
             JOIN ' . $tripsTable . ' t ON t.id = i.trip_id
             WHERE i.invite_code = :invite_code
             LIMIT 1'
        );
        $stmt->execute(['invite_code' => $inviteCode]);
        $row = $stmt->fetch();
        if (!is_array($row)) {
            return $fallback;
        }

        $revokedAt = trim((string) ($row['revoked_at'] ?? ''));
        $expiresAt = trim((string) ($row['expires_at'] ?? ''));
        $isExpired = $expiresAt === '' || strtotime($expiresAt) === false || strtotime($expiresAt) < time();
        $isActive = normalize_trip_status($row['trip_status'] ?? 'active') === 'active';
        $tripName = trim((string) ($row['trip_name'] ?? ''));
        return [
            'valid' => $revokedAt === '' && !$isExpired && $isActive,
            'trip_name' => $tripName !== '' ? $tripName : 'Splyto trip',
            'image_path' => trim((string) ($row['image_path'] ?? '')),
            'expires_at' => $expiresAt,
        ];
    } catch (Throwable $error) {
        return $fallback;
    }
}

function share_friend_meta(?string $token): array
{
    $fallback = [
        'valid' => false,
    ];
    if ($token === null || $token === '') {
        return $fallback;
    }

    try {
        $pdo = db();
        $tokensTable = table_name('friend_link_tokens');
        $stmt = $pdo->prepare(
            'SELECT id
             FROM ' . $tokensTable . '
             WHERE token_hash = :token_hash
               AND revoked_at IS NULL
               AND expires_at > UTC_TIMESTAMP()
             LIMIT 1'
        );
        $stmt->execute(['token_hash' => hash('sha256', $token)]);
        return [
            'valid' => (bool) $stmt->fetchColumn(),
        ];
    } catch (Throwable $error) {
        return $fallback;
    }
}

function share_send_html_headers(int $maxAgeSeconds = 300): void
{
    header('Content-Type: text/html; charset=utf-8');
    header('Cache-Control: public, max-age=' . max(60, $maxAgeSeconds));
    header('X-Content-Type-Options: nosniff');
    header('Referrer-Policy: strict-origin-when-cross-origin');
    header('Permissions-Policy: camera=(), microphone=(), geolocation=()');
}

function share_open_graph_tags(
    string $title,
    string $description,
    string $url,
    string $imageUrl
): string {
    $safeTitle = share_html($title);
    $safeDescription = share_html($description);
    $safeUrl = share_html($url);
    $safeImage = share_html($imageUrl);
    return implode("\n", [
        '<meta property="og:type" content="website" />',
        '<meta property="og:site_name" content="Splyto" />',
        '<meta property="og:title" content="' . $safeTitle . '" />',
        '<meta property="og:description" content="' . $safeDescription . '" />',
        '<meta property="og:url" content="' . $safeUrl . '" />',
        '<meta property="og:image" content="' . $safeImage . '" />',
        '<meta property="og:image:secure_url" content="' . $safeImage . '" />',
        '<meta property="og:image:type" content="image/png" />',
        '<meta property="og:image:width" content="1200" />',
        '<meta property="og:image:height" content="630" />',
        '<meta name="twitter:card" content="summary_large_image" />',
        '<meta name="twitter:title" content="' . $safeTitle . '" />',
        '<meta name="twitter:description" content="' . $safeDescription . '" />',
        '<meta name="twitter:image" content="' . $safeImage . '" />',
        '<link rel="canonical" href="' . $safeUrl . '" />',
    ]);
}

function share_output_png($image, int $maxAgeSeconds = 300): void
{
    header('Content-Type: image/png');
    header('Cache-Control: public, max-age=' . max(60, $maxAgeSeconds));
    header('X-Content-Type-Options: nosniff');
    imagepng($image);
    exit;
}

function share_hex_color($image, string $hex, int $alpha = 0): int
{
    $hex = ltrim($hex, '#');
    if (strlen($hex) !== 6) {
        $hex = '000000';
    }
    $r = hexdec(substr($hex, 0, 2));
    $g = hexdec(substr($hex, 2, 2));
    $b = hexdec(substr($hex, 4, 2));
    return imagecolorallocatealpha($image, $r, $g, $b, max(0, min(127, $alpha)));
}

function share_create_canvas(int $width = 1200, int $height = 630)
{
    $image = imagecreatetruecolor($width, $height);
    imagealphablending($image, true);
    imagesavealpha($image, true);
    return $image;
}

function share_fill_gradient($image, string $topHex, string $bottomHex): void
{
    $width = imagesx($image);
    $height = imagesy($image);
    $topHex = ltrim($topHex, '#');
    $bottomHex = ltrim($bottomHex, '#');
    $top = [
        hexdec(substr($topHex, 0, 2)),
        hexdec(substr($topHex, 2, 2)),
        hexdec(substr($topHex, 4, 2)),
    ];
    $bottom = [
        hexdec(substr($bottomHex, 0, 2)),
        hexdec(substr($bottomHex, 2, 2)),
        hexdec(substr($bottomHex, 4, 2)),
    ];
    for ($y = 0; $y < $height; $y++) {
        $ratio = $height > 1 ? $y / ($height - 1) : 0;
        $r = (int) round($top[0] + (($bottom[0] - $top[0]) * $ratio));
        $g = (int) round($top[1] + (($bottom[1] - $top[1]) * $ratio));
        $b = (int) round($top[2] + (($bottom[2] - $top[2]) * $ratio));
        imageline($image, 0, $y, $width, $y, imagecolorallocate($image, $r, $g, $b));
    }
}

function share_draw_rounded_rect($image, int $x1, int $y1, int $x2, int $y2, int $radius, int $color): void
{
    imagefilledrectangle($image, $x1 + $radius, $y1, $x2 - $radius, $y2, $color);
    imagefilledrectangle($image, $x1, $y1 + $radius, $x2, $y2 - $radius, $color);
    imagefilledellipse($image, $x1 + $radius, $y1 + $radius, $radius * 2, $radius * 2, $color);
    imagefilledellipse($image, $x2 - $radius, $y1 + $radius, $radius * 2, $radius * 2, $color);
    imagefilledellipse($image, $x1 + $radius, $y2 - $radius, $radius * 2, $radius * 2, $color);
    imagefilledellipse($image, $x2 - $radius, $y2 - $radius, $radius * 2, $radius * 2, $color);
}

function share_font_path(bool $bold = false): string
{
    $candidates = $bold
        ? [
            '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf',
            '/usr/share/fonts/dejavu/DejaVuSans-Bold.ttf',
            '/System/Library/Fonts/Supplemental/Arial Bold.ttf',
            '/Library/Fonts/Arial Bold.ttf',
        ]
        : [
            '/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf',
            '/usr/share/fonts/dejavu/DejaVuSans.ttf',
            '/System/Library/Fonts/Supplemental/Arial.ttf',
            '/Library/Fonts/Arial.ttf',
        ];

    foreach ($candidates as $candidate) {
        if (is_file($candidate) && is_readable($candidate)) {
            return $candidate;
        }
    }
    return '';
}

function share_text_width(string $text, int $size, bool $bold = false): int
{
    $font = share_font_path($bold);
    if ($font !== '' && function_exists('imagettfbbox')) {
        $box = imagettfbbox($size, 0, $font, $text);
        if (is_array($box)) {
            return (int) abs($box[2] - $box[0]);
        }
    }
    return strlen($text) * imagefontwidth(5);
}

function share_draw_text($image, string $text, int $size, int $x, int $y, int $color, bool $bold = false): void
{
    $font = share_font_path($bold);
    if ($font !== '' && function_exists('imagettftext')) {
        imagettftext($image, $size, 0, $x, $y, $color, $font, $text);
        return;
    }
    imagestring($image, 5, $x, max(0, $y - 16), $text, $color);
}

function share_wrap_text(string $text, int $size, int $maxWidth, int $maxLines, bool $bold = false): array
{
    $words = preg_split('/\s+/', trim($text)) ?: [];
    $lines = [];
    $line = '';
    foreach ($words as $word) {
        $candidate = $line === '' ? $word : $line . ' ' . $word;
        if (share_text_width($candidate, $size, $bold) <= $maxWidth) {
            $line = $candidate;
            continue;
        }
        if ($line !== '') {
            $lines[] = $line;
        }
        $line = $word;
        if (count($lines) >= $maxLines) {
            break;
        }
    }
    if ($line !== '' && count($lines) < $maxLines) {
        $lines[] = $line;
    }
    if (count($lines) > $maxLines) {
        $lines = array_slice($lines, 0, $maxLines);
    }
    if ($lines) {
        $lastIndex = count($lines) - 1;
        while (share_text_width($lines[$lastIndex], $size, $bold) > $maxWidth && strlen($lines[$lastIndex]) > 4) {
            $lines[$lastIndex] = rtrim(substr($lines[$lastIndex], 0, -4)) . '...';
        }
    }
    return $lines;
}

function share_load_image_from_path(string $relativePath)
{
    $absolute = upload_relative_path_to_abs($relativePath);
    if (!is_string($absolute) || $absolute === '' || !is_file($absolute)) {
        return null;
    }
    $info = @getimagesize($absolute);
    $mime = is_array($info) ? strtolower((string) ($info['mime'] ?? '')) : '';
    if ($mime === 'image/jpeg' || $mime === 'image/jpg') {
        return @imagecreatefromjpeg($absolute) ?: null;
    }
    if ($mime === 'image/png') {
        return @imagecreatefrompng($absolute) ?: null;
    }
    if ($mime === 'image/webp' && function_exists('imagecreatefromwebp')) {
        return @imagecreatefromwebp($absolute) ?: null;
    }
    return null;
}

function share_draw_cover($dst, $src, int $x, int $y, int $width, int $height): void
{
    $srcWidth = imagesx($src);
    $srcHeight = imagesy($src);
    if ($srcWidth <= 0 || $srcHeight <= 0) {
        return;
    }
    $scale = max($width / $srcWidth, $height / $srcHeight);
    $cropWidth = (int) round($width / $scale);
    $cropHeight = (int) round($height / $scale);
    $srcX = max(0, (int) floor(($srcWidth - $cropWidth) / 2));
    $srcY = max(0, (int) floor(($srcHeight - $cropHeight) / 2));
    imagecopyresampled($dst, $src, $x, $y, $srcX, $srcY, $width, $height, $cropWidth, $cropHeight);
}

function share_logo_path(bool $dark = false): string
{
    $relative = $dark
        ? 'mobile/assets/branding/logo_full_dark.png'
        : 'mobile/assets/branding/logo_full.png';
    $absolute = project_root_abs() . DIRECTORY_SEPARATOR . str_replace('/', DIRECTORY_SEPARATOR, $relative);
    return is_file($absolute) ? $absolute : '';
}

function share_draw_logo($image, int $x, int $y, int $targetWidth, bool $dark = false): void
{
    $path = share_logo_path($dark);
    if ($path === '') {
        share_draw_text($image, 'Splyto', 30, $x, $y + 38, share_hex_color($image, $dark ? '#07110d' : '#f3f8f5'), true);
        return;
    }
    $logo = @imagecreatefrompng($path);
    if (!$logo) {
        return;
    }
    imagealphablending($logo, true);
    imagesavealpha($logo, true);
    $ratio = imagesx($logo) > 0 ? $targetWidth / imagesx($logo) : 1;
    $targetHeight = (int) round(imagesy($logo) * $ratio);
    imagecopyresampled($image, $logo, $x, $y, 0, 0, $targetWidth, $targetHeight, imagesx($logo), imagesy($logo));
}

function share_render_fallback_card(string $title, string $subtitle)
{
    $image = share_create_canvas();
    share_fill_gradient($image, '#04100b', '#163525');
    share_draw_logo($image, 84, 76, 190);
    $white = share_hex_color($image, '#f3f8f5');
    $muted = share_hex_color($image, '#b5c7bd');
    $lines = share_wrap_text($title, 48, 900, 2, true);
    $y = 274;
    foreach ($lines as $line) {
        share_draw_text($image, $line, 48, 84, $y, $white, true);
        $y += 62;
    }
    share_draw_text($image, $subtitle, 24, 88, $y + 34, $muted);
    return $image;
}

function share_render_trip_card(string $tripName, string $imagePath)
{
    $image = share_create_canvas();
    $source = $imagePath !== '' ? share_load_image_from_path($imagePath) : null;
    if ($source) {
        share_draw_cover($image, $source, 0, 0, 1200, 630);
    } else {
        share_fill_gradient($image, '#07110d', '#1e4a33');
    }

    imagefilledrectangle($image, 0, 0, 1200, 630, share_hex_color($image, '#000000', 52));
    imagefilledrectangle($image, 0, 360, 1200, 630, share_hex_color($image, '#000000', 34));
    share_draw_logo($image, 72, 66, 176);

    $accent = share_hex_color($image, '#79d9aa');
    $white = share_hex_color($image, '#f4fbf7');
    $muted = share_hex_color($image, '#c7d6cf');
    share_draw_text($image, 'Trip invite', 24, 78, 400, $accent, true);
    $lines = share_wrap_text($tripName !== '' ? $tripName : 'Join this trip', 54, 940, 2, true);
    $y = 470;
    foreach ($lines as $line) {
        share_draw_text($image, $line, 54, 76, $y, $white, true);
        $y += 68;
    }
    share_draw_text($image, 'Open Splyto to join and split expenses together.', 25, 80, 582, $muted);
    return $image;
}

function share_qr_gf_mul(int $x, int $y, array $exp, array $log): int
{
    if ($x === 0 || $y === 0) {
        return 0;
    }
    return $exp[($log[$x] + $log[$y]) % 255];
}

function share_qr_tables(): array
{
    $exp = array_fill(0, 512, 0);
    $log = array_fill(0, 256, 0);
    $x = 1;
    for ($i = 0; $i < 255; $i++) {
        $exp[$i] = $x;
        $log[$x] = $i;
        $x <<= 1;
        if (($x & 0x100) !== 0) {
            $x ^= 0x11D;
        }
    }
    for ($i = 255; $i < 512; $i++) {
        $exp[$i] = $exp[$i - 255];
    }
    return [$exp, $log];
}

function share_qr_generator_poly(int $degree, array $exp, array $log): array
{
    $poly = [1];
    for ($i = 0; $i < $degree; $i++) {
        $next = array_fill(0, count($poly) + 1, 0);
        foreach ($poly as $j => $coefficient) {
            $next[$j] ^= $coefficient;
            $next[$j + 1] ^= share_qr_gf_mul($coefficient, $exp[$i], $exp, $log);
        }
        $poly = $next;
    }
    return $poly;
}

function share_qr_rs_remainder(array $data, int $ecCodewords): array
{
    [$exp, $log] = share_qr_tables();
    $generator = share_qr_generator_poly($ecCodewords, $exp, $log);
    $result = array_fill(0, $ecCodewords, 0);
    foreach ($data as $byte) {
        $factor = $byte ^ $result[0];
        array_shift($result);
        $result[] = 0;
        for ($i = 0; $i < $ecCodewords; $i++) {
            $result[$i] ^= share_qr_gf_mul($generator[$i + 1], $factor, $exp, $log);
        }
    }
    return $result;
}

function share_qr_data_codewords(string $data): array
{
    $bytes = array_values(unpack('C*', $data) ?: []);
    $bits = [0, 1, 0, 0];
    $length = count($bytes);
    for ($i = 7; $i >= 0; $i--) {
        $bits[] = ($length >> $i) & 1;
    }
    foreach ($bytes as $byte) {
        for ($i = 7; $i >= 0; $i--) {
            $bits[] = ($byte >> $i) & 1;
        }
    }

    $capacityBits = 86 * 8;
    $terminator = min(4, $capacityBits - count($bits));
    for ($i = 0; $i < $terminator; $i++) {
        $bits[] = 0;
    }
    while ((count($bits) % 8) !== 0) {
        $bits[] = 0;
    }

    $codewords = [];
    for ($i = 0; $i < count($bits); $i += 8) {
        $value = 0;
        for ($j = 0; $j < 8; $j++) {
            $value = ($value << 1) | ($bits[$i + $j] ?? 0);
        }
        $codewords[] = $value;
    }
    $pad = [0xEC, 0x11];
    $padIndex = 0;
    while (count($codewords) < 86) {
        $codewords[] = $pad[$padIndex % 2];
        $padIndex++;
    }
    return array_slice($codewords, 0, 86);
}

function share_qr_codewords(string $data): array
{
    $dataCodewords = share_qr_data_codewords($data);
    $blocks = [
        array_slice($dataCodewords, 0, 43),
        array_slice($dataCodewords, 43, 43),
    ];
    $ecBlocks = [
        share_qr_rs_remainder($blocks[0], 24),
        share_qr_rs_remainder($blocks[1], 24),
    ];

    $result = [];
    for ($i = 0; $i < 43; $i++) {
        $result[] = $blocks[0][$i];
        $result[] = $blocks[1][$i];
    }
    for ($i = 0; $i < 24; $i++) {
        $result[] = $ecBlocks[0][$i];
        $result[] = $ecBlocks[1][$i];
    }
    return $result;
}

function share_qr_empty_matrix(): array
{
    $size = 37;
    $matrix = array_fill(0, $size, array_fill(0, $size, 0));
    $reserved = array_fill(0, $size, array_fill(0, $size, false));
    return [$matrix, $reserved];
}

function share_qr_set(array &$matrix, array &$reserved, int $x, int $y, int $value, bool $reserve = true): void
{
    $size = count($matrix);
    if ($x < 0 || $y < 0 || $x >= $size || $y >= $size) {
        return;
    }
    $matrix[$y][$x] = $value ? 1 : 0;
    if ($reserve) {
        $reserved[$y][$x] = true;
    }
}

function share_qr_draw_finder(array &$matrix, array &$reserved, int $x, int $y): void
{
    for ($dy = -1; $dy <= 7; $dy++) {
        for ($dx = -1; $dx <= 7; $dx++) {
            $xx = $x + $dx;
            $yy = $y + $dy;
            if ($xx < 0 || $yy < 0 || $xx >= 37 || $yy >= 37) {
                continue;
            }
            $dark = $dx >= 0 && $dx <= 6 && $dy >= 0 && $dy <= 6
                && ($dx === 0 || $dx === 6 || $dy === 0 || $dy === 6 || ($dx >= 2 && $dx <= 4 && $dy >= 2 && $dy <= 4));
            share_qr_set($matrix, $reserved, $xx, $yy, $dark ? 1 : 0);
        }
    }
}

function share_qr_draw_alignment(array &$matrix, array &$reserved, int $centerX, int $centerY): void
{
    if ($reserved[$centerY][$centerX]) {
        return;
    }
    for ($dy = -2; $dy <= 2; $dy++) {
        for ($dx = -2; $dx <= 2; $dx++) {
            $dark = max(abs($dx), abs($dy)) !== 1;
            share_qr_set($matrix, $reserved, $centerX + $dx, $centerY + $dy, $dark ? 1 : 0);
        }
    }
}

function share_qr_draw_function_patterns(array &$matrix, array &$reserved): void
{
    share_qr_draw_finder($matrix, $reserved, 0, 0);
    share_qr_draw_finder($matrix, $reserved, 30, 0);
    share_qr_draw_finder($matrix, $reserved, 0, 30);

    for ($i = 8; $i <= 28; $i++) {
        $bit = $i % 2 === 0 ? 1 : 0;
        share_qr_set($matrix, $reserved, $i, 6, $bit);
        share_qr_set($matrix, $reserved, 6, $i, $bit);
    }

    foreach ([6, 30] as $cy) {
        foreach ([6, 30] as $cx) {
            share_qr_draw_alignment($matrix, $reserved, $cx, $cy);
        }
    }

    for ($i = 0; $i <= 8; $i++) {
        if ($i !== 6) {
            $reserved[8][$i] = true;
            $reserved[$i][8] = true;
        }
    }
    for ($i = 0; $i < 8; $i++) {
        $reserved[36 - $i][8] = true;
        $reserved[8][36 - $i] = true;
    }
    share_qr_set($matrix, $reserved, 8, 29, 1);
}

function share_qr_mask_bit(int $mask, int $x, int $y): bool
{
    return match ($mask) {
        0 => (($x + $y) % 2) === 0,
        1 => ($y % 2) === 0,
        2 => ($x % 3) === 0,
        3 => (($x + $y) % 3) === 0,
        4 => ((intdiv($y, 2) + intdiv($x, 3)) % 2) === 0,
        5 => ((($x * $y) % 2) + (($x * $y) % 3)) === 0,
        6 => (((($x * $y) % 2) + (($x * $y) % 3)) % 2) === 0,
        default => (((($x + $y) % 2) + (($x * $y) % 3)) % 2) === 0,
    };
}

function share_qr_format_bits(int $mask): int
{
    $data = $mask & 0x07; // Error correction level M.
    $rem = $data;
    for ($i = 0; $i < 10; $i++) {
        $rem = ($rem << 1) ^ ((($rem >> 9) & 1) ? 0x537 : 0);
    }
    return (($data << 10) | ($rem & 0x3FF)) ^ 0x5412;
}

function share_qr_draw_format_bits(array &$matrix, array &$reserved, int $mask): void
{
    $bits = share_qr_format_bits($mask);
    for ($i = 0; $i <= 5; $i++) {
        share_qr_set($matrix, $reserved, 8, $i, ($bits >> $i) & 1);
    }
    share_qr_set($matrix, $reserved, 8, 7, ($bits >> 6) & 1);
    share_qr_set($matrix, $reserved, 8, 8, ($bits >> 7) & 1);
    share_qr_set($matrix, $reserved, 7, 8, ($bits >> 8) & 1);
    for ($i = 9; $i < 15; $i++) {
        share_qr_set($matrix, $reserved, 14 - $i, 8, ($bits >> $i) & 1);
    }
    for ($i = 0; $i < 8; $i++) {
        share_qr_set($matrix, $reserved, 36 - $i, 8, ($bits >> $i) & 1);
    }
    for ($i = 8; $i < 15; $i++) {
        share_qr_set($matrix, $reserved, 8, 36 - 14 + $i, ($bits >> $i) & 1);
    }
    share_qr_set($matrix, $reserved, 8, 29, 1);
}

function share_qr_matrix_with_mask(string $data, int $mask): array
{
    [$matrix, $reserved] = share_qr_empty_matrix();
    share_qr_draw_function_patterns($matrix, $reserved);
    $bits = [];
    foreach (share_qr_codewords($data) as $codeword) {
        for ($i = 7; $i >= 0; $i--) {
            $bits[] = ($codeword >> $i) & 1;
        }
    }

    $bitIndex = 0;
    $upward = true;
    for ($right = 36; $right >= 1; $right -= 2) {
        if ($right === 6) {
            $right--;
        }
        for ($vertical = 0; $vertical < 37; $vertical++) {
            $y = $upward ? 36 - $vertical : $vertical;
            for ($j = 0; $j < 2; $j++) {
                $x = $right - $j;
                if ($reserved[$y][$x]) {
                    continue;
                }
                $bit = $bits[$bitIndex] ?? 0;
                $bitIndex++;
                if (share_qr_mask_bit($mask, $x, $y)) {
                    $bit ^= 1;
                }
                share_qr_set($matrix, $reserved, $x, $y, $bit, false);
            }
        }
        $upward = !$upward;
    }
    share_qr_draw_format_bits($matrix, $reserved, $mask);
    return $matrix;
}

function share_qr_penalty(array $matrix): int
{
    $size = count($matrix);
    $penalty = 0;
    for ($y = 0; $y < $size; $y++) {
        $runColor = $matrix[$y][0];
        $runLength = 1;
        for ($x = 1; $x < $size; $x++) {
            if ($matrix[$y][$x] === $runColor) {
                $runLength++;
                continue;
            }
            if ($runLength >= 5) {
                $penalty += 3 + ($runLength - 5);
            }
            $runColor = $matrix[$y][$x];
            $runLength = 1;
        }
        if ($runLength >= 5) {
            $penalty += 3 + ($runLength - 5);
        }
    }
    for ($x = 0; $x < $size; $x++) {
        $runColor = $matrix[0][$x];
        $runLength = 1;
        for ($y = 1; $y < $size; $y++) {
            if ($matrix[$y][$x] === $runColor) {
                $runLength++;
                continue;
            }
            if ($runLength >= 5) {
                $penalty += 3 + ($runLength - 5);
            }
            $runColor = $matrix[$y][$x];
            $runLength = 1;
        }
        if ($runLength >= 5) {
            $penalty += 3 + ($runLength - 5);
        }
    }
    for ($y = 0; $y < $size - 1; $y++) {
        for ($x = 0; $x < $size - 1; $x++) {
            $color = $matrix[$y][$x];
            if ($matrix[$y][$x + 1] === $color && $matrix[$y + 1][$x] === $color && $matrix[$y + 1][$x + 1] === $color) {
                $penalty += 3;
            }
        }
    }
    $dark = 0;
    for ($y = 0; $y < $size; $y++) {
        for ($x = 0; $x < $size; $x++) {
            $dark += $matrix[$y][$x] ? 1 : 0;
        }
    }
    $percent = ($dark * 100) / ($size * $size);
    $penalty += (int) (abs((int) floor($percent / 5) * 5 - 50) / 5) * 10;
    return $penalty;
}

function share_qr_matrix(string $data): array
{
    $bestMask = 0;
    $bestPenalty = PHP_INT_MAX;
    $bestMatrix = [];
    for ($mask = 0; $mask < 8; $mask++) {
        $matrix = share_qr_matrix_with_mask($data, $mask);
        $penalty = share_qr_penalty($matrix);
        if ($penalty < $bestPenalty) {
            $bestPenalty = $penalty;
            $bestMask = $mask;
            $bestMatrix = $matrix;
        }
    }
    return $bestMatrix ?: share_qr_matrix_with_mask($data, $bestMask);
}

function share_draw_qr($image, string $data, int $x, int $y, int $size): void
{
    $matrix = share_qr_matrix($data);
    $moduleCount = count($matrix);
    $quiet = 4;
    $totalModules = $moduleCount + ($quiet * 2);
    $moduleSize = max(1, (int) floor($size / $totalModules));
    $actualSize = $moduleSize * $totalModules;
    $offsetX = $x + (int) floor(($size - $actualSize) / 2);
    $offsetY = $y + (int) floor(($size - $actualSize) / 2);
    $white = share_hex_color($image, '#ffffff');
    $black = share_hex_color($image, '#050706');
    imagefilledrectangle($image, $x, $y, $x + $size, $y + $size, $white);
    for ($row = 0; $row < $moduleCount; $row++) {
        for ($col = 0; $col < $moduleCount; $col++) {
            if (!$matrix[$row][$col]) {
                continue;
            }
            $left = $offsetX + (($col + $quiet) * $moduleSize);
            $top = $offsetY + (($row + $quiet) * $moduleSize);
            imagefilledrectangle($image, $left, $top, $left + $moduleSize - 1, $top + $moduleSize - 1, $black);
        }
    }
}

function share_render_friend_qr_card(string $friendUrl)
{
    $image = share_create_canvas();
    share_fill_gradient($image, '#03100b', '#173825');
    imagefilledellipse($image, 980, 68, 520, 250, share_hex_color($image, '#57b487', 105));
    imagefilledellipse($image, 160, 620, 460, 210, share_hex_color($image, '#2eaf6e', 110));

    $panel = share_hex_color($image, '#07120d', 10);
    $stroke = share_hex_color($image, '#57b487', 92);
    share_draw_rounded_rect($image, 62, 56, 1138, 574, 40, $panel);
    imagerectangle($image, 102, 96, 498, 492, $stroke);

    $white = share_hex_color($image, '#ffffff');
    share_draw_rounded_rect($image, 92, 86, 520, 514, 32, $white);
    share_draw_qr($image, $friendUrl, 124, 118, 364);

    share_draw_logo($image, 604, 112, 196);
    $accent = share_hex_color($image, '#77d7a7');
    $text = share_hex_color($image, '#f4fbf7');
    $muted = share_hex_color($image, '#b7c9bf');
    share_draw_text($image, 'Friend QR', 26, 608, 234, $accent, true);
    share_draw_text($image, 'Add me on Splyto', 46, 604, 306, $text, true);
    $lines = share_wrap_text('Scan this QR or open the link to send a friend request.', 26, 460, 2);
    $y = 368;
    foreach ($lines as $line) {
        share_draw_text($image, $line, 26, 608, $y, $muted);
        $y += 36;
    }
    share_draw_text($image, 'Private link. No user ID in the URL.', 21, 608, 500, $muted);
    return $image;
}
