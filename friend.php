<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';
require_once __DIR__ . '/api/lib/web/splyto_web_page.php';

$rawCode = share_param(['code', 'friend_token', 'friend_code']);
$token = share_normalize_friend_token($rawCode);
$hasToken = is_string($token) && $token !== '';
$friendMeta = share_friend_meta($token);
$pageUrl = share_absolute_url('/friend', $hasToken ? ['code' => $token] : []);
$imageUrl = share_absolute_url('/share-image.php', [
    'type' => 'friend',
    'code' => $hasToken ? $token : '',
    'v' => $hasToken ? 'myqr5-' . substr(hash('sha256', $token), 0, 12) : 'myqr5-missing',
]);
$friendDisplayName = trim((string) ($friendMeta['display_name'] ?? ''));
$isValid = (bool) ($friendMeta['valid'] ?? false);
$title = $isValid && $friendDisplayName !== ''
    ? 'Add ' . $friendDisplayName . ' on Splyto'
    : 'Add me on Splyto';
$description = '';
$appQuery = $hasToken ? 'code=' . rawurlencode($token) : '';

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
  <?= splyto_web_page_styles() ?>
</head>
<body>
  <main class="card">
    <?= splyto_web_page_header() ?>
    <div class="content">
      <h1>Opening Splyto...</h1>
      <p>Accept or send a friend request in the app.</p>
      <div class="status" id="friendStatus">
        <?= $hasToken ? 'Private friend link ready' : 'Friend link missing' ?>
      </div>
      <button id="openAppBtn" type="button" class="btn"<?= $hasToken ? '' : ' disabled' ?>>Open in app</button>
      <div class="hint">Friend links work when you are logged in.</div>
    </div>
  </main>
  <script>
    (function () {
      var appQuery = <?= json_encode($appQuery, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
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
        if (!appQuery || document.hidden) return;
        if (isAndroid) {
          window.location.href =
            'intent://friend?' + appQuery +
            '#Intent;scheme=splyto;package=com.tripsplit.app.tripsplit;end';
          fallbackTimer = window.setTimeout(function () {
            if (!document.hidden) window.location.href = 'splyto://friend?' + appQuery;
          }, 650);
          return;
        }
        window.location.href = 'splyto://friend?' + appQuery;
        fallbackTimer = window.setTimeout(function () {
          if (!document.hidden) window.location.href = 'tripsplit://friend?' + appQuery;
        }, 650);
      }

      openBtn.addEventListener('click', openApp);
      if (appQuery) {
        openTimer = window.setTimeout(openApp, 220);
      }
    })();
  </script>
</body>
</html>
