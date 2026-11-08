<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

/** Runs the real trips handler in a separate process with the isolated SQLite harness. */
final class TripMembersPreviewTest extends TestCase
{
    public function test_trips_list_sends_up_to_three_members_with_their_own_avatars(): void
    {
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/trip_members_preview.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        $r = json_decode($output, true, 512, JSON_THROW_ON_ERROR);
        $rome = (string) $r['ids']['rome'];
        $oslo = (string) $r['ids']['oslo'];

        self::assertSame(5, $r['counts'][$rome], 'members_count still counts everyone');
        $preview = $r['owner'][$rome];
        self::assertCount(3, $preview);
        self::assertSame(['id', 'display_name', 'avatar_url', 'avatar_thumb_url'], array_keys($preview[0]));
        self::assertSame([1, 2, 3], array_column($preview, 'id'));
        self::assertSame('Matiss Geinerts', $preview[0]['display_name']);
        self::assertNull($preview[0]['avatar_url'], 'No avatar set means null, not a placeholder');
        self::assertNull($preview[0]['avatar_thumb_url']);
        self::assertSame('Invitee', $preview[1]['display_name']);
        self::assertStringEndsWith('uploads/avatars/2.jpg', (string) $preview[1]['avatar_url']);
        self::assertNotNull($preview[1]['avatar_thumb_url']);
        self::assertSame([[1, 'Matiss Geinerts']], array_map(
            static fn(array $m): array => [$m['id'], $m['display_name']],
            $r['owner'][$oslo]
        ));
        self::assertSame($preview, $r['member'][$rome], 'Every member sees the same preview');
        self::assertArrayNotHasKey($oslo, $r['member']);
        self::assertSame([], $r['outsider']);
    }
}
