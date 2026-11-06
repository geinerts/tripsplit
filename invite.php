<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';
require_once __DIR__ . '/api/lib/web/splyto_web_page.php';
require_once __DIR__ . '/api/lib/web/splyto_share_page_text.php';

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

$language = splyto_share_page_language((string) ($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? ''));
$text = SPLYTO_SHARE_PAGE_TEXT[$language];
$install = splyto_app_install_links();

// Invite validity can change immediately after this response.
share_send_html_headers(0);
header('Vary: Accept-Language');
?>
<!DOCTYPE html>
<html lang="<?= share_html($language) ?>">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title><?= share_html($title) ?></title>
  <meta name="description" content="<?= share_html($description) ?>" />
  <?= share_open_graph_tags($title, $description, $pageUrl, $imageUrl, 'image/jpeg') ?>
  <?= splyto_share_page_meta() ?>
  <?= splyto_web_page_styles() ?>
  <?= splyto_share_page_styles() ?>
</head>
<body>
  <main class="card">
    <?= splyto_share_page_header() ?>
    <div class="content">
      <?php if ($isValid): ?>
        <img class="share-image" src="<?= share_html($imageUrl) ?>" alt="">
        <h1><?= share_html($text['invite_title']) ?></h1>
        <div class="trip-name"><?= share_html($tripName) ?></div>
        <?php if ($install['ios'] !== ''): ?>
          <a id="installIos" class="btn" href="<?= share_html($install['ios']) ?>"><?= share_html($text['install']) ?></a>
        <?php endif; ?>
        <a id="installAndroid" class="btn" href="<?= share_html($install['android']) ?>"><?= share_html($text['install']) ?></a>
        <p id="returnHint" class="return-hint"><?= share_html($text['invite_return']) ?></p>
      <?php else: ?>
        <h1 class="alone"><?= share_html($hasInvite ? $text['invite_unavailable'] : $text['invite_missing']) ?></h1>
      <?php endif; ?>
      <button id="openAppBtn" type="button" class="open-app"<?= $isValid && $hasInvite ? '' : ' hidden' ?>><?= share_html($text['open_app']) ?></button>
    </div>
  </main>
  <script>
    (function () {
      var invite = <?= json_encode($hasInvite ? $inviteForApp : '', JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
      var openBtn = document.getElementById('openAppBtn');
      var ua = navigator.userAgent.toLowerCase();
      var isAndroid = ua.indexOf('android') >= 0;

      var isIos = /iphone|ipad|ipod/.test(ua);
      var installIos = document.getElementById('installIos');
      var installAndroid = document.getElementById('installAndroid');
      var returnHint = document.getElementById('returnHint');
      // Unknown devices, like a computer, keep both links.
      if (installIos && isAndroid) installIos.hidden = true;
      if (installAndroid && isIos) installAndroid.hidden = true;
      // Nothing to install yet, so don't talk about installing.
      if (returnHint && isIos && !installIos) returnHint.hidden = true;

      var fallbackTimer;
      function cancelOpen() {
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
    })();
  </script>
</body>
</html>
