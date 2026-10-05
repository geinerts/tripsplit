<?php
declare(strict_types=1);

use PHPUnit\Framework\Attributes\DataProvider;
use PHPUnit\Framework\TestCase;

final class PaymentDetailsPrivacyTest extends TestCase
{
    private PDO $pdo;

    protected function setUp(): void
    {
        $mysql = getenv('SPLYTO_ISOLATED_MYSQL') === '1';
        if ($mysql) {
            require_once __DIR__ . '/../Fixtures/isolated_mysql.php';
            $this->pdo = isolated_test_mysql();
            $this->pdo->exec('SET FOREIGN_KEY_CHECKS=0');
            foreach (['payments', 'trip_members', 'trips', 'users'] as $table) {
                $this->pdo->exec('DROP TABLE IF EXISTS trip_' . $table);
            }
            $this->pdo->exec('SET FOREIGN_KEY_CHECKS=1');
        } else {
            $this->pdo = new PDO('sqlite::memory:');
        }
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        $this->pdo->exec('CREATE TABLE trip_users (
            id INTEGER PRIMARY KEY, account_status VARCHAR(20), nickname VARCHAR(64),
            email VARCHAR(255), password_hash VARCHAR(255),
            bank_account_holder VARCHAR(100), bank_iban VARCHAR(100), bank_bic VARCHAR(100),
            revolut_handle VARCHAR(100), revolut_me_link VARCHAR(255),
            paypal_me_link VARCHAR(255), wise_pay_link VARCHAR(255))');
        $this->pdo->exec('CREATE TABLE trip_trips (id INTEGER PRIMARY KEY, status VARCHAR(20))');
        $this->pdo->exec('CREATE TABLE trip_trip_members (trip_id INTEGER, user_id INTEGER,
            PRIMARY KEY (trip_id, user_id))');
        $this->pdo->exec('CREATE TABLE trip_payments (id INTEGER PRIMARY KEY, trip_id INTEGER,
            from_user_id INTEGER, to_user_id INTEGER, requester_user_id INTEGER, status VARCHAR(20))');
        $this->pdo->exec('INSERT INTO trip_payments VALUES (5,10,1,2,2,"requested")');
        // Verify the actual migration preserves old requests with consent OFF.
        $this->pdo->exec($mysql
            ? file_get_contents(__DIR__ . '/../../../sql/migrations/2026-10-05-add-payment-details-consent.sql')
            : 'ALTER TABLE trip_payments ADD COLUMN share_payment_details INTEGER NOT NULL DEFAULT 0');
        self::assertSame(0, (int) $this->pdo->query('SELECT share_payment_details FROM trip_payments')->fetchColumn());
        $this->pdo->exec('INSERT INTO trip_trips VALUES (10,"active"),(20,"active")');
        $this->pdo->exec('INSERT INTO trip_trip_members VALUES (10,1),(10,2),(10,3),(20,1),(20,2)');
        $this->pdo->exec('INSERT INTO trip_users (id,account_status,nickname,email,password_hash,bank_iban)
            VALUES (1,"active","Payer","payer@example.invalid","private-hash","PAYER-SECRET"),
                   (2,"active","Payee","payee@example.invalid","private-hash","PAYEE-SECRET"),
                   (3,"active","Owner","owner@example.invalid","private-hash","OWNER-SECRET"),
                   (4,"active","Outsider","other@example.invalid","private-hash","OTHER-SECRET")');
        $this->pdo->exec('UPDATE trip_payments SET share_payment_details=1');
    }

    public function test_only_intended_payer_receives_allowlisted_fields(): void
    {
        $details = load_trip_payment_request_details($this->pdo, 10, 5, 1);
        self::assertSame('PAYEE-SECRET', $details['bank_iban']);
        self::assertSame(['bank_account_holder','bank_iban','bank_bic','revolut_handle',
            'revolut_me_link','paypal_me_link','wise_pay_link'], array_keys($details));
        self::assertStringNotContainsString('private-hash', json_encode($details));
    }

    public static function deniedCases(): iterable
    {
        yield 'payee is not payer' => [2, 10, 5, null];
        yield 'owner/admin has no override' => [3, 10, 5, null];
        yield 'outsider' => [4, 10, 5, null];
        yield 'anonymous' => [0, 10, 5, null];
        yield 'other shared trip' => [1, 20, 5, null];
        yield 'unknown payment' => [1, 10, 99, null];
        yield 'old request without consent' => [1, 10, 5, 'UPDATE trip_payments SET share_payment_details=0'];
        yield 'payer initiated' => [1, 10, 5, 'UPDATE trip_payments SET requester_user_id=1'];
        yield 'missing requester' => [1, 10, 5, 'UPDATE trip_payments SET requester_user_id=NULL'];
        foreach (['sent','confirmed','cancelled','unexpected'] as $status) {
            yield $status => [1,10,5,'UPDATE trip_payments SET status="' . $status . '"'];
        }
        foreach (['settling','archived'] as $status) {
            yield $status => [1,10,5,'UPDATE trip_trips SET status="' . $status . '"'];
        }
        foreach ([1,2] as $id) {
            yield 'removed member ' . $id => [1,10,5,'DELETE FROM trip_trip_members WHERE trip_id=10 AND user_id=' . $id];
            foreach (['deactivated','deleted'] as $status) {
                yield $status . ' user ' . $id => [1,10,5,'UPDATE trip_users SET account_status="' . $status . '" WHERE id=' . $id];
            }
        }
        yield 'self request' => [1,10,5,'UPDATE trip_payments SET to_user_id=1,requester_user_id=1'];
    }

    #[DataProvider('deniedCases')]
    public function test_denied_context_never_returns_payment_details(int $actor, int $trip, int $payment, ?string $mutation): void
    {
        if ($mutation !== null) $this->pdo->exec($mutation);
        self::assertNull(load_trip_payment_request_details($this->pdo, $trip, $payment, $actor));
    }

    public function test_cancellation_is_effective_on_next_read(): void
    {
        self::assertNotNull(load_trip_payment_request_details($this->pdo, 10, 5, 1));
        $this->pdo->exec('UPDATE trip_payments SET status="cancelled"');
        self::assertNull(load_trip_payment_request_details($this->pdo, 10, 5, 1));
    }

    public function test_response_action_flag_requires_consent_and_payer(): void
    {
        $row = ['from_user_id'=>1,'to_user_id'=>2,'requester_user_id'=>2,
            'status'=>'requested','share_payment_details'=>1];
        self::assertTrue(payment_row_to_payload($row, 1)['can_view_payment_details']);
        foreach ([0,2,3] as $actor) {
            self::assertFalse(payment_row_to_payload($row, $actor)['can_view_payment_details']);
        }
        foreach ([['share_payment_details'=>0],['requester_user_id'=>1],['status'=>'sent']] as $change) {
            self::assertFalse(payment_row_to_payload(array_replace($row, $change), 1)['can_view_payment_details']);
        }
        unset($row['share_payment_details']);
        self::assertFalse(payment_row_to_payload($row, 1)['can_view_payment_details']);
    }
}
