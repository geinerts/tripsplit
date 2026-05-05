<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';

$rawInvite = share_param(['invite']);
$inviteCode = share_normalize_invite_code($rawInvite);
$tripMeta = share_trip_meta($inviteCode);
$tripName = trim((string) ($tripMeta['trip_name'] ?? 'Splyto trip'));
$hasInvite = is_string($inviteCode) && $inviteCode !== '';
$pageInvite = trim($rawInvite) !== '' ? trim($rawInvite) : ($inviteCode ?? '');
$pageUrl = share_absolute_url('/invite', $pageInvite !== '' ? ['invite' => $pageInvite] : []);
$imageUrl = share_absolute_url('/share-image.php', [
    'type' => 'trip',
    'invite' => $pageInvite,
    'v' => $hasInvite ? substr(hash('sha256', $inviteCode), 0, 12) : 'missing',
]);
$inviteForApp = $pageInvite !== '' ? $pageInvite : ($inviteCode ?? '');
$isValid = (bool) ($tripMeta['valid'] ?? false);
$title = $isValid ? 'Join ' . $tripName . ' on Splyto' : 'Splyto trip invite';
$description = 'Open Splyto to join this trip and split expenses together.';

share_send_html_headers($isValid ? 300 : 60);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title><?= share_html($title) ?></title>
  <meta name="description" content="<?= share_html($description) ?>" />
  <?= share_open_graph_tags($title, $description, $pageUrl, $imageUrl) ?>
  <style>
    :root {
      --bg: #040607;
      --card: #0c1611;
      --text: #f3f8f5;
      --muted: #98ab9f;
      --accent: #57b487;
      --accent-2: #2eaf6e;
      --stroke: rgba(87, 180, 135, 0.24);
    }

    * { box-sizing: border-box; }
    body {
      margin: 0;
      min-height: 100vh;
      display: grid;
      place-items: center;
      padding: 22px;
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background:
        radial-gradient(760px 360px at 78% 0%, rgba(87, 180, 135, 0.24), transparent 58%),
        linear-gradient(180deg, var(--bg), #07110d 56%, var(--card));
      color: var(--text);
    }

    .card {
      width: min(100%, 460px);
      border: 1px solid var(--stroke);
      border-radius: 24px;
      background: rgba(12, 22, 17, 0.84);
      padding: 24px 20px;
      text-align: center;
      box-shadow: 0 24px 70px rgba(0, 0, 0, 0.42);
    }

    h1 {
      margin: 0 0 10px;
      font-size: 25px;
      line-height: 1.16;
    }

    p {
      margin: 0;
      color: var(--muted);
      line-height: 1.5;
      font-size: 15px;
    }

    .trip {
      margin: 16px 0 18px;
      padding: 11px 12px;
      border-radius: 14px;
      border: 1px solid var(--stroke);
      background: rgba(255, 255, 255, 0.04);
      font-size: 14px;
      color: #d9e8df;
    }

    button,
    a.action {
      display: inline-flex;
      justify-content: center;
      align-items: center;
      width: 100%;
      height: 46px;
      border-radius: 15px;
      border: 0;
      font-size: 15px;
      font-weight: 800;
      cursor: pointer;
      text-decoration: none;
    }

    button.primary {
      color: #07110d;
      background: linear-gradient(180deg, #b9f0d5, var(--accent));
    }

    button:disabled {
      cursor: not-allowed;
      opacity: 0.48;
    }

    a.action.secondary {
      margin-top: 10px;
      color: var(--text);
      border: 1px solid var(--stroke);
      background: rgba(255, 255, 255, 0.02);
    }

    .hint {
      margin-top: 13px;
      font-size: 12px;
      color: #83988d;
    }
  </style>
</head>
<body>
  <main class="card">
    <h1>Opening Splyto...</h1>
    <p>If app does not open automatically, tap the button below.</p>
    <div class="trip" id="inviteStatus">
      <?= $hasInvite ? share_html($tripName) : 'Invite link missing' ?>
    </div>
    <button id="openAppBtn" type="button" class="primary"<?= $hasInvite ? '' : ' disabled' ?>>Open in app</button>
    <a id="openPlayBtn" class="action secondary" href="https://play.google.com/store/apps/details?id=com.tripsplit.app.tripsplit">
      Open on Google Play
    </a>
    <div class="hint">Trip invite links work when you are logged in.</div>
  </main>
  <script>
    (function () {
      var invite = <?= json_encode($inviteForApp, JSON_UNESCAPED_SLASHES) ?>;
      var openBtn = document.getElementById('openAppBtn');
      var ua = navigator.userAgent.toLowerCase();
      var isAndroid = ua.indexOf('android') >= 0;

      function openApp() {
        if (!invite) return;
        var encoded = encodeURIComponent(invite);
        if (isAndroid) {
          window.location.href =
            'intent://join?invite=' + encoded +
            '#Intent;scheme=splyto;package=com.tripsplit.app.tripsplit;end';
          window.setTimeout(function () {
            window.location.href = 'splyto://join?invite=' + encoded;
          }, 650);
          return;
        }
        window.location.href = 'splyto://join?invite=' + encoded;
        window.setTimeout(function () {
          window.location.href = 'tripsplit://join?invite=' + encoded;
        }, 650);
      }

      openBtn.addEventListener('click', openApp);
      if (invite) {
        window.setTimeout(openApp, 220);
      }
    })();
  </script>
</body>
</html>
