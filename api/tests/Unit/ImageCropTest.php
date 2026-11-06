<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class ImageCropTest extends TestCase
{
    private function runFixture(string $case = ''): array
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/image_crop.php', $case],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors . $output);
        self::assertSame('', $errors);
        return json_decode($output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_only_people_allowed_to_change_an_image_can_reach_its_source(): void
    {
        $r = $this->runFixture();
        self::assertSame(403, $r['member_source']);
        self::assertSame(403, $r['outsider_source']);
        self::assertSame(403, $r['member_update']);
        self::assertSame(400, $r['invalid_kind']);
        self::assertSame(404, $r['visit_foreign']);
        self::assertSame(404, $r['visit_foreign_update']);
        self::assertSame(400, $r['visit_invalid']);
        self::assertTrue($r['no_source_in_response']);
        self::assertTrue($r['invalid_key_rejected']);
    }

    public function test_invalid_or_stale_requests_change_nothing(): void
    {
        $r = $this->runFixture();
        self::assertSame([400, 400, 400, 400, 400, 400], $r['bad_crops']);
        self::assertSame(400, $r['bad_tiny']);
        self::assertSame(['status' => 409, 'code' => 'image_changed'], $r['stale']);
        self::assertSame(409, $r['visit_stale']);
        self::assertSame(400, $r['avatar_wrong_shape']);
        self::assertTrue($r['unchanged_after_rejects']);
    }

    public function test_an_image_without_an_original_can_only_be_zoomed(): void
    {
        $r = $this->runFixture();
        self::assertSame(200, $r['legacy_source']['status']);
        self::assertFalse($r['legacy_source']['has_original']);
        self::assertTrue($r['legacy_source']['revision_ok']);
        self::assertEqualsWithDelta(1.0, $r['legacy_source']['crop']['width'], 0.001);
        self::assertEqualsWithDelta(0.75, $r['legacy_source']['crop']['height'], 0.001);

        $update = $r['legacy_update'];
        self::assertSame(200, $update['status']);
        self::assertTrue($update['new_path']);
        self::assertTrue($update['row_updated']);
        self::assertTrue($update['old_removed']);
        self::assertTrue($update['thumb_exists']);
        self::assertTrue($update['crop_applied']);
        self::assertFalse($update['has_original']);

        self::assertFalse($r['legacy_reopened']['has_original']);
        self::assertEqualsWithDelta(0.5, $r['legacy_reopened']['crop']['x'], 0.001);
    }

    public function test_an_original_is_kept_private_and_stripped_of_metadata(): void
    {
        $r = $this->runFixture();
        self::assertTrue($r['metadata_present_in_upload']);
        self::assertTrue($r['source_saved']);
        self::assertTrue($r['metadata_removed']);
        self::assertSame('640', $r['source_mode']);
        self::assertTrue($r['original_source']['has_original']);
        self::assertSame(1600, $r['original_source']['width']);
        self::assertSame(1200, $r['original_source']['height']);
        self::assertEqualsWithDelta(0.5, $r['original_source']['crop']['x'], 0.001);
    }

    public function test_moving_a_crop_uses_the_original_and_replaces_the_old_files(): void
    {
        $update = $this->runFixture()['original_update'];
        self::assertSame(200, $update['status']);
        self::assertTrue($update['has_original']);
        self::assertSame(800, $update['width']);
        self::assertEqualsWithDelta(0.0, $update['saved_crop']['x'], 0.001);
        self::assertTrue($update['old_source_removed']);
        self::assertTrue($update['old_file_removed']);
    }

    public function test_a_shared_image_survives_until_nothing_refers_to_it(): void
    {
        $r = $this->runFixture();
        self::assertSame(200, $r['shared']['status']);
        self::assertTrue($r['shared']['other_trip_kept']);
        self::assertTrue($r['shared']['file_kept']);
        self::assertTrue($r['shared']['source_kept']);
        self::assertTrue($r['source_removed_with_file']);
    }

    public function test_profile_photo(): void
    {
        $r = $this->runFixture();
        self::assertSame(404, $r['no_avatar']);
        self::assertSame(200, $r['avatar']['status']);
        self::assertSame(600, $r['avatar']['width']);
        self::assertSame(600, $r['avatar']['height']);
        self::assertTrue($r['avatar']['me_updated']);
        self::assertTrue($r['avatar']['old_removed']);
        self::assertTrue($r['avatar']['other_user_unchanged']);
        self::assertTrue($r['avatar_source_exists']);
        self::assertTrue($r['avatar_source_removed']);
    }

    public function test_visit_photo_and_every_deletion_path(): void
    {
        $r = $this->runFixture();
        self::assertSame(['status' => 200, 'has_original' => false, 'revision' => 'v1'], $r['visit_source']);
        $update = $r['visit_update'];
        self::assertSame(200, $update['status']);
        self::assertSame(2, $update['version']);
        self::assertSame('trip', $update['source_label_kept']);
        self::assertSame(384, $update['width']);
        self::assertTrue($update['crop_applied']);
        self::assertFalse($update['has_original']);
        self::assertTrue($update['place_returned']);
        self::assertFalse($r['visit_source_after_edit']);
        self::assertTrue($r['repeat_save_keeps_source']);
        self::assertTrue($r['removed_photo_removes_source']);
        self::assertTrue($r['deleted_visit_removes_source']);
        self::assertTrue($r['deleted_account_removes_source']);
    }

    public function test_cleanup_finds_only_old_originals_nothing_refers_to(): void
    {
        $r = $this->runFixture();
        self::assertSame([$r['orphan_expected']], $r['orphans']);
        self::assertTrue($r['oversized_source_ignored']);
    }

    public function test_editing_still_works_when_storage_is_not_configured(): void
    {
        $r = $this->runFixture('no_storage');
        self::assertFalse($r['storage']);
        self::assertSame(200, $r['legacy_update']['status']);
        self::assertTrue($r['legacy_update']['crop_applied']);
        self::assertFalse($r['source_saved']);
    }

    public function test_actions_are_registered(): void
    {
        $router = (string) file_get_contents(__DIR__ . '/../../lib/http/action_router.php');
        foreach (['image_crop_source', 'update_image_crop', 'upload_travel_photo_source'] as $action) {
            self::assertStringContainsString("'{$action}' => '{$action}_action'", $router);
        }
    }
}
