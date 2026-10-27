<?php
declare(strict_types=1);

function travel_places_available(PDO $pdo): bool
{
    $stmt = $pdo->prepare('SELECT COUNT(*) FROM information_schema.tables
        WHERE table_schema = DATABASE() AND table_name = :table_name');
    $stmt->execute(['table_name' => DB_TABLE_PREFIX . 'travel_places']);
    return (int)$stmt->fetchColumn() > 0;
}

function require_travel_places_schema(PDO $pdo): void
{
    if (!travel_places_available($pdo) || !travel_column_available($pdo, 'travel_places', 'trip_id')) {
        json_out(['ok'=>false, 'error'=>'Travel map requires a server update.', 'code'=>'travel_map_unavailable'], 409);
    }
}

function travel_column_available(PDO $pdo, string $table, string $column): bool
{
    $s = $pdo->prepare('SELECT COUNT(*) FROM information_schema.columns WHERE table_schema = DATABASE()
        AND table_name = :table_name AND column_name = :column');
    $s->execute(['table_name'=>DB_TABLE_PREFIX.$table, 'column'=>$column]);
    return (int)$s->fetchColumn() > 0;
}

function trip_destinations_input(PDO $pdo, array $body): ?string
{
    if (!array_key_exists('destinations', $body)) return null;
    $items = $body['destinations'];
    if (!is_array($items) || !array_is_list($items) || count($items)>20) {
        json_out(['ok'=>false,'error'=>'Choose up to 20 destinations.'],400);
    }
    // Empty destinations from a new app remain compatible with an old schema.
    if (!travel_column_available($pdo, 'trips', 'destinations_json')) {
        if (!$items) return null;
        json_out(['ok'=>false,'error'=>'Destinations require a server update.'],409);
    }
    $validated = [];
    foreach ($items as $item) {
        if (!is_array($item)) json_out(['ok'=>false,'error'=>'Invalid destination.'],400);
        $place = validate_travel_place(array_replace($item,['visited_on'=>gmdate('Y-m-d')]));
        $key = $place['place_key'];
        unset($place['visited_on'], $place['place_key']);
        $validated[$key]=$place;
    }
    return json_encode(array_values($validated), JSON_THROW_ON_ERROR|JSON_UNESCAPED_UNICODE);
}

function trip_destinations_payload(array $trip): array
{
    $items = json_decode((string)($trip['destinations_json'] ?? '[]'), true);
    return is_array($items) && array_is_list($items) ? $items : [];
}

/** Decode and re-encode a bounded thumbnail; never store EXIF or arbitrary files. */
function travel_photo_encode(string $bytes): string
{
    $size = @getimagesizefromstring($bytes);
    if (strlen($bytes)>524288 || !$size || $size[0]<1 || $size[1]<1 || $size[0]*$size[1]>12000000
        || !in_array($size['mime'], ['image/jpeg','image/png','image/webp'], true)) {
        json_out(['ok'=>false,'error'=>'Choose a smaller JPG, PNG or WebP image.'],400);
    }
    $image = @imagecreatefromstring($bytes);
    if (!$image) json_out(['ok'=>false,'error'=>'Invalid photo.'],400);
    $ratio = min(1, 768/max($size[0],$size[1]));
    $thumb = imagecreatetruecolor(max(1,(int)round($size[0]*$ratio)),max(1,(int)round($size[1]*$ratio)));
    imagefill($thumb,0,0,imagecolorallocate($thumb,255,255,255));
    imagecopyresampled($thumb,$image,0,0,0,0,imagesx($thumb),imagesy($thumb),$size[0],$size[1]);
    ob_start(); imagewebp($thumb,null,78); $encoded=(string)ob_get_clean();
    if ($encoded==='' || strlen($encoded)>262144) json_out(['ok'=>false,'error'=>'Photo is too large.'],400);
    return $encoded;
}

function travel_trip_cover(array $trip): ?string
{
    $path = (string)($trip['image_path'] ?? '');
    if ($path==='') return null;
    // Only a server-owned, normalized trip image path, never a URL from input.
    $path = normalize_trip_image_path($path, true);
    $thumb = upload_thumb_relative_path($path);
    $absolute = $thumb ? upload_relative_path_to_abs($thumb) : null;
    if (!$absolute || !is_file($absolute)) $absolute=upload_relative_path_to_abs($path);
    if (!$absolute || !is_file($absolute) || filesize($absolute)>524288) return null;
    return travel_photo_encode((string)file_get_contents($absolute));
}

function delete_user_travel_places(PDO $pdo, int $userId): void
{
    if (travel_places_available($pdo)) {
        $pdo->prepare('DELETE FROM ' . table_name('travel_places') . ' WHERE user_id = :user')
            ->execute(['user'=>$userId]);
    }
}

function validate_travel_place(array $body): array
{
    $result = [];
    foreach (['city', 'region', 'country'] as $field) {
        $value = $body[$field] ?? ($field === 'region' ? '' : null);
        if (!is_string($value) || mb_strlen(trim($value)) > 120
            || ($field !== 'region' && trim($value) === '') || preg_match('/[\x00-\x1f\x7f]/u', $value)) {
            json_out(['ok'=>false, 'error'=>'Invalid place name.', 'code'=>'invalid_travel_place'], 400);
        }
        $result[$field] = trim($value);
    }
    $code = $body['country_code'] ?? null;
    if (!is_string($code) || !preg_match('/^[A-Z]{2}$/D', $code)) {
        json_out(['ok'=>false, 'error'=>'Invalid country code.', 'code'=>'invalid_travel_place'], 400);
    }
    $result['country_code'] = $code;
    foreach (['latitude'=>90, 'longitude'=>180] as $key=>$max) {
        $value = $body[$key] ?? null;
        if ((!is_int($value) && !is_float($value)) || !is_finite((float)$value) || abs($value) > $max) {
            json_out(['ok'=>false, 'error'=>'Invalid place coordinates.', 'code'=>'invalid_travel_place'], 400);
        }
        $result[$key] = round((float)$value, 5);
    }
    $date = $body['visited_on'] ?? null;
    $parsed = is_string($date) ? DateTimeImmutable::createFromFormat('!Y-m-d', $date, new DateTimeZone('UTC')) : false;
    if (!$parsed || $parsed->format('Y-m-d') !== $date || $date < '1900-01-01' || $date > gmdate('Y-m-d', time()+86400)) {
        json_out(['ok'=>false, 'error'=>'Invalid visit date.', 'code'=>'invalid_travel_date'], 400);
    }
    $result['visited_on'] = $date;
    $result['place_key'] = hash('sha256', $code . '|' . mb_strtolower($result['region']) . '|' . mb_strtolower($result['city']));
    return $result;
}

function travel_place_payload(array $row): array
{
    return ['id'=>(int)$row['id'], 'place_key'=>$row['place_key'], 'city'=>$row['city'],
        'region'=>$row['region'], 'country'=>$row['country'], 'country_code'=>$row['country_code'],
        'latitude'=>(float)$row['latitude'], 'longitude'=>(float)$row['longitude'], 'visited_on'=>$row['visited_on'],
        'trip_id'=>isset($row['accessible_trip_id']) ? (int)$row['accessible_trip_id'] : null,
        'trip_name'=>$row['trip_name'] ?? null, 'title'=>$row['title'] ?? '',
        'has_photo'=>(bool)($row['has_photo'] ?? false), 'photo_source'=>$row['photo_source'] ?? null,
        'photo_version'=>(int)($row['photo_version'] ?? 0)];
}

function travel_places_select(PDO $pdo): string
{
    return 'SELECT p.id,p.place_key,p.city,p.region,p.country,p.country_code,p.latitude,p.longitude,p.visited_on,
        p.trip_name,p.title,p.photo_source,p.photo_version,(p.photo_data IS NOT NULL) AS has_photo,
        tm.trip_id AS accessible_trip_id FROM '.table_name('travel_places').' p
        LEFT JOIN '.table_name('trip_members').' tm ON tm.trip_id=p.trip_id AND tm.user_id=p.user_id';
}
