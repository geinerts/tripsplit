const { test } = require('node:test');
const assert = require('node:assert/strict');
const { execFileSync } = require('node:child_process');
const path = require('node:path');
const { chromium } = require('playwright');
const root = path.resolve(__dirname, '../..');

function render(file, token) {
  return execFileSync('php', ['-r', '$_GET = json_decode($argv[2], true); include $argv[1];',
    path.join(root, 'api', file), JSON.stringify({ token })], { encoding: 'utf8' });
}

for (const file of ['delete-account.php', 'reactivate-account.php']) {
  test(`${file}: malformed tokens render no confirmation control`, () => {
    for (const token of ['', 'a'.repeat(64) + '\n', '<script>bad()</script>', ['a'.repeat(64)]]) {
      const html = render(file, token);
      assert.match(html, /Invalid link/);
      assert.doesNotMatch(html, /id="btn"|fetch\(/);
    }
  });
  for (const width of [360, 1280]) {
    test(`${file}: explicit confirmation, retry and duplicate-click protection at ${width}px`, async () => {
      const browser = await chromium.launch({ channel: process.env.PLAYWRIGHT_CHANNEL || 'chrome' });
      try {
        const page = await browser.newPage({ viewport: { width, height: 900 } });
        const token = 'a'.repeat(64);
        const calls = [];
        let release;
        let pending = new Promise(resolve => { release = resolve; });
        await page.route('https://confirmation.invalid/**', async route => {
          const url = new URL(route.request().url());
          if (url.pathname === '/api/' + file) {
            return route.fulfill({ contentType: 'text/html', body: render(file, token) });
          }
          if (url.pathname === '/api/api.php') {
            calls.push({ action: url.searchParams.get('action'), body: route.request().postDataJSON() });
            const response = await pending;
            return route.fulfill({ status: response.status, contentType: 'application/json', body: JSON.stringify(response.body) });
          }
          return route.fulfill({ status: 404, body: '' });
        });
        await page.goto(`https://confirmation.invalid/api/${file}?token=${token}`);
        assert.equal(new URL(page.url()).search, '');
        assert.equal(calls.length, 0, 'GET/prefetch must never submit a proof');
        const button = page.locator('#btn');
        if (file === 'delete-account.php') {
          assert.equal(await button.isDisabled(), true);
          await page.locator('#confirm').fill('DELETE');
        }
        await button.click();
        await page.waitForFunction(() => document.getElementById('btn').disabled);
        if (file === 'delete-account.php') {
          await page.locator('#confirm').fill('DELETE ');
          assert.equal(await button.isDisabled(), true, 'Editing must not unlock a pending request');
        }
        await button.evaluate(el => el.dispatchEvent(new Event('click')));
        release({ status: 503, body: { ok: true, error: 'Please retry' } });
        await page.locator('#msg.error').waitFor();
        assert.equal(calls.length, 1);
        assert.equal(await button.isDisabled(), false);
        pending = new Promise(resolve => { release = resolve; });
        await button.click();
        release({ status: 200, body: { ok: true } });
        await page.locator('#msg.success').waitFor();
        await button.evaluate(el => el.dispatchEvent(new Event('click')));
        assert.equal(calls.length, 2, 'Completed proof must not be resubmitted');
        for (const call of calls) {
          assert.equal(call.action, file === 'delete-account.php' ? 'confirm_account_deletion' : 'confirm_reactivation');
          assert.deepEqual(call.body, { token });
        }
        assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), true);
      } finally { await browser.close(); }
    });
  }
}
