<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;

class MathHelpersTest extends TestCase
{
    // --- cents_to_float ---

    public function test_cents_to_float_whole_euro(): void
    {
        $this->assertSame(10.0, cents_to_float(1000));
    }

    public function test_cents_to_float_with_cents(): void
    {
        $this->assertSame(9.99, cents_to_float(999));
    }

    public function test_cents_to_float_zero(): void
    {
        $this->assertSame(0.0, cents_to_float(0));
    }

    public function test_cents_to_float_one_cent(): void
    {
        $this->assertSame(0.01, cents_to_float(1));
    }

    public function test_cents_to_float_large_amount(): void
    {
        $this->assertSame(1234.56, cents_to_float(123456));
    }

    // --- decimal_to_cents ---

    public function test_decimal_to_cents_whole_number(): void
    {
        $this->assertSame(2000, decimal_to_cents(20.0));
    }

    public function test_decimal_to_cents_with_decimals(): void
    {
        $this->assertSame(999, decimal_to_cents(9.99));
    }

    public function test_decimal_to_cents_rounds_half_up(): void
    {
        $this->assertSame(10, decimal_to_cents(0.095));
    }

    public function test_decimal_to_cents_zero(): void
    {
        $this->assertSame(0, decimal_to_cents(0));
    }

    public function test_decimal_to_cents_string_input(): void
    {
        $this->assertSame(1550, decimal_to_cents('15.50'));
    }

    // --- roundtrip ---

    public function test_roundtrip_cents_to_float_and_back(): void
    {
        $original = 4750;
        $this->assertSame($original, decimal_to_cents(cents_to_float($original)));
    }
}
