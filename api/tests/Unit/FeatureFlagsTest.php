<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

/** docs/api/feature-flags.md */
final class FeatureFlagsTest extends TestCase
{
    private function scenario(string $name): array
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/feature_flags.php', $name],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($p);
        fclose($pipes[0]);
        $out = stream_get_contents($pipes[1]);
        $error = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($p), $error . $out);
        self::assertSame('', $error);
        return json_decode($out, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_modes_decide_who_has_the_feature(): void
    {
        $r = $this->scenario('modes');
        // 1 owner (granted), 2 other (no grant), 3 trip guest, 4 deleted, 5 deactivated (all but 2 granted).
        self::assertSame(['1' => false, '2' => false, '3' => false, '4' => false, '5' => false], $r['off']);
        self::assertSame(['1' => true, '2' => false, '3' => false, '4' => false, '5' => false], $r['allowlist']);
        self::assertSame(['1' => true, '2' => true, '3' => false, '4' => false, '5' => false], $r['everyone']);
        self::assertSame(['receipt_ai', 'year_summary'], $r['payload_keys']);
        self::assertFalse($r['unknown_key']);
    }

    public function test_year_summary_keeps_its_season_except_for_granted_testers(): void
    {
        $r = $this->scenario('year_summary');
        // 1 has a grant (tester), 2 has none.
        self::assertSame(['1' => true, '2' => false], $r['everyone_outside']);
        self::assertSame(['1' => true, '2' => true], $r['everyone_inside']);
        self::assertSame(['1' => true, '2' => false], $r['allowlist_outside']);
        self::assertSame(['1' => true, '2' => false], $r['allowlist_inside']);
        self::assertSame(['1' => false, '2' => false], $r['off_inside']);
        self::assertFalse($r['receipt_untouched']);
    }

    public function test_missing_tables_mean_off(): void
    {
        $r = $this->scenario('missing_tables');
        self::assertSame(['receipt_ai' => false, 'year_summary' => false], $r['flags']);
        self::assertSame(503, $r['list']);
    }

    public function test_only_superadmin_changes_mode_with_reason_and_audit(): void
    {
        $r = $this->scenario('set_mode');
        self::assertSame(403, $r['admin_forbidden']);
        self::assertSame(400, $r['no_reason']);
        self::assertSame(400, $r['bad_key']);
        self::assertSame(400, $r['bad_mode']);
        self::assertSame(200, $r['ok']['status']);
        self::assertSame('allowlist', $r['ok']['payload']['flag']['mode']);
        self::assertSame('owner', $r['ok']['payload']['flag']['updated_by']);
        // If the audit entry fails, the change is rolled back.
        self::assertTrue($r['audit_failure_threw']);
        self::assertSame('allowlist', $r['mode_after_audit_failure']);
        self::assertFalse($r['open_transaction']);
        self::assertCount(1, $r['audit']);
        self::assertSame('feature.mode_set', $r['audit'][0]['action']);
        self::assertSame(['key' => 'receipt_ai', 'from' => 'off', 'to' => 'allowlist', 'reason' => 'start test'],
            json_decode($r['audit'][0]['details'], true));
    }

    public function test_grants_only_for_eligible_accounts_and_are_audited(): void
    {
        $r = $this->scenario('grants');
        self::assertSame(404, $r['unknown_user']);
        self::assertSame(409, $r['guest']);
        self::assertSame(409, $r['deleted']);
        self::assertSame(400, $r['not_bool']);
        self::assertSame(['ok' => true, 'enabled' => true, 'effective' => true], $r['grant']['payload']);
        self::assertSame(['1' => true, '2' => false, '3' => false, '4' => false, '5' => false], $r['effective_after_grant']);
        self::assertSame('allowlist', $r['list']['flags'][0]['mode']);
        self::assertSame([1], array_column($r['list']['grants'], 'user_id'));
        self::assertSame('owner', $r['list']['grants'][0]['granted_by']);
        self::assertSame([
            ['key' => 'receipt_ai', 'label' => 'AI receipt reading', 'granted' => true, 'effective' => true],
            ['key' => 'year_summary', 'label' => 'Year summary', 'granted' => false, 'effective' => false],
        ], $r['detail']);
        self::assertSame(['ok' => true, 'enabled' => false, 'effective' => false], $r['revoke']['payload']);
        self::assertSame(['1' => false, '2' => false, '3' => false, '4' => false, '5' => false], $r['effective_after_revoke']);
        self::assertSame(['feature.user_grant', 'feature.user_revoke'], $r['audit']);
    }

    public function test_account_deletion_removes_grants(): void
    {
        self::assertSame(0, $this->scenario('deletion')['rows']);
    }

    public function test_migration_starts_off_without_grants_and_cascades_with_the_user(): void
    {
        $sql = (string) file_get_contents(__DIR__ . '/../../../sql/migrations/2026-11-20-feature-flags.sql');
        self::assertStringContainsString("VALUES ('receipt_ai', 'off')", $sql);
        self::assertStringContainsString('REFERENCES trip_users(id) ON DELETE CASCADE', $sql);
        self::assertStringNotContainsString('INSERT INTO trip_user_features', $sql);
        self::assertStringNotContainsString('INSERT IGNORE INTO trip_user_features', $sql);
    }
}
