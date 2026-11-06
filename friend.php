<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';
require_once __DIR__ . '/api/lib/web/splyto_web_page.php';
require_once __DIR__ . '/api/lib/web/splyto_share_page_text.php';

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

$language = splyto_share_page_language((string) ($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? ''));
$text = SPLYTO_SHARE_PAGE_TEXT[$language];
$install = splyto_app_install_links();

share_send_html_headers($isValid ? 300 : 60);
header('Vary: Accept-Language');
?>
<!DOCTYPE html>
<html lang="<?= share_html($language) ?>">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title><?= share_html($title) ?></title>
  <meta name="description" content="<?= share_html($description) ?>" />
  <?= share_open_graph_tags($title, $description, $pageUrl, $imageUrl) ?>
  <?= splyto_share_page_meta() ?>
  <?= splyto_web_page_styles() ?>
  <?= splyto_share_page_styles() ?>
</head>
<body>
  <main class="card">
    <?= splyto_share_page_header() ?>
    <div class="content">
      <?php if ($hasToken): ?>
        <h1 class="alone"><?= share_html($text['friend_title']) ?></h1>
        <?php if ($install['ios'] !== ''): ?>
          <a id="installIos" class="btn" href="<?= share_html($install['ios']) ?>"><?= share_html($text['install']) ?></a>
        <?php endif; ?>
        <a id="installAndroid" class="btn" href="<?= share_html($install['android']) ?>"><?= share_html($text['install']) ?></a>
        <p id="returnHint" class="return-hint"><?= share_html($text['friend_return']) ?></p>
      <?php else: ?>
        <h1 class="alone"><?= share_html($text['friend_missing']) ?></h1>
      <?php endif; ?>
      <button id="openAppBtn" type="button" class="open-app"<?= $hasToken ? '' : ' hidden' ?>><?= share_html($text['open_app']) ?></button>
    </div>
  </main>
  <script>
    (function () {
      var appQuery = <?= json_encode($appQuery, JSON_HEX_TAG | JSON_HEX_AMP | JSON_HEX_APOS | JSON_HEX_QUOT) ?>;
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
    })();
  </script>
</body>
</html>
