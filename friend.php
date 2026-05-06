<?php
declare(strict_types=1);

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';

$rawCode = share_param(['code', 'friend_token', 'friend_code']);
$token = share_normalize_friend_token($rawCode);
$hasToken = is_string($token) && $token !== '';
$friendMeta = share_friend_meta($token);
$pageUrl = share_absolute_url('/friend', $hasToken ? ['code' => $token] : []);
$imageUrl = share_absolute_url('/share-image.php', [
    'type' => 'friend',
    'code' => $hasToken ? $token : '',
    'v' => $hasToken ? 'myqr4-' . substr(hash('sha256', $token), 0, 12) : 'myqr4-missing',
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
  <style>
    :root {
      --bg: #040607;
      --card: #0c1611;
      --text: #f3f8f5;
      --muted: #98ab9f;
      --accent: #57b487;
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
        radial-gradient(720px 360px at 82% 0%, rgba(46, 175, 110, 0.26), transparent 58%),
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

    .status {
      margin: 16px 0 18px;
      padding: 11px 12px;
      border-radius: 14px;
      border: 1px solid var(--stroke);
      background: rgba(255, 255, 255, 0.04);
      font-size: 14px;
      color: #d9e8df;
    }

    button {
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
      color: #07110d;
      background: linear-gradient(180deg, #b9f0d5, var(--accent));
    }

    button:disabled {
      cursor: not-allowed;
      opacity: 0.48;
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
    <p>Accept or send a friend request in the app.</p>
    <div class="status" id="friendStatus">
      <?= $hasToken ? 'Private friend link ready' : 'Friend link missing' ?>
    </div>
    <button id="openAppBtn" type="button"<?= $hasToken ? '' : ' disabled' ?>>Open in app</button>
    <div class="hint">Friend links work when you are logged in.</div>
  </main>
  <script>
    (function () {
      var appQuery = <?= json_encode($appQuery, JSON_UNESCAPED_SLASHES) ?>;
      var openBtn = document.getElementById('openAppBtn');
      var ua = navigator.userAgent.toLowerCase();
      var isAndroid = ua.indexOf('android') >= 0;

      function openApp() {
        if (!appQuery) return;
        if (isAndroid) {
          window.location.href =
            'intent://friend?' + appQuery +
            '#Intent;scheme=splyto;package=com.tripsplit.app.tripsplit;end';
          window.setTimeout(function () {
            window.location.href = 'splyto://friend?' + appQuery;
          }, 650);
          return;
        }
        window.location.href = 'splyto://friend?' + appQuery;
        window.setTimeout(function () {
          window.location.href = 'tripsplit://friend?' + appQuery;
        }, 650);
      }

      openBtn.addEventListener('click', openApp);
      if (appQuery) {
        window.setTimeout(openApp, 220);
      }
    })();
  </script>
</body>
</html>
