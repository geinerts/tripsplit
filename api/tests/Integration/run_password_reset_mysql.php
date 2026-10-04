<?php
declare(strict_types=1);
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
require __DIR__ . '/../Fixtures/password_reset_harness.php';
$pdo = isolated_test_mysql();
$process = proc_open([PHP_BINARY, 'vendor/bin/phpunit', '--do-not-cache-result',
    '--filter', 'PasswordResetSecurityTest'], [STDIN, STDOUT, STDERR], $pipes);
if (!is_resource($process) || proc_close($process) !== 0) {
    throw new RuntimeException('MySQL password recovery regressions failed');
}
function check_reset_race(bool $condition, string $message): void
{
    if (!$condition) { throw new RuntimeException($message); }
}
for ($round = 1; $round <= 5; $round++) {
    foreach (['request', 'same_link', 'different_links'] as $mode) {
        reset_password_test_schema($pdo);
        seed_credential_user($pdo, 'social');
        if ($mode !== 'request') { seed_password_reset($pdo); seed_password_reset($pdo, 'b'); }
        $workers = [];
        try {
            for ($i = 0; $i < 4; $i++) {
                $p = proc_open([PHP_BINARY, __DIR__ . '/password_reset_worker.php', $mode, (string) $i],
                    [0 => ['pipe', 'r'], 1 => ['pipe', 'w'], 2 => ['pipe', 'w']], $pipes);
                check_reset_race(is_resource($p), 'Could not start worker');
                stream_set_timeout($pipes[1], 30);
                $workers[] = ['process' => $p, 'pipes' => $pipes];
            }
            foreach ($workers as $w) { check_reset_race(fgets($w['pipes'][1]) === "READY\n", 'Worker not ready'); }
            foreach ($workers as $w) { fwrite($w['pipes'][0], "GO\n"); fflush($w['pipes'][0]); }
            $results = [];
            foreach ($workers as &$w) {
                $line = fgets($w['pipes'][1]);
                check_reset_race(is_string($line), 'Worker has no response');
                $results[] = json_decode($line, true, 512, JSON_THROW_ON_ERROR);
                fclose($w['pipes'][0]); fclose($w['pipes'][1]);
                $error = stream_get_contents($w['pipes'][2]); fclose($w['pipes'][2]);
                $exit = proc_close($w['process']); $w = [];
                check_reset_race($exit === 0 && $error === '', 'Worker failure: ' . $error);
            }
            unset($w);
            foreach ($results as $r) { check_reset_race(!$r['transaction_open'], 'Leaked transaction'); }
            $winners = array_values(array_filter($results, fn($r) => $r['status'] === 200));
            if ($mode === 'request') {
                check_reset_race(count($winners) === 4 && array_sum(array_column($results, 'mail_count')) === 1,
                    'Concurrent requests did not send exactly one email');
                check_reset_race((int) $pdo->query('SELECT COUNT(*) FROM trip_password_resets')->fetchColumn() === 1,
                    'Concurrent requests created extra proofs');
            } else {
                check_reset_race(count($winners) === 1, 'Expected one reset winner');
                foreach ($results as $r) { check_reset_race(in_array($r['status'], [200, 400], true), 'Unexpected status'); }
                $user = fetch_me_row_by_id($pdo, 1);
                check_reset_race(password_verify('Race-password-456-' . $winners[0]['index'], $user['password_hash']),
                    'Password does not belong to winner');
                check_reset_race((int) $pdo->query('SELECT COUNT(*) FROM trip_password_resets WHERE used_at IS NULL')->fetchColumn() === 0,
                    'Old reset proof still active');
            }
            $active = (int) $pdo->query('SELECT COUNT(*) FROM trip_refresh_tokens WHERE user_id = 1 AND revoked_at IS NULL')->fetchColumn();
            check_reset_race($active === ($mode === 'request' ? 2 : 0), 'Wrong refresh revocation state');
            check_reset_race((int) $pdo->query('SELECT COUNT(*) FROM trip_refresh_tokens WHERE user_id = 2 AND revoked_at IS NULL')->fetchColumn() === 1,
                'Unrelated user affected');
            echo "PASS recovery race $round/$mode\n";
        } finally {
            foreach ($workers as $w) {
                if ($w === []) { continue; }
                proc_terminate($w['process']);
                foreach ($w['pipes'] as $pipe) { if (is_resource($pipe)) { fclose($pipe); } }
                proc_close($w['process']);
            }
        }
    }
}
echo "PASS: 15 recovery races / 60 synthetic requests. No real email.\n";
