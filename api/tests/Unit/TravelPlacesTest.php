<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;
final class TravelPlacesTest extends TestCase
{
 public function test_visit_queries_use_the_real_production_table_mapper(): void
 {
  foreach (['trip_', 'isolated_'] as $prefix) {
   $process=proc_open([PHP_BINARY,__DIR__.'/../Fixtures/travel_places_schema_contract.php',$prefix],[0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
   self::assertIsResource($process); fclose($pipes[0]);
   $output=stream_get_contents($pipes[1]); $errors=stream_get_contents($pipes[2]);
   fclose($pipes[1]); fclose($pipes[2]);
   self::assertSame(0,proc_close($process),$errors); self::assertSame('',$errors);
   self::assertSame(['city'=>'Lisbon','trip_id'=>9],json_decode($output,true,512,JSON_THROW_ON_ERROR));
  }
 }
 public function test_private_visits_validation_deduplication_and_deletion(): void
 {
  $process=proc_open([PHP_BINARY,__DIR__.'/../Fixtures/travel_places.php'],[0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']],$pipes);
  self::assertIsResource($process); fclose($pipes[0]);
  $output=stream_get_contents($pipes[1]); $errors=stream_get_contents($pipes[2]);
  fclose($pipes[1]); fclose($pipes[2]);
  self::assertSame(0,proc_close($process),$errors); self::assertSame('',$errors);
  $r=json_decode($output,true,512,JSON_THROW_ON_ERROR);
  self::assertSame(409,$r['unmigrated']['status']);
  self::assertSame(200,$r['saved']['status']);
  self::assertSame($r['saved']['body']['place']['id'],$r['duplicate']['body']['place']['id']);
  self::assertCount(2,$r['own']['body']['places']);
  self::assertSame('2026-10-02',$r['own']['body']['places'][0]['visited_on']);
  self::assertArrayNotHasKey('user_id',$r['saved']['body']['place']);
  self::assertSame([],$r['other']['body']['places']);
  self::assertSame(404,$r['delete_other']['status']);
  self::assertSame(2,$r['kept_after_attack']);
  foreach($r['invalid'] as $status) self::assertSame(400,$status);
  self::assertSame(400,$r['invalid_delete']['status']);
  self::assertSame(200,$r['delete_own']['status']);
  self::assertCount(1,$r['remaining']['body']['places']);
  self::assertSame([],$r['cleanup_own']['body']['places']);
  self::assertCount(1,$r['cleanup_other']['body']['places']);
  self::assertContains($r['deleted_account']['status'],[401,403]);
  self::assertSame(409,$r['limit']['status']);
  self::assertSame('travel_map_limit',$r['limit']['body']['code']);
  self::assertSame(200,$r['destinations_create']['status']);
  self::assertCount(1,$r['destinations_create']['body']['trip']['destinations']);
  self::assertSame([],$r['no_auto_visit']);
  self::assertSame(403,$r['unaccepted_import']['status']);
  self::assertSame(403,$r['member_edit_destination']['status']);
  self::assertSame('Lisbon',$r['destination_roundtrip'][0]['city']);
  self::assertSame(200,$r['import']['status']);
  self::assertSame('Lisbon weekend',$r['import']['body']['place']['trip_name']);
  self::assertSame($r['import']['body']['place']['id'],$r['import_duplicate']['body']['place']['id']);
  self::assertCount(2,$r['manual_and_trip_distinct']['body']['places']);
  self::assertTrue($r['photo_edit']['body']['place']['has_photo']);
  self::assertSame('custom',$r['photo_edit']['body']['place']['photo_source']);
  self::assertSame(2,$r['photo_edit']['body']['place']['photo_version']);
  self::assertSame('trip',$r['import']['body']['place']['photo_source']);
  self::assertTrue($r['import']['body']['place']['has_photo']);
  self::assertTrue($r['cover_kept_after_source_removed']);
  self::assertSame('image/webp',$r['photo_mime']);
  self::assertSame(404,$r['photo_other']['status']);
  self::assertSame(404,$r['foreign_edit']['status']);
  self::assertSame(400,$r['bad_photo']['status']);
  self::assertSame(400,$r['too_large_photo']['status']);
  self::assertSame('Sunset in Lisbon',$r['retry_preserves_photo']['body']['place']['title']);
  self::assertTrue($r['retry_preserves_photo']['body']['place']['has_photo']);
  foreach($r['left_trip']['body']['places'] as $visit) self::assertNull($visit['trip_id']);
  self::assertSame(200,$r['edit_after_leaving']['status']);
  self::assertTrue($r['edit_after_leaving']['body']['place']['has_photo']);
  self::assertSame(403,$r['reimport_after_leaving']['status']);
  self::assertFalse($r['photo_remove']['body']['place']['has_photo']);
  self::assertNull($r['photo_removed']['body']['photo_base64']);
  self::assertSame([],$r['destinations_clear']['body']['trip']['destinations']);
  self::assertSame(400,$r['bad_destination']['status']);

 }
}
