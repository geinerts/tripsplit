<?php
declare(strict_types=1);

require_once __DIR__ . '/web_security_headers.php';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="referrer" content="no-referrer">
  <title>Reset Password · Splyto</title>
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
    }
    .logo {
      margin-bottom: 28px;
      text-align: center;
    }
    .logo img {
      display: block;
      margin: 0 auto;
      width: 188px;
      max-width: 100%;
      height: auto;
    }
    h1 { font-size: 20px; color: #111827; margin-bottom: 8px; }
    p  { font-size: 14px; color: #6b7280; margin-bottom: 24px; line-height: 1.5; }
    label { display: block; font-size: 13px; font-weight: 600; color: #374151; margin-bottom: 6px; }
    input[type=password] {
      width: 100%; padding: 12px 14px; border: 1.5px solid #e5e7eb;
      border-radius: 10px; font-size: 15px; outline: none;
      transition: border-color .2s;
    }
    input[type=password]:focus { border-color: #57B487; }
    .field { margin-bottom: 16px; }
    button {
      width: 100%; padding: 14px;
      background: linear-gradient(135deg, #57B487, #2D7A5E);
      border: none; border-radius: 12px;
      font-size: 15px; font-weight: 600; color: #fff;
      cursor: pointer; margin-top: 8px;
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
  <div class="logo"><img src="/mobile/assets/branding/logo_full.png" alt="Splyto"></div>

  <?php
  $token = trim((string) ($_GET['token'] ?? ''));
  if ($token === ''):
  ?>
    <h1>Invalid link</h1>
    <p>This password reset link is invalid or has expired. Please request a new one from the app.</p>
  <?php else: ?>
    <h1>Reset password</h1>
    <p>Enter your new password below.</p>

    <form id="form">
      <input type="hidden" id="token" value="<?= htmlspecialchars($token, ENT_QUOTES) ?>">
      <div class="field">
        <label for="pw">New password</label>
        <input type="password" id="pw" placeholder="Min 8 chars, uppercase, number, symbol" autocomplete="new-password">
      </div>
      <div class="field">
        <label for="pw2">Confirm password</label>
        <input type="password" id="pw2" placeholder="Repeat password" autocomplete="new-password">
      </div>
      <button type="submit" id="btn">Set new password</button>
    </form>
    <div class="msg" id="msg"></div>

    <script>
      document.getElementById('form').addEventListener('submit', async function(e) {
        e.preventDefault();
        const pw   = document.getElementById('pw').value;
        const pw2  = document.getElementById('pw2').value;
        const btn  = document.getElementById('btn');
        const msg  = document.getElementById('msg');
        msg.className = 'msg'; msg.textContent = '';

        if (pw !== pw2) {
          msg.className = 'msg error'; msg.textContent = 'Passwords do not match.'; return;
        }

        btn.disabled = true; btn.textContent = 'Saving…';

        try {
          const res  = await fetch('/api/api.php?action=reset_password', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ token: document.getElementById('token').value, password: pw })
          });
          const data = await res.json();
          if (data.ok) {
            msg.className = 'msg success';
            msg.textContent = '✓ Password updated! You can now log in with your new password.';
            document.getElementById('form').style.display = 'none';
          } else {
            msg.className = 'msg error'; msg.textContent = data.error || 'Something went wrong.';
            btn.disabled = false; btn.textContent = 'Set new password';
          }
        } catch {
          msg.className = 'msg error'; msg.textContent = 'Network error. Please try again.';
          btn.disabled = false; btn.textContent = 'Set new password';
        }
      });
    </script>
  <?php endif; ?>
</div>
</body>
</html>
