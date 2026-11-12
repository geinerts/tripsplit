'use strict';

// ── API ───────────────────────────────────────────────────────────────────────

const API = '/api/api.php';

async function api(action, params = {}, method = 'GET') {
  const url = `${API}?action=${action}`;
  const opts = {
    method,
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
  };
  if (method === 'POST') {
    opts.body = JSON.stringify(params);
  } else {
    const qs = new URLSearchParams(params).toString();
    return fetch(qs ? `${url}&${qs}` : url, { ...opts, body: undefined }).then(r => r.json());
  }
  return fetch(url, opts).then(r => r.json());
}

const get  = (action, params = {})  => api(action, params, 'GET');
const post = (action, params = {})  => api(action, params, 'POST');

// ── State ─────────────────────────────────────────────────────────────────────

const state = {
  user:        null,   // { id, username, email, role, totp_enabled }
  view:        null,
  viewData:    {},
  navigationId: 0,
  openIncidentCount: 0,
};

// ── Topbar clock ──────────────────────────────────────────────────────────────

function updateClock() {
  const el = document.getElementById('topbar-time');
  if (!el) return;
  const now = new Date();
  const days = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
  el.textContent = `${days[now.getDay()]}, ${now.getDate()} ${months[now.getMonth()]} · ${String(now.getHours()).padStart(2,'0')}:${String(now.getMinutes()).padStart(2,'0')}`;
}
updateClock();
setInterval(updateClock, 30_000);

// ── Toast ─────────────────────────────────────────────────────────────────────

function toast(msg, type = 'info', durationMs = 3500) {
  const el = document.createElement('div');
  el.className = `toast ${type}`;
  el.textContent = msg;
  document.getElementById('toast-container').appendChild(el);
  setTimeout(() => el.remove(), durationMs);
}

// ── Modal ─────────────────────────────────────────────────────────────────────

const modal = {
  open(title, bodyHtml, footerHtml = '') {
    const pending = modal.afterClose;
    modal.afterClose = null;
    if (pending) pending();
    document.getElementById('modal-title').textContent = title;
    document.getElementById('modal-body').innerHTML = bodyHtml;
    document.getElementById('modal-footer').innerHTML = footerHtml;
    document.getElementById('modal-backdrop').classList.add('open');
  },
  close() {
    document.getElementById('modal-backdrop').classList.remove('open');
    const afterClose = modal.afterClose;
    modal.afterClose = null;
    if (afterClose) afterClose();
  },
  afterClose: null,
};

// Asks inside the panel's own modal instead of the browser's prompt()/confirm().
// Resolves to the entered text (or true without an input), or null when cancelled.
function askInModal({ title, message, input = null, confirmLabel = 'Confirm', danger = false }) {
  return new Promise(resolve => {
    modal.close();
    const field = input ? `
      <div class="form-group" style="margin-top:14px">
        <label class="form-label" for="ask-input">${esc(input.label)}</label>
        <input class="form-input" id="ask-input" type="${input.type === 'password' ? 'password' : 'text'}"
               autocomplete="${input.type === 'password' ? 'current-password' : 'off'}" maxlength="500"
               ${input.required ? 'required' : ''}/>
      </div>` : '';
    modal.open(title, `<form id="ask-form" novalidate><p class="ask-message">${esc(message)}</p>${field}
      <p class="ask-error" id="ask-error" hidden>This field is required.</p></form>`, `
      <button class="btn btn-ghost" type="button" id="ask-cancel">Cancel</button>
      <button class="btn ${danger ? 'btn-danger' : 'btn-primary'}" type="submit" form="ask-form">${esc(confirmLabel)}</button>`);
    let settled = false;
    const finish = value => { if (!settled) { settled = true; resolve(value); } };
    modal.afterClose = () => finish(null);
    document.getElementById('ask-cancel').addEventListener('click', () => modal.close());
    const inputEl = document.getElementById('ask-input');
    document.getElementById('ask-form').addEventListener('submit', e => {
      e.preventDefault();
      const value = inputEl ? inputEl.value.trim() : true;
      if (input?.required && !value) { document.getElementById('ask-error').hidden = false; inputEl.focus(); return; }
      finish(inputEl ? (input.type === 'password' ? inputEl.value : value) : true);
      modal.afterClose = null;
      modal.close();
    });
    (inputEl || document.querySelector('#modal-footer [type="submit"]')).focus();
  });
}

document.getElementById('modal-backdrop').addEventListener('click', e => {
  if (e.target === e.currentTarget) modal.close();
});

// ── Routing ───────────────────────────────────────────────────────────────────

const views = {};

function registerView(name, { title, render, init }) {
  views[name] = { title, render, init };
}

// ── Sidebar toggle (mobile) ────────────────────────────────────────────────────

function openSidebar() {
  document.getElementById('sidebar').classList.add('open');
  document.getElementById('sidebar-overlay').classList.add('open');
}

function closeSidebar() {
  document.getElementById('sidebar').classList.remove('open');
  document.getElementById('sidebar-overlay').classList.remove('open');
}

document.getElementById('sidebar-toggle').addEventListener('click', () => {
  const isOpen = document.getElementById('sidebar').classList.contains('open');
  isOpen ? closeSidebar() : openSidebar();
});

document.getElementById('sidebar-overlay').addEventListener('click', closeSidebar);

// Close on swipe-left (mobile)
(function() {
  let startX = 0;
  const sidebar = document.getElementById('sidebar');
  sidebar.addEventListener('touchstart', e => { startX = e.touches[0].clientX; }, { passive: true });
  sidebar.addEventListener('touchend', e => {
    if (startX - e.changedTouches[0].clientX > 60) closeSidebar();
  }, { passive: true });
})();

// ─────────────────────────────────────────────────────────────────────────────

function navigate(name, data = {}) {
  const navigationId = ++state.navigationId;
  state.view     = name;
  state.viewData = data;

  // Close sidebar on mobile when navigating
  closeSidebar();

  // Sidebar active state
  document.querySelectorAll('.nav-item').forEach(el => {
    el.classList.toggle('active', el.dataset.view === name);
  });

  const v = views[name];
  if (!v) { setContent('<div class="empty-state">Unknown view.</div>'); return; }

  document.getElementById('page-title').textContent = v.title;
  document.getElementById('topbar-actions').innerHTML = '';
  setContent('<div class="loading-state"><span class="spinner"></span> Loading…</div>');

  return Promise.resolve()
    .then(() => v.render(data))
    .then(html => {
      if (navigationId !== state.navigationId) return;
      setContent(html);
      if (v.init) v.init(data);
    })
    .catch(err => {
      if (navigationId !== state.navigationId) return;
      setContent(`<div class="empty-state">Error: ${esc(err.message)}</div>`);
    });
}

function setContent(html) {
  document.getElementById('page-content').innerHTML = html;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function esc(str) {
  return String(str ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

// Arguments stay JSON data, never JavaScript in an HTML event attribute.
function actionAttrs(action, ...args) {
  return `data-action="${esc(action)}" data-args="${esc(JSON.stringify(args))}"`;
}

const clickActions = Object.freeze({
  openPremiumForm, premiumPage,
  navigate, openUserDetail, suspendUser, reactivateUser, deleteUser, clearPushTokens, signOutEverywhere,
  userSearch, retryPush,
  updateIncident, submitIncident, loadAuditLog, loadAppEvents,
  editAdminUser, deleteAdminUser, showCreateAdminModal, createAdminUser, saveAdminUser,
  revokeSession, replace2fa, confirm2fa,
  closeModal: () => modal.close(),
});

document.addEventListener('click', async e => {
  const control = e.target.closest('[data-action]');
  if (!control || control.disabled || !Object.hasOwn(clickActions, control.dataset.action)) return;
  try {
    const args = JSON.parse(control.dataset.args || '[]');
    if (!Array.isArray(args)) return;
    if (control.hasAttribute('data-close-modal')) modal.close();
    await clickActions[control.dataset.action](...args);
  } catch {
    toast('Unable to complete the action. Please try again.', 'error');
  }
});

function relTime(raw) {
  if (!raw) return '—';
  const iso = raw.replace(' ', 'T');
  const d   = new Date(iso.includes('Z') || iso.includes('+') ? iso : iso + 'Z');
  const diff = (Date.now() - d) / 1000;
  if (diff <  60) return 'just now';
  if (diff <  3600) return `${Math.floor(diff/60)}m ago`;
  if (diff <  86400) return `${Math.floor(diff/3600)}h ago`;
  if (diff < 604800) return `${Math.floor(diff/86400)}d ago`;
  return d.toLocaleDateString('lv-LV', { day:'2-digit', month:'2-digit', year:'numeric' });
}

function statusBadge(status) {
  const map = {
    active: 'badge-green', deactivated: 'badge-red', suspended: 'badge-red', deleted: 'badge-gray',
    open: 'badge-red', investigating: 'badge-amber', resolved: 'badge-green',
    pending: 'badge-amber', sent: 'badge-green', failed: 'badge-red', dead: 'badge-gray',
    ok: 'badge-green', stale: 'badge-amber', unknown: 'badge-gray',
  };
  return `<span class="badge ${map[status] ?? 'badge-gray'}">${esc(status)}</span>`;
}

function roleBadge(role) {
  const map = {
    superadmin: 'badge-purple', admin: 'badge-blue',
    support: 'badge-green', ops: 'badge-amber', readonly: 'badge-gray',
  };
  return `<span class="badge ${map[role] ?? 'badge-gray'}">${esc(role)}</span>`;
}

function sevBadge(sev) {
  const map = {
    critical: 'badge-red', high: 'badge-amber', medium: 'badge-green', low: 'badge-gray',
  };
  return `<span class="badge ${map[sev] ?? 'badge-gray'}">${esc(sev)}</span>`;
}

function can(...roles) {
  return state.user && roles.includes(state.user.role);
}

// ── Auth ──────────────────────────────────────────────────────────────────────

async function checkSession() {
  const res = await get('admin_panel_session_check');
  if (!res.authenticated) return false;
  if (res.requires_2fa_enrollment) return 'needs_enrollment';
  if (res.requires_2fa)   return 'needs_2fa';
  state.user = res.user;
  return true;
}

function showAuth(mode = 'login') {
  document.getElementById('auth-screen').classList.add('visible');
  document.getElementById('app').style.display = 'none';
  document.getElementById('login-card').style.display = mode === 'login' ? '' : 'none';
  document.getElementById('totp-card').style.display  = mode === '2fa'   ? '' : 'none';
  document.getElementById('enroll-card').style.display = mode === 'enroll' ? '' : 'none';
  if (mode === 'enroll') resetEnrollCard();
}

async function enterApp() {
  const sessRes = await get('admin_panel_session_check');
  if (!sessRes.full_auth) { showAuth(sessRes.requires_2fa_enrollment ? 'enroll' : 'login'); return; }
  state.user = sessRes.user;
  showApp();
  navigate('dashboard');
  pollIncidents();
}

function showApp() {
  document.getElementById('auth-screen').classList.remove('visible');
  document.getElementById('app').style.display = 'flex';
  // Set sidebar user info
  if (state.user) {
    for (const id of ['nav-premium', 'nav-partners']) {
      document.getElementById(id).style.display = can('superadmin', 'admin') ? '' : 'none';
    }
    document.getElementById('nav-system').style.display = can('superadmin', 'admin', 'ops') ? '' : 'none';
    document.getElementById('nav-security').style.display = can('superadmin', 'admin') ? '' : 'none';
    document.getElementById('sidebar-avatar').textContent =
      state.user.username.slice(0, 2).toUpperCase();
    document.getElementById('sidebar-username').textContent = state.user.username;
    document.getElementById('sidebar-role').textContent     = state.user.role;
    // Show admin-users section only for superadmins
    document.getElementById('admin-users-section').style.display =
      state.user.role === 'superadmin' ? '' : 'none';
  }
}

// ── Login form ────────────────────────────────────────────────────────────────

document.getElementById('login-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = document.getElementById('login-btn');
  btn.disabled = true;
  btn.textContent = 'Signing in…';
  document.getElementById('login-error').style.display = 'none';

  const res = await post('admin_panel_login', {
    username: document.getElementById('inp-username').value,
    password: document.getElementById('inp-password').value,
  }).catch(err => ({ ok: false, error: err.message }));

  btn.disabled = false;
  btn.textContent = 'Sign in';

  if (!res.ok) {
    const el = document.getElementById('login-error');
    el.textContent = res.error || 'Login failed.';
    el.style.display = '';
    return;
  }

  document.getElementById('inp-password').value = '';
  if (res.requires_2fa_enrollment) {
    showAuth('enroll');
    return;
  }
  if (res.requires_2fa) {
    showAuth('2fa');
    return;
  }

  await enterApp();
});

// ── 2FA form ──────────────────────────────────────────────────────────────────

document.getElementById('totp-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = document.getElementById('totp-btn');
  btn.disabled = true;
  btn.textContent = 'Verifying…';
  document.getElementById('totp-error').style.display = 'none';

  const res = await post('admin_panel_verify_2fa', {
    code: document.getElementById('inp-totp').value,
  }).catch(err => ({ ok: false, error: err.message }));

  btn.disabled = false;
  btn.textContent = 'Verify';

  if (!res.ok) {
    const el = document.getElementById('totp-error');
    el.textContent = res.error || 'Verification failed.';
    el.style.display = '';
    return;
  }

  document.getElementById('inp-totp').value = '';
  await enterApp();
});

document.getElementById('back-to-login-btn').addEventListener('click', () => {
  post('admin_panel_logout');
  showAuth('login');
});

// ── Mandatory 2FA enrolment ───────────────────────────────────────────────────

function showEnrollError(message) {
  const el = document.getElementById('enroll-error');
  el.textContent = message;
  el.style.display = message ? '' : 'none';
}

function resetEnrollCard() {
  document.getElementById('enroll-start-form').style.display = '';
  document.getElementById('enroll-confirm-form').style.display = 'none';
  document.getElementById('enroll-secret').textContent = '';
  document.getElementById('inp-enroll-password').value = '';
  document.getElementById('inp-enroll-code').value = '';
  showEnrollError('');
}

document.getElementById('enroll-start-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = document.getElementById('enroll-start-btn');
  btn.disabled = true;
  showEnrollError('');
  const res = await post('admin_panel_setup_totp', {
    password: document.getElementById('inp-enroll-password').value,
  }).catch(err => ({ ok: false, error: err.message }));
  btn.disabled = false;
  document.getElementById('inp-enroll-password').value = '';
  if (!res.ok) { showEnrollError(res.error || 'Could not start setup.'); return; }
  document.getElementById('enroll-secret').textContent = res.secret;
  document.getElementById('enroll-start-form').style.display = 'none';
  document.getElementById('enroll-confirm-form').style.display = '';
  document.getElementById('inp-enroll-code').focus();
});

document.getElementById('enroll-confirm-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = document.getElementById('enroll-confirm-btn');
  btn.disabled = true;
  showEnrollError('');
  const res = await post('admin_panel_confirm_totp', {
    code: document.getElementById('inp-enroll-code').value.trim(),
  }).catch(err => ({ ok: false, error: err.message }));
  btn.disabled = false;
  if (!res.ok) {
    if (res.code === 'totp_setup_expired') resetEnrollCard();
    showEnrollError(res.error || 'Invalid code.');
    return;
  }
  document.getElementById('enroll-secret').textContent = '';
  toast('2FA enabled', 'success');
  await enterApp();
});

document.getElementById('enroll-back-btn').addEventListener('click', () => {
  post('admin_panel_logout');
  showAuth('login');
});

// ── Logout ────────────────────────────────────────────────────────────────────

document.getElementById('logout-btn').addEventListener('click', async () => {
  await post('admin_panel_logout');
  state.user = null;
  document.getElementById('app').style.display = 'none';
  showAuth('login');
  toast('Signed out', 'info');
});

// ── Sidebar navigation ────────────────────────────────────────────────────────

document.querySelectorAll('.nav-item[data-view]').forEach(el => {
  el.addEventListener('click', () => navigate(el.dataset.view));
});

// ── Incident badge poll ───────────────────────────────────────────────────────

// The topbar pill reflects open incidents; it is not a live health check.
function renderIncidentStatus(count) {
  const pill = document.getElementById('topbar-status');
  if (!pill) return;
  pill.classList.toggle('alert', count > 0);
  pill.querySelector('.topbar-pill-text').textContent =
    count > 0 ? `${count} open incident${count === 1 ? '' : 's'}` : 'No open incidents';
}

document.getElementById('topbar-status').addEventListener('click', () => navigate('incidents'));

async function pollIncidents() {
  if (!state.user) return;
  const res = await get('admin_panel_incidents', { status: 'open', limit: 1 }).catch(() => null);
  if (!res?.ok) return;
  const count = res.total ?? 0;
  state.openIncidentCount = count;
  const badge = document.querySelector('#nav-incidents .nav-badge');
  const navEl  = document.getElementById('nav-incidents');
  if (count > 0) {
    if (!badge) {
      navEl.insertAdjacentHTML('beforeend', `<span class="nav-badge">${count}</span>`);
    } else {
      badge.textContent = count;
    }
  } else if (badge) {
    badge.remove();
  }
  renderIncidentStatus(count);
  setTimeout(pollIncidents, 60_000);
}

// ── View: Dashboard ───────────────────────────────────────────────────────────

// Anonymous selections from deletion requests, not completed deletions.
function renderFeatureUsage(usage) {
  const labels = [
    ['trip_export_pdf', 'Trip export, PDF'],
    ['trip_export_csv', 'Trip export, CSV'],
    ['year_summary_view', 'Year summary'],
    ['receipt_upload', 'Receipt upload'],
    ['travel_map_open', 'Travel map'],
    ['travel_place_save', 'Travel visit saved'],
    ['live_location_start', 'Live location started'],
    ['random_pick', 'Random picker'],
    ['analytics_open', 'Analytics'],
  ];
  const months = usage?.available === true && Array.isArray(usage.months) ? usage.months : [];
  const count = (month, feature) => {
    const value = month?.counts?.find?.(row => row.feature === feature)?.count;
    return Number.isSafeInteger(value) && value > 0 ? value : 0;
  };
  const body = usage?.available !== true
    ? '<div class="empty-state" role="status">Usage totals are unavailable. Check the feature usage migration.</div>'
    : !months.length
      ? '<div class="empty-state" role="status">No feature use counted yet.</div>'
      : `<div class="table-wrap feature-usage-table"><table>
          <thead><tr><th scope="col">Feature</th>${months.map(month => `<th scope="col">${esc(month.month)}</th>`).join('')}</tr></thead>
          <tbody>${labels.map(([feature, label]) => `<tr><th scope="row">${esc(label)}</th>${months.map(month => `<td>${count(month, feature)}</td>`).join('')}</tr>`).join('')}</tbody>
        </table></div>
        <p class="deletion-note">Monthly totals of uses, not people. They include our own testing. Don't share numbers below 5 outside this panel.</p>`;
  return `<section class="table-card feature-usage" aria-labelledby="feature-usage-title">
    <div class="table-card-header">
      <div class="table-card-title" id="feature-usage-title">Feature usage</div>
      <span class="deletion-period">Last ${months.length || 0} months</span>
    </div>
    ${body}
  </section>`;
}

function renderDeletionFeedback(feedback) {
  const definitions = [
    ['not_using', 'No longer needed for trips', '#00BED4'],
    ['another_way', 'Using another way to split expenses', '#DD2684'],
    ['too_complicated', 'Too complicated to use', '#A58AE5'],
    ['technical_issue', 'Bugs or technical issues', '#F0AC57'],
    ['privacy', 'Wants account details removed', '#57B487'],
    ['other', 'Another reason', '#8294AE'],
  ];
  const available = feedback?.available === true && Array.isArray(feedback.reasons);
  const rows = definitions.map(([code, label, color]) => {
    const value = feedback?.reasons?.find?.(row => row.code === code)?.count;
    return {code, label, color, count: Number.isSafeInteger(value) && value > 0 ? value : 0};
  });
  const total = rows.reduce((sum, row) => sum + row.count, 0);
  let offset = 0;
  const segments = total ? rows.filter(row => row.count).map(row => {
    const portion = row.count / total * 100;
    const circle = `<circle cx="60" cy="60" r="46" pathLength="100" fill="none"
      stroke="${row.color}" stroke-width="16" stroke-dasharray="${portion} ${100 - portion}"
      stroke-dashoffset="${-offset}" transform="rotate(-90 60 60)"/>`;
    offset += portion;
    return circle;
  }).join('') : '';
  return `<section class="table-card deletion-feedback" aria-labelledby="deletion-feedback-title">
    <div class="table-card-header">
      <div class="table-card-title" id="deletion-feedback-title">Account deletion reasons</div>
      <span class="deletion-period">All time</span>
    </div>
    ${!available ? '<div class="empty-state" role="status">Reason statistics are unavailable. Check the feedback migration and try refreshing.</div>' : `
      <div class="deletion-feedback-body">
        <div class="deletion-donut" aria-hidden="true">
          <svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="46" fill="none" stroke="var(--border)" stroke-width="16"/>${segments}</svg>
          <div class="deletion-donut-total"><strong>${total.toLocaleString('en')}</strong><span>selections</span></div>
        </div>
        <ul class="deletion-legend">
          ${rows.map(row => `<li><svg width="10" height="10" aria-hidden="true"><circle cx="5" cy="5" r="5" fill="${row.color}"/></svg>
            <span>${row.label}</span><strong>${row.count.toLocaleString('en')}</strong>
            <span class="deletion-percent">${total ? (row.count / total * 100).toFixed(1) : '0.0'}%</span></li>`).join('')}
        </ul>
      </div>
      ${!total ? '<p class="deletion-empty" role="status">No reasons collected yet.</p>' : ''}
      <p class="deletion-note">Anonymous selections from deletion requests. Multiple reasons are allowed; these are not confirmed deletions.</p>
    `}
  </section>`;
}

// Last 30 days, one small column chart per measure (different scales, so never one shared axis).
const GROWTH_SERIES = [
  { key: 'signups', title: 'Sign-ups', total: true },
  { key: 'active', title: 'Active users', total: false },
  { key: 'trips', title: 'New trips', total: true },
];

function growthDay(date) {
  const d = new Date(date + 'T00:00:00Z');
  return d.toLocaleDateString('lv-LV', { day: '2-digit', month: '2-digit', timeZone: 'UTC' });
}

function renderGrowthChart(days, { key, title, total }) {
  const values = days.map(d => Number(d[key]) || 0);
  const max = Math.max(...values, 0);
  const sum = values.reduce((a, b) => a + b, 0);
  const today = values[values.length - 1] ?? 0;
  const headline = total ? `${sum}<span class="growth-unit">in 30 days</span>`
    : `${today}<span class="growth-unit">today · peak ${max}</span>`;
  const cols = days.map((d, i) => {
    const v = values[i];
    const h = max ? Math.max(v ? 4 : 0, Math.round((v / max) * 100)) : 0;
    return `<div class="growth-col" data-tip="${esc(growthDay(d.date))} · ${v} ${esc(title.toLowerCase())}">
      <div class="growth-bar" style="height:${h}%"></div></div>`;
  }).join('');
  const rows = days.map((d, i) => `<tr><td>${esc(d.date)}</td><td>${values[i]}</td></tr>`).join('');
  return `
    <div class="growth-chart">
      <div class="growth-title">${esc(title)}</div>
      <div class="growth-value">${headline}</div>
      <div class="growth-plot" role="img" aria-label="${esc(title)} per day for the last 30 days, maximum ${max}">
        <span class="growth-max">${max}</span>${cols}
      </div>
      <div class="growth-axis"><span>${esc(growthDay(days[0].date))}</span><span>${esc(growthDay(days[days.length - 1].date))}</span></div>
      <details class="growth-table"><summary>Table</summary>
        <table><thead><tr><th>Date</th><th>${esc(title)}</th></tr></thead><tbody>${rows}</tbody></table>
      </details>
    </div>`;
}

function renderGrowth(days) {
  if (!Array.isArray(days) || !days.length) return '';
  return `
    <div class="table-card growth-card">
      <div class="table-card-header"><div class="table-card-title">📈 Last 30 days</div></div>
      <div class="growth-grid">${GROWTH_SERIES.map(series => renderGrowthChart(days, series)).join('')}</div>
    </div>`;
}

// One shared tooltip for chart columns: pointer hover anywhere in the column's full height.
(function growthTooltip() {
  const tip = document.createElement('div');
  tip.className = 'chart-tip';
  tip.hidden = true;
  document.body.appendChild(tip);
  document.addEventListener('pointerover', e => {
    const col = e.target.closest?.('[data-tip]');
    if (!col) { tip.hidden = true; return; }
    tip.textContent = col.dataset.tip;
    tip.hidden = false;
    const r = col.getBoundingClientRect();
    const w = tip.offsetWidth;
    tip.style.left = `${Math.min(window.innerWidth - w - 8, Math.max(8, r.left + r.width / 2 - w / 2))}px`;
    tip.style.top = `${Math.max(8, r.top - tip.offsetHeight - 6)}px`;
  });
  document.addEventListener('scroll', () => { tip.hidden = true; }, true);
})();

registerView('dashboard', {
  title: 'Dashboard',
  async render() {
    const [dashRes, auditRes, appEventsRes] = await Promise.all([
      get('admin_panel_dashboard'),
      get('admin_panel_audit_log', { limit: 6, offset: 0 }),
      get('admin_panel_app_events', { limit: 8, offset: 0 }),
    ]);
    if (!dashRes.ok) return `<div class="empty-state">Failed to load stats.</div>`;
    const s  = dashRes.stats || {};
    const pq = s.push_queue || {};

    const incidentCards = (s.recent_incidents || []).map(inc => `
      <div class="data-row" ${actionAttrs('navigate', 'incidents')} style="cursor:pointer">
        <div class="data-row-top">
          <span class="inc-dot ${esc(inc.severity)}"></span>
          <span class="data-row-title">${esc(inc.title)}</span>
          ${sevBadge(inc.severity)}
          ${statusBadge(inc.status)}
        </div>
        <div class="data-row-meta">
          <span>${esc(inc.admin_username)}</span>
          <span>·</span>
          <span>${relTime(inc.created_at)}</span>
        </div>
      </div>
    `).join('');

    // Push health mini cards (dashboard returns plain numbers per status)
    const pushSent    = (pq.sent    ?? 0);
    const pushPending = (pq.pending ?? 0);
    const pushFailed  = (pq.failed  ?? 0);
    const pushDead    = (pq.dead    ?? 0);

    // App events activity feed
    const appEventColor = type => type.includes('delete') || type.includes('deleted') ? 'var(--red)'
      : type.startsWith('user.login') || type.startsWith('user.register') ? 'var(--green)'
      : type.startsWith('trip.') ? 'var(--blue)'
      : type.startsWith('expense.') ? 'var(--amber)'
      : type.startsWith('settlement.') ? 'var(--purple, #a78bfa)'
      : 'var(--fg-muted)';

    const appEventIcon = type => type.startsWith('user.login') ? '🔐'
      : type.startsWith('user.register') ? '🆕'
      : type.startsWith('trip.') ? '✈️'
      : type.startsWith('expense.') ? '💸'
      : type.startsWith('settlement.') ? '💰'
      : type.startsWith('friend.') ? '🤝'
      : '⚡';

    const appItems = (appEventsRes.ok ? (appEventsRes.events || []) : []).map(entry => {
      const color = appEventColor(entry.event_type);
      return `
        <div class="activity-item">
          <div class="activity-dot" style="background:${color}"></div>
          <div style="flex:1;min-width:0">
            <div class="activity-text">
              <span style="margin-right:4px">${appEventIcon(entry.event_type)}</span>
              <strong>${esc(entry.username || '—')}</strong> — <span style="font-family:monospace;font-size:11.5px;color:var(--fg-dim)">${esc(entry.event_type)}</span>
              ${entry.entity_id ? `<span style="color:var(--fg-muted)"> #${esc(entry.entity_id)}</span>` : ''}
            </div>
            <div class="activity-time">${relTime(entry.created_at)}</div>
          </div>
        </div>
      `;
    }).join('') || '<div style="padding:20px 18px;color:var(--fg-muted);font-size:13px">No recent activity</div>';

    return `
      <!-- Stats -->
      <div class="stats-grid">
        <div class="stat-card green">
          <div class="stat-label">Total users</div>
          <div class="stat-value">${(s.total_users ?? 0)}</div>
          <div class="stat-sub">+${s.new_users_7d ?? 0} this week</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Active users</div>
          <div class="stat-value">${(s.active_users ?? 0)}</div>
          <div class="stat-sub">${s.total_users ? Math.round((s.active_users/s.total_users)*100) : 0}% of total</div>
        </div>
        <div class="stat-card blue">
          <div class="stat-label">Total trips</div>
          <div class="stat-value">${(s.total_trips ?? 0)}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Expenses</div>
          <div class="stat-value">${(s.total_expenses ?? 0)}</div>
        </div>
        <div class="stat-card ${pushFailed + pushDead > 0 ? 'amber' : ''}">
          <div class="stat-label">Push pending</div>
          <div class="stat-value">${pushPending}</div>
          <div class="stat-sub" style="${pushFailed > 0 ? 'color:var(--red)' : ''}">${pushFailed} failed · ${pushDead} dead</div>
        </div>
        <div class="stat-card ${(s.open_incidents ?? 0) > 0 ? 'red' : ''}">
          <div class="stat-label">Open incidents</div>
          <div class="stat-value">${s.open_incidents ?? 0}</div>
        </div>
      </div>

      ${renderGrowth(s.growth)}

      <!-- Two-col grid -->
      <div class="dashboard-grid">

        <!-- Left: deletion feedback + incidents + activity -->
        <div>
          ${renderDeletionFeedback(s.account_deletion_feedback)}
          ${renderFeatureUsage(s.feature_usage)}
          <div class="table-card">
            <div class="table-card-header">
              <div class="table-card-title">🚨 Open Incidents</div>
              <span class="table-card-link" ${actionAttrs('navigate', 'incidents')}>View all →</span>
            </div>
            ${incidentCards || '<div class="empty-state" style="padding:24px">No open incidents — all clear ✓</div>'}
          </div>

          <div class="table-card dashboard-audit-table">
            <div class="table-card-header">
              <div class="table-card-title">⚡ Recent Activity</div>
              <span class="table-card-link" ${actionAttrs('navigate', 'app-events')}>View all →</span>
            </div>
            ${appEventsRes.ok && appEventsRes.events.length ? `
            <table>
              <thead><tr><th>Event</th><th>User</th><th>Entity</th><th>Time</th></tr></thead>
              <tbody>
                ${appEventsRes.events.map(e => `
                  <tr>
                    <td style="font-family:monospace;font-size:12px;color:${e.event_type.includes('delete')?'var(--red)':e.event_type.startsWith('user.')?'var(--green-soft)':e.event_type.startsWith('trip.')?'var(--blue)':e.event_type.startsWith('expense.')?'var(--amber)':'var(--fg-dim)'}">${esc(e.event_type)}</td>
                    <td style="color:var(--fg-muted)">${esc(e.username || '—')}</td>
                    <td style="color:var(--fg-muted)">${esc(e.entity_type ?? '')}${e.entity_id ? ` #${esc(e.entity_id)}` : ''}</td>
                    <td style="color:var(--fg-muted);font-size:12px">${relTime(e.created_at)}</td>
                  </tr>`).join('')}
              </tbody>
            </table>` : '<div class="empty-state" style="padding:24px">No recent activity yet</div>'}
          </div>
        </div>

        <!-- Right: push health + audit -->
        <div>
          <div class="push-health-card">
            <div class="push-health-header">🔔 Push Queue Health</div>
            <div class="push-mini-grid">
              <div class="push-mini">
                <div class="push-mini-label">Pending</div>
                <div class="push-mini-val" style="color:${pushPending>0?'var(--amber)':'var(--fg-dim)'}">${pushPending}</div>
              </div>
              <div class="push-mini">
                <div class="push-mini-label">Sent</div>
                <div class="push-mini-val" style="color:var(--green-soft)">${pushSent}</div>
              </div>
              <div class="push-mini">
                <div class="push-mini-label">Failed</div>
                <div class="push-mini-val" style="color:${pushFailed>0?'var(--red)':'var(--fg-muted)'}">${pushFailed}</div>
              </div>
              <div class="push-mini">
                <div class="push-mini-label">Dead</div>
                <div class="push-mini-val" style="color:${pushDead>0?'var(--red)':'var(--fg-muted)'}">${pushDead}</div>
              </div>
            </div>
          </div>

          <div class="activity-card">
            <div class="activity-header" style="display:flex;justify-content:space-between;align-items:center">
              <span>📋 Recent Audit</span>
              <span class="table-card-link" ${actionAttrs('navigate', 'audit-log')}>View all →</span>
            </div>
            ${(auditRes.ok ? (auditRes.log || []) : []).map(entry => {
              const color = entry.action.includes('delete') ? 'var(--red)'
                : entry.action.includes('suspend') || entry.action.includes('disable') ? 'var(--amber)'
                : 'var(--green)';
              return `
                <div class="activity-item">
                  <div class="activity-dot" style="background:${color}"></div>
                  <div style="flex:1;min-width:0">
                    <div class="activity-text">
                      <strong>${esc(entry.admin_username)}</strong> — <span style="font-family:monospace;font-size:11.5px;color:var(--fg-dim)">${esc(entry.action)}</span>
                      ${entry.target_id ? `<span style="color:var(--fg-muted)"> #${esc(entry.target_id)}</span>` : ''}
                    </div>
                    <div class="activity-time">${relTime(entry.created_at)}</div>
                  </div>
                </div>
              `;
            }).join('') || '<div style="padding:20px 18px;color:var(--fg-muted);font-size:13px">No recent audit</div>'}
          </div>
        </div>

      </div><!-- /dashboard-grid -->
    `;
  },
});

// ── View: Users ───────────────────────────────────────────────────────────────

// Remembered per browser; falls back to the list when storage is unavailable.
function usersLayout() {
  try { return localStorage.getItem('splyto-admin-users-layout') === 'grid' ? 'grid' : 'list'; } catch { return 'list'; }
}

function setUsersLayout(layout) {
  try { localStorage.setItem('splyto-admin-users-layout', layout); } catch { /* private mode */ }
  for (const btn of document.querySelectorAll('[data-users-layout]')) {
    btn.setAttribute('aria-pressed', String(btn.dataset.usersLayout === layout));
  }
  userSearch(usersState.offset);
}

const usersState = { offset: 0 };

registerView('users', {
  title: 'Users',
  async render() {
    const layout = usersLayout();
    const option = (value, label) => `<option value="${value}">${label}</option>`;
    return `
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="user-search-inp" placeholder="Search by name or email…" aria-label="Search users"/>
        </div>
        <button class="btn btn-ghost btn-sm" id="user-search-btn">Search</button>
        <div class="segmented" role="group" aria-label="Layout">
          <button type="button" class="segmented-btn" data-users-layout="list" aria-pressed="${layout === 'list'}">☰ List</button>
          <button type="button" class="segmented-btn" data-users-layout="grid" aria-pressed="${layout === 'grid'}">▦ Grid</button>
        </div>
      </div>
      <div class="toolbar filter-row">
        <select class="form-input" id="user-status-filter" aria-label="Status">
          ${option('all', 'All statuses')}${option('active', 'Active')}${option('deactivated', 'Suspended')}${option('deleted', 'Deleted')}
        </select>
        <select class="form-input" id="user-platform-filter" aria-label="Platform">
          ${option('', 'All platforms')}${option('ios', 'iOS')}${option('android', 'Android')}
        </select>
        <select class="form-input" id="user-signin-filter" aria-label="Sign-in method">
          ${option('', 'Any sign-in')}${option('email', 'Email')}${option('apple', 'Apple')}${option('google', 'Google')}
        </select>
        <select class="form-input" id="user-sort" aria-label="Sort">
          ${option('newest', 'Newest first')}${option('last_active', 'Last active')}${option('trips', 'Most trips')}${option('oldest', 'Oldest first')}
        </select>
        <label class="check-chip"><input type="checkbox" id="user-premium-filter"/> Premium</label>
        <label class="check-chip"><input type="checkbox" id="user-unverified-filter"/> Email not verified</label>
      </div>
      <div id="user-results"><div class="loading-state"><span class="spinner"></span></div></div>
    `;
  },
  init() {
    const doSearch = () => userSearch(0);
    document.getElementById('user-search-btn').addEventListener('click', doSearch);
    for (const id of ['user-status-filter', 'user-platform-filter', 'user-signin-filter', 'user-sort',
      'user-premium-filter', 'user-unverified-filter']) {
      document.getElementById(id).addEventListener('change', doSearch);
    }
    for (const btn of document.querySelectorAll('[data-users-layout]')) {
      btn.addEventListener('click', () => setUsersLayout(btn.dataset.usersLayout));
    }
    document.getElementById('user-search-inp').addEventListener('keydown', e => {
      if (e.key === 'Enter') doSearch();
    });
    // Newest sign-ups first, so new or suspicious accounts are visible without searching.
    doSearch();
  },
});

function userSearchQuery(offset) {
  const value = id => document.getElementById(id).value;
  const query = { q: value('user-search-inp').trim(), status: value('user-status-filter'),
    sort: value('user-sort'), limit: 40, offset };
  if (value('user-platform-filter')) query.platform = value('user-platform-filter');
  if (value('user-signin-filter')) query.sign_in = value('user-signin-filter');
  if (document.getElementById('user-premium-filter').checked) query.premium = 1;
  if (document.getElementById('user-unverified-filter').checked) query.unverified = 1;
  return query;
}

function userInitials(name) {
  const parts = String(name || '?').trim().split(/\s+/).filter(Boolean);
  return ((parts[0]?.[0] || '?') + (parts.length > 1 ? parts[parts.length - 1][0] : '')).toUpperCase();
}

// Stable colour per user id, so the same person keeps the same avatar colour.
function userAvatarHue(id) {
  return (Number(id) * 47) % 360;
}

function userActions(u) {
  const actions = [`<button class="btn btn-ghost btn-sm" ${actionAttrs('openUserDetail', u.id)}>View</button>`];
  if (u.account_status === 'active' && can('superadmin', 'admin', 'support'))
    actions.push(`<button class="btn btn-amber btn-sm" ${actionAttrs('suspendUser', u.id, u.nickname)}>Suspend</button>`);
  if (u.account_status === 'deactivated' && can('superadmin', 'admin', 'support'))
    actions.push(`<button class="btn btn-ghost btn-sm" ${actionAttrs('reactivateUser', u.id, u.nickname)}>Reactivate</button>`);
  return actions.join('');
}

function userFacts(u, premiumForEveryone) {
  const trips = `${u.trips_count} trip${u.trips_count === 1 ? '' : 's'}`;
  const premium = u.premium_grant ? '<span class="badge badge-green">Premium</span>'
    : premiumForEveryone && u.account_status === 'active' ? '<span class="badge badge-gray">Premium (launch)</span>' : '';
  const active = u.last_active_at ? `Active ${relTime(u.last_active_at)}` : 'No session use';
  return `<span>${trips}</span><span>·</span><span title="Last session use">${active}</span>`
    + `<span>·</span><span>Joined ${relTime(u.created_at)}</span>${premium}`;
}

function userListItem(u, premiumForEveryone) {
  return `
    <div class="cl-item">
      <div class="cl-row" style="margin-bottom:6px">
        <span class="user-avatar" style="--hue:${userAvatarHue(u.id)}" aria-hidden="true">${esc(userInitials(u.nickname))}</span>
        <div style="flex:1;min-width:0">
          <div class="cl-title">${esc(u.nickname)}</div>
          <div class="cl-sub">${esc(u.email || '—')}</div>
        </div>
        ${statusBadge(u.account_status)}
      </div>
      <div class="user-signals">${userSignalBadges(u)}</div>
      <div class="user-facts">${userFacts(u, premiumForEveryone)}</div>
      <div class="cl-actions">${userActions(u)}</div>
    </div>`;
}

function userGridCard(u, premiumForEveryone) {
  return `
    <article class="user-card">
      <div class="user-card-head">
        <span class="user-avatar large" style="--hue:${userAvatarHue(u.id)}" aria-hidden="true">${esc(userInitials(u.nickname))}</span>
        ${statusBadge(u.account_status)}
      </div>
      <div class="cl-title">${esc(u.nickname)}</div>
      <div class="cl-sub">${esc(u.email || '—')}</div>
      <div class="user-signals">${userSignalBadges(u)}</div>
      <div class="user-facts">${userFacts(u, premiumForEveryone)}</div>
      <div class="cl-actions">${userActions(u)}</div>
    </article>`;
}

async function userSearch(offset = 0) {
  usersState.offset = offset;
  const results = document.getElementById('user-results');
  if (!results) return;
  results.innerHTML = '<div class="loading-state"><span class="spinner"></span></div>';

  const res = await get('admin_panel_user_search', userSearchQuery(offset));
  if (!res.ok) { results.innerHTML = `<div class="empty-state">Error: ${esc(res.error)}</div>`; return; }
  if (!res.users.length) { results.innerHTML = '<div class="empty-state">No users found.</div>'; return; }

  const everyone = Boolean(res.premium_for_everyone);
  const body = usersLayout() === 'grid'
    ? `<div class="user-grid">${res.users.map(u => userGridCard(u, everyone)).join('')}</div>`
    : `<div class="table-card" style="padding:0">${res.users.map(u => userListItem(u, everyone)).join('')}</div>`;

  const prevBtn = offset > 0
    ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('userSearch', offset - 40)}>← Prev</button>` : '';
  const nextBtn = (offset + 40) < res.total
    ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('userSearch', offset + 40)}>Next →</button>` : '';

  results.innerHTML = `${body}
    <div class="pagination">
      Showing ${offset + 1}–${Math.min(offset + 40, res.total)} of ${res.total}
      ${prevBtn} ${nextBtn}
    </div>`;
}

const SIGN_IN_LABELS = { email: 'Email', apple: 'Apple', google: 'Google' };
const PLATFORM_LABELS = { ios: 'iOS', android: 'Android', web: 'Web' };

// How the account signs in, which apps registered for push, and email verification.
function userSignalBadges(u) {
  const methods = (u.sign_in_methods || []).map(m => `<span class="badge badge-blue">${esc(SIGN_IN_LABELS[m] || m)}</span>`);
  const platforms = (u.platforms || []).map(p => `<span class="badge badge-purple">${esc(PLATFORM_LABELS[p] || p)}</span>`);
  const parts = [...methods, ...platforms];
  if (!methods.length) parts.push('<span class="badge badge-gray">No sign-in</span>');
  if (!platforms.length) parts.push('<span class="badge badge-gray">No app push</span>');
  if (u.email_verified === false && u.email) parts.push('<span class="badge badge-amber">Email not verified</span>');
  return parts.join('');
}

async function openUserDetail(userId) {
  modal.open('User detail', '<div class="loading-state"><span class="spinner"></span> Loading…</div>', '');
  const res = await get('admin_panel_user_detail', { user_id: userId });
  if (!res.ok) { modal.open('Error', `<div class="empty-state">${esc(res.error)}</div>`); return; }

  const u  = res.user;
  const tripGrants = res.premium?.trip_grants || [];
  const canManageTrips = Boolean(res.premium?.can_manage);
  const trips = (res.trips || []).map(t => {
    const grant = tripGrants.find(g => Number(g.trip_id) === Number(t.id));
    const button = !canManageTrips ? '' : grant
      ? `<button class="btn btn-danger btn-sm" ${actionAttrs('openPremiumForm', 'trip_grant_revoke', u.id, grant.id)}>Revoke trip Premium</button>`
      : `<button class="btn btn-ghost btn-sm" ${actionAttrs('openPremiumForm', 'trip_grant_create', u.id, t.id)}>Grant trip Premium</button>`;
    const members = Number(t.members_count) || 0;
    return `<div class="detail-row"><span><span>${esc(t.name)}</span> <span class="muted-inline">· ${members} member${members === 1 ? '' : 's'}</span></span><span class="trip-premium-row">
      <span class="badge badge-gray">${esc(t.status)}</span>${grant ? '<span class="badge">Trip Premium</span>' : ''}${button}</span></div>`;
  }).join('') || '<div class="empty-state" style="padding:8px">No trips</div>';

  const actions = [];
  if (u.account_status === 'active' && can('superadmin','admin','support'))
    actions.push(`<button class="btn btn-amber btn-sm" data-close-modal ${actionAttrs('suspendUser', u.id, u.nickname)}>Suspend</button>`);
  if (u.account_status === 'deactivated' && can('superadmin','admin','support'))
    actions.push(`<button class="btn btn-ghost btn-sm" data-close-modal ${actionAttrs('reactivateUser', u.id, u.nickname)}>Reactivate</button>`);
  if (can('superadmin','admin','support'))
    actions.push(`<button class="btn btn-ghost btn-sm" data-close-modal ${actionAttrs('clearPushTokens', u.id)}>Clear push tokens</button>`);
  if (can('superadmin','admin','support') && (res.sessions || []).length)
    actions.push(`<button class="btn btn-amber btn-sm" data-close-modal ${actionAttrs('signOutEverywhere', u.id, u.nickname)}>Sign out everywhere</button>`);
  if (can('superadmin','admin'))
    actions.push(`<button class="btn btn-danger btn-sm" data-close-modal ${actionAttrs('deleteUser', u.id, u.nickname)}>Delete user</button>`);

  modal.open('User: ' + u.nickname, `
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">${u.id}</span></div>
    <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value">${esc(u.email)}</span></div>
    <div class="detail-row"><span class="detail-label">Status</span><span class="detail-value">${statusBadge(u.account_status)}</span></div>
    <div class="detail-row"><span class="detail-label">Joined</span><span class="detail-value">${relTime(u.created_at)}</span></div>
    <div class="detail-row"><span class="detail-label">Unread notifs</span><span class="detail-value">${res.unread_notifs}</span></div>
    <div class="detail-row"><span class="detail-label">Sign-in &amp; apps</span><span class="detail-value user-signals">${userSignalBadges(u)}</span></div>
    <div class="detail-row"><span class="detail-label">Push tokens</span><span class="detail-value">${pushTokenSummary(res.push_tokens || [])}</span></div>
    <div style="margin-top:14px;font-size:12px;font-weight:700;color:var(--fg-muted);letter-spacing:0.3px;text-transform:uppercase;margin-bottom:6px;">Recent trips</div>
    ${trips}
    ${premiumDetailHtml(res.premium, u)}
    <div class="detail-section-title">Signed-in devices (${(res.sessions || []).length})</div>
    ${userSessionsHtml(res.sessions || [])}
    <div class="detail-section-title">Recent activity</div>
    ${userTimelineHtml(res.timeline || [])}
    <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:16px;">${actions.join('')}</div>
  `, `<button class="btn btn-ghost" ${actionAttrs('closeModal')}>Close</button>`);
}

// A short device name from the app's User-Agent; the raw string is the tooltip.
function deviceLabel(ua) {
  const text = String(ua || '');
  if (!text) return 'Unknown device';
  const os = /iPhone|iPad|iOS/i.test(text) ? 'iOS' : /Android/i.test(text) ? 'Android' : /Mac OS|Macintosh/i.test(text) ? 'Mac'
    : /Windows/i.test(text) ? 'Windows' : '';
  const app = /Splyto|Dart|okhttp|CFNetwork/i.test(text) ? 'App' : 'Browser';
  return os ? `${app} · ${os}` : app;
}

function userSessionsHtml(sessions) {
  if (!sessions.length) return '<div class="empty-state" style="padding:8px">No active sessions</div>';
  return sessions.map(s => `
    <div class="detail-row"><span title="${esc(s.user_agent)}">${esc(deviceLabel(s.user_agent))}</span>
      <span class="detail-value" style="margin-left:auto;text-align:right">used ${esc(relTime(s.last_used_at || s.created_at))} · since ${esc(relTime(s.created_at))}</span></div>`).join('');
}

function userTimelineHtml(events) {
  if (!events.length) return '<div class="empty-state" style="padding:8px">No recorded activity</div>';
  return `<div class="user-timeline">${events.map(e => `
    <div class="timeline-row">
      <span class="timeline-event">${esc(e.event_type)}</span>
      <span class="timeline-meta">${e.trip_name ? esc(e.trip_name) + ' · ' : ''}${esc(relTime(e.created_at))}</span>
    </div>`).join('')}</div>`;
}

async function signOutEverywhere(userId, name) {
  if (!await askInModal({ title: `Sign ${name} out everywhere?`, confirmLabel: 'Sign out', danger: true,
    message: 'Every app session ends now. The account stays active and the user can sign in again.' })) return;
  const res = await post('admin_panel_user_sign_out_everywhere', { user_id: userId });
  if (res.ok) toast(`${res.revoked} session(s) signed out`, 'success');
  else toast(res.error || 'Failed', 'error');
}

function pushTokenSummary(tokens) {
  if (!tokens.length) return '0';
  return tokens.map(t => `${esc(PLATFORM_LABELS[String(t.platform).toLowerCase()] || t.platform)}`
    + `${Number(t.is_active) === 1 ? '' : ' (inactive)'} · ${esc(relTime(t.last_seen_at))}`).join('<br>');
}

async function suspendUser(userId, name) {
  const reason = await askInModal({ title: `Suspend ${name}?`, confirmLabel: 'Suspend', danger: true,
    message: 'The user is signed out and cannot use the app until reactivated.',
    input: { label: 'Reason (optional)' } });
  if (reason === null) return;
  const res = await post('admin_panel_user_suspend', { user_id: userId, reason });
  if (res.ok) { toast(`${name} suspended`, 'success'); userSearch(); }
  else toast(res.error || 'Failed', 'error');
}

async function reactivateUser(userId, name) {
  const res = await post('admin_panel_user_reactivate', { user_id: userId, reason: 'admin action' });
  if (res.ok) { toast(`${name} reactivated`, 'success'); userSearch(); }
  else toast(res.error || 'Failed', 'error');
}

async function deleteUser(userId, name) {
  const reason = await askInModal({ title: `Delete ${name}?`, confirmLabel: 'Delete user', danger: true,
    message: 'This cannot be undone. Personal data, sign-in links, friends, sessions and push tokens are erased; shared trip history stays as "Deleted User".',
    input: { label: 'Reason', required: true } });
  if (!reason) return;
  const res = await post('admin_panel_user_delete', { user_id: userId, reason });
  if (res.ok) { toast(`${name} deleted`, 'success'); userSearch(); }
  else toast(res.error || 'Failed', 'error');
}

async function clearPushTokens(userId) {
  if (!await askInModal({ title: 'Clear push tokens?', confirmLabel: 'Clear',
    message: 'The user stops receiving push notifications until the app registers again.' })) return;
  const res = await post('admin_panel_clear_push_tokens', { user_id: userId });
  if (res.ok) toast(`Removed ${res.removed} push token(s)`, 'success');
  else toast(res.error || 'Failed', 'error');
}

// Expose existing public helpers for integrations.
Object.assign(window, { navigate, openUserDetail, suspendUser, reactivateUser, deleteUser, clearPushTokens, modal });

// Premium is an expiring, audited grant, independent from paid subscriptions.
function premiumDate(value) {
  if (!value) return '-';
  const date = new Date(value.includes('T') ? value : value.replace(' ', 'T') + 'Z');
  return Number.isNaN(date.getTime()) ? '-' : date.toLocaleString();
}

function premiumStatus(grant) {
  if (grant.revoked_at) return 'Revoked';
  if (new Date(grant.ends_at.replace(' ', 'T') + 'Z') <= new Date()) return 'Expired';
  return grant.account_status && grant.account_status !== 'active' ? 'Account inactive' : 'Active';
}

function premiumHistoryDates(event) {
  try {
    const before = JSON.parse(event.before_json || 'null');
    const after = JSON.parse(event.after_json || 'null');
    if (!after?.ends_at || event.action === 'grant_revoke') return '';
    return `<div>${before?.ends_at ? `${esc(premiumDate(before.ends_at))} &rarr; ` : 'Until '}${esc(premiumDate(after.ends_at))}</div>`;
  } catch { return ''; }
}

function premiumDetailHtml(premium, user) {
  if (!premium) return '';
  const access = premium.access || {};
  const title = access.plan === 'premium' ? `Premium until ${premiumDate(access.expires_at)}`
    : access.plan === 'free' ? 'Free' : 'Status unavailable';
  const controls = premium.can_manage && user.account_status === 'active';
  return `<section class="premium-section"><h3>${esc(title)}</h3>
    ${controls ? `<button class="btn btn-primary btn-sm" ${actionAttrs('openPremiumForm', 'grant_create', user.id)}>Grant Premium</button>` : ''}
    ${(premium.grants || []).map(g => `<div class="premium-entry">
      <div><strong>${esc(g.partner_name || g.source)}</strong> <span class="badge badge-gray">${esc(premiumStatus({...g, account_status: user.account_status}))}</span></div>
      <div>${esc(premiumDate(g.starts_at))} - ${esc(premiumDate(g.ends_at))}</div>
      <div>${esc(g.reason)}</div>
      ${premium.can_manage && !g.revoked_at ? `<div class="premium-actions">
        ${controls ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('openPremiumForm', 'grant_extend', user.id, g.id)}>Extend</button>` : ''}
        <button class="btn btn-danger btn-sm" ${actionAttrs('openPremiumForm', 'grant_revoke', user.id, g.id)}>Revoke</button></div>` : ''}
    </div>`).join('')}
    ${(premium.history || []).length ? `<details><summary>Premium history (latest 100)</summary>${premium.history.map(h =>
      `<div class="premium-entry"><strong>${esc(h.action.replace('grant_', ''))}</strong> &middot; ${esc(h.admin_username)}
      <div>${esc(premiumDate(h.created_at))}</div>${premiumHistoryDates(h)}<div>${esc(h.reason)}</div></div>`).join('')}</details>` : ''}
    ${!premium.can_manage && can('superadmin') ? '<p class="muted">Changes require enabled and verified two-factor authentication.</p>' : ''}
  </section>`;
}

for (const kind of ['premium', 'partners']) {
  registerView(kind, {
    title: kind === 'premium' ? 'Premium' : 'Partners',
    async render() {
      if (!can('superadmin', 'admin')) throw new Error('Access denied.');
      return `<div class="toolbar"><input class="form-input" id="premium-search" type="search" placeholder="Search ${kind}" aria-label="Search ${kind}">
        ${kind === 'premium' ? `<select class="form-input" id="premium-status" aria-label="Status"><option value="active">Active</option><option value="expiring">Expiring in 14 days</option><option value="expired">Expired</option><option value="revoked">Revoked</option><option value="all">All</option></select>` : ''}
        <button class="btn btn-ghost" id="premium-filter">Filter</button>
        ${kind === 'partners' ? '<button class="btn btn-primary" id="partner-create" hidden>Add partner</button>' : ''}</div>
        <div id="premium-results"></div>`;
    },
    init() {
      document.getElementById('premium-filter').addEventListener('click', () => premiumPage(0));
      document.getElementById('premium-search').addEventListener('keydown', e => { if (e.key === 'Enter') premiumPage(0); });
      document.getElementById('premium-status')?.addEventListener('change', () => premiumPage(0));
      document.getElementById('partner-create')?.addEventListener('click', () => openPremiumForm('partner_create'));
      premiumPage(0);
    },
  });
}

let premiumListSequence = 0;
async function premiumPage(offset = 0) {
  const sequence = ++premiumListSequence;
  const target = document.getElementById('premium-results');
  if (!target) return;
  const kind = state.view === 'partners' ? 'partners' : 'grants';
  const params = {kind, offset, q: document.getElementById('premium-search').value,
    status: document.getElementById('premium-status')?.value || 'all', partner_id: state.viewData.partnerId || ''};
  target.innerHTML = '<div class="loading-state">Loading...</div>';
  try {
    const result = await get('admin_panel_premium_list', params);
    if (sequence !== premiumListSequence || !target.isConnected) return;
    if (!result.ok) throw new Error(result.error || 'Unable to load Premium.');
    const create = document.getElementById('partner-create');
    if (create) create.hidden = !result.can_manage;
    target.innerHTML = `${params.partner_id ? `<p>Partner filter active <button class="btn btn-ghost btn-sm" ${actionAttrs('navigate', 'premium')}>Clear</button></p>` : ''}
      ${result.rows.length ? `<div class="table-wrap"><table><thead><tr>${kind === 'partners' ? '<th>Partner</th><th>Active grants</th><th></th>' : '<th>User</th><th>Partner / Source</th><th>Until</th><th>Status</th><th></th>'}</tr></thead><tbody>
      ${result.rows.map(r => kind === 'partners'
        ? `<tr><td>${esc(r.name)}</td><td>${Number(r.active_grants)}</td><td><button class="btn btn-ghost btn-sm" ${actionAttrs('navigate', 'premium', {partnerId:r.id})}>View grants</button></td></tr>`
        : `<tr><td>${esc(r.nickname)}</td><td>${esc(r.partner_name || r.source)}</td><td>${esc(premiumDate(r.ends_at))}</td><td>${esc(premiumStatus(r))}</td><td><button class="btn btn-ghost btn-sm" ${actionAttrs('openUserDetail', r.user_id)}>View user</button></td></tr>`).join('')}</tbody></table></div>`
        : '<div class="empty-state">No matching records</div>'}
      <div class="premium-actions"><button class="btn btn-ghost" ${offset === 0 ? 'disabled' : ''} ${actionAttrs('premiumPage', Math.max(0, offset - 40))}>Previous</button>
      <button class="btn btn-ghost" ${!result.has_more ? 'disabled' : ''} ${actionAttrs('premiumPage', offset + 40)}>Next</button></div>`;
  } catch (error) {
    if (target.isConnected && sequence === premiumListSequence) target.innerHTML = `<div class="empty-state">${esc(error.message)}</div>`;
  }
}

async function openPremiumForm(operation, userId = null, grantId = null) {
  const isPartner = operation === 'partner_create';
  const isTrip = operation === 'trip_grant_create' || operation === 'trip_grant_revoke';
  const isCreate = operation === 'grant_create';
  const needsDate = isCreate || operation === 'grant_extend';
  const result = isPartner ? await get('admin_panel_premium_list', {kind:'partners'})
    : await get('admin_panel_user_detail', {user_id:userId});
  const permission = isPartner ? result : result.premium;
  if (!result.ok || !permission?.can_manage) { toast(result.error || 'Verified 2FA is required.', 'error'); return; }
  const grant = (operation === 'trip_grant_revoke' ? permission.trip_grants : permission.grants)
    ?.find(g => Number(g.id) === Number(grantId));
  // For a new trip Premium, grantId is the trip's id.
  const trip = (result.trips || []).find(t => Number(t.id) === Number(operation === 'trip_grant_revoke' ? grant?.trip_id : grantId));
  if (!isPartner && !isCreate && operation !== 'trip_grant_create' && !grant) { toast('Grant not found. Reload the user.', 'error'); return; }
  if (isTrip && !trip) { toast('Trip not found. Reload the user.', 'error'); return; }
  const titles = {partner_create:'Add partner', grant_create:'Grant Premium', grant_extend:'Extend Premium', grant_revoke:'Revoke Premium',
    trip_grant_create:'Grant trip Premium', trip_grant_revoke:'Revoke trip Premium'};
  const title = titles[operation];
  modal.open(title, `<form id="premium-form" class="premium-form">
    ${isPartner ? '<label>Partner name<input class="form-input" name="name" required maxlength="120"></label>' : `<p><strong>${esc(result.user.nickname)}</strong> &middot; ${esc(result.user.email)}</p>`}
    ${isCreate ? `<label>Source<select class="form-input" name="source"><option value="testing">Testing</option><option value="partner">Partner</option><option value="compensation">Compensation</option></select></label>
      <label id="premium-partner-label" hidden>Partner<select class="form-input" name="partner_id" disabled><option value="">Select partner</option></select></label>` : ''}
    ${needsDate ? `<label>Expires (your local time)<input class="form-input" name="ends_at" type="datetime-local" required></label>` : ''}
    ${isTrip ? `<p>Trip: <strong>${esc(trip.name)}</strong>. Trip Premium covers every current member of this trip and has no end date.</p>` : ''}
    ${operation === 'trip_grant_create' ? `<label>Source<select class="form-input" name="source"><option value="testing">Testing</option><option value="compensation">Compensation</option></select></label>` : ''}
    ${operation === 'grant_revoke' ? '<p>This revokes only this grant. Other valid grants remain active.</p>' : ''}
    <label>Reason<textarea class="form-input" name="reason" required maxlength="500" rows="3"></textarea></label>
    <p id="premium-form-error" role="alert"></p>
    <div class="premium-actions"><button type="button" class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button><button type="submit" class="btn btn-primary">${esc(title)}</button></div>
  </form>`);
  const form = document.getElementById('premium-form');
  form.querySelector('[type="submit"]').disabled = true;
  if (needsDate) {
    const base = grant ? new Date(grant.ends_at.replace(' ', 'T') + 'Z').getTime() : Date.now();
    const end = new Date(Math.max(base, Date.now()) + 30 * 86400000);
    form.elements.ends_at.value = new Date(end.getTime() - end.getTimezoneOffset() * 60000).toISOString().slice(0,16);
  }
  if (isCreate) {
    form.elements.source.addEventListener('change', () => {
      const selected = form.elements.source.value === 'partner';
      form.querySelector('#premium-partner-label').hidden = !selected;
      form.elements.partner_id.disabled = !selected;
      form.elements.partner_id.required = selected;
    });
    // Paginate the partner selector instead of silently omitting partners after the first page.
    let offset = 0;
    try {
      do {
        const page = await get('admin_panel_premium_list', {kind:'partners', offset});
        if (!form.isConnected) return;
        if (!page.ok) throw new Error(page.error);
        for (const partner of page.rows) form.elements.partner_id.add(new Option(partner.name, partner.id));
        if (!page.has_more) break;
        offset += 40;
      } while (offset <= 100000);
    } catch {
      form.querySelector('#premium-form-error').textContent = 'Partners could not be loaded. Reopen this form to retry.';
    }
  }
  let requestId = crypto.randomUUID();
  let previousBody = null;
  form.addEventListener('submit', async event => {
    event.preventDefault();
    const button = form.querySelector('[type="submit"]');
    if (button.disabled) return;
    const body = {operation, reason:form.elements.reason.value.trim()};
    if (isPartner) body.name = form.elements.name.value.trim();
    else if (operation === 'trip_grant_create') { body.trip_id = Number(trip.id); body.source = form.elements.source.value; }
    else if (operation === 'trip_grant_revoke') { body.trip_grant_id = Number(grant.id); body.version = Number(grant.version); }
    else if (isCreate) {
      body.user_id = Number(userId);
      body.source = form.elements.source.value;
      if (body.source === 'partner') body.partner_id = Number(form.elements.partner_id.value);
    } else { body.grant_id = Number(grant.id); body.version = Number(grant.version); }
    if (needsDate) body.ends_at = new Date(form.elements.ends_at.value).toISOString().replace(/\.\d{3}Z$/, 'Z');
    const serialized = JSON.stringify(body);
    if (previousBody !== null && previousBody !== serialized) requestId = crypto.randomUUID();
    previousBody = serialized;
    body.request_id = requestId;
    button.disabled = true;
    form.querySelector('#premium-form-error').textContent = '';
    try {
      const response = await fetch(`${API}?action=admin_panel_premium_mutate`, {method:'POST', credentials:'include',
        headers:{'Content-Type':'application/json', 'X-Premium-CSRF':permission.csrf_token}, body:JSON.stringify(body)});
      const saved = await response.json();
      if (!saved.ok) throw new Error(saved.error || 'Change was not saved.');
      toast('Saved', 'success');
      if (form.isConnected) {
        modal.close();
        if (isPartner) premiumPage(0); else await openUserDetail(userId);
      }
    } catch (error) {
      if (form.isConnected) form.querySelector('#premium-form-error').textContent = error.message;
    } finally { button.disabled = false; }
  });
  form.querySelector('[type="submit"]').disabled = false;
}

// ── View: System health ──────────────────────────────────────────────────────

function formatBytes(bytes) {
  if (bytes === null || bytes === undefined) return '—';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  let value = Number(bytes);
  let unit = 0;
  while (value >= 1024 && unit < units.length - 1) { value /= 1024; unit += 1; }
  return `${value.toFixed(value >= 10 || unit === 0 ? 0 : 1)} ${units[unit]}`;
}

const JOB_STATE_LABELS = { ok: 'OK', stale: 'Late', failed: 'Failed', unknown: 'No data yet' };

function jobDetails(details) {
  const parts = Object.entries(details || {})
    .filter(([key, value]) => typeof value === 'number' && !['limit', 'interval_minutes', 'min_age_minutes'].includes(key))
    .map(([key, value]) => key.endsWith('_bytes') ? `${key.replace(/_bytes$/, '')} ${formatBytes(value)}` : `${key.replace(/_/g, ' ')} ${value}`);
  return parts.length ? parts.join(' · ') : '';
}

registerView('system', {
  title: 'System',
  async render() {
    const res = await get('admin_panel_system_health');
    if (!res.ok) return `<div class="empty-state">${esc(res.error || 'Failed to load system health.')}</div>`;
    const sys = res.system || {};
    const push = res.push || {};
    const jobs = res.jobs || [];
    const problems = jobs.filter(j => j.state === 'failed' || j.state === 'stale').length;
    const used = sys.disk_total_bytes && sys.disk_free_bytes !== null ? sys.disk_total_bytes - sys.disk_free_bytes : null;
    const usedPct = used !== null ? Math.round((used / sys.disk_total_bytes) * 100) : null;
    const oldestAge = push.oldest_pending_at ? relTime(push.oldest_pending_at) : '—';

    const jobRows = jobs.map(j => `
      <div class="cl-item">
        <div class="cl-row">
          <div style="flex:1;min-width:0">
            <div class="cl-title">${esc(j.label)}</div>
            <div class="cl-sub">${esc(j.schedule)}${j.last_run ? ` · last run ${esc(relTime(j.last_run))}` : ''}</div>
          </div>
          <span class="badge ${j.state === 'ok' ? 'badge-green' : j.state === 'failed' ? 'badge-red' : j.state === 'stale' ? 'badge-amber' : 'badge-gray'}">${esc(JOB_STATE_LABELS[j.state] || j.state)}</span>
        </div>
        ${jobDetails(j.details) ? `<div class="user-facts">${esc(jobDetails(j.details))}</div>` : ''}
      </div>`).join('');

    return `
      <div class="stats-grid">
        <div class="stat-card ${problems ? 'red' : 'green'}">
          <div class="stat-label">Scheduled jobs</div>
          <div class="stat-value">${problems ? `${problems} need attention` : 'All OK'}</div>
          <div class="stat-sub">${jobs.filter(j => j.state === 'unknown').length} without data yet</div>
        </div>
        <div class="stat-card ${usedPct !== null && usedPct >= 85 ? 'amber' : ''}">
          <div class="stat-label">Disk used</div>
          <div class="stat-value">${usedPct !== null ? `${usedPct}%` : '—'}</div>
          <div class="stat-sub">${formatBytes(sys.disk_free_bytes)} free of ${formatBytes(sys.disk_total_bytes)}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Database</div>
          <div class="stat-value">${formatBytes(sys.database_bytes)}</div>
          <div class="stat-sub">MySQL ${esc(sys.mysql_version || '—')}</div>
        </div>
        <div class="stat-card ${push.failed_24h ? 'amber' : ''}">
          <div class="stat-label">Push queue</div>
          <div class="stat-value">${push.pending ?? 0} pending</div>
          <div class="stat-sub">${push.failed_24h ?? 0} failed in 24 h · oldest ${esc(oldestAge)}</div>
        </div>
      </div>
      <div class="table-card">
        <div class="table-card-header">
          <div class="table-card-title">⏱ Scheduled jobs</div>
          <span class="table-card-link" ${actionAttrs('navigate', 'system')}>Refresh</span>
        </div>
        ${jobRows}
      </div>
      <div class="card system-facts">
        <div class="detail-row"><span class="detail-label">Deployed commit</span><span class="detail-value">${esc(sys.commit || '—')}</span></div>
        <div class="detail-row"><span class="detail-label">PHP</span><span class="detail-value">${esc(sys.php_version || '—')}</span></div>
        <div class="detail-row"><span class="detail-label">Last push sent</span><span class="detail-value">${esc(relTime(push.last_sent_at))}</span></div>
      </div>
    `;
  },
});

// ── View: Security ───────────────────────────────────────────────────────────

const SECURITY_ACTION_LABELS = {
  'admin.auth.login_success': ['Password OK', 'badge-gray'],
  'admin.auth.2fa_success': ['Signed in', 'badge-green'],
  'admin.auth.login_failed': ['Wrong password', 'badge-amber'],
  'admin.auth.login_failed_unknown_user': ['Unknown username', 'badge-amber'],
  'admin.auth.2fa_failed': ['Wrong 2FA code', 'badge-amber'],
  'admin.auth.login_blocked_locked': ['Locked out', 'badge-red'],
  'admin.auth.logout': ['Signed out', 'badge-gray'],
  'admin.totp.enable': ['2FA enabled', 'badge-blue'],
  'admin.totp.replace': ['2FA replaced', 'badge-blue'],
  'admin.totp.reset': ['2FA reset', 'badge-red'],
  'user.sessions.revoke_all': ['User signed out everywhere', 'badge-purple'],
};

registerView('security', {
  title: 'Security',
  async render() {
    const res = await get('admin_panel_security_overview');
    if (!res.ok) return `<div class="empty-state">${esc(res.error || 'Failed to load.')}</div>`;
    const c = res.counts_7d || {};
    const events = (res.events || []).map(e => {
      const [label, cls] = SECURITY_ACTION_LABELS[e.action] || [e.action, 'badge-gray'];
      return `<div class="cl-item"><div class="cl-row">
        <span class="badge ${cls}">${esc(label)}</span>
        <div style="flex:1;min-width:0;margin-left:10px"><div class="cl-sub" style="margin:0">${esc(e.admin_username)} · ${esc(e.ip_address || '—')}</div></div>
        <span class="timeline-meta">${esc(relTime(e.created_at))}</span></div></div>`;
    }).join('') || '<div class="empty-state" style="padding:24px">No sign-in or security events in the last 7 days</div>';
    const limits = (res.rate_limits_24h || []).map(r => `
      <tr><td style="font-family:ui-monospace,monospace;font-size:12px">${esc(r.scope)}</td>
      <td>${r.peak}</td><td>${r.requests}</td><td>${r.windows}</td></tr>`).join('');
    return `
      <div class="stats-grid">
        <div class="stat-card ${c.failed_logins ? 'amber' : ''}"><div class="stat-label">Failed admin logins</div>
          <div class="stat-value">${c.failed_logins ?? 0}</div><div class="stat-sub">last 7 days</div></div>
        <div class="stat-card ${c.failed_2fa ? 'amber' : ''}"><div class="stat-label">Wrong 2FA codes</div>
          <div class="stat-value">${c.failed_2fa ?? 0}</div><div class="stat-sub">last 7 days</div></div>
        <div class="stat-card ${c.locked ? 'red' : ''}"><div class="stat-label">Lockouts</div>
          <div class="stat-value">${c.locked ?? 0}</div><div class="stat-sub">last 7 days</div></div>
        <div class="stat-card"><div class="stat-label">Admin sessions</div>
          <div class="stat-value">${res.active_admin_sessions ?? 0}</div><div class="stat-sub">${c.successful_logins ?? 0} sign-ins in 7 days</div></div>
      </div>
      <div class="table-card">
        <div class="table-card-header"><div class="table-card-title">🔐 Admin sign-ins and 2FA (7 days)</div>
          <span class="table-card-link" ${actionAttrs('navigate', 'audit-log')}>Full audit log →</span></div>
        ${events}
      </div>
      <div class="table-card">
        <div class="table-card-header"><div class="table-card-title">🚦 Rate limits (24 h)</div></div>
        ${limits ? `<div class="table-wrap" style="border:0;border-radius:0"><table>
          <thead><tr><th>Scope</th><th>Peak in one window</th><th>Requests</th><th>Windows</th></tr></thead>
          <tbody>${limits}</tbody></table></div>` : '<div class="empty-state" style="padding:24px">No rate-limited requests in the last 24 hours</div>'}
        <div class="cl-sub" style="padding:10px 18px 14px;white-space:normal">A high peak for one scope means one IP or account sent many requests in a short window. Subjects are stored only as hashes.</div>
      </div>`;
  },
});

// ── View: Push Queue ──────────────────────────────────────────────────────────

registerView('push-queue', {
  title: 'Push Queue',
  async render() {
    const res = await get('admin_panel_push_queue', { limit: 50 });
    if (!res.ok) return `<div class="empty-state">Failed: ${esc(res.error)}</div>`;

    const h = res.health || {};
    const healthCards = Object.entries(h).map(([status, data]) => `
      <div class="stat-card ${status === 'failed' || status === 'dead' ? 'red' : status === 'pending' ? 'amber' : ''}">
        <div class="stat-label">${esc(status)}</div>
        <div class="stat-value">${data.count}</div>
        <div class="stat-sub">latest ${relTime(data.latest)}</div>
      </div>
    `).join('');

    const cards = res.rows.map(r => `
      <div class="cl-item">
        <div class="cl-row" style="margin-bottom:6px">
          <span style="font-family:monospace;font-size:11.5px;color:var(--fg-dim);flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(r.type ?? '—')}</span>
          ${statusBadge(r.status)}
          <span style="font-size:11px;color:var(--fg-muted)">#${r.id}</span>
        </div>
        <div style="font-weight:600;font-size:13.5px;color:var(--fg);margin-bottom:5px">${esc(r.title ?? '—')}</div>
        ${r.last_error ? `<div style="font-size:12px;color:var(--red);margin-bottom:5px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(r.last_error)}</div>` : ''}
        <div class="cl-row">
          <span class="cl-meta">${r.attempts} attempt${r.attempts !== 1 ? 's' : ''} · ${relTime(r.created_at)}</span>
          ${r.status !== 'sent' && can('superadmin','admin','ops')
            ? `<button class="btn btn-ghost btn-sm" style="margin-left:auto" ${actionAttrs('retryPush', r.id)}>Retry</button>` : ''}
        </div>
      </div>
    `).join('');

    return `
      <div class="stats-grid" style="grid-template-columns:repeat(auto-fit,minmax(140px,1fr));margin-bottom:20px;">
        ${healthCards || '<div class="empty-state">No queue data</div>'}
      </div>
      <div class="table-card" style="padding:0">
        ${cards || '<div class="empty-state" style="padding:32px">Queue is empty</div>'}
      </div>
    `;
  },
});

async function retryPush(queueId) {
  const res = await post('admin_panel_push_retry', { queue_id: queueId });
  if (res.ok) { toast('Queued for retry', 'success'); navigate('push-queue'); }
  else toast(res.error || 'Failed', 'error');
}

window.retryPush = retryPush;

// ── View: Incidents ───────────────────────────────────────────────────────────

registerView('incidents', {
  title: 'Incidents',
  async render() {
    return `
      <div class="section-header">
        <div class="section-title">Active incidents</div>
        ${can('superadmin','admin','ops')
          ? `<button class="btn btn-primary btn-sm" id="new-inc-btn">+ New incident</button>` : ''}
      </div>
      <div id="incidents-list"><div class="loading-state"><span class="spinner"></span></div></div>
    `;
  },
  init() {
    loadIncidents();
    document.getElementById('new-inc-btn')?.addEventListener('click', showNewIncidentModal);
  },
});

async function loadIncidents() {
  const res = await get('admin_panel_incidents', { limit: 50 });
  if (!res.ok) { document.getElementById('incidents-list').innerHTML = `<div class="empty-state">Error</div>`; return; }

  if (!res.incidents.length) {
    document.getElementById('incidents-list').innerHTML = '<div class="empty-state">No incidents. All clear! ✓</div>';
    return;
  }

  const cards = res.incidents.map(inc => `
    <div class="data-row">
      <div class="data-row-top">
        <span class="inc-dot ${esc(inc.severity)}"></span>
        <span class="data-row-title">${esc(inc.title)}</span>
        ${sevBadge(inc.severity)}
        ${statusBadge(inc.status)}
      </div>
      <div style="font-size:12px;color:var(--fg-muted);margin:4px 0 6px 15px;line-height:1.4">
        ${esc(inc.body.slice(0,100))}${inc.body.length>100?'…':''}
      </div>
      <div class="data-row-meta" style="justify-content:space-between">
        <span>${esc(inc.admin_username)} · ${relTime(inc.created_at)}</span>
        ${inc.status !== 'resolved' && can('superadmin','admin','ops') ? `
          <div style="display:flex;gap:6px">
            <button class="btn btn-ghost btn-sm" ${actionAttrs('updateIncident', inc.id, 'investigating')}>Investigate</button>
            <button class="btn btn-primary btn-sm" ${actionAttrs('updateIncident', inc.id, 'resolved')}>Resolve</button>
          </div>` : ''}
      </div>
    </div>
  `).join('');

  document.getElementById('incidents-list').innerHTML = `
    <div class="table-card" style="padding:0">
      ${cards}
    </div>
  `;
}

function showNewIncidentModal() {
  modal.open('New incident', `
    <div class="form-group">
      <label class="form-label">Title</label>
      <input class="form-input" id="inc-title" placeholder="Brief description"/>
    </div>
    <div class="form-group">
      <label class="form-label">Details</label>
      <textarea class="form-input" id="inc-body" rows="4" placeholder="What's happening, impact, steps taken…" style="resize:vertical;"></textarea>
    </div>
    <div class="form-group">
      <label class="form-label">Severity</label>
      <select class="form-input" id="inc-severity">
        <option value="low">Low</option>
        <option value="medium" selected>Medium</option>
        <option value="high">High</option>
        <option value="critical">Critical</option>
      </select>
    </div>
  `, `
    <button class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button>
    <button class="btn btn-primary" ${actionAttrs('submitIncident')}>Create incident</button>
  `);
}

async function submitIncident() {
  const title    = document.getElementById('inc-title').value.trim();
  const body     = document.getElementById('inc-body').value.trim();
  const severity = document.getElementById('inc-severity').value;
  if (!title) { toast('Title is required', 'error'); return; }
  const res = await post('admin_panel_create_incident', { title, body, severity });
  if (res.ok) {
    modal.close();
    toast('Incident created', 'success');
    loadIncidents();
    pollIncidents();
  } else {
    toast(res.error || 'Failed', 'error');
  }
}

async function updateIncident(id, status) {
  const res = await post('admin_panel_update_incident', { id, status });
  if (res.ok) { toast(`Incident ${status}`, 'success'); loadIncidents(); pollIncidents(); }
  else toast(res.error || 'Failed', 'error');
}

Object.assign(window, { loadIncidents, showNewIncidentModal, submitIncident, updateIncident });

// ── View: Audit Log ───────────────────────────────────────────────────────────

registerView('audit-log', {
  title: 'Audit Log',
  async render() {
    return `
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="audit-action-filter" placeholder="Filter by action (e.g. user.suspend)…"/>
        </div>
        <select class="form-input" id="audit-target-filter" style="width:auto;">
          <option value="">All targets</option>
          <option value="user">user</option>
          <option value="admin_user">admin_user</option>
          <option value="incident">incident</option>
          <option value="push_queue">push_queue</option>
          <option value="session">session</option>
        </select>
        <button class="btn btn-ghost btn-sm" id="audit-search-btn">Filter</button>
      </div>
      <div id="audit-results"><div class="loading-state"><span class="spinner"></span></div></div>
    `;
  },
  init() {
    loadAuditLog(0);
    document.getElementById('audit-search-btn').addEventListener('click', () => loadAuditLog(0));
  },
});

async function loadAuditLog(offset = 0) {
  const action = document.getElementById('audit-action-filter').value.trim();
  const target = document.getElementById('audit-target-filter').value;
  document.getElementById('audit-results').innerHTML = '<div class="loading-state"><span class="spinner"></span></div>';

  const res = await get('admin_panel_audit_log', { action_filter: action, target, limit: 50, offset });
  if (!res.ok) { document.getElementById('audit-results').innerHTML = `<div class="empty-state">Error: ${esc(res.error)}</div>`; return; }

  if (!res.log.length) {
    document.getElementById('audit-results').innerHTML = '<div class="empty-state">No audit entries found.</div>';
    return;
  }

  const cards = res.log.map(entry => {
    const actionColor = entry.action.includes('delete') ? 'var(--red)'
      : entry.action.includes('suspend') || entry.action.includes('disable') ? 'var(--amber)'
      : 'var(--green-soft)';
    return `
      <div class="cl-item">
        <div class="cl-row" style="margin-bottom:5px">
          <span style="font-family:monospace;font-size:12px;color:${actionColor};flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(entry.action)}</span>
          <span style="font-size:11px;color:var(--fg-muted);flex-shrink:0">${relTime(entry.created_at)}</span>
        </div>
        <div class="cl-meta">
          ${esc(entry.admin_username)}
          ${entry.target_type ? ` → ${esc(entry.target_type)}${entry.target_id ? ` #${esc(entry.target_id)}` : ''}` : ''}
          ${entry.ip_address ? ` · ${esc(entry.ip_address)}` : ''}
        </div>
        ${entry.details ? `<div style="font-size:11px;color:var(--fg-muted);margin-top:3px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(JSON.stringify(entry.details).slice(0,80))}</div>` : ''}
      </div>
    `;
  }).join('');

  const prevBtn = offset > 0
    ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('loadAuditLog', offset - 50)}>← Prev</button>` : '';
  const nextBtn = (offset + 50) < res.total
    ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('loadAuditLog', offset + 50)}>Next →</button>` : '';

  document.getElementById('audit-results').innerHTML = `
    <div class="table-card" style="padding:0">
      ${cards}
    </div>
    <div class="pagination">${offset + 1}–${Math.min(offset + 50, res.total)} of ${res.total} ${prevBtn} ${nextBtn}</div>
  `;
}

window.loadAuditLog = loadAuditLog;

// ── View: App Events ──────────────────────────────────────────────────────────

registerView('app-events', {
  title: 'App Events',
  async render() {
    return `
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="app-event-filter" placeholder="Filter by event type (e.g. trip.created)…"/>
        </div>
        <button class="btn btn-ghost btn-sm" id="app-events-search-btn">Filter</button>
      </div>
      <div id="app-events-results"><div class="loading-state"><span class="spinner"></span></div></div>
    `;
  },
  init() {
    loadAppEvents(0);
    document.getElementById('app-events-search-btn').addEventListener('click', () => loadAppEvents(0));
  },
});

const _appEventColor = type => type.includes('delete') || type.includes('deleted') ? 'var(--red)'
  : type.startsWith('user.login') || type.startsWith('user.register') ? 'var(--green-soft)'
  : type.startsWith('trip.') ? 'var(--blue)'
  : type.startsWith('expense.') ? 'var(--amber)'
  : type.startsWith('settlement.') ? '#a78bfa'
  : type.startsWith('friend.') ? 'var(--green-soft)'
  : 'var(--fg-muted)';

async function loadAppEvents(offset = 0) {
  const typeFilter = document.getElementById('app-event-filter').value.trim();
  document.getElementById('app-events-results').innerHTML = '<div class="loading-state"><span class="spinner"></span></div>';

  const res = await get('admin_panel_app_events', { event_type: typeFilter, limit: 50, offset });
  if (!res.ok) { document.getElementById('app-events-results').innerHTML = `<div class="empty-state">Error: ${esc(res.error)}</div>`; return; }

  if (!res.events.length) {
    document.getElementById('app-events-results').innerHTML = '<div class="empty-state">No events found.</div>';
    return;
  }

  const cards = res.events.map(entry => `
    <div class="cl-item">
      <div class="cl-row" style="margin-bottom:5px">
        <span style="font-family:monospace;font-size:12px;color:${_appEventColor(entry.event_type)};flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(entry.event_type)}</span>
        <span style="font-size:11px;color:var(--fg-muted);flex-shrink:0">${relTime(entry.created_at)}</span>
      </div>
      <div class="cl-meta">
        ${esc(entry.username || 'deleted user')}
        ${entry.entity_type ? ` → ${esc(entry.entity_type)}${entry.entity_id ? ` #${esc(entry.entity_id)}` : ''}` : ''}
      </div>
    </div>
  `).join('');

  const prevBtn = offset > 0
    ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('loadAppEvents', offset - 50)}>← Prev</button>` : '';
  const nextBtn = (offset + 50) < res.total
    ? `<button class="btn btn-ghost btn-sm" ${actionAttrs('loadAppEvents', offset + 50)}>Next →</button>` : '';

  document.getElementById('app-events-results').innerHTML = `
    <div class="table-card" style="padding:0">
      ${cards}
    </div>
    <div class="pagination">${offset + 1}–${Math.min(offset + 50, res.total)} of ${res.total} ${prevBtn} ${nextBtn}</div>
  `;
}

window.loadAppEvents = loadAppEvents;

// ── View: Admin Users ─────────────────────────────────────────────────────────

registerView('admin-users', {
  title: 'Admin Users',
  async render() {
    const res = await get('admin_panel_admin_users');
    if (!res.ok) return `<div class="empty-state">Access denied or error: ${esc(res.error)}</div>`;

    const cards = res.users.map(u => `
      <div class="cl-item">
        <div class="cl-row" style="margin-bottom:6px">
          <div style="flex:1;min-width:0">
            <div class="cl-title">${esc(u.username)}</div>
            <div class="cl-sub">${esc(u.email)}</div>
          </div>
          ${roleBadge(u.role)}
          ${u.is_active ? '<span class="badge badge-green">active</span>' : '<span class="badge badge-red">inactive</span>'}
        </div>
        <div class="cl-row">
          <span class="cl-meta">2FA: ${u.totp_enabled ? '✓' : '—'} · Last login: ${relTime(u.last_login_at)} · ${u.active_sessions} session${u.active_sessions !== 1 ? 's' : ''}</span>
        </div>
        <div class="cl-actions">
          <button class="btn btn-ghost btn-sm" ${actionAttrs('editAdminUser', u.id, u.username, u.role, u.is_active)}>Edit</button>
          ${u.id !== state.user?.id
            ? `<button class="btn btn-danger btn-sm" ${actionAttrs('deleteAdminUser', u.id, u.username)}>Delete</button>` : ''}
        </div>
      </div>
    `).join('');

    return `
      <div class="section-header">
        <div class="section-title">Admin accounts</div>
        <button class="btn btn-primary btn-sm" ${actionAttrs('showCreateAdminModal')}>+ Add admin</button>
      </div>
      <div class="table-card" style="padding:0">
        ${cards}
      </div>
    `;
  },
});

function showCreateAdminModal() {
  modal.open('Create admin user', `
    <div class="form-group"><label class="form-label">Username</label><input class="form-input" id="new-admin-username" placeholder="johndoe"/></div>
    <div class="form-group"><label class="form-label">Email</label><input class="form-input" id="new-admin-email" type="email" placeholder="john@example.com"/></div>
    <div class="form-group"><label class="form-label">Password (min 12 chars)</label><input class="form-input" id="new-admin-password" type="password"/></div>
    <div class="form-group">
      <label class="form-label">Role</label>
      <select class="form-input" id="new-admin-role">
        <option value="readonly">readonly</option>
        <option value="support">support</option>
        <option value="ops">ops</option>
        <option value="admin">admin</option>
        <option value="superadmin">superadmin</option>
      </select>
    </div>
  `, `
    <button class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button>
    <button class="btn btn-primary" ${actionAttrs('createAdminUser')}>Create</button>
  `);
}

async function createAdminUser() {
  const username = document.getElementById('new-admin-username').value.trim();
  const email    = document.getElementById('new-admin-email').value.trim();
  const password = document.getElementById('new-admin-password').value;
  const role     = document.getElementById('new-admin-role').value;
  const res = await post('admin_panel_create_admin_user', { username, email, password, role });
  if (res.ok) { modal.close(); toast(`Admin user created (ID ${res.id})`, 'success'); navigate('admin-users'); }
  else toast(res.error || 'Failed', 'error');
}

function editAdminUser(id, username, role, isActive) {
  modal.open(`Edit: ${username}`, `
    <div class="form-group">
      <label class="form-label">Role</label>
      <select class="form-input" id="edit-admin-role">
        ${['readonly','support','ops','admin','superadmin'].map(r =>
          `<option value="${r}" ${r === role ? 'selected' : ''}>${r}</option>`).join('')}
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">Status</label>
      <select class="form-input" id="edit-admin-active">
        <option value="1" ${isActive ? 'selected' : ''}>Active</option>
        <option value="0" ${!isActive ? 'selected' : ''}>Inactive</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label">New password (leave blank to keep)</label>
      <input class="form-input" id="edit-admin-pw" type="password" placeholder="(unchanged)"/>
    </div>
    ${id !== state.user?.id ? `
    <div class="form-group">
      <label class="form-label"><input type="checkbox" id="edit-admin-reset-2fa"/> Reset 2FA (lost authenticator)</label>
      <p style="color:var(--fg-muted);font-size:12px;">Signs this admin out. They set up a new authenticator at the next login.</p>
    </div>` : ''}
  `, `
    <button class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button>
    <button class="btn btn-primary" ${actionAttrs('saveAdminUser', id)}>Save</button>
  `);
}

async function saveAdminUser(id) {
  const payload = {
    id,
    role:      document.getElementById('edit-admin-role').value,
    is_active: parseInt(document.getElementById('edit-admin-active').value),
  };
  const pw = document.getElementById('edit-admin-pw').value;
  if (pw) payload.password = pw;
  if (document.getElementById('edit-admin-reset-2fa')?.checked) payload.reset_totp = true;
  const res = await post('admin_panel_update_admin_user', payload);
  if (res.ok) { modal.close(); toast('Updated', 'success'); navigate('admin-users'); }
  else toast(res.error || 'Failed', 'error');
}

async function deleteAdminUser(id, username) {
  if (!await askInModal({ title: `Delete admin user ${username}?`, confirmLabel: 'Delete', danger: true,
    message: 'This cannot be undone.' })) return;
  const res = await post('admin_panel_delete_admin_user', { id });
  if (res.ok) { toast(`Deleted ${username}`, 'success'); navigate('admin-users'); }
  else toast(res.error || 'Failed', 'error');
}

Object.assign(window, { showCreateAdminModal, createAdminUser, editAdminUser, saveAdminUser, deleteAdminUser });

// ── View: Sessions ────────────────────────────────────────────────────────────

registerView('sessions', {
  title: 'Active Sessions',
  async render() {
    const res = await get('admin_panel_active_sessions');
    if (!res.ok) return `<div class="empty-state">Error: ${esc(res.error)}</div>`;

    if (!res.sessions.length)
      return '<div class="empty-state">No active sessions found.</div>';

    const rows = res.sessions.map(s => `
      <tr style="${s.is_current ? 'background:var(--green-dim)' : ''}">
        <td>${s.username ? esc(s.username) : '—'} ${s.is_current ? '<span class="badge badge-green">current</span>' : ''}</td>
        <td>${s.role ? roleBadge(s.role) : '—'}</td>
        <td>${esc(s.ip_address)}</td>
        <td style="font-size:11px;color:var(--fg-muted);max-width:160px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap;">${esc(s.user_agent)}</td>
        <td>${s.is_2fa_verified ? '✓' : '—'}</td>
        <td>${relTime(s.last_active_at)}</td>
        <td>
          ${!s.is_current
            ? `<button class="btn btn-danger btn-sm" ${actionAttrs('revokeSession', s.session_id)}>Revoke</button>` : ''}
        </td>
      </tr>
    `).join('');

    return `
      <div class="table-wrap">
        <table>
          <thead><tr><th>User</th><th>Role</th><th>IP</th><th>User agent</th><th>2FA</th><th>Last active</th><th></th></tr></thead>
          <tbody>${rows}</tbody>
        </table>
      </div>
    `;
  },
});

async function revokeSession(sessionId) {
  if (!await askInModal({ title: 'Revoke this session?', confirmLabel: 'Revoke', danger: true,
    message: 'That browser is signed out of the admin panel.' })) return;
  const res = await post('admin_panel_revoke_session', { session_id: sessionId });
  if (res.ok) { toast('Session revoked', 'success'); navigate('sessions'); }
  else toast(res.error || 'Failed', 'error');
}

window.revokeSession = revokeSession;

// ── View: My Account ──────────────────────────────────────────────────────────

registerView('my-account', {
  title: 'My Account',
  async render() {
    const u = state.user;
    return `
      <div class="card" style="max-width:480px;">
        <div class="card-title">Profile</div>
        <div class="detail-row"><span class="detail-label">Username</span><span class="detail-value">${esc(u?.username)}</span></div>
        <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value">${esc(u?.email)}</span></div>
        <div class="detail-row"><span class="detail-label">Role</span><span class="detail-value">${roleBadge(u?.role)}</span></div>
        <div class="detail-row"><span class="detail-label">2FA</span><span class="detail-value">
          <span class="badge badge-green">Enabled</span>
          <button class="btn btn-ghost btn-sm" style="margin-left:8px" ${actionAttrs('replace2fa')}>Replace authenticator</button>
        </span></div>
        <p style="color:var(--fg-muted);font-size:12px;margin-top:12px;">
          2FA is required for admin accounts. Lost your authenticator? Ask a superadmin to reset it,
          or use scripts/admin_totp.php on the server.
        </p>
      </div>
    `;
  },
});

// Replacing needs the password and a code from the current app; the old
// authenticator keeps working until the new one is confirmed.
async function replace2fa() {
  modal.open('Replace authenticator', `
    <form id="replace-2fa-form" novalidate>
      <div class="form-group">
        <label class="form-label" for="replace-2fa-password">Your password</label>
        <input class="form-input" id="replace-2fa-password" type="password" autocomplete="current-password" required/>
      </div>
      <div class="form-group">
        <label class="form-label" for="replace-2fa-code">Code from your current authenticator</label>
        <input class="form-input" id="replace-2fa-code" type="text" inputmode="numeric" maxlength="6"
               placeholder="000000" autocomplete="one-time-code" required/>
      </div>
    </form>
  `, `
    <button class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button>
    <button class="btn btn-primary" type="submit" form="replace-2fa-form">Continue</button>
  `);
  document.getElementById('replace-2fa-form').addEventListener('submit', async e => {
    e.preventDefault();
    const res = await post('admin_panel_setup_totp', {
      password: document.getElementById('replace-2fa-password').value,
      current_code: document.getElementById('replace-2fa-code').value.trim(),
    }).catch(err => ({ ok: false, error: err.message }));
    if (!res.ok) { toast(res.error || 'Failed', 'error'); return; }
    showNewSecret(res.secret);
  });
  document.getElementById('replace-2fa-password').focus();
}

function showNewSecret(secret) {
  modal.open('New authenticator', `
    <p style="color:var(--fg-dim);font-size:13px;margin-bottom:16px;">
      Add a new account in your authenticator app and enter this setup key manually.
      Your current authenticator keeps working until you confirm.
    </p>
    <div class="setup-key">${esc(secret)}</div>
    <div class="form-group">
      <label class="form-label" for="totp-confirm-code">Code from the new app</label>
      <input class="form-input" id="totp-confirm-code" type="text" inputmode="numeric" maxlength="6" placeholder="000000"/>
    </div>
  `, `
    <button class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button>
    <button class="btn btn-primary" ${actionAttrs('confirm2fa')}>Confirm &amp; switch</button>
  `);
}

async function confirm2fa() {
  const code = document.getElementById('totp-confirm-code').value.trim();
  const res  = await post('admin_panel_confirm_totp', { code });
  if (res.ok) {
    modal.close();
    const others = res.revoked_sessions ? ` ${res.revoked_sessions} other session(s) signed out.` : '';
    toast(`Authenticator replaced.${others}`, 'success');
    navigate('my-account');
  } else {
    toast(res.error || 'Invalid code', 'error');
  }
}

Object.assign(window, { replace2fa, confirm2fa });

// ── Boot ──────────────────────────────────────────────────────────────────────

(async function boot() {
  const sessState = await checkSession().catch(() => false);

  if (sessState === 'needs_enrollment') {
    showAuth('enroll');
    return;
  }
  if (sessState === 'needs_2fa') {
    showAuth('2fa');
    return;
  }

  if (!sessState) {
    showAuth('login');
    return;
  }

  showApp();
  navigate('dashboard');
  pollIncidents();
})();
