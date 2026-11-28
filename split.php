<?php
declare(strict_types=1);

// A shared quick split, for anyone with the link. See docs/api/quick-split-share-links.md.

require_once __DIR__ . '/api/config.php';
require_once __DIR__ . '/api/lib/helpers/api_core_helpers.php';
require_once __DIR__ . '/api/lib/helpers/helper_share_preview.php';
require_once __DIR__ . '/api/lib/web/splyto_web_page.php';
require_once __DIR__ . '/api/lib/web/splyto_share_page_text.php';
require_once __DIR__ . '/api/lib/web/splyto_split_page_text.php';
require_once __DIR__ . '/api/lib/actions/quick_splits_actions.php';

$language = splyto_share_page_language((string) ($_SERVER['HTTP_ACCEPT_LANGUAGE'] ?? ''));
$t = static fn (string $key, array $values = []): string => splyto_split_text($language, $key, $values);
$code = share_param(['code']);

$bill = null;
$status = 404;
try {
    $pdo = db();
    if (!rate_limit_try(
        $pdo,
        'quick_split_share_view',
        client_ip_address(),
        QUICK_SPLIT_SHARE_VIEW_IP_MAX,
        QUICK_SPLIT_SHARE_VIEW_WINDOW_SEC
    )) {
        $status = 429;
    } else {
        $resolved = quick_split_share_resolve($pdo, $code);
        if ($resolved !== null) {
            $bill = quick_split_share_page_data($pdo, $resolved);
            $status = 200;
        }
    }
} catch (Throwable $error) {
    error_log('Quick split share page failed.');
    $bill = null;
    $status = 404;
}

share_send_html_headers(0);
header('Vary: Accept-Language');
header('Referrer-Policy: no-referrer');
header('X-Robots-Tag: noindex, nofollow');
http_response_code($status);

$install = splyto_app_install_links();
$token = $bill !== null ? (string) quick_split_share_normalize_token($code) : '';
$pageUrl = share_absolute_url('/split', $token !== '' ? ['code' => $token] : []);

if ($bill !== null) {
    $money = static fn (int $cents): string => splyto_split_money($cents, $bill['currency_code'], $language);
    $title = $bill['note'] !== '' ? $bill['note'] : $t('title_fallback');
    $total = $money($bill['amount_cents']);
    $ogTitle = $t('og_title', ['name' => $bill['sharer_name'], 'total' => $total]);
    $ogDescription = $t('og_description');
    $imageUrl = share_absolute_url('/share-image.php', [
        'type' => 'quick_split',
        'code' => $token,
        'v' => $bill['version'],
    ]);
    $peopleById = [];
    foreach ($bill['people'] as $person) {
        $peopleById[$person['id']] = $person;
    }
    $selectedId = (int) share_param(['p']);
    $selected = $peopleById[$selectedId] ?? null;
    $personLink = static fn (?int $id): string => '/split?' . http_build_query(
        $id !== null ? ['code' => $token, 'p' => $id] : ['code' => $token],
        '',
        '&',
        PHP_QUERY_RFC3986
    );
    $items = $bill['items'];
    if ($selected !== null) {
        $items = array_values(array_filter(
            $items,
            static fn (array $item): bool => in_array($selected['id'], $item['person_ids'], true)
        ));
    }
} else {
    $title = $t('not_shared');
    $ogTitle = 'SPLYTO';
    $ogDescription = $t('not_shared');
    $imageUrl = share_absolute_url('/share-image.php', ['type' => 'quick_split']);
}
?>
<!DOCTYPE html>
<html lang="<?= share_html($language) ?>">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <meta name="robots" content="noindex, nofollow" />
  <meta name="referrer" content="no-referrer" />
  <link rel="icon" href="/favicon.ico" sizes="48x48">
  <link rel="icon" type="image/png" sizes="192x192" href="/site/images/icon-192.png">
  <link rel="apple-touch-icon" href="/apple-touch-icon.png">
  <title><?= share_html($bill !== null ? $title . ' · SPLYTO' : 'SPLYTO') ?></title>
  <meta name="description" content="<?= share_html($ogDescription) ?>" />
  <?= share_open_graph_tags($ogTitle, $ogDescription, $pageUrl, $imageUrl, 'image/jpeg') ?>
  <?= splyto_share_page_meta() ?>
  <?= splyto_web_page_styles() ?>
  <?= splyto_share_page_styles() ?>
  <link rel="stylesheet" href="/site/css/split.css?v=1">
</head>
<body class="split-page">
  <main class="card">
    <?= splyto_share_page_header() ?>
    <div class="content">
<?php if ($bill === null): ?>
      <h1 class="alone"><?= share_html($t('not_shared')) ?></h1>
<?php else: ?>
      <section class="bill" aria-labelledby="billTitle">
        <p class="bill-date"><?= share_html(splyto_split_date($bill['date'], $language)) ?></p>
        <h1 id="billTitle" class="bill-title"><?= share_html($title) ?></h1>
        <p class="bill-total"><span class="label"><?= share_html($t('total')) ?></span> <strong><?= share_html($total) ?></strong></p>
<?php if ($bill['payer_name'] !== ''): ?>
        <p class="bill-payer"><?= share_html($t('paid_by', ['name' => $bill['payer_name']])) ?></p>
<?php endif; ?>
      </section>

      <nav class="switcher" aria-label="<?= share_html($t('who_pays')) ?>">
        <a class="pill<?= $selected === null ? ' on' : '' ?>" href="<?= share_html($personLink(null)) ?>"<?= $selected === null ? ' aria-current="page"' : '' ?>><?= share_html($t('everyone')) ?></a>
<?php foreach ($bill['people'] as $person): ?>
        <a class="pill<?= $selected !== null && $selected['id'] === $person['id'] ? ' on' : '' ?>" href="<?= share_html($personLink($person['id'])) ?>"<?= $selected !== null && $selected['id'] === $person['id'] ? ' aria-current="page"' : '' ?>><?= share_html($person['name']) ?></a>
<?php endforeach; ?>
      </nav>

<?php if ($selected !== null): ?>
      <section class="panel person-total">
        <span class="avatar" aria-hidden="true"><?= share_html($selected['initials']) ?></span>
        <span class="name"><?= share_html($selected['name']) ?><?php if ($selected['is_payer']): ?> <em class="badge"><?= share_html($t('paid')) ?></em><?php endif; ?></span>
        <strong class="amount"><?= share_html($money($selected['amount_cents'])) ?></strong>
      </section>
<?php else: ?>
      <section class="panel">
        <h2><?= share_html($t('who_pays')) ?></h2>
        <ul class="rows">
<?php foreach ($bill['people'] as $person): ?>
          <li>
            <span class="avatar" aria-hidden="true"><?= share_html($person['initials']) ?></span>
            <span class="name"><?= share_html($person['name']) ?><?php if ($person['is_payer']): ?> <em class="badge"><?= share_html($t('paid')) ?></em><?php endif; ?></span>
            <span class="amount"><?= share_html($money($person['amount_cents'])) ?></span>
          </li>
<?php endforeach; ?>
        </ul>
      </section>
<?php endif; ?>

<?php if ($items !== []): ?>
      <section class="panel">
        <h2><?= share_html($t('items')) ?></h2>
        <ul class="rows items">
<?php foreach ($items as $item): ?>
<?php $count = max(1, count($item['person_ids'])); ?>
          <li>
            <span class="name"><?= share_html($item['name']) ?>
<?php if ($selected === null): ?>
              <span class="who"><?php foreach ($item['person_ids'] as $pid): ?><?php if (isset($peopleById[$pid])): ?><i title="<?= share_html($peopleById[$pid]['name']) ?>"><?= share_html($peopleById[$pid]['initials']) ?></i><?php endif; ?><?php endforeach; ?></span>
<?php elseif ($count > 1): ?>
              <span class="share">1/<?= $count ?> · <?= share_html($t('shared')) ?></span>
<?php endif; ?>
            </span>
            <span class="amount"><?= share_html($money($selected !== null ? intdiv($item['amount_cents'], $count) : $item['amount_cents'])) ?></span>
          </li>
<?php endforeach; ?>
<?php if ($selected === null && $bill['extra_cents'] !== 0): ?>
          <li><span class="name"><?= share_html($t('extra')) ?></span><span class="amount"><?= share_html($money($bill['extra_cents'])) ?></span></li>
<?php endif; ?>
        </ul>
      </section>
<?php endif; ?>

<?php if ($bill['receipt_url'] !== null): ?>
      <a class="panel receipt-row" href="#receipt"><span><?= share_html($t('receipt')) ?></span><span class="view"><?= share_html($t('view')) ?></span></a>
      <div id="receipt" class="viewer" role="dialog" aria-label="<?= share_html($t('receipt')) ?>">
        <a class="viewer-close" href="#"><?= share_html($t('close')) ?></a>
        <img src="<?= share_html($bill['receipt_url']) ?>" alt="<?= share_html($t('receipt')) ?>" loading="lazy">
      </div>
<?php endif; ?>
<?php endif; ?>

      <section class="cta">
        <p><?= share_html($t('cta')) ?></p>
<?php if ($install['ios'] !== ''): ?>
        <a class="btn" href="<?= share_html($install['ios']) ?>">App Store</a>
<?php endif; ?>
        <a class="btn<?= $install['ios'] !== '' ? ' btn-secondary' : '' ?>" href="<?= share_html($install['android']) ?>">Google Play</a>
      </section>
    </div>
  </main>
</body>
</html>
