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
  <title>Verify Email · Splyto</title>
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
  $token = strtolower(trim((string) ($_GET['token'] ?? '')));
  if ($token === '' || !preg_match('/^[a-f0-9]{64}$/', $token)):
  ?>
    <h1>Invalid link</h1>
    <p>This verification link is invalid or expired. Request a new one from the app.</p>
  <?php else: ?>
    <h1 id="title">Verify email</h1>
    <p id="intro">Click below to verify your email and activate your account.</p>

    <button class="btn" id="btn">Verify email</button>
    <div class="msg" id="msg" role="status" aria-live="polite"></div>

    <script>
      const token = <?= json_encode($token, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
      const btn = document.getElementById('btn');
      const msg = document.getElementById('msg');

      btn.addEventListener('click', async () => {
        btn.disabled = true;
        btn.textContent = 'Verifying...';
        msg.className = 'msg';
        msg.textContent = '';

        try {
          const res = await fetch('/api/api.php?action=confirm_email_verification', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ token })
          });
          const data = await res.json();
          if (data.ok) {
            msg.className = 'msg success';
            msg.textContent = 'You can now log in to Splyto.';
            document.getElementById('title').textContent = 'Email verified';
            document.getElementById('intro').hidden = true;
            btn.hidden = true;
            return;
          }
          msg.className = 'msg error';
          msg.textContent = data.error || 'Could not verify email.';
          btn.disabled = false;
          btn.textContent = 'Verify email';
        } catch (_) {
          msg.className = 'msg error';
          msg.textContent = 'Network error. Please try again.';
          btn.disabled = false;
          btn.textContent = 'Verify email';
        }
      });
    </script>
  <?php endif; ?>
  </div>
</main>
</body>
</html>
