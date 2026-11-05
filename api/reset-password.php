<?php
declare(strict_types=1);

require_once __DIR__ . '/web_security_headers.php';
require_once __DIR__ . '/lib/web/splyto_web_page.php';
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
  <?= splyto_web_page_styles() ?>
</head>
<body>
<main class="card">
  <?= splyto_web_page_header() ?>
  <div class="content">

  <?php
  $token = trim((string) ($_GET['token'] ?? ''));
  if ($token === ''):
  ?>
    <h1>Invalid link</h1>
    <p>This password reset link is invalid or has expired. Please request a new one from the app.</p>
  <?php else: ?>
    <h1 id="title">Reset password</h1>
    <p id="intro">Enter your new password below.</p>

    <form id="form">
      <input type="hidden" id="token" value="<?= htmlspecialchars($token, ENT_QUOTES) ?>">
      <div class="field">
        <label for="pw">New password</label>
        <input type="password" id="pw" autocomplete="new-password" aria-describedby="pw-help">
        <div class="help" id="pw-help">Min 8 chars, uppercase, number, symbol</div>
      </div>
      <div class="field">
        <label for="pw2">Confirm password</label>
        <input type="password" id="pw2" autocomplete="new-password">
      </div>
      <button class="btn" type="submit" id="btn">Set new password</button>
    </form>
    <div class="msg" id="msg" role="status" aria-live="polite"></div>

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
            msg.textContent = 'You can now log in with your new password.';
            document.getElementById('title').textContent = 'Password updated';
            document.getElementById('intro').hidden = true;
            document.getElementById('form').hidden = true;
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
</main>
</body>
</html>
