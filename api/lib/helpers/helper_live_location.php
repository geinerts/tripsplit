<?php
declare(strict_types=1);

function live_location_available(PDO $pdo): bool
{
    $s = $pdo->prepare('SELECT COUNT(*) FROM information_schema.tables WHERE table_schema=DATABASE() AND table_name=:table_name');
    $s->execute(['table_name' => DB_TABLE_PREFIX . 'live_locations']);
    return (int)$s->fetchColumn() > 0;
}

function clear_live_locations(PDO $pdo, ?int $userId = null, ?int $tripId = null): void
{
    if (!live_location_available($pdo)) return;
    if ($userId !== null) {
        $pdo->prepare('DELETE FROM ' . table_name('live_locations') . ' WHERE user_id=:id')->execute(['id'=>$userId]);
    } elseif ($tripId !== null) {
        $pdo->prepare('DELETE FROM ' . table_name('live_locations') . ' WHERE trip_id=:id')->execute(['id'=>$tripId]);
    }
}

function cleanup_live_locations(PDO $pdo): void
{
    if (!live_location_available($pdo)) return;
    // Only the latest fix is retained. Expired consent is never revived by an update.
    $table = table_name('live_locations');
    $now = gmdate('Y-m-d H:i:s');
    $pdo->prepare('DELETE FROM ' . $table . ' WHERE expires_at<=:now')->execute(['now'=>$now]);
    $pdo->prepare('UPDATE ' . $table . ' SET latitude=NULL,longitude=NULL,accuracy_m=NULL,observed_at=NULL,updated_at=NULL
        WHERE observed_at<:stale')->execute(['stale'=>gmdate('Y-m-d H:i:s', time()-120)]);
}

function validate_live_fix(array $body): array
{
    foreach (['latitude'=>[-90,90], 'longitude'=>[-180,180], 'accuracy_m'=>[0,100000]] as $key=>$range) {
        $value = $body[$key] ?? null;
        if ((!is_int($value) && !is_float($value)) || !is_finite((float)$value) || $value<$range[0] || $value>$range[1]) {
            json_out(['ok'=>false,'error'=>'Invalid location.'],400);
        }
    }
    $observed = $body['observed_at'] ?? null;
    if (!is_int($observed) || $observed<time()-120 || $observed>time()+60) {
        json_out(['ok'=>false,'error'=>'A fresh location is required.','code'=>'live_location_stale'],400);
    }
    return ['latitude'=>$body['latitude'],'longitude'=>$body['longitude'],
        'accuracy_m'=>$body['accuracy_m'],'observed_at'=>gmdate('Y-m-d H:i:s',$observed)];
}

function lock_live_location_account(PDO $pdo, int $userId): void
{
    // Account deactivation and publication serialize on the same account row.
    $s = $pdo->prepare('SELECT account_status FROM ' . table_name('users') . ' WHERE id=:id FOR UPDATE');
    $s->execute(['id'=>$userId]);
    if ($s->fetchColumn() !== 'active') {
        $pdo->rollBack();
        json_out(['ok'=>false,'error'=>'Account is unavailable.'],403);
    }
    if (resolve_user_id_from_access_token(bearer_access_token_from_header(), $pdo) !== $userId) {
        $pdo->rollBack();
        json_out(['ok'=>false,'error'=>'Please sign in again.'],401);
    }
}
