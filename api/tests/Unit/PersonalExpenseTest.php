<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

/** Personal expenses in group trips: docs/api/personal-expenses.md. */
final class PersonalExpenseTest extends TestCase
{
    private static ?array $result = null;

    private static function fixture(): array
    {
        if (self::$result !== null) {
            return self::$result;
        }
        $process = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/personal_expenses.php'],
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        return self::$result = json_decode((string) $output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_everything_works_as_before_until_the_migration_runs(): void
    {
        $r = self::fixture();
        self::assertSame([409, 'Personal expenses are not available yet.'], $r['before']);
        self::assertFalse($r['before_column']);
        self::assertSame(200, $r['before_plain']);
        self::assertSame([[false, false]], $r['before_list']);
        self::assertSame([30, 0, 0], $r['before_balances']);
        self::assertSame(1, $r['before_social']);
    }

    public function test_a_personal_expense_has_only_its_payer(): void
    {
        $r = self::fixture();
        self::assertSame([
            'shared' => [400, 'Personal expenses cannot be shared.'],
            'other_person' => [400, 'Personal expenses cannot be shared.'],
            'shares' => [400, 'Personal expenses cannot be shared.'],
            'bad_value' => [400, 'Invalid is_personal.'],
            'solo' => [400, 'Solo trips have no personal expenses.'],
        ], $r['errors']);
        self::assertSame(0, $r['nothing_saved']);
        self::assertSame([[1, 1, 'equal'], [2, 0, 'equal'], [3, 0, 'equal']],
            array_map(static fn (array $row): array => [(int) $row['id'], (int) $row['is_personal'], $row['split_mode']], $r['stored']));
        self::assertSame([['user_id' => 1, 'owed_cents' => 3000]], $r['personal_participants']);
        // Only the shared dinner notifies anyone; the personal expense and the treat do not.
        self::assertSame([1, 3], array_map('intval', array_column($r['notified'], 'user_id')));
        foreach ($r['notified'] as $note) {
            self::assertSame(2, json_decode($note['payload_json'], true)['expense_id']);
        }
    }

    public function test_others_see_only_amount_date_and_payer(): void
    {
        $r = self::fixture();
        $own = $r['list_payer']['1'];
        self::assertSame([true, false, 'shopping', 'Souvenir'], [$own['is_personal'], $own['locked'], $own['category'], $own['note']]);
        self::assertNotNull($own['receipt_url']);

        foreach ([$r['list_other']['1'], $r['workspace_other']['1'], $r['workspace_nobody']['1']] as $locked) {
            self::assertTrue($locked['is_personal']);
            self::assertTrue($locked['locked']);
            self::assertSame([30, '2026-12-01', 1, 'Owner'], [$locked['amount'], $locked['expense_date'], $locked['paid_by_id'], $locked['paid_by_nickname']]);
            self::assertSame(['other', null, '', 'equal'], [$locked['category'], $locked['subcategory'], $locked['note'], $locked['split_mode']]);
            self::assertSame([null, null, null], [$locked['receipt_path'], $locked['receipt_url'], $locked['receipt_thumb_url']]);
            self::assertSame([['id' => 1, 'nickname' => 'Owner', 'owed' => 30, 'split_value' => null]], $locked['participants']);
            self::assertArrayNotHasKey('source_amount', $locked);
            self::assertArrayNotHasKey('items', $locked);
        }
        self::assertFalse($r['list_other']['1']['from_quick_split']);
        // Group expenses and the treat stay open to everyone.
        self::assertSame([false, false], [$r['list_other']['2']['locked'], $r['list_other']['3']['locked']]);
        self::assertSame('Dinner', $r['list_other']['2']['note']);
        self::assertSame([3000, 0], $r['personal_totals']);
    }

    public function test_balances_leave_personal_expenses_out_without_changing_debts(): void
    {
        $r = self::fixture();
        // Owner's own 30 is neither paid nor owed; the treat counts for Other as before.
        self::assertSame([[1, 0, 30, -30], [2, 90, 30, 60], [3, 12, 42, -30]], $r['balances']);
        self::assertSame([[1, 2, 3000], [3, 2, 3000]], array_map(
            static fn (array $s): array => [$s['from_user_id'], $s['to_user_id'], $s['amount_cents']],
            $r['settlements']
        ));
    }

    public function test_only_the_payer_opens_comments_and_reactions(): void
    {
        $r = self::fixture();
        self::assertSame([403, 'Personal expense is locked.'], $r['comments']['other_add']);
        self::assertSame([403, 'Personal expense is locked.'], $r['comments']['other_list']);
        self::assertSame([403, 'Personal expense is locked.'], $r['comments']['other_reactions']);
        self::assertSame(1, $r['comments']['payer_open']);
        self::assertSame(2, $r['comments']['other_group']);
    }

    public function test_updates_keep_or_clear_the_flag(): void
    {
        $r = self::fixture();
        self::assertSame([200, 1], $r['update_kept'], 'Older apps keep it while only the payer takes part');
        self::assertSame([403, 'Only expense owner can edit.'], $r['update_other']);
        self::assertSame([400, 'Personal expenses cannot be shared.'], $r['update_shared_refused']);
        self::assertSame([200, 0], $r['update_cleared'], 'Sharing it from an older app makes it a group expense');
        self::assertSame([200, 1, [1]], $r['update_back']);
        self::assertSame([200, 0], $r['update_treat'], 'A treat never becomes personal by itself');
    }

    public function test_activity_shows_others_only_the_amount(): void
    {
        $r = self::fixture();
        $payer = $r['activity_payer'];
        $other = $r['activity_other'];
        self::assertCount(4, $payer);
        self::assertCount(4, $other);
        self::assertSame('Souvenir', $payer[3][1]['note']);
        foreach ([0, 2, 3] as $personalEvent) {
            self::assertSame(['amount_cents', 'trip_currency_code', 'is_personal'], array_keys($other[$personalEvent][1]));
            self::assertTrue($other[$personalEvent][1]['is_personal']);
        }
        // While it was shared, its event was a normal one.
        self::assertSame('Souvenirs', $other[1][1]['note']);
    }

    public function test_analytics_and_report_leave_personal_expenses_out(): void
    {
        $r = self::fixture();
        foreach (['analytics_payer', 'analytics_other'] as $key) {
            self::assertSame(['food'], array_column($r[$key]['buckets'], 'category'));
            self::assertSame(10200, $r[$key]['buckets'][0]['total_cents']);
            self::assertNotContains(1, array_column($r[$key]['largest_by_total'], 'id'));
        }
        self::assertSame(0, $r['analytics_payer']['members'][2]['paid_cents']);
        self::assertSame([4000, 0], [$r['analytics_payer']['personal_cents'], $r['analytics_other']['personal_cents']]);

        self::assertSame([10200, 4000, 2], [$r['report_payer']['total_cents'], $r['report_payer']['personal_cents'], $r['report_payer']['expense_count']]);
        self::assertSame([['key' => 'food', 'cents' => 10200]], $r['report_payer']['categories']);
        self::assertSame([10200, 0, 2], [$r['report_other']['total_cents'], $r['report_other']['personal_cents'], $r['report_other']['expense_count']]);
    }
}
