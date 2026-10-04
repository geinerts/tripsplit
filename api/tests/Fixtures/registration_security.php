<?php
declare(strict_types=1);

// No production bootstrap or .env. Defaults to SQLite; MySQL requires the isolated runtime.
if (PHP_SAPI !== 'cli') {
    http_response_code(404);
    exit;
}

$scenario = $argv[1] ?? '';
$hasNames = ($argv[2] ?? 'names') === 'names';
$options = [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC];
if (getenv('SPLYTO_ISOLATED_MYSQL') === '1') {
    require __DIR__ . '/isolated_mysql.php';
    $pdo = isolated_test_mysql();
    reset_registration_mysql_schema($pdo, $hasNames);
} else {
    $pdo = class_exists('Pdo\\Sqlite')
        ? new Pdo\Sqlite('sqlite::memory:', null, null, $options)
        : new PDO('sqlite::memory:', null, null, $options);
    $pdo->exec('CREATE TABLE trip_users (
    id INTEGER PRIMARY KEY AUTOINCREMENT, nickname TEXT NOT NULL,
    ' . ($hasNames ? 'first_name TEXT, last_name TEXT,' : '') . '
    email TEXT UNIQUE, password_hash TEXT, credentials_required INTEGER NOT NULL DEFAULT 1,
    email_verified_at TEXT, account_status TEXT NOT NULL DEFAULT \'active\',
    device_token TEXT NOT NULL UNIQUE)');
}

require __DIR__ . '/registration_harness.php';

$victimToken = str_repeat('a', 64);
$freshToken = str_repeat('b', 64);
$pdo->prepare('INSERT INTO trip_users
    (nickname, email, password_hash, credentials_required, email_verified_at, device_token)
    VALUES (?, ?, ?, 0, ?, ?)')->execute([
        'Existing user', 'existing@example.invalid', password_hash('OriginalPassword9!', PASSWORD_BCRYPT),
        '2026-01-01 00:00:00', $victimToken,
    ]);
if ($scenario === 'existing_guest') {
    $pdo->exec('UPDATE trip_users SET email = NULL, password_hash = NULL,
        credentials_required = 1, email_verified_at = NULL');
} elseif ($scenario === 'existing_unverified') {
    $pdo->exec('UPDATE trip_users SET email_verified_at = NULL');
} elseif ($scenario === 'existing_inactive') {
    $pdo->exec("UPDATE trip_users SET account_status = 'deactivated'");
}
$before = fetch_me_row_by_id($pdo, 1);
$isNew = in_array($scenario, ['new_guest', 'new_credentials', 'duplicate_email',
    'invalid_proof', 'replay', 'database_failure'], true);
$_SERVER['HTTP_X_DEVICE_TOKEN'] = $isNew ? $freshToken : $victimToken;
$proof = runRegistrationHandler('register_proof_action')['payload']['register_proof'];
$requestBody = ['first_name' => 'New', 'last_name' => 'User', 'register_proof' => $proof];
if (in_array($scenario, ['new_credentials', 'existing_credentials', 'duplicate_email', 'existing_same_email'], true)) {
    $requestBody['email'] = in_array($scenario, ['duplicate_email', 'existing_same_email'], true)
        ? 'existing@example.invalid' : 'new@example.invalid';
    $requestBody['password'] = 'NewSyntheticPassword9!';
}
if ($scenario === 'invalid_proof') { $requestBody['register_proof'] = 'not-a-valid-proof'; }
if ($scenario === 'database_failure') { $pdo->exec('DROP TABLE trip_users'); }

try {
    $response = runRegistrationHandler('register_action');
    $firstResponse = $response;
    if ($scenario === 'replay') { $response = runRegistrationHandler('register_action'); }
    $after = fetch_me_row_by_id($pdo, 1);
    $created = fetch_me_row_by_id($pdo, 2);
    $result = [
        'response' => $response, 'first_response' => $firstResponse,
        'existing_unchanged' => $before === $after,
        'user_count' => (int) $pdo->query('SELECT COUNT(*) FROM trip_users')->fetchColumn(),
        'new_password_matches' => $created !== null && isset($requestBody['password'])
            && password_verify($requestBody['password'], (string) $created['password_hash']),
        'new_email_verified' => $created !== null && !empty($created['email_verified_at']),
    ];
} catch (PDOException $error) {
    $result = ['database_error_propagated' => true];
}
echo json_encode($result + ['auth_issued' => $authIssued, 'mail_users' => $verificationMail,
    'event_users' => $events, 'rate_scopes' => $rateCalls], JSON_THROW_ON_ERROR);
