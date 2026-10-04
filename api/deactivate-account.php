<?php
declare(strict_types=1);
require_once __DIR__ . '/web_security_headers.php';
header('Cache-Control: no-store');
$token = (string) ($_GET['token'] ?? '');
$valid = (bool) preg_match('/^[a-f0-9]{64}$/D', $token);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="referrer" content="no-referrer"><title>Deactivate account | Splyto</title>
  <script>history.replaceState(null, '', location.pathname);</script>
  <style>
    * { box-sizing:border-box; }
    body { margin:0; padding:32px 20px; background:#fff; color:#17251d; font:16px/1.5 system-ui,sans-serif; }
    main { max-width:480px; margin:40px auto; }
    img { width:188px; max-width:100%; height:auto; }
    h1 { font-size:24px; line-height:1.2; }
    button { padding:12px 20px; border:0; border-radius:8px; font:inherit; color:white; background:#a12d32; cursor:pointer; }
    button:disabled { opacity:.6; cursor:default; }
    #result { overflow-wrap:anywhere; }
  </style>
</head>
<body><main>
  <img src="/mobile/assets/branding/logo_full.png" alt="Splyto">
  <?php if (!$valid): ?>
  <h1>Invalid link</h1><p>Request a new deactivation email from your Splyto profile.</p>
  <?php else: ?>
  <h1>Deactivate your account?</h1>
  <p>Your trips and expenses will remain. To restore access later, request a reactivation email from the sign-in screen.</p>
  <form id="confirmation">
    <input type="hidden" id="token" value="<?= htmlspecialchars($token, ENT_QUOTES, 'UTF-8') ?>">
    <button type="submit" id="submit">Confirm deactivation</button>
  </form>
  <p id="result" role="status" aria-live="polite"></p>
  <script>
    document.getElementById('confirmation').addEventListener('submit', async (event) => {
      event.preventDefault();
      const button = document.getElementById('submit');
      const result = document.getElementById('result');
      if (button.disabled) return;
      button.disabled = true;
      result.textContent = '';
      try {
        const response = await fetch('/api/api.php?action=confirm_deactivation', {
          method:'POST', headers:{'Content-Type':'application/json'},
          body:JSON.stringify({token:document.getElementById('token').value})
        });
        const data = await response.json();
        if (!response.ok || !data.ok) throw new Error(data.error || 'Could not deactivate your account.');
        document.getElementById('confirmation').hidden = true;
        document.getElementById('token').value = '';
        result.textContent = 'Your account is deactivated. Your trips and expenses have not been deleted.';
      } catch (error) {
        result.textContent = error.message || 'Connection failed. Please try again.';
        button.disabled = false;
      }
    });
  </script>
  <?php endif; ?>
</main></body></html>
