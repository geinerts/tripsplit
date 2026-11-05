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
  <title>Delete Account · Splyto</title>
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
  $token = is_string($_GET['token'] ?? null) ? $_GET['token'] : '';
  if (!preg_match('/^[a-f0-9]{64}$/D', $token)):
  ?>
    <h1>Invalid link</h1>
    <p>This account deletion link is invalid or expired. Request a new one from the app profile page.</p>
  <?php else: ?>
    <h1 id="title">Delete account permanently</h1>
    <div id="request">
      <p>This action removes account access permanently and anonymizes your profile data. It cannot be undone.</p>
      <p>Shared trip and expense records are kept for other members. Your account remains active until you confirm below.</p>
      <div class="note">Type <strong>DELETE</strong> below to confirm.</div>
      <div class="field">
        <label for="confirm">Confirmation</label>
        <input type="text" id="confirm" placeholder="DELETE" autocomplete="off" autocapitalize="characters" autocorrect="off" spellcheck="false">
      </div>
    </div>
    <button class="btn btn-danger" id="btn" disabled>Delete account</button>
    <div class="msg" id="msg" role="status" aria-live="polite"></div>

    <script>
      let token = <?= json_encode($token, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
      let pending = false;
      const input = document.getElementById('confirm');
      const btn = document.getElementById('btn');
      const msg = document.getElementById('msg');

      input.addEventListener('input', () => {
        btn.disabled = pending || input.value.trim().toUpperCase() !== 'DELETE';
      });

      btn.addEventListener('click', async () => {
        if (pending || !token || input.value.trim().toUpperCase() !== 'DELETE') return;
        pending = true;
        btn.disabled = true;
        btn.textContent = 'Deleting...';
        msg.className = 'msg';
        msg.textContent = '';

        try {
          const res = await fetch('/api/api.php?action=confirm_account_deletion', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ token })
          });
          const data = await res.json();
          if (res.ok && data.ok) {
            token = '';
            msg.className = 'msg success';
            msg.textContent = 'Your account has been deleted. You can close this page.';
            document.getElementById('title').textContent = 'Account deleted';
            document.getElementById('request').hidden = true;
            btn.hidden = true;
            return;
          }
          msg.className = 'msg error';
          msg.textContent = data.error || 'Could not delete account.';
          pending = false;
          btn.disabled = input.value.trim().toUpperCase() !== 'DELETE';
          btn.textContent = 'Delete account';
        } catch (_) {
          msg.className = 'msg error';
          msg.textContent = 'Network error. Please try again.';
          pending = false;
          btn.disabled = input.value.trim().toUpperCase() !== 'DELETE';
          btn.textContent = 'Delete account';
        }
      });
    </script>
  <?php endif; ?>
  </div>
</main>
</body>
</html>
