<?php
declare(strict_types=1);

use PHPUnit\Framework\TestCase;
require_once __DIR__ . '/../../lib/helpers/helper_profile_payment_sharing.php';

final class ProfilePaymentSharingTest extends TestCase
{
    private PDO $pdo;

    protected function setUp(): void
    {
        $this->pdo = new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]);
        $this->pdo->exec('CREATE TABLE trip_users (id INTEGER PRIMARY KEY, account_status TEXT,
            share_payment_details_with_trips INTEGER NOT NULL DEFAULT 0,
            bank_account_holder TEXT, bank_iban TEXT, bank_bic TEXT, revolut_handle TEXT,
            revolut_me_link TEXT, paypal_me_link TEXT, wise_pay_link TEXT, email TEXT, password_hash TEXT)');
        $this->pdo->exec('CREATE TABLE trip_trips (id INTEGER PRIMARY KEY)');
        $this->pdo->exec('CREATE TABLE trip_trip_members (trip_id INTEGER, user_id INTEGER)');
        $this->pdo->exec('CREATE TABLE trip_trip_invites (trip_id INTEGER, target_user_id INTEGER)');
        $this->pdo->exec("INSERT INTO trip_users (id,account_status,revolut_handle,email,password_hash) VALUES
            (1,'active','@viewer','private','secret'),(2,'active','@member','private','secret'),(3,'active','@outsider','private','secret')");
        $this->pdo->exec('INSERT INTO trip_trips VALUES (10),(20)');
        $this->pdo->exec('INSERT INTO trip_trip_members VALUES (10,1),(10,2),(20,1)');
        $this->pdo->exec('INSERT INTO trip_trip_invites VALUES (10,3),(20,2)');
    }

    public function test_default_off_opt_in_and_revocation_apply_to_all_joined_trips(): void
    {
        self::assertNull(load_trip_member_payment_details($this->pdo, 10, 2, 1));
        $this->pdo->exec('UPDATE trip_users SET share_payment_details_with_trips=1 WHERE id=2');
        $details = load_trip_member_payment_details($this->pdo, 10, 2, 1);
        self::assertSame('@member', $details['revolut_handle']);
        self::assertSame(['bank_account_holder','bank_iban','bank_bic','revolut_handle','revolut_me_link','paypal_me_link','wise_pay_link'], array_keys($details));
        self::assertNull(load_trip_member_payment_details($this->pdo, 20, 2, 1), 'Invitation alone cannot share details');
        $this->pdo->exec('INSERT INTO trip_trip_members VALUES (20,2)');
        self::assertNotNull(load_trip_member_payment_details($this->pdo, 20, 2, 1));
        $this->pdo->exec('UPDATE trip_users SET share_payment_details_with_trips=0 WHERE id=2');
        self::assertNull(load_trip_member_payment_details($this->pdo, 10, 2, 1));
        self::assertNull(load_trip_member_payment_details($this->pdo, 20, 2, 1));
    }

    public function test_pending_outsider_removed_and_inactive_members_cannot_read(): void
    {
        $this->pdo->exec('UPDATE trip_users SET share_payment_details_with_trips=1');
        foreach ([0,3,99] as $viewer) self::assertNull(load_trip_member_payment_details($this->pdo, 10, 2, $viewer));
        foreach ([0,3,99] as $target) self::assertNull(load_trip_member_payment_details($this->pdo, 10, $target, 1));
        self::assertNull(load_trip_member_payment_details($this->pdo, 99, 2, 1));
        foreach ([1,2] as $id) {
            foreach (['deactivated','deleted'] as $status) {
                $this->pdo->exec("UPDATE trip_users SET account_status='$status' WHERE id=$id");
                self::assertNull(load_trip_member_payment_details($this->pdo, 10, 2, 1));
                $this->pdo->exec("UPDATE trip_users SET account_status='active' WHERE id=$id");
            }
            $this->pdo->exec("DELETE FROM trip_trip_members WHERE trip_id=10 AND user_id=$id");
            self::assertNull(load_trip_member_payment_details($this->pdo, 10, 2, 1));
            $this->pdo->exec("INSERT INTO trip_trip_members VALUES (10,$id)");
        }
    }

    public function test_profile_handler_updates_only_the_signed_in_users_consent(): void
    {
        foreach (['available', 'missing'] as $schema) {
            $process = proc_open([PHP_BINARY, __DIR__.'/../Fixtures/profile_payment_sharing.php', $schema],
                [0=>['pipe','r'],1=>['pipe','w'],2=>['pipe','w']], $pipes);
            self::assertIsResource($process);
            fclose($pipes[0]);
            $output=stream_get_contents($pipes[1]); $errors=stream_get_contents($pipes[2]);
            fclose($pipes[1]); fclose($pipes[2]);
            self::assertSame(0,proc_close($process),$errors);
            self::assertSame('', $errors);
            $cases=json_decode($output,true,512,JSON_THROW_ON_ERROR);
            self::assertSame($schema === 'available' ? 200 : 409, $cases['enable']['status']);
            self::assertSame($schema === 'available' ? 1 : 0, $cases['enable']['owner']['share_payment_details_with_trips']);
            self::assertSame(0, $cases['enable']['other']['share_payment_details_with_trips']);
            self::assertSame(0, $cases['disable']['owner']['share_payment_details_with_trips']);
            self::assertSame(400, $cases['invalid']['status']);
            self::assertSame(0, $cases['invalid']['owner']['share_payment_details_with_trips']);
        }
    }

    public function test_consent_requires_explicit_boolean(): void
    {
        self::assertSame(1, profile_payment_sharing_value(true));
        self::assertSame(0, profile_payment_sharing_value(false));
        foreach ([null, '', 'true', 'false', '1', 1, 0, []] as $invalid) {
            try {
                profile_payment_sharing_value($invalid);
                self::fail('Invalid consent accepted');
            } catch (ApiResponseException $error) {
                self::assertSame(400, $error->statusCode);
            }
        }
    }
}
