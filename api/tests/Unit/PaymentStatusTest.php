<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

class PaymentStatusTest extends TestCase
{
    public function test_supported_payment_statuses_are_preserved(): void
    {
        foreach (['requested', 'sent', 'confirmed', 'cancelled'] as $status) {
            $this->assertSame($status, normalize_payment_status($status));
        }
    }

    public function test_unknown_payment_status_falls_back_to_sent(): void
    {
        $this->assertSame('sent', normalize_payment_status('unknown'));
    }

    public function test_only_open_payment_states_reserve_the_balance(): void
    {
        $this->assertTrue(payment_status_reserves_balance('requested'));
        $this->assertTrue(payment_status_reserves_balance('sent'));
        $this->assertFalse(payment_status_reserves_balance('confirmed'));
        $this->assertFalse(payment_status_reserves_balance('cancelled'));
    }

    public function test_suggested_pair_amount_matches_direction(): void
    {
        $computed = [
            'recommended_settlements' => [
                [
                    'from_user_id' => 8,
                    'to_user_id' => 3,
                    'amount_cents' => 4250,
                ],
            ],
        ];

        $this->assertSame(4250, trip_payment_suggested_pair_cents($computed, 8, 3));
        $this->assertSame(0, trip_payment_suggested_pair_cents($computed, 3, 8));
    }

    public function test_payment_actions_enforce_state_and_participant_role(): void
    {
        $payer = 8;
        $receiver = 3;
        $outsider = 99;

        $this->assertTrue(trip_payment_action_is_allowed('request_sent', 'requested', $payer, $payer, $receiver));
        $this->assertTrue(trip_payment_action_is_allowed('request_decline', 'requested', $payer, $payer, $receiver));
        $this->assertTrue(trip_payment_action_is_allowed('request_cancel', 'requested', $receiver, $payer, $receiver));
        $this->assertTrue(trip_payment_action_is_allowed('confirm', 'sent', $receiver, $payer, $receiver));
        $this->assertTrue(trip_payment_action_is_allowed('cancel', 'sent', $payer, $payer, $receiver));
        $this->assertTrue(trip_payment_action_is_allowed('not_received', 'sent', $receiver, $payer, $receiver));

        $this->assertFalse(trip_payment_action_is_allowed('request_sent', 'requested', $receiver, $payer, $receiver));
        $this->assertFalse(trip_payment_action_is_allowed('request_cancel', 'requested', $payer, $payer, $receiver));
        $this->assertFalse(trip_payment_action_is_allowed('confirm', 'requested', $receiver, $payer, $receiver));
        $this->assertFalse(trip_payment_action_is_allowed('confirm', 'sent', $outsider, $payer, $receiver));
        $this->assertFalse(trip_payment_action_is_allowed('unknown', 'sent', $payer, $payer, $receiver));
    }

    public function test_payment_payload_only_exposes_actions_to_the_correct_user(): void
    {
        $row = [
            'id' => 41,
            'from_user_id' => 8,
            'to_user_id' => 3,
            'from_nickname' => 'Payer',
            'to_nickname' => 'Receiver',
            'amount_cents' => 4250,
            'status' => 'requested',
            'requester_user_id' => 3,
        ];

        $payerPayload = payment_row_to_payload($row, 8);
        $this->assertTrue($payerPayload['can_mark_request_sent']);
        $this->assertTrue($payerPayload['can_decline_request']);
        $this->assertFalse($payerPayload['can_cancel_request']);

        $receiverPayload = payment_row_to_payload($row, 3);
        $this->assertFalse($receiverPayload['can_mark_request_sent']);
        $this->assertFalse($receiverPayload['can_decline_request']);
        $this->assertTrue($receiverPayload['can_cancel_request']);

        $outsiderPayload = payment_row_to_payload($row, 99);
        $this->assertFalse($outsiderPayload['can_mark_request_sent']);
        $this->assertFalse($outsiderPayload['can_decline_request']);
        $this->assertFalse($outsiderPayload['can_cancel_request']);
    }

    public function test_payment_notifications_follow_settlement_preferences(): void
    {
        $this->assertSame(
            'in_app_settlement_updates_enabled',
            notification_in_app_pref_key_for_type('payment_requested')
        );
        $this->assertSame(
            'in_app_settlement_sent_enabled',
            notification_in_app_pref_key_for_type('payment_request_sent')
        );
        $this->assertSame(
            'in_app_settlement_confirmed_enabled',
            notification_in_app_pref_key_for_type('payment_confirmed')
        );
        $this->assertSame(
            'push_settlement_updates_enabled',
            notification_push_pref_key_for_type('payment_request_declined')
        );
    }

    public function test_payment_request_push_is_localized(): void
    {
        $localized = push_localize_notification_for_locale([
            'type' => 'payment_requested',
            'title' => 'Payment requested',
            'body' => 'Anna requested €42.50 from you.',
        ], 'lv');

        $this->assertSame('Pieprasīts maksājums', $localized['title']);
        $this->assertSame('Anna pieprasīja no tevis €42.50.', $localized['body']);
    }

    public function test_payment_confirmation_push_is_localized(): void
    {
        $localized = push_localize_notification_for_locale([
            'type' => 'payment_confirmed',
            'title' => 'Payment confirmed',
            'body' => 'Anna confirmed receiving €42.50 from you.',
        ], 'es');

        $this->assertSame('Pago confirmado', $localized['title']);
        $this->assertSame(
            'Anna confirmó haber recibido €42.50 de ti.',
            $localized['body']
        );
    }
}
