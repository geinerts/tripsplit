<?php
declare(strict_types=1);

header('Cache-Control: no-store, no-cache, must-revalidate, max-age=0');
header('Pragma: no-cache');
header('Referrer-Policy: no-referrer');
header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="referrer" content="no-referrer">
  <title>Cancel Email Change · Splyto</title>
  <script>
    (function () {
      if (!window.history || !window.history.replaceState) return;
      var cleanUrl = window.location.pathname + window.location.hash;
      window.history.replaceState(null, document.title, cleanUrl);
    })();
  </script>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      min-height: 100vh;
      background: #f4f4f5;
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
      display: flex; align-items: center; justify-content: center;
      padding: 24px;
    }
    .card {
      background: #fff;
      border-radius: 20px;
      padding: 40px 36px;
      width: 100%; max-width: 420px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
      border: 1px solid #fef3c7;
    }
    .logo {
      font-size: 24px; font-weight: 800; color: #78350f;
      margin-bottom: 28px; text-align: center; letter-spacing: -0.5px;
    }
    h1 { font-size: 20px; color: #111827; margin-bottom: 8px; }
    p  { font-size: 14px; color: #6b7280; margin-bottom: 20px; line-height: 1.5; }
    button {
      width: 100%; padding: 14px;
      background: #b45309;
      border: none; border-radius: 12px;
      font-size: 15px; font-weight: 600; color: #fff;
      cursor: pointer; margin-top: 4px;
      transition: opacity .2s;
    }
    button:hover { opacity: .9; }
    button:disabled { opacity: .6; cursor: not-allowed; }
    .msg { margin-top: 16px; padding: 12px 16px; border-radius: 10px; font-size: 14px; text-align: center; display: none; }
    .msg.success { background: #ecfdf5; color: #065f46; display: block; }
    .msg.error   { background: #fef2f2; color: #991b1b; display: block; }
  </style>
</head>
<body>
<div class="card">
  <div class="logo">SPLYTO</div>

  <?php
  $token = strtolower(trim((string) ($_GET['token'] ?? '')));
  if ($token === '' || !preg_match('/^[a-f0-9]{64}$/', $token)):
  ?>
    <h1>Invalid link</h1>
    <p>This cancellation link is invalid or expired.</p>
  <?php else: ?>
    <h1>Cancel email change</h1>
    <p>Click below if you did not request to change your account email.</p>

    <button id="btn">Cancel email change</button>
    <div class="msg" id="msg"></div>

    <script>
      const token = <?= json_encode($token, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
      const btn = document.getElementById('btn');
      const msg = document.getElementById('msg');

      btn.addEventListener('click', async () => {
        btn.disabled = true;
        btn.textContent = 'Cancelling...';
        msg.className = 'msg';
        msg.textContent = '';

        try {
          const res = await fetch('/api/api.php?action=cancel_email_change', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ token })
          });
          const data = await res.json();
          if (data.ok) {
            msg.className = 'msg success';
            msg.textContent = 'Email change request has been cancelled.';
            btn.style.display = 'none';
            return;
          }
          msg.className = 'msg error';
          msg.textContent = data.error || 'Could not cancel email change.';
          btn.disabled = false;
          btn.textContent = 'Cancel email change';
        } catch (_) {
          msg.className = 'msg error';
          msg.textContent = 'Network error. Please try again.';
          btn.disabled = false;
          btn.textContent = 'Cancel email change';
        }
      });
    </script>
  <?php endif; ?>
</div>
</body>
</html>
