<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;

final class QuickSplitsTest extends TestCase
{
    private static function run_fixture(string ...$args): array
    {
        $process = proc_open(array_merge([PHP_BINARY, __DIR__ . '/../Fixtures/quick_splits.php'], $args),
            [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
        self::assertIsResource($process);
        fclose($pipes[0]);
        $output = stream_get_contents($pipes[1]);
        $errors = stream_get_contents($pipes[2]);
        fclose($pipes[1]);
        fclose($pipes[2]);
        self::assertSame(0, proc_close($process), $errors);
        self::assertSame('', $errors);
        return json_decode((string) $output, true, 512, JSON_THROW_ON_ERROR);
    }

    public function test_actions_answer_409_before_the_migration(): void
    {
        $r = self::run_fixture('before');
        self::assertSame(409, $r['list']['status']);
        self::assertSame('Quick splits are not available yet.', $r['add']['body']['error']);
    }

    public function test_quick_splits_are_shared_records_only_the_creator_changes(): void
    {
        $r = self::run_fixture();
        $errors = array_map(static fn (array $e): array => [$e['status'], $e['body']['error']], $r['errors']);
        self::assertSame([
            'one_person' => [400, 'Add at least two people.'],
            'no_key' => [400, 'Each person needs a key.'],
            'dup_key' => [400, 'People keys must be unique.'],
            'not_me' => [400, 'You must be part of the quick split.'],
            'stranger' => [403, 'You can only add friends.'],
            'guest' => [403, 'You can only add friends.'],
            'unknown_payer' => [400, 'Unknown person.'],
            'link_name' => [400, 'Name must not contain links.'],
            'exact_sum' => [400, 'Exact split must sum to full expense amount.'],
        ], $errors);
        self::assertSame(0, $r['nothing_saved']);

        $created = $r['created']['body']['quick_split'];
        self::assertSame([90, 'EUR', 3, 30, true, 'Owner', true], [$created['amount'], $created['currency_code'],
            $created['people_count'], $created['my_amount'], $created['paid_by_me'], $created['paid_by_name'], $created['can_edit']]);
        self::assertSame(['Owner', 'Invitee', 'Andris'], array_column($created['people'], 'name'));
        self::assertSame([true, true, false], array_column($created['people'], 'is_account'));

        // Same client_mutation_id: same quick split, no second notification.
        self::assertSame($created['id'], $r['replay']);
        self::assertSame(1, $r['count_after_replay']);
        self::assertCount(1, $r['notes_after_create']);
        $note = $r['notes_after_create'][0];
        self::assertSame([2, null, 'quick_split_added', 'Quick split', 'Owner added you to a quick split: Dinner at Lido'],
            [(int) $note['user_id'], $note['trip_id'], $note['type'], $note['title'], $note['body']]);
        self::assertSame(['quick_split_id' => $created['id']], json_decode($note['payload_json'], true));

        // People see it; only the creator changes it.
        self::assertSame(200, $r['invitee_get']['status']);
        self::assertFalse($r['invitee_get']['body']['quick_split']['can_edit']);
        self::assertSame(30, $r['invitee_get']['body']['quick_split']['my_amount']);
        self::assertSame([404, 403, 403, 403], [$r['other_get'], $r['invitee_update'], $r['invitee_delete'], $r['invitee_move']]);

        // Itemized: shared items, extra in proportion, a name-only payer.
        $itemized = $r['itemized'];
        self::assertSame('itemized', $itemized['split_mode']);
        self::assertSame([7.06, 12.94, 0], array_column($itemized['people'], 'amount'));
        self::assertSame([false, false, true], array_column($itemized['people'], 'is_payer'));
        self::assertSame('Andris', $itemized['paid_by_name']);
        self::assertSame(['Pizza', 'Beer'], array_column($itemized['items'], 'name'));
        $ids = array_column($itemized['people'], 'id');
        self::assertSame([[$ids[0], $ids[1]], [$ids[1]]], array_column($itemized['items'], 'person_ids'));
        self::assertSame(3, $itemized['extra_amount']);
        self::assertSame('Unknown person.', $r['bad_item_person']['error']);
        self::assertSame(2, $r['notes_after_itemized']);

        // Newest date first, paged; strangers see nothing.
        self::assertSame([3, 1, 2], $r['owner_list']);
        self::assertSame([1, 2], array_column($r['invitee_list'], 'id'));
        self::assertSame([], $r['other_list']);
        self::assertSame([[3, 1], true, [2], false], $r['pages']);

        // Update replaces the split and tells only newly added accounts.
        self::assertSame([['Owner', 20, 1], ['Invitee', 20, 1], ['Andris', 20, 1], ['Friend', 40, 2]], $r['updated']);
        self::assertSame([4], $r['update_notes']);

        // Receipts.
        self::assertSame(403, $r['foreign_receipt']);
        self::assertSame([true, true, true], $r['receipt']);
        self::assertNull($r['friend_sees_receipt_path']);
        self::assertSame(['ok' => true], $r['delete_third']);
        self::assertCount(1, $r['deleted_receipts']);
        self::assertSame(404, $r['friend_after_delete']);

        // Add to a trip.
        self::assertSame(404, $r['move_errors'][0]);
        self::assertSame('Expense not found.', $r['move_errors'][1]['error']);
        self::assertSame(['ok' => true], $r['move']);
        self::assertSame([2], $r['after_move_list']);
        // The trip expense knows it came from a quick split, only in that trip.
        self::assertSame([[true, false], false], $r['origin']);
        self::assertSame([['trip_id' => 7, 'expense_id' => 950], false], $r['after_move_get']);
        self::assertSame('This quick split was added to a trip.', $r['after_move_update']['error']);
        self::assertSame(409, $r['after_move_delete']);

        // Account deletion.
        self::assertSame('Invitee', $r['deleted_person_name']);
        self::assertSame([], $r['creator_erased_receipts']);
        self::assertSame(0, $r['left_after_creator_erased']);
    }

    public function test_notification_is_translated_and_uses_the_expense_switches(): void
    {
        $r = self::run_fixture();
        self::assertSame(['title' => 'Ātrā dalīšana', 'body' => 'Owner tevi pievienoja ātrajai dalīšanai: Dinner at Lido'], $r['push_lv'][0]);
        self::assertSame('Owner tevi pievienoja ātrajai dalīšanai par EUR 84.00', $r['push_lv'][1]['body']);
        self::assertSame(['in_app_expense_added_enabled', 'push_expense_added_enabled'], $r['prefs']);
    }

    public function test_router_schema_and_migration_agree(): void
    {
        $root = __DIR__ . '/../../';
        $router = (string) file_get_contents($root . 'lib/http/action_router.php');
        foreach (['add', 'update', 'delete', 'list', 'get'] as $verb) {
            $action = $verb === 'list' ? 'list_quick_splits' : $verb . '_quick_split';
            self::assertStringContainsString("'" . $action . "' => '" . $action . "_action'", $router);
        }
        self::assertStringContainsString("'move_quick_split_to_trip' => 'move_quick_split_to_trip_action'", $router);
        $schema = (string) file_get_contents($root . '../sql/schema.sql');
        $migration = (string) file_get_contents($root . '../sql/migrations/2026-11-17-add-quick-splits.sql');
        foreach (['trip_quick_splits', 'trip_quick_split_people', 'trip_quick_split_items', 'trip_quick_split_item_people'] as $table) {
            self::assertStringContainsString('CREATE TABLE IF NOT EXISTS ' . $table . ' (', $schema);
            self::assertStringContainsString('CREATE TABLE IF NOT EXISTS ' . $table . ' (', $migration);
        }
    }
}
