// Run: node --test admin2/tests/web-security.test.cjs
// Requires PHP CLI, plus Playwright and Chrome (or PLAYWRIGHT_CHANNEL) for the browser test.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const { execFileSync } = require('node:child_process');
const root = path.resolve(__dirname, '../..');

function landing(file, query, android = false, renderedHtml) {
  const html = renderedHtml ?? fs.readFileSync(path.join(root, file), 'utf8');
  const elements = new Map();
  const listeners = {};
  const timers = new Map();
  const navigations = [];
  let timerId = 0;
  const element = id => {
    if (!elements.has(id)) elements.set(id, { addEventListener(type, fn) { this[type] = fn; } });
    return elements.get(id);
  };
  const document = {
    hidden: false, getElementById: element, querySelector: element,
    addEventListener(type, fn) { listeners[type] = fn; },
  };
  const window = {
    location: { search: query, set href(value) { navigations.push(value); } },
    setTimeout(fn) { timers.set(++timerId, fn); return timerId; },
    clearTimeout(id) { timers.delete(id); },
    addEventListener(type, fn) { listeners[type] = fn; },
  };
  vm.runInNewContext(html.match(/<script>([\s\S]*?)<\/script>/)[1], {
    window, document, navigator: { userAgent: android ? 'Android' : 'iPhone' },
    URLSearchParams, encodeURIComponent,
  });
  return {
    html, document, listeners, timers, navigations, button: element('openAppBtn'),
    tick() {
      const next = timers.entries().next().value;
      if (next) { timers.delete(next[0]); next[1](); }
    },
  };
}

function renderPhpScript(file, value, valid = true) {
  const source = fs.readFileSync(path.join(root, file), 'utf8');
  const script = source.match(/<script>[\s\S]*?<\/script>/)[0];
  // Render the real template's script with fixture variables only: no config, secrets, or DB.
  return execFileSync(process.env.PHP_BINARY || 'php', ['-n', '-r', `
    $fixture = json_decode(stream_get_contents(STDIN), true, 512, JSON_THROW_ON_ERROR);
    $appQuery = $fixture['value'];
    $inviteForApp = $fixture['value'];
    $hasInvite = $fixture['valid'];
    eval('?>' . $fixture['script']);
  `], { input: JSON.stringify({ script, value, valid }), encoding: 'utf8' });
}

for (const file of ['friend.html', 'invite.html']) {
  test(`${file}: deployed HTML copy stays synchronized`, () => {
    assert.equal(fs.readFileSync(path.join(root, 'html', file), 'utf8'),
      fs.readFileSync(path.join(root, file), 'utf8'));
  });
}

for (const file of ['friend.php', 'invite.php']) {
  test(`${file}: rendered empty script never launches`, () => {
    const page = landing(file, '', false, renderPhpScript(file, ''));
    page.button.click();
    assert.equal(page.timers.size, 0);
    assert.deepEqual(page.navigations, []);
  });

  test(`${file}: PHP JSON cannot terminate the script element`, () => {
    const payload = '</script><script>window.xss=1</script>\"&\'';
    const rendered = renderPhpScript(file, payload);
    assert.equal((rendered.match(/<\/script>/gi) || []).length, 1);
    assert.equal((rendered.match(/<script>/gi) || []).length, 1);
    const page = landing(file, '', false, rendered);
    page.tick();
    assert.ok(page.navigations[0].endsWith(file === 'friend.php' ? payload : encodeURIComponent(payload)));
  });

  for (const android of [false, true]) {
    test(`${file}: actual rendered timers cancel on click, app handoff and page exit (${android ? 'Android' : 'iOS'})`, () => {
      const page = landing(file, '', android, renderPhpScript(file,
        file === 'friend.php' ? 'code=ABCDEFGHIJKLMNOPQRSTUVWX' : 'trip-abcdefghij'));
      page.button.click();
      page.button.click();
      assert.equal(page.timers.size, 1);
      assert.equal(page.navigations.length, 2);
      assert.match(page.navigations[0], android ? /^intent:\/\// : /^splyto:\/\//);
      page.document.hidden = true;
      page.listeners.visibilitychange();
      page.document.hidden = false;
      page.tick();
      assert.equal(page.navigations.length, 2);
      page.button.click();
      page.tick();
      assert.match(page.navigations.at(-1), android ? /^splyto:\/\// : /^tripsplit:\/\//);
      page.button.click();
      page.listeners.pagehide();
      assert.equal(page.timers.size, 0);
      page.document.hidden = true;
      page.button.click();
      assert.equal(page.timers.size, 0);
    });
  }
}

test('invite.php: nonempty invalid invite never auto-launches', () => {
  const page = landing('invite.php', '', false, renderPhpScript('invite.php', 'invalid-invite', false));
  page.button.click();
  assert.equal(page.timers.size, 0);
  assert.deepEqual(page.navigations, []);
});

for (const file of ['friend.html', 'invite.html']) {
  test(`${file}: missing link is disabled and never navigates`, () => {
    const page = landing(file, '');
    assert.equal(page.button.disabled, true);
    page.button.click();
    assert.equal(page.timers.size, 0);
    assert.deepEqual(page.navigations, []);
    assert.match(page.html, /name="referrer" content="no-referrer"/);
  });

  for (const android of [false, true]) {
    test(`${file}: encoded parameters and cancellable fallback (${android ? 'Android' : 'iOS'})`, () => {
      const payload = `abc'\"<&;#Intent;scheme=evil;end`;
      const key = file === 'friend.html' ? 'friend_token' : 'invite';
      const page = landing(file, `?${key}=${encodeURIComponent(payload)}`, android);
      assert.equal(page.button.disabled, false);
      // Manual clicks cancel the pending automatic open; repeated clicks leave one fallback.
      page.button.click();
      page.button.click();
      assert.equal(page.timers.size, 1);
      assert.equal(page.navigations.length, 2);
      assert.ok(page.navigations[0].includes(encodeURIComponent(payload)));
      assert.match(page.navigations[0], android ? /^intent:\/\// : /^splyto:\/\//);
      page.document.hidden = true;
      page.listeners.visibilitychange();
      page.document.hidden = false;
      page.tick();
      assert.equal(page.navigations.length, 2);
      page.button.click();
      page.tick();
      assert.match(page.navigations.at(-1), android ? /^splyto:\/\// : /^tripsplit:\/\//);
      page.button.click();
      page.listeners.pagehide();
      assert.equal(page.timers.size, 0);
    });
  }
}

test('admin actions render and operate under CSP without executing untrusted data', async () => {
  const { chromium } = require('playwright');
  const browser = await chromium.launch({ headless: true, channel: process.env.PLAYWRIGHT_CHANNEL || 'chrome' });
  try {
    const page = await browser.newPage();
    const errors = [];
    const violations = [];
    const requests = [];
    const name = `O'Brien');window.xss=1;//\" <img src=x onerror=window.xss=2> &quot;`;
    const target = '<img src=x onerror=window.xss=3>';
    const user = { id: 42, nickname: name, username: name, email: 'fixture@example.test',
      role: 'support', is_active: 1, account_status: 'active', created_at: '2026-01-01 00:00:00' };
    page.on('pageerror', error => errors.push(error.message));
    page.on('console', message => {
      if (/Executing inline|Refused to execute/.test(message.text())) violations.push(message.text());
    });
    await page.route('**/*', async route => {
      const url = new URL(route.request().url());
      if (url.pathname === '/api/api.php') {
        const action = url.searchParams.get('action');
        requests.push({ action, body: route.request().postDataJSON(), offset: url.searchParams.get('offset') });
        const responses = {
          admin_panel_session_check: { authenticated: false },
          admin_panel_user_search: { ok: true, users: [user], total: 41 },
          admin_panel_user_detail: { ok: true, user, trips: [], unread_notifs: 0 },
          admin_panel_admin_users: { ok: true, users: [user] },
          admin_panel_active_sessions: { ok: true, sessions: [{ session_id: name, username: name }] },
          admin_panel_audit_log: { ok: true, log: [{ action: 'session.revoke', target_type: 'session', target_id: target }], total: 1 },
          admin_panel_app_events: { ok: true, events: [{ event_type: 'trip.update', entity_type: 'trip', entity_id: target }], total: 1 },
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
    await page.locator('#auth-screen.visible').waitFor();
    await page.evaluate(() => { state.user = { id: 1, username: 'Test', role: 'superadmin' }; showApp(); navigate('users'); });
    await page.locator('#user-search-btn').click();
    await page.locator('[data-action="suspendUser"]').waitFor();
    assert.equal(await page.locator('.cl-title').textContent(), name);
    assert.equal(await page.locator('#page-content img, #page-content [onclick]').count(), 0);
    const promptSeen = new Promise(resolve => page.once('dialog', async dialog => {
      assert.ok(dialog.message().includes(name));
      await dialog.accept('Regression test');
      resolve();
    }));
    await page.locator('[data-action="suspendUser"]').click();
    await promptSeen;
    await page.waitForFunction(() => document.querySelector('.toast.success'));
    assert.deepEqual(requests.find(r => r.action === 'admin_panel_user_suspend').body,
      { user_id: 42, reason: 'Regression test' });
    await page.locator('[data-action="userSearch"]').click();
    await page.waitForFunction(() => document.querySelector('.pagination')?.textContent.includes('Showing 41'));
    assert.ok(requests.some(r => r.action === 'admin_panel_user_search' && r.offset === '40'));
    await page.locator('[data-action="openUserDetail"]').click();
    await page.locator('#modal-body [data-action="deleteUser"]').waitFor();
    assert.equal(await page.locator('#modal-title').textContent(), 'User: ' + name);
    await page.locator('[data-action="closeModal"]').click();
    assert.equal(await page.locator('#modal-backdrop.open').count(), 0);
    await page.evaluate(() => navigate('admin-users'));
    await page.locator('[data-action="editAdminUser"]').click();
    assert.equal(await page.locator('#modal-title').textContent(), 'Edit: ' + name);
    await page.locator('[data-action="saveAdminUser"]').click();
    await page.locator('#modal-backdrop').waitFor({ state: 'hidden' });
    assert.equal(requests.find(r => r.action === 'admin_panel_update_admin_user').body.id, 42);
    await page.evaluate(() => navigate('sessions'));
    page.once('dialog', dialog => dialog.accept());
    await page.locator('[data-action="revokeSession"]').click();
    await page.waitForFunction(() => [...document.querySelectorAll('.toast')].some(el => el.textContent === 'Session revoked'));
    assert.equal(requests.find(r => r.action === 'admin_panel_revoke_session').body.session_id, name);
    for (const view of ['audit-log', 'app-events']) {
      await page.evaluate(view => navigate(view), view);
      await page.locator('.cl-meta').waitFor();
      assert.ok((await page.locator('.cl-meta').textContent()).includes(target));
      assert.equal(await page.locator('#page-content img').count(), 0);
    }
    assert.equal(await page.evaluate(() => window.xss), undefined);
    assert.deepEqual(errors, []);
    assert.deepEqual(violations, []);
    const source = fs.readFileSync(path.join(root, 'admin2/app.js'), 'utf8');
    assert.doesNotMatch(source, /\bon\w+\s*=/i);
  } finally {
    await browser.close();
  }
});
