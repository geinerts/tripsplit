<?php
declare(strict_types=1);
require_once __DIR__ . '/../helpers/helper_travel_places.php';

function list_travel_places_action(): void
{
    $me=get_me(); $pdo=db(); require_travel_places_schema($pdo);
    $stmt=$pdo->prepare(travel_places_select($pdo).' WHERE p.user_id=:user ORDER BY p.visited_on DESC,p.id DESC LIMIT 1000');
    $stmt->execute(['user'=>(int)$me['id']]);
    json_out(['ok'=>true,'places'=>array_map('travel_place_payload',$stmt->fetchAll())]);
}

function travel_place_photo_action(): void
{
    $me=get_me(); $pdo=db(); require_travel_places_schema($pdo);
    $id=filter_var($_GET['id'] ?? null,FILTER_VALIDATE_INT);
    if (!$id || $id<1) json_out(['ok'=>false,'error'=>'Invalid visit.'],400);
    $s=$pdo->prepare('SELECT photo_data FROM '.table_name('travel_places').' WHERE id=:id AND user_id=:user');
    $s->execute(['id'=>$id,'user'=>(int)$me['id']]);
    $row=$s->fetch();
    if (!$row) json_out(['ok'=>false,'error'=>'Visit not found.'],404);
    if (!headers_sent()) header('Cache-Control: private, no-store');
    json_out(['ok'=>true,'photo_base64'=>$row['photo_data']===null ? null : base64_encode($row['photo_data'])]);
}

function save_travel_place_action(): void
{
    require_post(); $me=get_me(); $pdo=db(); require_travel_places_schema($pdo);
    // Authenticated photo submissions need room for 512 KiB base64 + visit metadata.
    // Other JSON actions retain their normal (64 KiB) limit.
    $body=read_json(720_896); $place=validate_travel_place($body); $user=(int)$me['id'];
    $id=$body['id'] ?? null;
    if ($id!==null && (!is_int($id) || $id<1)) json_out(['ok'=>false,'error'=>'Invalid visit.'],400);
    $tripId=$body['trip_id'] ?? null;
    if ($tripId!==null && (!is_int($tripId) || $tripId<1)) json_out(['ok'=>false,'error'=>'Invalid trip.'],400);
    $title=$body['title'] ?? '';
    if (!is_string($title) || mb_strlen(trim($title))>120 || preg_match('/[\x00-\x1f\x7f]/u',$title)) {
        json_out(['ok'=>false,'error'=>'Invalid visit title.'],400);
    }
    enforce_rate_limit($pdo,'travel_place_write_user',(string)$user,60,900);
    $photo=null; $changePhoto=array_key_exists('photo_base64',$body) || ($body['remove_photo'] ?? false)===true;
    if (array_key_exists('photo_base64',$body)) {
        enforce_rate_limit($pdo,'travel_photo_write_user',(string)$user,15,900);
        if (!is_string($body['photo_base64']) || strlen($body['photo_base64'])>700000) json_out(['ok'=>false,'error'=>'Invalid photo.'],400);
        $decoded=base64_decode($body['photo_base64'],true);
        if ($decoded===false) json_out(['ok'=>false,'error'=>'Invalid photo.'],400);
        $photo=travel_photo_encode($decoded);
    }
    $table=table_name('travel_places');
    $pdo->beginTransaction();
    try {
        $lock=$pdo->prepare('SELECT id FROM '.table_name('users').' WHERE id=:user AND account_status="active" FOR UPDATE');
        $lock->execute(['user'=>$user]);
        if (!$lock->fetchColumn()) json_out(['ok'=>false,'error'=>'Account unavailable.'],403);
        $old=null;
        if ($id!==null) {
            $s=$pdo->prepare('SELECT id,trip_id,trip_name,source_key FROM '.$table.' WHERE id=:id AND user_id=:user');
            $s->execute(['id'=>$id,'user'=>$user]); $old=$s->fetch();
            if (!$old) json_out(['ok'=>false,'error'=>'Visit not found.'],404);
        }
        // Once saved, the personal memory remains editable even after leaving a trip.
        // Re-linking or importing always requires current, accepted membership.
        $trip=null; $tripName=$old['trip_name'] ?? null; $source=$old['source_key'] ?? 'manual';
        if ($old && !array_key_exists('trip_id',$body)) $tripId=isset($old['trip_id']) ? (int)$old['trip_id'] : null;
        if ($tripId!==null && (!$old || $tripId!==(int)$old['trip_id'])) {
            $lockTrip=$pdo->prepare('SELECT id FROM '.table_name('trips').' WHERE id=:id FOR UPDATE');
            $lockTrip->execute(['id'=>$tripId]);
            $trip=find_trip_for_user($pdo,$user,$tripId);
            if (!$trip) json_out(['ok'=>false,'error'=>'Trip not found or access denied.'],403);
            $tripName=$trip['name']; $source='trip:'.$tripId;
        }
        if (!$old && !$tripId) $source='manual';
        // The same city/date can belong to distinct trips without overwriting them.
        $existing=$pdo->prepare('SELECT id FROM '.$table.' WHERE user_id=:user AND place_key=:key AND visited_on=:date AND source_key=:source');
        $existing->execute(['user'=>$user,'key'=>$place['place_key'],'date'=>$place['visited_on'],'source'=>$source]);
        $duplicate=(int)$existing->fetchColumn();
        if ($old && $duplicate && $duplicate!==$id) json_out(['ok'=>false,'error'=>'This visit is already saved.','code'=>'duplicate_travel_visit'],409);
        if (!$old && $duplicate) {
            // Retrying an import is idempotent and never overwrites a personal photo/title.
            $id=$duplicate;
        } else {
            if (!$old) {
                $count=$pdo->prepare('SELECT COUNT(*) FROM '.$table.' WHERE user_id=:user'); $count->execute(['user'=>$user]);
                if ((int)$count->fetchColumn()>=1000) json_out(['ok'=>false,'error'=>'Travel map limit reached.','code'=>'travel_map_limit'],409);
                $pdo->prepare('INSERT INTO '.$table.' (user_id,place_key,city,region,country,country_code,latitude,longitude,visited_on,trip_id,trip_name,source_key,title)
                    VALUES (:user_id,:place_key,:city,:region,:country,:country_code,:latitude,:longitude,:visited_on,:trip_id,:trip_name,:source_key,:title)')
                    ->execute(['user_id'=>$user,'trip_id'=>$tripId,'trip_name'=>$tripName,'source_key'=>$source,'title'=>trim($title)]+$place);
                $id=(int)$pdo->lastInsertId();
                if (!$changePhoto && $trip) {
                    $photo=travel_trip_cover($trip); $changePhoto=$photo!==null;
                }
            } else {
                $pdo->prepare('UPDATE '.$table.' SET city=:city,region=:region,country=:country,country_code=:country_code,
                    latitude=:latitude,longitude=:longitude,place_key=:place_key,visited_on=:visited_on,title=:title,
                    trip_id=:trip_id,trip_name=:trip_name,source_key=:source_key WHERE id=:id AND user_id=:user')
                    ->execute(['id'=>$id,'user'=>$user,'title'=>trim($title),'trip_id'=>$tripId,'trip_name'=>$tripName,'source_key'=>$source]+$place);
            }
            if ($changePhoto) {
                $stmt=$pdo->prepare('UPDATE '.$table.' SET photo_data=:photo,photo_source=:source,photo_version=photo_version+1 WHERE id=:id AND user_id=:user');
                $stmt->bindValue(':photo',$photo,$photo===null ? PDO::PARAM_NULL : PDO::PARAM_LOB);
                $stmt->bindValue(':source',$photo===null ? null : (isset($body['photo_base64']) ? 'custom' : 'trip'));
                $stmt->bindValue(':id',$id,PDO::PARAM_INT); $stmt->bindValue(':user',$user,PDO::PARAM_INT); $stmt->execute();
            }
        }
        $select=$pdo->prepare(travel_places_select($pdo).' WHERE p.id=:id AND p.user_id=:user');
        $select->execute(['id'=>$id,'user'=>$user]); $saved=$select->fetch();
        $pdo->commit();
    } catch (Throwable $error) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        throw $error;
    }
    json_out(['ok'=>true,'place'=>travel_place_payload($saved)]);
}

function delete_travel_place_action(): void
{
    require_post(); $me=get_me(); $pdo=db(); require_travel_places_schema($pdo); $body=read_json();
    $id=$body['id'] ?? null;
    if (!is_int($id) || $id<1) json_out(['ok'=>false,'error'=>'Invalid place id.'],400);
    enforce_rate_limit($pdo,'travel_place_write_user',(string)$me['id'],60,900);
    $stmt=$pdo->prepare('DELETE FROM '.table_name('travel_places').' WHERE id=:id AND user_id=:user');
    $stmt->execute(['id'=>$id,'user'=>(int)$me['id']]);
    if ($stmt->rowCount()!==1) json_out(['ok'=>false,'error'=>'Place not found.'],404);
    json_out(['ok'=>true]);
}
