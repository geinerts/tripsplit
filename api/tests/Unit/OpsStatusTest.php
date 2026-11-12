<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_ops_status.php';

final class OpsStatusTest extends TestCase
{
    private string $dir;

    protected function setUp(): void
    {
        $this->dir = sys_get_temp_dir() . '/splyto-ops-status-' . bin2hex(random_bytes(6));
    }

    protected function tearDown(): void
    {
        foreach (glob($this->dir . '/*') ?: [] as $file) {
            unlink($file);
        }
        if (is_dir($this->dir)) {
            rmdir($this->dir);
        }
    }

    private function states(int $now): array
    {
        return array_column(ops_status_read($now, $this->dir), 'state', 'job');
    }

    public function test_heartbeat_keeps_only_numbers_and_flags(): void
    {
        ops_heartbeat('push_delivery', true, ['sent' => 3, 'dry_run' => false, 'error' => 'secret text',
            'rows' => [1], 'Bad-Key' => 1], $this->dir);
        ops_heartbeat('../escape', true, [], $this->dir);

        self::assertSame(['push_delivery.json'], array_map('basename', glob($this->dir . '/*')));
        $data = json_decode((string) file_get_contents($this->dir . '/push_delivery.json'), true);
        self::assertSame(['sent' => 3, 'dry_run' => false], $data['details']);
        self::assertTrue($data['ok']);
    }

    public function test_states_are_ok_stale_failed_or_unknown(): void
    {
        ops_heartbeat('push_delivery', true, [], $this->dir);
        ops_heartbeat('backup', false, [], $this->dir);
        ops_heartbeat('settlement_reminders', true, [], $this->dir);

        $now = time();
        $states = $this->states($now + 60);
        self::assertSame('ok', $states['push_delivery']);
        self::assertSame('failed', $states['backup']);
        self::assertSame('unknown', $states['trip_report_delivery']);

        $later = $this->states($now + 6 * 60);
        self::assertSame('stale', $later['push_delivery']);
        self::assertSame('ok', $later['settlement_reminders']);
    }

    public function test_corrupt_file_is_unknown(): void
    {
        mkdir($this->dir, 0750, true);
        file_put_contents($this->dir . '/backup.json', '{not json');
        self::assertSame('unknown', $this->states(time())['backup']);
    }
}
