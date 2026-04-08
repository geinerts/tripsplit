<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Delete Account · Splyto</title>
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
      width: 100%; max-width: 440px;
      box-shadow: 0 4px 24px rgba(0,0,0,0.08);
      border: 1px solid #fee2e2;
    }
    .logo {
      font-size: 24px; font-weight: 800; color: #7f1d1d;
      margin-bottom: 28px; text-align: center; letter-spacing: -0.5px;
    }
    h1 { font-size: 20px; color: #111827; margin-bottom: 8px; }
    p  { font-size: 14px; color: #6b7280; margin-bottom: 16px; line-height: 1.5; }
    .danger-note {
      padding: 10px 12px;
      border-radius: 10px;
      background: #fff1f2;
      color: #9f1239;
      font-size: 13px;
      margin-bottom: 16px;
      border: 1px solid #fecdd3;
    }
    label { display: block; font-size: 13px; font-weight: 700; color: #374151; margin-bottom: 6px; }
    input[type=text] {
      width: 100%; padding: 12px 14px; border: 1.5px solid #e5e7eb;
      border-radius: 10px; font-size: 15px; outline: none;
      transition: border-color .2s;
      margin-bottom: 12px;
    }
    input[type=text]:focus { border-color: #ef4444; }
    button {
      width: 100%; padding: 14px;
      background: #dc2626;
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
    <p>This account deletion link is invalid or expired. Request a new one from the app profile page.</p>
  <?php else: ?>
    <h1>Delete account permanently</h1>
    <p>This action removes account access permanently and anonymizes your profile data. It cannot be undone.</p>
    <div class="danger-note">Type <strong>DELETE</strong> below to confirm.</div>

    <label for="confirm">Confirmation</label>
    <input type="text" id="confirm" placeholder="Type DELETE">
    <button id="btn" disabled>Delete account</button>
    <div class="msg" id="msg"></div>

    <script>
      const token = <?= json_encode($token, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE) ?>;
      const input = document.getElementById('confirm');
      const btn = document.getElementById('btn');
      const msg = document.getElementById('msg');

      input.addEventListener('input', () => {
        btn.disabled = input.value.trim().toUpperCase() !== 'DELETE';
      });

      btn.addEventListener('click', async () => {
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
          if (data.ok) {
            msg.className = 'msg success';
            msg.textContent = 'Account deleted successfully.';
            btn.style.display = 'none';
            input.style.display = 'none';
            return;
          }
          msg.className = 'msg error';
          msg.textContent = data.error || 'Could not delete account.';
          btn.disabled = input.value.trim().toUpperCase() !== 'DELETE';
          btn.textContent = 'Delete account';
        } catch (_) {
          msg.className = 'msg error';
          msg.textContent = 'Network error. Please try again.';
          btn.disabled = input.value.trim().toUpperCase() !== 'DELETE';
          btn.textContent = 'Delete account';
        }
      });
    </script>
  <?php endif; ?>
</div>
</body>
</html>
