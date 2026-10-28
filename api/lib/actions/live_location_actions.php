<?php
declare(strict_types=1);
require_once __DIR__ . '/../helpers/helper_live_location.php';

function live_location_context(): array
{
    $me = get_me(); $pdo = db();
    if (!live_location_available($pdo)) json_out(['ok'=>false,'error'=>'Live map is not available yet.','code'=>'live_location_unavailable'],409);
    $trip = get_current_trip($pdo,$me,true);
    if (trip_is_solo($trip) || normalize_trip_status($trip['status'] ?? '') !== 'active') {
        json_out(['ok'=>false,'error'=>'Live map is available in active group trips.','code'=>'live_location_closed'],409);
    }
    enforce_rate_limit($pdo,'live_location_user',(string)$me['id'],180,60);
    return [$pdo,(int)$me['id'],(int)$trip['id']];
}

function list_trip_live_locations_action(): void
{
    [$pdo,$user,$trip] = live_location_context();
    cleanup_live_locations($pdo);
    // Join both memberships and both active accounts at read time, not cached roles.
    $s = $pdo->prepare('SELECT l.user_id,l.latitude,l.longitude,l.accuracy_m,l.observed_at,l.updated_at,l.expires_at,
        u.nickname,u.first_name,u.last_name FROM ' . table_name('live_locations') . ' l
        JOIN ' . table_name('trip_members') . ' m ON m.trip_id=l.trip_id AND m.user_id=l.user_id
        JOIN ' . table_name('trip_members') . ' viewer ON viewer.trip_id=l.trip_id AND viewer.user_id=:viewer
        JOIN ' . table_name('users') . ' u ON u.id=l.user_id AND u.account_status="active"
        JOIN ' . table_name('users') . ' actor ON actor.id=viewer.user_id AND actor.account_status="active"
        JOIN ' . table_name('trips') . ' t ON t.id=l.trip_id AND t.status="active"
        WHERE l.trip_id=:trip AND l.expires_at>:now AND l.observed_at>=:recent AND l.latitude IS NOT NULL');
    $s->execute(['viewer'=>$user,'trip'=>$trip,'now'=>gmdate('Y-m-d H:i:s'),'recent'=>gmdate('Y-m-d H:i:s',time()-120)]);
    $members=[];
    foreach ($s->fetchAll(PDO::FETCH_ASSOC) as $row) {
        $members[]=['user_id'=>(int)$row['user_id'], 'name'=>me_display_name($row),
            'latitude'=>(float)$row['latitude'],'longitude'=>(float)$row['longitude'],
            'accuracy_m'=>(float)$row['accuracy_m'],'observed_at'=>strtotime($row['observed_at'].' UTC'),
            'updated_at'=>strtotime($row['updated_at'].' UTC'),'expires_at'=>strtotime($row['expires_at'].' UTC')];
    }
    // Consent metadata is private to the current account; tokens are never listed.
    $s=$pdo->prepare('SELECT expires_at FROM '.table_name('live_locations').' WHERE trip_id=:trip AND user_id=:user AND expires_at>:now');
    $s->execute(['trip'=>$trip,'user'=>$user,'now'=>gmdate('Y-m-d H:i:s')]); $own=$s->fetchColumn();
    json_out(['ok'=>true,'server_time'=>time(),'members'=>$members,'own_expires_at'=>$own ? strtotime($own.' UTC') : null]);
}

function start_trip_live_location_action(): void
{
    require_post(); [$pdo,$user,$trip]=live_location_context(); $body=read_json();
    $minutes=$body['minutes'] ?? null;
    if (!is_int($minutes) || !in_array($minutes,[15,60,240,480],true)) json_out(['ok'=>false,'error'=>'Invalid sharing duration.'],400);
    $fix=validate_live_fix($body);
    enforce_rate_limit($pdo,'live_location_start',(string)$user,20,900);
    $token=bin2hex(random_bytes(32)); $expires=time()+$minutes*60;
    $pdo->beginTransaction();
    try {
        lock_live_location_account($pdo,$user);
        $locked=lock_active_trip_membership_scope($pdo,$trip);
        if (trip_is_solo($locked)) json_out(['ok'=>false,'error'=>'Group trip required.'],409);
        require_locked_trip_member($pdo,$trip,$user);
        $pdo->prepare('DELETE FROM '.table_name('live_locations').' WHERE trip_id=:trip AND user_id=:user')->execute(['trip'=>$trip,'user'=>$user]);
        $pdo->prepare('INSERT INTO '.table_name('live_locations').' (trip_id,user_id,session_token,expires_at,latitude,longitude,accuracy_m,observed_at,updated_at)
            VALUES (:trip,:user,:token,:expires,:latitude,:longitude,:accuracy_m,:observed_at,:updated)')
            ->execute(['trip'=>$trip,'user'=>$user,'token'=>$token,'expires'=>gmdate('Y-m-d H:i:s',$expires),'updated'=>gmdate('Y-m-d H:i:s')]+$fix);
        $pdo->commit();
    } catch (Throwable $error) { if ($pdo->inTransaction()) $pdo->rollBack(); throw $error; }
    json_out(['ok'=>true,'session_token'=>$token,'expires_at'=>$expires,'server_time'=>time()]);
}

function update_trip_live_location_action(): void
{
    require_post(); [$pdo,$user,$trip]=live_location_context(); $body=read_json(); $fix=validate_live_fix($body);
    $token=$body['session_token'] ?? '';
    if (!is_string($token) || !preg_match('/^[a-f0-9]{64}$/D',$token)) json_out(['ok'=>false,'error'=>'Invalid sharing session.'],400);
    $pdo->beginTransaction();
    try {
        lock_live_location_account($pdo,$user);
        lock_active_trip_membership_scope($pdo,$trip); require_locked_trip_member($pdo,$trip,$user);
        $s=$pdo->prepare('SELECT session_token,expires_at,observed_at FROM '.table_name('live_locations').' WHERE trip_id=:trip AND user_id=:user FOR UPDATE');
        $s->execute(['trip'=>$trip,'user'=>$user]); $row=$s->fetch();
        if (!$row || !hash_equals($row['session_token'],$token) || $row['expires_at']<=gmdate('Y-m-d H:i:s')) {
            $pdo->rollBack(); json_out(['ok'=>false,'error'=>'Sharing has ended.','code'=>'live_location_expired'],409);
        }
        if (!$row['observed_at'] || $fix['observed_at']>=$row['observed_at']) {
            $pdo->prepare('UPDATE '.table_name('live_locations').' SET latitude=:latitude,longitude=:longitude,accuracy_m=:accuracy_m,observed_at=:observed_at,updated_at=:updated
                WHERE trip_id=:trip AND user_id=:user AND session_token=:token')->execute($fix+['updated'=>gmdate('Y-m-d H:i:s'),'trip'=>$trip,'user'=>$user,'token'=>$token]);
        }
        $pdo->commit();
    } catch (Throwable $error) { if ($pdo->inTransaction()) $pdo->rollBack(); throw $error; }
    json_out(['ok'=>true,'server_time'=>time()]);
}

function stop_trip_live_location_action(): void
{
    require_post(); $me=get_me(); $pdo=db(); $body=read_json();
    // Own stop remains available even after leaving/closing the trip; idempotent.
    $trip=$body['trip_id'] ?? null;
    if (!is_int($trip) || $trip<1) json_out(['ok'=>false,'error'=>'Invalid trip.'],400);
    if (live_location_available($pdo)) {
        $pdo->prepare('DELETE FROM '.table_name('live_locations').' WHERE trip_id=:trip AND user_id=:user')->execute(['trip'=>$trip,'user'=>(int)$me['id']]);
    }
    json_out(['ok'=>true]);
}
