<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';
require_once __DIR__ . '/api/lib/web/splyto_web_page.php';

$rawInvite = share_param(['invite']);
$inviteCode = share_normalize_invite_code($rawInvite);
$tripMeta = share_trip_meta($inviteCode);
$tripName = trim((string) ($tripMeta['trip_name'] ?? 'Splyto trip'));
$hasInvite = is_string($inviteCode) && $inviteCode !== '';
$pageInvite = trim($rawInvite) !== '' ? trim($rawInvite) : ($inviteCode ?? '');
$pageUrl = share_absolute_url('/invite', $pageInvite !== '' ? ['invite' => $pageInvite] : []);
$imageUrl = share_absolute_url('/share-image.php', [
    'type' => 'trip',
    'format' => 'jpeg',
    'invite' => $pageInvite,
    'v' => $hasInvite ? 'trip5-' . substr(hash('sha256', $inviteCode), 0, 12) : 'trip5-missing',
]);
$inviteForApp = $pageInvite !== '' ? $pageInvite : ($inviteCode ?? '');
$isValid = (bool) ($tripMeta['valid'] ?? false);
$title = $isValid ? 'Join ' . $tripName . ' on Splyto' : 'Splyto trip invite';
$description = 'Open Splyto to join this trip and split expenses together.';

// Invite validity can change immediately after this response.
share_send_html_headers(0);
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title><?= share_html($title) ?></title>
  <meta name="description" content="<?= share_html($description) ?>" />
  <?= share_open_graph_tags($title, $description, $pageUrl, $imageUrl, 'image/jpeg') ?>
  <?= splyto_web_page_styles() ?>
</head>
<body>
  <main class="card">
    <?= splyto_web_page_header() ?>
    <div class="content">
      <h1>Opening Splyto...</h1>
      <p>If app does not open automatically, tap the button below.</p>
      <div class="status" id="inviteStatus">
        <?= $isValid ? share_html($tripName) : ($hasInvite ? 'Invite unavailable or expired' : 'Invite link missing') ?>
      </div>
      <button id="openAppBtn" type="button" class="btn"<?= $hasInvite ? '' : ' disabled' ?>>Open in app</button>
      <a id="openPlayBtn" class="btn btn-secondary" href="https://play.google.com/store/apps/details?id=com.tripsplit.app.tripsplit">
        Open on Google Play
      </a>
      <div class="hint">Trip invite links work when you are logged in.</div>
    </div>
  </main>
  <script>
    (function () {
      var invite = <?= json_encode($hasInvite ? $inviteForApp : '', JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
      var openBtn = document.getElementById('openAppBtn');
      var ua = navigator.userAgent.toLowerCase();
      var isAndroid = ua.indexOf('android') >= 0;

      var openTimer;
      var fallbackTimer;
      function cancelOpen() {
        window.clearTimeout(openTimer);
        window.clearTimeout(fallbackTimer);
      }
      document.addEventListener('visibilitychange', function () {
        if (document.hidden) cancelOpen();
      });
      window.addEventListener('pagehide', cancelOpen);

      function openApp() {
        cancelOpen();
        if (!invite || document.hidden) return;
        var encoded = encodeURIComponent(invite);
        if (isAndroid) {
          window.location.href =
            'intent://join?invite=' + encoded +
            '#Intent;scheme=splyto;package=com.tripsplit.app.tripsplit;end';
          fallbackTimer = window.setTimeout(function () {
            if (!document.hidden) window.location.href = 'splyto://join?invite=' + encoded;
          }, 650);
          return;
        }
        window.location.href = 'splyto://join?invite=' + encoded;
        fallbackTimer = window.setTimeout(function () {
          if (!document.hidden) window.location.href = 'tripsplit://join?invite=' + encoded;
        }, 650);
      }

      openBtn.addEventListener('click', openApp);
      if (invite) {
        openTimer = window.setTimeout(openApp, 220);
      }
    })();
  </script>
</body>
</html>
