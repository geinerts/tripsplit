<?php
declare(strict_types=1);
use PHPUnit\Framework\TestCase;
require_once __DIR__ . '/../../lib/actions/trip_invitations.php';

final class ReceivedTripInvitationsTest extends TestCase
{
    public function test_only_current_recipients_actionable_invitations_are_returned(): void
    {
        $pdo = class_exists('Pdo\\Sqlite')
            ? new Pdo\Sqlite('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION])
            : new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION]);
        $method = method_exists($pdo, 'createFunction') ? 'createFunction' : 'sqliteCreateFunction';
        $pdo->$method('UTC_TIMESTAMP', static fn() => '2026-10-26 12:00:00');
        $pdo->exec('CREATE TABLE trip_users(id INTEGER PRIMARY KEY, nickname TEXT)');
        $pdo->exec('CREATE TABLE trip_trips(id INTEGER PRIMARY KEY, name TEXT, status TEXT)');
        $pdo->exec('CREATE TABLE trip_trip_members(trip_id INTEGER,user_id INTEGER)');
        $pdo->exec('CREATE TABLE trip_trip_invites(id INTEGER PRIMARY KEY,trip_id INTEGER,created_by INTEGER,target_user_id INTEGER,invite_code TEXT,expires_at TEXT,revoked_at TEXT)');
        $pdo->exec("INSERT INTO trip_users VALUES(1,'Sender'),(2,'Recipient'),(3,'Other')");
        $pdo->exec("INSERT INTO trip_trips VALUES(10,'Summer','active'),(20,'Closed','archived')");
        $stmt=$pdo->prepare('INSERT INTO trip_trip_invites VALUES(?,?,?,?,?,?,?)');
        $stmt->execute([1,10,1,2,'mine000001','2026-10-27 12:00:00',null]);
        $stmt->execute([2,10,1,3,'other00002','2026-10-27 12:00:00',null]);
        $stmt->execute([3,10,1,null,'public0003','2026-10-27 12:00:00',null]);
        $stmt->execute([4,10,1,2,'expired004','2026-10-26 12:00:00',null]);
        $stmt->execute([5,10,1,2,'revoked005','2026-10-27 12:00:00','2026-10-26 11:00:00']);
        $stmt->execute([6,20,1,2,'closed0006','2026-10-27 12:00:00',null]);
        $list=load_received_trip_invitations($pdo,2);
        self::assertCount(1,$list);
        self::assertSame('mine000001',$list[0]['invite_token']);
        self::assertSame('Summer',$list[0]['trip_name']);
        self::assertSame('Sender',$list[0]['inviter_name']);
        self::assertSame(['id','trip_id','invite_token','trip_name','inviter_name','expires_at'],array_keys($list[0]));
        self::assertSame([],load_received_trip_invitations($pdo,1));
        self::assertSame([],load_received_trip_invitations($pdo,0));
        self::assertSame('other00002',load_received_trip_invitations($pdo,3)[0]['invite_token']);
        $pdo->exec('INSERT INTO trip_trip_members VALUES(10,2)');
        self::assertSame([],load_received_trip_invitations($pdo,2),'Acceptance removes the badge independently of notification read state');
        $pdo->exec('DELETE FROM trip_trip_members WHERE user_id=2');
        $pdo->exec("UPDATE trip_trip_invites SET revoked_at='2026-10-26 12:00:00' WHERE id=1");
        self::assertSame([],load_received_trip_invitations($pdo,2),'Decline/revocation removes the invitation');
    }
}
