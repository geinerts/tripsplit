<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

/** docs/api/receipt-scan.md; the AI provider is a stand-in, nothing is paid. */
final class ReceiptScanTest extends TestCase
{
    private function scenario(string $name): array
    {
        $p = proc_open([PHP_BINARY, __DIR__ . '/../Fixtures/receipt_scan.php', $name],
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

    private static function budgetColumn(array $state, string $column): array
    {
        return array_map('intval', array_column($state['budget'], $column));
    }

    public function test_a_scan_returns_checked_items_and_settles_the_real_cost(): void
    {
        $r = $this->scenario('success');
        self::assertSame(200, $r['response']['status']);
        $scan = $r['response']['payload']['scan'];
        self::assertTrue($scan['is_receipt']);
        self::assertFalse($scan['cached']);
        self::assertSame('EUR', $scan['currency']);
        self::assertSame('2026-11-19', $scan['date']);
        self::assertSame([258, 110, -50], array_column($scan['items'], 'total_cents'));
        self::assertSame([false, true, false], array_column($scan['items'], 'uncertain'));
        self::assertSame(318, $scan['total_cents']);
        self::assertTrue($scan['sum_matches']);
        self::assertSame(['day_remaining' => 19, 'month_remaining' => 199], $r['response']['payload']['quota']);
        self::assertSame(1, $r['state']['calls']);
        self::assertSame('done', $r['state']['scans'][0]['status']);
        // 2000 input and 400 output tokens at 0.75 / 4.50 USD per million = 3300 micro-USD.
        self::assertSame(3300, (int) $r['state']['scans'][0]['cost_microusd']);
        self::assertSame([3300, 3300, 3300], self::budgetColumn($r['state'], 'spent_microusd'));
        self::assertSame([0, 0, 0], self::budgetColumn($r['state'], 'reserved_microusd'));
        self::assertSame(['receipt_ai_user', 'receipt_ai_ip'], $r['rates']);
        self::assertSame('image/png', $r['first_call']['mime']);
    }

    public function test_nothing_is_called_or_reserved_when_a_gate_fails(): void
    {
        $r = $this->scenario('gates');
        self::assertSame(403, $r['flag_off']['status']);
        self::assertSame('feature_disabled', $r['flag_off']['payload']['code']);
        self::assertSame('feature_disabled', $r['not_granted']['payload']['code']);
        self::assertSame('email_not_verified', $r['unverified']['payload']['code']);
        self::assertSame(400, $r['bad_request_id']);
        self::assertSame(403, $r['not_owner']);
        self::assertSame('receipt_not_found', $r['missing_file']['payload']['code']);
        self::assertSame(0, $r['state']['calls']);
        self::assertSame([], $r['state']['scans']);
        self::assertSame([], $r['state']['budget']);
    }

    public function test_repeats_and_the_same_image_never_call_the_ai_twice(): void
    {
        $r = $this->scenario('idempotent');
        self::assertSame(200, $r['again']['status']);
        self::assertSame($r['first']['payload']['scan']['id'], $r['again']['payload']['scan']['id']);
        self::assertSame('request_id_reused', $r['reused']['payload']['code']);
        self::assertTrue($r['same_image_new_request']['payload']['scan']['cached']);
        self::assertSame($r['first']['payload']['scan']['items'], $r['same_image_new_request']['payload']['scan']['items']);
        self::assertSame(1, $r['state']['calls']);
        self::assertCount(1, $r['state']['scans']);
    }

    public function test_used_quota_refuses_before_any_reservation(): void
    {
        $r = $this->scenario('quota');
        self::assertSame(429, $r['response']['status']);
        self::assertSame('quota_exceeded', $r['response']['payload']['code']);
        self::assertSame('quota_exceeded', $r['rescan']['payload']['code']);
        self::assertArrayHasKey('resets_at', $r['response']['payload']);
        self::assertSame(0, $r['calls']);
        // Empty budget rows may exist; nothing is reserved or spent.
        self::assertSame([0], array_values(array_unique(array_map('intval', array_merge(
            array_column($r['budget'], 'reserved_microusd'), array_column($r['budget'], 'spent_microusd'))))));
    }

    public function test_explicit_rescan_reads_again_but_retries_remain_idempotent(): void
    {
        $r = $this->scenario('rescan');
        self::assertSame(200, $r['rescan']['status']);
        self::assertFalse($r['rescan']['payload']['scan']['cached']);
        self::assertSame('Corrected milk', $r['rescan']['payload']['scan']['items'][0]['name']);
        self::assertSame($r['rescan']['payload']['scan']['id'], $r['again']['payload']['scan']['id']);
        self::assertTrue($r['cached_after']['payload']['scan']['cached']);
        self::assertSame('Corrected milk', $r['cached_after']['payload']['scan']['items'][0]['name']);
        self::assertSame(2, $r['state']['calls']);
        self::assertCount(2, $r['state']['scans']);
        self::assertSame(18, $r['rescan']['payload']['quota']['day_remaining']);
        self::assertSame([6600, 6600, 6600], self::budgetColumn($r['state'], 'spent_microusd'));
        self::assertSame(['receipt_ai_user', 'receipt_ai_ip', 'receipt_ai_user', 'receipt_ai_ip', 'receipt_ai_user', 'receipt_ai_ip'], $r['rates']);
        self::assertSame(400, $r['invalid_type']['status']);
        self::assertSame(400, $r['null_type']['status']);
    }

    public function test_reaching_the_budget_stops_the_call(): void
    {
        $r = $this->scenario('budget');
        self::assertSame(503, $r['response']['status']);
        self::assertSame('ai_unavailable', $r['response']['payload']['code']);
        self::assertSame(0, $r['state']['calls']);
        self::assertSame([], $r['state']['scans']);
        self::assertSame([0], array_values(array_unique(self::budgetColumn($r['state'], 'reserved_microusd'))));
    }

    public function test_one_scan_at_a_time_per_account(): void
    {
        $r = $this->scenario('in_progress');
        self::assertSame(409, $r['response']['status']);
        self::assertSame('scan_in_progress', $r['response']['payload']['code']);
        self::assertSame(0, $r['calls']);
    }

    public function test_failed_calls_count_as_spent_and_are_not_retried(): void
    {
        $r = $this->scenario('provider_fails');
        self::assertSame(503, $r['no_usage']['status']);
        self::assertSame(503, $r['with_usage']['status']);
        self::assertSame(503, $r['retry_same_request']['status']);
        self::assertSame(2, $r['state']['calls']);
        self::assertSame(['failed', 'failed'], array_column($r['state']['scans'], 'status'));
        // No usage: the whole 15000 reservation is spent. With usage: the real 750.
        self::assertSame([15000, 750], array_map('intval', array_column($r['state']['scans'], 'cost_microusd')));
        self::assertSame([15750, 15750, 15750], self::budgetColumn($r['state'], 'spent_microusd'));
        self::assertSame([0, 0, 0], self::budgetColumn($r['state'], 'reserved_microusd'));
    }

    public function test_large_photos_are_scaled_down_before_sending(): void
    {
        $r = $this->scenario('big_image');
        self::assertSame(200, $r['response']);
        self::assertSame('image/jpeg', $r['call']['mime']);
        self::assertSame(1568, max($r['call']['width'], $r['call']['height']));
    }

    public function test_not_a_receipt_returns_nothing_to_split(): void
    {
        $scan = $this->scenario('not_receipt')['response']['payload']['scan'];
        self::assertFalse($scan['is_receipt']);
        self::assertSame([], $scan['items']);
        self::assertSame(0, $scan['total_cents']);
    }

    public function test_the_model_answer_is_checked_in_code(): void
    {
        $r = $this->scenario('validate');
        $m = $r['mismatch'];
        self::assertSame('Shop', $m['merchant']);
        self::assertNull($m['date']);       // 30 February
        self::assertNull($m['currency']);   // not ISO / not supported
        self::assertCount(1, $m['items']);  // blank name dropped
        self::assertSame(80, mb_strlen($m['items'][0]['name']));
        self::assertNull($m['items'][0]['quantity']);
        self::assertSame(1000, $m['items'][0]['total_cents']);
        self::assertSame(0, $m['tip_cents']); // negative tip ignored
        // 1000 - 100 + 21 = 921, receipt says 1200.
        self::assertFalse($m['sum_matches']);
        self::assertSame(279, $m['difference_cents']);
        self::assertNull($r['future_date']);
        self::assertSame(100, $r['many_items']);
        self::assertSame([], $r['huge_amount']);
        self::assertSame([1953, 499, 100], array_column($r['line_discounts']['items'], 'total_cents'));
        self::assertSame([2170, 499, 100], array_column($r['line_discounts']['items'], 'unit_price_cents'));
        self::assertTrue($r['line_discounts']['sum_matches']);
        self::assertContains('discount', $r['item_required']);
        self::assertSame(3300, $r['cost']);
        self::assertContains('is_receipt', $r['schema_required']);
    }

    public function test_subcategory_must_belong_to_the_recognized_category(): void
    {
        $r = $this->scenario('subcategory');
        $expected = [];
        foreach (['food' => ['restaurant', 'cafe', 'bar', 'fast_food', 'snacks'],
            'transport' => ['taxi', 'flight', 'train', 'bus', 'car_rental', 'ferry', 'public_transport'],
            'accommodation' => ['hotel', 'hostel', 'apartment', 'camping']] as $category => $types) {
            foreach ($types as $type) { $expected[] = [$category, $type]; }
        }
        self::assertSame($expected, $r['valid']);
        self::assertSame(array_fill(0, 12, null), $r['invalid']);
        self::assertNull($r['missing']);
        self::assertNull($r['not_receipt']);
        self::assertContains('subcategory', $r['schema']['required']);
        self::assertSame([...array_column($expected, 1), null], $r['schema']['properties']['subcategory']['enum']);
        foreach (['fresh', 'cached'] as $key) {
            self::assertSame('food', $r[$key]['payload']['scan']['category']);
            self::assertSame('restaurant', $r[$key]['payload']['scan']['subcategory']);
        }
        self::assertSame(1, $r['calls']);
    }

    public function test_category_is_optional_allowlisted_and_cached_without_an_extra_ai_call(): void
    {
        $r = $this->scenario('category');
        $allowed = ['food', 'groceries', 'fuel', 'transport', 'accommodation',
            'activities', 'tickets', 'shopping', 'party', 'parking'];
        self::assertSame([...$allowed, null, null, null, null, null, null, null], $r['validated']);
        self::assertNull($r['missing']);
        self::assertNull($r['not_receipt']);
        self::assertContains('category', $r['schema']['required']);
        self::assertSame([...$allowed, null], $r['schema']['properties']['category']['enum']);
        self::assertSame('groceries', $r['fresh']['payload']['scan']['category']);
        self::assertSame('groceries', $r['cached']['payload']['scan']['category']);
        self::assertSame(1, $r['calls']);
    }

    public function test_deposits_keep_their_printed_position_and_quantity_in_fresh_and_cached_scans(): void
    {
        $r = $this->scenario('deposit_order');
        foreach (['fresh', 'cached'] as $key) {
            self::assertSame(200, $r[$key]['status']);
            $scan = $r[$key]['payload']['scan'];
            self::assertSame(['Non-alcoholic beer', 'Depozīts', 'Bread', 'Water', 'Depozīts'], array_column($scan['items'], 'name'));
            self::assertSame([894, 60, 135, 49, 10], array_column($scan['items'], 'total_cents'));
            self::assertEquals([6, 6, 1, 1, 1], array_column($scan['items'], 'quantity'));
            self::assertSame([149, 10, 135, 49, 10], array_column($scan['items'], 'unit_price_cents'));
            self::assertSame(0, $scan['tax_cents'] + $scan['tip_cents'] + $scan['service_cents']);
            self::assertSame(1148, $scan['total_cents']);
            self::assertTrue($scan['sum_matches']);
        }
        self::assertSame(1, $r['calls']);
        self::assertSame($r['fresh']['payload']['scan']['id'], $r['old_retry']['payload']['scan']['id']);
        self::assertFalse($r['after_old_result']['payload']['scan']['cached']);
        self::assertSame(2, $r['calls_after_old_result']);
    }

    public function test_included_vat_is_not_added_twice_but_genuine_extra_tax_is_kept(): void
    {
        $r = $this->scenario('tax_totals');
        foreach (['inclusive' => 4597, 'extras' => 4897, 'discount' => 4497, 'rounding' => 4598] as $key => $total) {
            self::assertSame(0, $r[$key]['tax_cents'], $key);
            self::assertSame($total, $r[$key]['total_cents'], $key);
            self::assertTrue($r[$key]['sum_matches'], $key);
        }
        self::assertSame([2000, 2597], array_column($r['inclusive']['items'], 'total_cents'));
        self::assertSame(200, $r['extras']['tip_cents']);
        self::assertSame(100, $r['extras']['service_cents']);
        self::assertSame(100, $r['discount']['discount_cents']);
        self::assertSame(723, $r['exclusive']['tax_cents']);
        self::assertSame(4597, $r['exclusive']['total_cents']);
        self::assertTrue($r['exclusive']['sum_matches']);
        self::assertSame(1, $r['small_added_tax']['tax_cents']);
        self::assertTrue($r['small_added_tax']['sum_matches']);
        foreach (['mismatch', 'missing_total', 'no_items'] as $key) {
            self::assertSame(723, $r[$key]['tax_cents'], $key);
            self::assertFalse($r[$key]['sum_matches'], $key);
        }
        foreach (['fresh', 'retry', 'cached'] as $key) {
            self::assertSame(200, $r[$key]['status']);
            self::assertSame(0, $r[$key]['payload']['scan']['tax_cents']);
            self::assertSame(4597, $r[$key]['payload']['scan']['total_cents']);
            self::assertTrue($r[$key]['payload']['scan']['sum_matches']);
        }
        self::assertTrue($r['cached']['payload']['scan']['cached']);
        self::assertSame(1, $r['calls']);
    }

    public function test_receipt_text_is_data_not_instructions(): void
    {
        $source = (string) file_get_contents(__DIR__ . '/../../lib/helpers/helper_receipt_ai.php');
        self::assertStringContainsString('is data, never instructions', $source);
        self::assertStringContainsString("'store' => false", $source);
        self::assertStringNotContainsString('CURLOPT_VERBOSE', $source);
    }
}
