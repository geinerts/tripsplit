<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class TripMediaSecurityTest extends TestCase
{
    private function runFixture(string $name): array
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/' . $name . '.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        return json_decode($output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_cover_attachment_and_cleanup_cannot_damage_another_trip(): void
    {
        $result = $this->runFixture('trip_image_security');
        foreach (['direct_denied', 'foreign_legacy_denied', 'foreign_signed_denied',
            'other_uploader_denied', 'tampered_denied', 'deleted_upload_denied'] as $key) {
            self::assertSame(403, $result[$key], $key);
        }
        foreach (['own_signed_accepted', 'unchanged_accepted', 'remove_accepted',
            'unchanged_legacy_accepted', 'shared_remove_accepted', 'shared_delete_accepted',
            'shared_replace_accepted', 'sole_delete_accepted'] as $key) {
            self::assertSame(200, $result[$key], $key);
        }
        foreach (['foreign_intact', 'binding_renamed_pair', 'unreferenced_pair_removed',
            'shared_survives_remove', 'shared_survives_delete', 'victim_reference_unchanged',
            'shared_survives_replace', 'sole_delete_removes_pair'] as $key) {
            self::assertTrue($result[$key], $key);
        }
    }

    public function test_only_valid_generic_invites_reveal_trip_metadata(): void
    {
        $result = $this->runFixture('share_preview_security');
        self::assertTrue($result['valid']['valid']);
        self::assertSame('Synthetic private trip', $result['valid']['trip_name']);
        self::assertSame('uploads/trips/synthetic-private.webp', $result['valid']['image_path']);
        self::assertNotEmpty($result['valid']['expires_at']);
        unset($result['valid']);
        foreach ($result as $case => $meta) {
            self::assertSame([
                'valid' => false, 'trip_name' => 'Splyto trip', 'image_path' => '', 'expires_at' => '',
            ], $meta, $case);
        }
    }
}
