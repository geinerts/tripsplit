// Run: node --test admin2/tests/admin-overview.test.cjs
// Requires Playwright and Chrome (or PLAYWRIGHT_CHANNEL). The API is mocked.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '../..');

const hostile = '<img src=x onerror=window.xss=1>';
const users = [
  { id: 12, nickname: `Anna ${hostile}`, email: 'anna@example.test', account_status: 'active', created_at: '2026-11-11 09:00:00',
    sign_in_methods: ['apple'], platforms: ['ios'], email_verified: true, trips_count: 4, last_active_at: '2026-11-12 07:10:00', premium_grant: true },
  { id: 11, nickname: 'Jānis', email: null, account_status: 'deactivated', created_at: '2026-11-09 09:00:00',
    sign_in_methods: [], platforms: [], email_verified: null, trips_count: 0, last_active_at: null, premium_grant: false },
];
const growth = Array.from({ length: 30 }, (_, i) => ({
  date: new Date(Date.UTC(2026, 9, 14 + i)).toISOString().slice(0, 10), signups: i % 4, active: 5 + (i % 3), trips: i % 2,
}));

async function openPanel(browser, width) {
  const page = await browser.newPage({ viewport: { width, height: 900 } });
  const errors = [];
  const requests = [];
  page.on('pageerror', error => errors.push(error.message));
  await page.route('**/*', async route => {
    const url = new URL(route.request().url());
    if (url.pathname === '/api/api.php') {
      const action = url.searchParams.get('action');
      requests.push({ action, query: Object.fromEntries(url.searchParams), body: route.request().postDataJSON() });
      const responses = {
        admin_panel_session_check: { ok: true, authenticated: true, full_auth: true,
          user: { id: 1, username: 'owner', role: 'superadmin', totp_enabled: true } },
        admin_panel_user_search: { ok: true, users, total: 2, premium_for_everyone: false },
        admin_panel_dashboard: { ok: true, stats: { growth, push_queue: {}, recent_incidents: [] } },
        admin_panel_audit_log: { ok: true, log: [], total: 0 },
        admin_panel_app_events: { ok: true, events: [], total: 0 },
        admin_panel_user_detail: { ok: true, user: users[0], trips: [{ id: 3, name: 'Rome', status: 'active', members_count: 3 }],
          premium: { can_manage: false }, push_tokens: [], unread_notifs: 0,
          sessions: [{ id: 1, created_at: '2026-11-01 08:00:00', last_used_at: '2026-11-12 07:00:00', user_agent: hostile }],
          timeline: [{ event_type: hostile, trip_name: hostile, created_at: '2026-11-12 07:05:00' }] },
        admin_panel_user_sign_out_everywhere: { ok: true, revoked: 1 },
        admin_panel_system_health: { ok: true,
          jobs: [{ job: 'backup', label: 'Database & files backup', schedule: 'daily', state: 'failed', last_run: '2026-11-12 03:20:00', details: { db_bytes: 2048 } },
            { job: 'push_delivery', label: 'Push delivery', schedule: 'every minute', state: 'ok', last_run: '2026-11-12 07:59:00', details: {} },
            { job: 'image_originals_cleanup', label: 'Image originals cleanup', schedule: 'weekly', state: 'unknown', last_run: null, details: [] }],
          system: { disk_total_bytes: 100, disk_free_bytes: 10, database_bytes: 1048576, php_version: '8.3', mysql_version: '8.4', commit: 'abc1234' },
          push: { pending: 0, failed_24h: 0, oldest_pending_at: null, last_sent_at: null } },
        admin_panel_security_overview: { ok: true, counts_7d: { failed_logins: 2, failed_2fa: 0, locked: 0, successful_logins: 1 },
          events: [{ admin_username: hostile, action: 'admin.auth.login_failed', ip_address: '192.0.2.1', created_at: '2026-11-12 07:00:00' }],
          rate_limits_24h: [{ scope: 'login_ip', windows: 2, requests: 9, peak: 7 }], active_admin_sessions: 1 },
      };
      return route.fulfill({ json: responses[action] || { ok: true } });
    }
    const files = { '/admin2/': 'admin2/index.html', '/admin2/app.js': 'admin2/app.js', '/admin2/app.css': 'admin2/app.css' };
    const file = files[url.pathname];
    if (!file) return route.abort();
    return route.fulfill({ body: fs.readFileSync(path.join(root, file)),
      contentType: file.endsWith('.js') ? 'text/javascript' : file.endsWith('.css') ? 'text/css' : 'text/html' });
  });
  await page.goto('http://splyto.test/admin2/');
  await page.locator('#app').waitFor();
  return { page, errors, requests };
}

const noOverflow = page => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth);

for (const width of [1280, 390]) {
  test(`Users grid, growth chart, user detail, system and security views at ${width}px`, async () => {
    const { chromium } = require('playwright');
    const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chrome' });
    try {
      const { page, errors, requests } = await openPanel(browser, width);

      // Dashboard: three 30-day charts with a hover tooltip and a table view.
      await page.locator('.growth-chart').first().waitFor();
      assert.equal(await page.locator('.growth-chart').count(), 3);
      assert.equal(await page.locator('.growth-chart').first().locator('.growth-col').count(), 30);
      await page.locator('.growth-col').nth(3).hover();
      assert.match(await page.locator('.chart-tip').textContent(), /sign-ups$/);
      assert.equal(await page.locator('.growth-table tr').first().isVisible(), false);
      assert.ok(await noOverflow(page));

      // Users: filters reach the API, the grid layout is remembered.
      await page.evaluate(() => navigate('users'));
      await page.locator('.cl-item').first().waitFor();
      await page.selectOption('#user-sort', 'last_active');
      await page.selectOption('#user-platform-filter', 'ios');
      await page.check('#user-premium-filter');
      await page.waitForFunction(() => document.querySelector('.cl-item'));
      const last = requests.filter(r => r.action === 'admin_panel_user_search').at(-1).query;
      assert.equal(last.sort, 'last_active');
      assert.equal(last.platform, 'ios');
      assert.equal(last.premium, '1');
      await page.click('[data-users-layout="grid"]');
      await page.locator('.user-card').first().waitFor();
      assert.equal(await page.locator('.user-card').count(), 2);
      assert.equal(await page.locator('[data-users-layout="grid"]').getAttribute('aria-pressed'), 'true');
      assert.equal(await page.locator('.user-card .user-avatar').first().textContent(), 'AO');
      assert.ok((await page.locator('.user-card').nth(1).textContent()).includes('No session use'));
      assert.ok(await noOverflow(page));
      await page.evaluate(() => navigate('dashboard'));
      await page.evaluate(() => navigate('users'));
      await page.locator('.user-card').first().waitFor();

      // User detail: devices, timeline and sign out everywhere.
      await page.locator('.user-card [data-action="openUserDetail"]').first().click();
      await page.locator('.user-timeline').waitFor();
      assert.ok((await page.locator('#modal-body').textContent()).includes('3 members'));
      await page.click('[data-action="signOutEverywhere"]');
      await page.locator('#modal-footer [type="submit"]').click();
      await page.waitForFunction(() => [...document.querySelectorAll('.toast')].some(t => t.textContent.includes('1 session(s) signed out')));
      assert.deepEqual(requests.find(r => r.action === 'admin_panel_user_sign_out_everywhere').body, { user_id: 12 });

      // System health: states are labelled, not colour only.
      await page.evaluate(() => navigate('system'));
      await page.locator('.cl-item').first().waitFor();
      const systemText = await page.locator('#page-content').textContent();
      for (const label of ['Failed', 'OK', 'No data yet', '1 need attention', '90%', 'abc1234']) {
        assert.ok(systemText.includes(label), label);
      }
      assert.ok(await noOverflow(page));

      // Security overview.
      await page.evaluate(() => navigate('security'));
      await page.locator('table').waitFor();
      const securityText = await page.locator('#page-content').textContent();
      assert.ok(securityText.includes('Wrong password'));
      assert.ok(securityText.includes('login_ip'));
      assert.ok(await noOverflow(page));

      assert.equal(await page.evaluate(() => window.xss), undefined);
      assert.equal(await page.locator('#page-content img, #modal-body img').count(), 0);
      assert.deepEqual(errors, []);
    } finally {
      await browser.close();
    }
  });
}
