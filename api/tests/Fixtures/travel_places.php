<?php
declare(strict_types=1);
require __DIR__.'/trip_invitations.php';
require __DIR__.'/../../lib/actions/travel_places_actions.php';
define('TRIP_IMAGES_REL_DIR','output/tests/travel-cover-'.bin2hex(random_bytes(8)));
require __DIR__.'/../../config/config_uploads.php';
$pdo = invitation_test_setup(false);
$r = [];
$r['unmigrated'] = invitation_call('list_travel_places_action', 1);
$pdo->exec('CREATE TABLE trip_travel_places (id INTEGER PRIMARY KEY AUTOINCREMENT,
 user_id INTEGER NOT NULL REFERENCES trip_users(id) ON DELETE CASCADE,
 place_key TEXT NOT NULL, city TEXT, region TEXT, country TEXT, country_code TEXT,
 latitude REAL, longitude REAL, visited_on TEXT, trip_id INTEGER REFERENCES trip_trips(id) ON DELETE SET NULL,
 source_key TEXT DEFAULT "manual", trip_name TEXT, title TEXT DEFAULT "", photo_data BLOB,photo_source TEXT,photo_version INTEGER DEFAULT 0,
 UNIQUE(user_id,place_key,visited_on,source_key))');
$place = ['city'=>'Lisbon','region'=>'Lisbon','country'=>'Portugal','country_code'=>'PT',
 'latitude'=>38.7223,'longitude'=>-9.1393,'visited_on'=>'2026-10-01','user_id'=>2];
$r['saved'] = invitation_call('save_travel_place_action',1,$place);
$r['save_json_limit'] = $GLOBALS['json_limit'];
$id = $r['saved']['body']['place']['id'];
$r['duplicate'] = invitation_call('save_travel_place_action',1,$place);
$r['second_visit'] = invitation_call('save_travel_place_action',1,array_replace($place,['visited_on'=>'2026-10-02']));
$r['own'] = invitation_call('list_travel_places_action',1);
$r['other'] = invitation_call('list_travel_places_action',2);
$r['delete_other'] = invitation_call('delete_travel_place_action',2,['id'=>$id]);
$r['kept_after_attack'] = (int)$pdo->query('SELECT COUNT(*) FROM trip_travel_places')->fetchColumn();
foreach ([['city'=>''],['city'=>"A\nB"],['city'=>str_repeat('x',121)],['latitude'=>91],['longitude'=>-181],
 ['latitude'=>'38.7'],['latitude'=>true],['latitude'=>INF],['country_code'=>'XX1'],['visited_on'=>'2026-02-30'],
 ['visited_on'=>'1899-01-01'],['visited_on'=>'2999-01-01']] as $bad) {
 $r['invalid'][] = invitation_call('save_travel_place_action',1,array_replace($place,$bad))['status'];
}
$r['invalid_delete'] = invitation_call('delete_travel_place_action',1,['id'=>(string)$id]);
$r['delete_own'] = invitation_call('delete_travel_place_action',1,['id'=>$id]);
$r['remaining'] = invitation_call('list_travel_places_action',1);
invitation_call('save_travel_place_action',2,$place);
delete_user_travel_places($pdo,1);
$r['cleanup_own'] = invitation_call('list_travel_places_action',1);
$r['cleanup_other'] = invitation_call('list_travel_places_action',2);
$pdo->exec('UPDATE trip_users SET account_status="deleted" WHERE id=1');
$r['deleted_account'] = invitation_call('save_travel_place_action',1,$place);
$pdo->beginTransaction();
$insert = $pdo->prepare('INSERT INTO trip_travel_places(user_id,place_key,city,region,country,country_code,latitude,longitude,visited_on) VALUES(3,?,"Test","","Test","LV",1,1,"2026-10-01")');
for ($i=0;$i<1000;$i++) $insert->execute(['test-'.$i]);
$pdo->commit();
$r['limit'] = invitation_call('save_travel_place_action',3,$place);

// Trip import is explicit, accepted-members only, and creates a private snapshot.
$pdo->exec('UPDATE trip_users SET account_status="active" WHERE id=1');
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN destinations_json TEXT');
$pdo->exec('ALTER TABLE trip_trips ADD COLUMN image_path TEXT');
$directory=dirname(__DIR__,3).'/'.TRIP_IMAGES_REL_DIR;
mkdir($directory,0700,true);
$cover=imagecreatetruecolor(60,30);imagefill($cover,0,0,imagecolorallocate($cover,40,130,200));
imagewebp($cover,$directory.'/cover.webp');
$destination=$place; unset($destination['visited_on'],$destination['user_id']);
$created=invitation_call('create_trip_action',1,['name'=>'Lisbon weekend','destinations'=>[$destination,$destination]]);
$tripId=(int)$created['body']['trip']['id'];
$r['destinations_create']=$created;
$pdo->prepare('UPDATE trip_trips SET image_path=? WHERE id=?')->execute([TRIP_IMAGES_REL_DIR.'/cover.webp',$tripId]);
$r['no_auto_visit']=invitation_call('list_travel_places_action',1)['body']['places'];
$r['unaccepted_import']=invitation_call('save_travel_place_action',2,array_replace($place,['trip_id'=>$tripId]));
$pdo->exec('INSERT INTO trip_trip_members(trip_id,user_id,role) VALUES ('.$tripId.',2,"member")');
$r['member_edit_destination']=invitation_call('update_trip_action',2,['id'=>$tripId,'destinations'=>[]]);
$r['destination_roundtrip']=trip_destinations_payload(find_trip_for_user($pdo,2,$tripId));
$r['import']=invitation_call('save_travel_place_action',2,array_replace($place,['trip_id'=>$tripId]));
$importId=$r['import']['body']['place']['id'];
$_GET['id']=$importId;
$originalCover=invitation_call('travel_place_photo_action',2)['body']['photo_base64'];
unlink($directory.'/cover.webp');
$r['cover_kept_after_source_removed']=$originalCover===invitation_call('travel_place_photo_action',2)['body']['photo_base64'];
$r['import_duplicate']=invitation_call('save_travel_place_action',2,array_replace($place,['trip_id'=>$tripId]));
$r['manual_and_trip_distinct']=invitation_call('list_travel_places_action',2);
$image=imagecreatetruecolor(20,10); imagefill($image,0,0,imagecolorallocate($image,30,150,90));
ob_start();imagepng($image);$png=(string)ob_get_clean();
$r['photo_edit']=invitation_call('save_travel_place_action',2,array_replace($place,['id'=>$importId,'title'=>'Sunset in Lisbon','photo_base64'=>base64_encode($png)]));
$_GET['id']=$importId;
$r['photo_other']=invitation_call('travel_place_photo_action',1);
$photo=invitation_call('travel_place_photo_action',2);
$r['photo_mime']=getimagesizefromstring(base64_decode($photo['body']['photo_base64']))['mime'];
$r['foreign_edit']=invitation_call('save_travel_place_action',1,array_replace($place,['id'=>$importId,'photo_base64'=>base64_encode($png)]));
$r['bad_photo']=invitation_call('save_travel_place_action',2,array_replace($place,['id'=>$importId,'photo_base64'=>base64_encode('<svg/>')]));
$r['too_large_photo']=invitation_call('save_travel_place_action',2,array_replace($place,['id'=>$importId,'photo_base64'=>str_repeat('A',700004)]));
$r['retry_preserves_photo']=invitation_call('save_travel_place_action',2,array_replace($place,['trip_id'=>$tripId]));
$pdo->exec('DELETE FROM trip_trip_members WHERE trip_id='.$tripId.' AND user_id=2');
$r['left_trip']=invitation_call('list_travel_places_action',2);
$r['edit_after_leaving']=invitation_call('save_travel_place_action',2,array_replace($place,['id'=>$importId,'title'=>'My memory']));
$r['reimport_after_leaving']=invitation_call('save_travel_place_action',2,array_replace($place,['trip_id'=>$tripId]));
$r['photo_remove']=invitation_call('save_travel_place_action',2,array_replace($place,['id'=>$importId,'remove_photo'=>true]));
$r['photo_removed']=invitation_call('travel_place_photo_action',2);
$r['destinations_clear']=invitation_call('update_trip_action',1,['id'=>$tripId,'destinations'=>[]]);
$r['bad_destination']=invitation_call('update_trip_action',1,['id'=>$tripId,'destinations'=>[['city'=>'Broken']]]);
rmdir($directory);
echo json_encode($r,JSON_THROW_ON_ERROR);
