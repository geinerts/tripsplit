<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_account_deletion_feedback.php';

final class AccountDeletionFeedbackTest extends TestCase
{
    public function test_summary_distinguishes_missing_storage_from_empty_data(): void
    {
        $pdo = new PDO('sqlite::memory:');
        $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        self::assertSame(['available' => false, 'total_selections' => null, 'reasons' => []], account_deletion_feedback_summary($pdo));
        $table = table_name('account_deletion_reason_counts');
        $pdo->exec("CREATE TABLE {$table} (reason_code TEXT PRIMARY KEY, request_count INTEGER)");
        $summary = account_deletion_feedback_summary($pdo);
        self::assertTrue($summary['available']);
        self::assertSame(0, $summary['total_selections']);
        self::assertCount(6, $summary['reasons']);
        record_account_deletion_feedback($pdo, ['privacy', 'privacy', 'technical_issue']);
        record_account_deletion_feedback($pdo, ['technical_issue']);
        $pdo->exec("INSERT INTO {$table} VALUES ('unknown', 50), ('other', -1)");
        $summary = account_deletion_feedback_summary($pdo);
        self::assertSame(3, $summary['total_selections']);
        self::assertSame([0, 0, 0, 2, 1, 0], array_column($summary['reasons'], 'count'));
        self::assertSame(['code', 'count'], array_keys($summary['reasons'][0]));
    }

    public function test_feedback_is_optional_deduplicated_and_allowlisted(): void
    {
        foreach ([null, '', 'privacy', 12, ['reason' => 'privacy']] as $input) {
            self::assertSame([], account_deletion_reason_codes($input));
        }
        self::assertSame(['not_using', 'privacy'], account_deletion_reason_codes([
            'privacy', 'not_using', 'privacy', '<script>', ['other'], true, 1,
        ]));
    }

    public function test_empty_feedback_does_not_need_storage(): void
    {
        $pdo = new PDO('sqlite::memory:');
        record_account_deletion_feedback($pdo, []);
        self::assertSame([], $pdo->query('SELECT name FROM sqlite_master')->fetchAll());
    }

    public function test_missing_optional_storage_does_not_block_deletion(): void
    {
        $log = tempnam(sys_get_temp_dir(), 'splyto-feedback-test-');
        $old = ini_set('error_log', $log);
        try {
            $pdo = new PDO('sqlite::memory:');
            $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
            record_account_deletion_feedback($pdo, ['privacy']);
            self::assertStringContainsString('could not be counted', file_get_contents($log));
            self::assertStringNotContainsString('privacy', file_get_contents($log));
        } finally {
            ini_set('error_log', $old);
            unlink($log);
        }
    }
}
