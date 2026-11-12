// Run: node --test admin2/tests/admin-mfa.test.cjs
// Requires Playwright and Chrome (or PLAYWRIGHT_CHANNEL). The API is mocked.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');

const SECRET = 'JBSWY3DPEHPK3PXPJBSWY3DPEHPK3PXP';
const NEW_SECRET = 'KRSXG5CTMVRXEZLUKRSXG5CTMVRXEZLU';

async function openPanel(browser, width) {
  const page = await browser.newPage({ viewport: { width, height: 800 } });
  const errors = [];
  const requests = [];
  const state = { enrolled: false, verified: false, setups: 0 };
  page.on('pageerror', error => errors.push(error.message));
  await page.route('**/*', async route => {
    const url = new URL(route.request().url());
    if (url.pathname === '/api/api.php') {
      const action = url.searchParams.get('action');
      const body = route.request().postDataJSON();
      requests.push({ action, body });
      const user = { id: 1, username: 'owner', email: 'owner@example.test', role: 'superadmin', totp_enabled: state.enrolled };
      let json = { ok: true };
      if (action === 'admin_panel_session_check') {
        json = state.loggedIn
          ? { ok: true, authenticated: true, full_auth: state.enrolled && state.verified,
              requires_2fa: state.enrolled && !state.verified, requires_2fa_enrollment: !state.enrolled, user }
          : { ok: false, authenticated: false };
      } else if (action === 'admin_panel_login') {
        state.loggedIn = true;
        json = { ok: true, requires_2fa: false, requires_2fa_enrollment: true, user };
      } else if (action === 'admin_panel_setup_totp') {
        state.setups += 1;
        json = { ok: true, secret: state.setups === 1 ? SECRET : NEW_SECRET, replacing: state.enrolled };
      } else if (action === 'admin_panel_confirm_totp') {
        if (body.code !== '123456') {
          json = { ok: false, code: '2fa_invalid', error: 'Invalid or expired 2FA code.' };
        } else {
          json = { ok: true, replaced: state.enrolled, revoked_sessions: state.enrolled ? 2 : 0 };
          state.enrolled = true;
          state.verified = true;
        }
      } else if (action === 'admin_panel_dashboard') {
        json = { ok: true, stats: {} };
      }
      return route.fulfill({ json });
    }
    const files = { '/admin2/': 'admin2/index.html', '/admin2/app.js': 'admin2/app.js', '/admin2/app.css': 'admin2/app.css' };
    const file = files[url.pathname];
    if (!file) return route.abort();
    return route.fulfill({ body: fs.readFileSync(path.join(root, file)),
      contentType: file.endsWith('.js') ? 'text/javascript' : file.endsWith('.css') ? 'text/css' : 'text/html' });
  });
  await page.goto('http://splyto.test/admin2/');
  return { page, errors, requests };
}

for (const width of [1280, 390]) {
  test(`Mandatory 2FA enrolment and authenticator replacement at ${width}px`, async () => {
    const { chromium } = require('playwright');
    const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chrome' });
    try {
      const { page, errors, requests } = await openPanel(browser, width);
      await page.locator('#login-card').waitFor();
      await page.fill('#inp-username', 'owner');
      await page.fill('#inp-password', 'password-1234');
      await page.click('#login-btn');

      // Password alone never opens the panel.
      await page.locator('#enroll-card').waitFor();
      assert.equal(await page.locator('#app').isVisible(), false);
      assert.equal(await page.inputValue('#inp-password'), '');
      await page.fill('#inp-enroll-password', 'password-1234');
      await page.click('#enroll-start-btn');
      await page.locator('#enroll-confirm-form').waitFor();
      assert.equal(await page.locator('#enroll-secret').textContent(), SECRET);
      assert.deepEqual(requests.find(r => r.action === 'admin_panel_setup_totp').body, { password: 'password-1234' });
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true);

      await page.fill('#inp-enroll-code', '000000');
      await page.click('#enroll-confirm-btn');
      await page.locator('#enroll-error').filter({ hasText: 'Invalid or expired' }).waitFor();
      await page.fill('#inp-enroll-code', '123456');
      await page.click('#enroll-confirm-btn');
      await page.locator('#app').waitFor();
      assert.equal(await page.locator('#enroll-secret').textContent(), '');

      // My Account offers replacement only; 2FA cannot be turned off.
      await page.evaluate(() => navigate('my-account'));
      await page.locator('[data-action="replace2fa"]').click();
      assert.equal(await page.locator('[data-action="disable2fa"]').count(), 0);
      await page.fill('#replace-2fa-password', 'password-1234');
      await page.fill('#replace-2fa-code', '654321');
      await page.click('#modal-footer [type="submit"]');
      await page.locator('#modal-body .setup-key').filter({ hasText: NEW_SECRET }).waitFor();
      assert.deepEqual(requests.filter(r => r.action === 'admin_panel_setup_totp')[1].body,
        { password: 'password-1234', current_code: '654321' });
      await page.fill('#totp-confirm-code', '123456');
      await page.click('[data-action="confirm2fa"]');
      await page.waitForFunction(() => [...document.querySelectorAll('.toast')]
        .some(el => el.textContent.includes('2 other session(s) signed out')));
      assert.deepEqual(errors, []);
    } finally {
      await browser.close();
    }
  });
}
