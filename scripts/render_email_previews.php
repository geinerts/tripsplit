<?php
declare(strict_types=1);
// Local-only renderer: no configuration, database, network or email sending.
if (PHP_SAPI !== 'cli') { http_response_code(404); exit; }
define('PUBLIC_BASE_URL', 'https://splyto.eu');
define('APP_BASE_URL', 'https://splyto.eu');
require __DIR__ . '/../api/lib/helpers/helper_email.php';
$directory = __DIR__ . '/../output/design/account-emails';
if (!is_dir($directory)) { mkdir($directory, 0755, true); }
copy(__DIR__ . '/../email-logo.png', $directory . '/logo.png');
copy(__DIR__ . '/../email-logo-dark.png', $directory . '/logo-dark.png');
$previews = [
    'password' => build_password_reset_email('https://splyto.eu/reset-password?token=preview-only', 'Matiss'),
    'deletion' => build_account_delete_email('https://splyto.eu/delete-account?token=preview-only', 'Matiss'),
    'verification' => build_email_verification_email('https://splyto.eu/verify-email?token=preview-only', 'Matiss', 7),
];
foreach ($previews as $name => $html) {
    $html = str_replace(['https://splyto.eu/email-logo-dark.png', 'https://splyto.eu/email-logo.png'], ['logo-dark.png', 'logo.png'], $html);
    file_put_contents($directory . '/' . $name . '.html', $html);
}
file_put_contents($directory . '/index.html', <<<'HTML'
<!doctype html><html lang="lv"><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>Splyto · E-pastu dizains</title>
<style>*{box-sizing:border-box}body{margin:0;background:#e9efed;color:#193149;font-family:Arial,sans-serif;padding:42px 36px}header{max-width:1400px;margin:0 auto 32px}small{font-size:11px;color:#008576;font-weight:700;letter-spacing:2px}h1{font-size:34px;letter-spacing:-1px;margin:12px 0}p{color:#59696f;font-size:15px}.grid{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:20px;max-width:1400px;margin:auto}h2{font-size:16px;margin:0 0 16px}iframe{width:100%;height:980px;border:1px solid #dae4df;border-radius:18px;background:#f2f6f5}nav a{display:inline-block;font-size:13px;margin:10px 20px 0 0;color:#007a6d}@media(max-width:1000px){.grid{grid-template-columns:1fr}iframe{height:1020px}body{padding:24px 12px}}</style>
<header><small>SPLYTO / ACCOUNT EMAILS</small><h1>Mazāk trokšņa. Skaidra nākamā darbība.</h1><p>Vienots noformējums ar Splyto logo un krāsām. Īstas HTML veidnes — bez nosūtītiem e-pastiem.</p></header>
<main class="grid"><section><h2>01 / E-pasta apstiprināšana</h2><iframe src="verification.html" title="E-pasta apstiprināšanas e-pasts"></iframe></section><section><h2>02 / Paroles iestatīšana</h2><iframe src="password.html" title="Paroles iestatīšanas e-pasts"></iframe></section><section><h2>03 / Konta dzēšana</h2><iframe src="deletion.html" title="Dzēšanas e-pasts"></iframe></section></main></html>
HTML);
echo "Email previews: output/design/account-emails/index.html\n";
