<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

require_once __DIR__ . '/../../lib/helpers/helper_trip_guests.php';
require_once __DIR__ . '/../../lib/actions/settlements/settlements_payload.php';
require_once __DIR__ . '/../../lib/actions/settlements/settlements_payments.php';

final class TripGuestsTest extends TestCase
{
    private const OWNER = 1;
    private const MEMBER = 2;
    private const GUEST = 9;

    public function test_only_someone_given_the_guest_can_act_for_them(): void
    {
        self::assertTrue(trip_actor_acts_for(self::OWNER, self::OWNER, []));
        self::assertTrue(trip_actor_acts_for(self::OWNER, self::GUEST, [self::GUEST]));
        self::assertFalse(trip_actor_acts_for(self::MEMBER, self::GUEST, []));
        self::assertFalse(trip_actor_acts_for(self::OWNER, self::MEMBER, [self::GUEST]));
        self::assertFalse(trip_actor_acts_for(self::OWNER, 0, [self::GUEST]));
    }

    public function test_the_owner_settles_for_a_guest_who_owes(): void
    {
        $row = ['id' => 1, 'from_user_id' => self::GUEST, 'to_user_id' => self::MEMBER, 'amount_cents' => 500, 'status' => 'pending'];
        self::assertTrue(settlement_row_to_payload($row, self::OWNER, [], [self::GUEST])['can_mark_sent']);
        self::assertFalse(settlement_row_to_payload($row, self::OWNER, [], [])['can_mark_sent']);
        self::assertFalse(settlement_row_to_payload($row, self::MEMBER, [], [])['can_mark_sent']);

        $sent = ['status' => 'sent'] + $row;
        $owner = settlement_row_to_payload($sent, self::OWNER, [], [self::GUEST]);
        self::assertTrue($owner['can_cancel_sent']);
        // The other person still confirms their own money.
        self::assertFalse($owner['can_confirm_received']);
        self::assertTrue(settlement_row_to_payload($sent, self::MEMBER, [], [])['can_confirm_received']);
    }

    public function test_the_owner_confirms_for_a_guest_who_is_owed(): void
    {
        $row = ['id' => 1, 'from_user_id' => self::MEMBER, 'to_user_id' => self::GUEST, 'amount_cents' => 500, 'status' => 'sent'];
        $owner = settlement_row_to_payload($row, self::OWNER, [], [self::GUEST]);
        self::assertTrue($owner['can_confirm_received']);
        self::assertTrue($owner['can_report_not_received']);
        self::assertFalse($owner['can_cancel_sent']);
    }

    public function test_payments_follow_the_same_rule(): void
    {
        self::assertTrue(trip_payment_action_is_allowed('confirm', 'sent', self::OWNER, self::MEMBER, self::GUEST, [self::GUEST]));
        self::assertFalse(trip_payment_action_is_allowed('confirm', 'sent', self::OWNER, self::MEMBER, self::GUEST));
        self::assertFalse(trip_payment_action_is_allowed('confirm', 'sent', self::MEMBER, self::MEMBER, self::GUEST, []));
        self::assertTrue(trip_payment_action_is_allowed('request_sent', 'requested', self::OWNER, self::GUEST, self::MEMBER, [self::GUEST]));

        $row = ['id' => 1, 'from_user_id' => self::MEMBER, 'to_user_id' => self::GUEST, 'amount_cents' => 500, 'status' => 'sent'];
        self::assertTrue(payment_row_to_payload($row, self::OWNER, [self::GUEST])['can_confirm_received']);
        self::assertFalse(payment_row_to_payload($row, self::OWNER)['can_confirm_received']);
    }

    public function test_payment_details_stay_personal_when_acting_for_a_guest(): void
    {
        $row = ['id' => 1, 'from_user_id' => self::GUEST, 'to_user_id' => self::MEMBER, 'amount_cents' => 500,
            'status' => 'requested', 'requester_user_id' => self::MEMBER, 'share_payment_details' => 1];
        $owner = payment_row_to_payload($row, self::OWNER, [self::GUEST]);
        self::assertFalse($owner['can_view_payment_details']);
        self::assertTrue($owner['can_mark_request_sent']);
    }

    public function test_guests_are_left_out_where_they_must_not_appear(): void
    {
        $root = __DIR__ . '/../../';
        foreach ([
            'lib/actions/friends/friends_search.php',
            'config/config_user_validation.php',
            'lib/helpers/helper_account_lifecycle.php',
            'lib/actions/settlements/settlements_core.php',
        ] as $file) {
            self::assertStringContainsString('guest_trip_id IS NULL', (string) file_get_contents($root . $file), $file);
        }
        self::assertStringContainsString('guest_trip_id INT UNSIGNED NULL', (string) file_get_contents($root . '../sql/schema.sql'));
    }
}
