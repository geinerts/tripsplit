<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

final class SoloTripTest extends TestCase
{
    public function test_existing_one_person_trips_remain_groups(): void
    {
        self::assertFalse(trip_is_solo(['members_count' => 1]));
        self::assertFalse(trip_is_solo(['trip_mode' => 'group', 'members_count' => 1]));
        self::assertTrue(trip_is_solo(['trip_mode' => 'solo']));
        self::assertSame('group', validate_trip_mode('group'));
        self::assertSame('solo', validate_trip_mode('solo'));
    }

    public function test_invalid_mode_is_rejected(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        validate_trip_mode('private-ish');
    }

    public function test_solo_trips_cannot_be_shared(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(409);
        require_group_trip(['trip_mode' => 'solo']);
    }

    public function test_group_sharing_and_split_inputs_are_unchanged(): void
    {
        require_group_trip(['trip_mode' => 'group']);
        require_group_trip([]);
        validate_solo_expense(['trip_mode' => 'group'], 7, ['participants' => [7, 8], 'split_mode' => 'shares']);
        $this->addToAssertionCount(3);
    }

    public function test_owner_can_save_solo_expenses_with_explicit_or_implicit_participants(): void
    {
        $trip = ['trip_mode' => 'solo', 'created_by' => 7];
        validate_solo_expense($trip, 7, []);
        validate_solo_expense($trip, 7, ['participants' => [7], 'split_mode' => 'equal', 'splits' => []]);
        $this->addToAssertionCount(2);
    }

    public function test_solo_expenses_reject_another_actor(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(403);
        validate_solo_expense(['trip_mode' => 'solo', 'created_by' => 7], 8, []);
    }

    public function test_solo_expenses_reject_other_participants(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        validate_solo_expense(['trip_mode' => 'solo', 'created_by' => 7], 7, ['participants' => [7, 8]]);
    }

    public function test_solo_expenses_reject_custom_split_mode(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        validate_solo_expense(['trip_mode' => 'solo', 'created_by' => 7], 7, ['split_mode' => 'exact']);
    }

    public function test_solo_expenses_reject_hidden_split_values(): void
    {
        $this->expectException(ApiResponseException::class);
        $this->expectExceptionCode(400);
        validate_solo_expense(['trip_mode' => 'solo', 'created_by' => 7], 7, ['splits' => [['user_id' => 8, 'value' => 100]]]);
    }

    public function test_solo_creation_uses_its_own_fail_closed_route(): void
    {
        self::assertSame('create_solo_trip_action', api_action_handlers()['create_solo_trip']);
    }
}
