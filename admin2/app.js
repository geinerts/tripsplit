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
    document.getElementById('modal-title').textContent = title;
    document.getElementById('modal-body').innerHTML = bodyHtml;
    document.getElementById('modal-footer').innerHTML = footerHtml;
    document.getElementById('modal-backdrop').classList.add('open');
  },
  close() {
    document.getElementById('modal-backdrop').classList.remove('open');
  },
};

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

  Promise.resolve()
    .then(() => v.render(data))
    .then(html => { setContent(html); if (v.init) v.init(data); })
    .catch(err => { setContent(`<div class="empty-state">Error: ${esc(err.message)}</div>`); });
}

function setContent(html) {
  document.getElementById('page-content').innerHTML = html;
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function esc(str) {
  return String(str ?? '').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

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
  if (res.requires_2fa)   return 'needs_2fa';
  state.user = res.user;
  return true;
}

function showAuth(mode = 'login') {
  document.getElementById('auth-screen').classList.add('visible');
  document.getElementById('app').style.display = 'none';
  document.getElementById('login-card').style.display = mode === 'login' ? '' : 'none';
  document.getElementById('totp-card').style.display  = mode === '2fa'   ? '' : 'none';
}

function showApp() {
  document.getElementById('auth-screen').classList.remove('visible');
  document.getElementById('app').style.display = 'flex';
  // Set sidebar user info
  if (state.user) {
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

  if (res.requires_2fa) {
    showAuth('2fa');
    return;
  }

  state.user = res.user;
  showApp();
  navigate('dashboard');
  pollIncidents();
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

  state.user = res.user;
  const sessRes = await get('admin_panel_session_check');
  state.user = sessRes.user;

  showApp();
  navigate('dashboard');
  pollIncidents();
});

document.getElementById('back-to-login-btn').addEventListener('click', () => {
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
  setTimeout(pollIncidents, 60_000);
}

// ── View: Dashboard ───────────────────────────────────────────────────────────

registerView('dashboard', {
  title: 'Dashboard',
  async render() {
    const [dashRes, auditRes] = await Promise.all([
      get('admin_panel_dashboard'),
      get('admin_panel_audit_log', { limit: 6, offset: 0 }),
    ]);
    if (!dashRes.ok) return `<div class="empty-state">Failed to load stats.</div>`;
    const s  = dashRes.stats || {};
    const pq = s.push_queue || {};

    const incidentCards = (s.recent_incidents || []).map(inc => `
      <div class="data-row" onclick="navigate('incidents')" style="cursor:pointer">
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

    // Audit activity feed
    const auditItems = (auditRes.ok ? (auditRes.log || []) : []).map(entry => {
      const actionColor = entry.action.includes('delete') ? 'var(--red)'
        : entry.action.includes('suspend') || entry.action.includes('disable') ? 'var(--amber)'
        : 'var(--green)';
      return `
        <div class="activity-item">
          <div class="activity-dot" style="background:${actionColor};${actionColor === 'var(--red)' ? 'box-shadow:0 0 5px var(--red)' : ''}"></div>
          <div style="flex:1;min-width:0">
            <div class="activity-text">
              <strong>${esc(entry.admin_username)}</strong> — <span style="font-family:monospace;font-size:11.5px;color:var(--fg-dim)">${esc(entry.action)}</span>
              ${entry.target_id ? `<span style="color:var(--fg-muted)"> #${entry.target_id}</span>` : ''}
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

      <!-- Two-col grid -->
      <div class="dashboard-grid">

        <!-- Left: incidents + audit log -->
        <div>
          <div class="table-card">
            <div class="table-card-header">
              <div class="table-card-title">🚨 Open Incidents</div>
              <span class="table-card-link" onclick="navigate('incidents')">View all →</span>
            </div>
            ${incidentCards || '<div class="empty-state" style="padding:24px">No open incidents — all clear ✓</div>'}
          </div>

          <div class="table-card dashboard-audit-table">
            <div class="table-card-header">
              <div class="table-card-title">📋 Recent Audit</div>
              <span class="table-card-link" onclick="navigate('audit-log')">View all →</span>
            </div>
            ${auditRes.ok && auditRes.log.length ? `
            <table>
              <thead><tr><th>Action</th><th>Admin</th><th>Target</th><th>Time</th></tr></thead>
              <tbody>
                ${auditRes.log.map(e => `
                  <tr>
                    <td style="font-family:monospace;font-size:12px;color:${e.action.includes('delete')?'var(--red)':e.action.includes('suspend')||e.action.includes('disable')?'var(--amber)':'var(--green-soft)'}">${esc(e.action)}</td>
                    <td style="color:var(--fg-muted)">${esc(e.admin_username)}</td>
                    <td style="color:var(--fg-muted)">${esc(e.target_type ?? '')}${e.target_id ? ` #${e.target_id}` : ''}</td>
                    <td style="color:var(--fg-muted);font-size:12px">${relTime(e.created_at)}</td>
                  </tr>`).join('')}
              </tbody>
            </table>` : '<div class="empty-state" style="padding:24px">No audit entries yet</div>'}
          </div>
        </div>

        <!-- Right: push health + activity -->
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
            <div class="activity-header">⚡ Recent Activity</div>
            ${auditItems}
          </div>
        </div>

      </div><!-- /dashboard-grid -->
    `;
  },
});

// ── View: Users ───────────────────────────────────────────────────────────────

registerView('users', {
  title: 'Users',
  async render() {
    return `
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="user-search-inp" placeholder="Search by name or email…"/>
        </div>
        <select class="form-input" id="user-status-filter" style="width:auto;">
          <option value="all">All statuses</option>
          <option value="active">Active</option>
          <option value="deactivated">Deactivated/Suspended</option>
          <option value="deleted">Deleted</option>
        </select>
        <button class="btn btn-ghost btn-sm" id="user-search-btn">Search</button>
      </div>
      <div id="user-results"><div class="empty-state">Enter a search term to find users.</div></div>
    `;
  },
  init() {
    const doSearch = () => userSearch();
    document.getElementById('user-search-btn').addEventListener('click', doSearch);
    document.getElementById('user-search-inp').addEventListener('keydown', e => {
      if (e.key === 'Enter') doSearch();
    });
  },
});

async function userSearch(offset = 0) {
  const q      = document.getElementById('user-search-inp').value.trim();
  const status = document.getElementById('user-status-filter').value;
  document.getElementById('user-results').innerHTML =
    '<div class="loading-state"><span class="spinner"></span></div>';

  const res = await get('admin_panel_user_search', { q, status, limit: 40, offset });
  if (!res.ok) { document.getElementById('user-results').innerHTML = `<div class="empty-state">Error: ${esc(res.error)}</div>`; return; }

  if (!res.users.length) {
    document.getElementById('user-results').innerHTML = '<div class="empty-state">No users found.</div>';
    return;
  }

  const cards = res.users.map(u => `
    <div class="cl-item">
      <div class="cl-row" style="margin-bottom:6px">
        <div style="flex:1;min-width:0">
          <div class="cl-title">${esc(u.nickname)}</div>
          <div class="cl-sub">${esc(u.email)}</div>
        </div>
        ${statusBadge(u.account_status)}
      </div>
      <div class="cl-actions">
        <button class="btn btn-ghost btn-sm" onclick="openUserDetail(${u.id})">View</button>
        ${u.account_status === 'active' && can('superadmin','admin','support') ?
          `<button class="btn btn-amber btn-sm" onclick="suspendUser(${u.id},'${esc(u.nickname)}')">Suspend</button>` : ''}
        ${u.account_status === 'deactivated' && can('superadmin','admin','support') ?
          `<button class="btn btn-ghost btn-sm" onclick="reactivateUser(${u.id},'${esc(u.nickname)}')">Reactivate</button>` : ''}
        <span style="margin-left:auto;font-size:11px;color:var(--fg-muted);align-self:center">${relTime(u.created_at)}</span>
      </div>
    </div>
  `).join('');

  const prevBtn = offset > 0
    ? `<button class="btn btn-ghost btn-sm" onclick="userSearch(${offset - 40})">← Prev</button>`
    : '';
  const nextBtn = (offset + 40) < res.total
    ? `<button class="btn btn-ghost btn-sm" onclick="userSearch(${offset + 40})">Next →</button>`
    : '';

  document.getElementById('user-results').innerHTML = `
    <div class="table-card" style="padding:0">
      ${cards}
    </div>
    <div class="pagination">
      Showing ${offset + 1}–${Math.min(offset + 40, res.total)} of ${res.total}
      ${prevBtn} ${nextBtn}
    </div>
  `;
}

async function openUserDetail(userId) {
  modal.open('User detail', '<div class="loading-state"><span class="spinner"></span> Loading…</div>', '');
  const res = await get('admin_panel_user_detail', { user_id: userId });
  if (!res.ok) { modal.open('Error', `<div class="empty-state">${esc(res.error)}</div>`); return; }

  const u  = res.user;
  const trips = (res.trips || []).map(t =>
    `<div class="detail-row"><span>${esc(t.name)}</span><span class="badge badge-gray">${esc(t.status)}</span></div>`
  ).join('') || '<div class="empty-state" style="padding:8px">No trips</div>';

  const actions = [];
  if (u.account_status === 'active' && can('superadmin','admin','support'))
    actions.push(`<button class="btn btn-amber btn-sm" onclick="modal.close();suspendUser(${u.id},'${esc(u.nickname)}')">Suspend</button>`);
  if (u.account_status === 'deactivated' && can('superadmin','admin','support'))
    actions.push(`<button class="btn btn-ghost btn-sm" onclick="modal.close();reactivateUser(${u.id},'${esc(u.nickname)}')">Reactivate</button>`);
  if (can('superadmin','admin','support'))
    actions.push(`<button class="btn btn-ghost btn-sm" onclick="modal.close();clearPushTokens(${u.id})">Clear push tokens</button>`);
  if (can('superadmin','admin'))
    actions.push(`<button class="btn btn-danger btn-sm" onclick="modal.close();deleteUser(${u.id},'${esc(u.nickname)}')">Delete user</button>`);

  modal.open('User: ' + u.nickname, `
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">${u.id}</span></div>
    <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value">${esc(u.email)}</span></div>
    <div class="detail-row"><span class="detail-label">Status</span><span class="detail-value">${statusBadge(u.account_status)}</span></div>
    <div class="detail-row"><span class="detail-label">Joined</span><span class="detail-value">${relTime(u.created_at)}</span></div>
    <div class="detail-row"><span class="detail-label">Unread notifs</span><span class="detail-value">${res.unread_notifs}</span></div>
    <div class="detail-row"><span class="detail-label">Push tokens</span><span class="detail-value">${(res.push_tokens || []).length}</span></div>
    <div style="margin-top:14px;font-size:12px;font-weight:700;color:var(--fg-muted);letter-spacing:0.3px;text-transform:uppercase;margin-bottom:6px;">Recent trips</div>
    ${trips}
    <div style="display:flex;flex-wrap:wrap;gap:8px;margin-top:16px;">${actions.join('')}</div>
  `, `<button class="btn btn-ghost" onclick="modal.close()">Close</button>`);
}

async function suspendUser(userId, name) {
  const reason = prompt(`Suspend ${name}? Enter a reason (optional):`);
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
  const reason = prompt(`⚠️ Delete user ${name}? This is irreversible. Enter reason:`);
  if (!reason) return;
  const res = await post('admin_panel_user_delete', { user_id: userId, reason });
  if (res.ok) { toast(`${name} deleted`, 'success'); userSearch(); }
  else toast(res.error || 'Failed', 'error');
}

async function clearPushTokens(userId) {
  if (!confirm('Clear all push tokens for this user?')) return;
  const res = await post('admin_panel_clear_push_tokens', { user_id: userId });
  if (res.ok) toast(`Removed ${res.removed} push token(s)`, 'success');
  else toast(res.error || 'Failed', 'error');
}

// Make functions global (called from inline onclick)
Object.assign(window, { navigate, openUserDetail, suspendUser, reactivateUser, deleteUser, clearPushTokens, modal });

// ── View: Feedback ────────────────────────────────────────────────────────────

registerView('feedback', {
  title: 'Feedback',
  async render() {
    return `
      <div class="toolbar">
        <select class="form-input" id="fb-type" style="width:auto;">
          <option value="all">All types</option>
          <option value="bug">Bugs</option>
          <option value="suggestion">Suggestions</option>
        </select>
        <select class="form-input" id="fb-status" style="width:auto;">
          <option value="open">Open</option>
          <option value="all">All</option>
          <option value="archived">Archived</option>
        </select>
        <div class="toolbar-search">
          <input type="search" id="fb-search" placeholder="Search feedback…"/>
        </div>
        <button class="btn btn-ghost btn-sm" id="fb-search-btn">Filter</button>
      </div>
      <div id="fb-stats" style="margin-bottom:16px;"></div>
      <div id="fb-results"><div class="loading-state"><span class="spinner"></span></div></div>
    `;
  },
  init() {
    loadFeedback(0);
    document.getElementById('fb-search-btn').addEventListener('click', () => loadFeedback(0));
  },
});

async function loadFeedback(offset = 0) {
  const type   = document.getElementById('fb-type').value;
  const status = document.getElementById('fb-status').value;
  const search = document.getElementById('fb-search').value.trim();
  document.getElementById('fb-results').innerHTML = '<div class="loading-state"><span class="spinner"></span></div>';

  const res = await get('admin_panel_feedback', { type, status, search, limit: 40, offset });
  if (!res.ok) { document.getElementById('fb-results').innerHTML = `<div class="empty-state">Error: ${esc(res.error)}</div>`; return; }

  const s = res.stats || {};
  document.getElementById('fb-stats').innerHTML = `
    <div class="stats-grid" style="grid-template-columns:repeat(auto-fit,minmax(110px,1fr));">
      <div class="stat-card"><div class="stat-label">Total</div><div class="stat-value">${s.total ?? 0}</div></div>
      <div class="stat-card red"><div class="stat-label">Bugs</div><div class="stat-value">${s.bugs ?? 0}</div></div>
      <div class="stat-card blue"><div class="stat-label">Suggestions</div><div class="stat-value">${s.suggestions ?? 0}</div></div>
      <div class="stat-card amber"><div class="stat-label">Open</div><div class="stat-value">${s.open_count ?? 0}</div></div>
    </div>
  `;

  if (!res.feedback.length) {
    document.getElementById('fb-results').innerHTML = '<div class="empty-state">No feedback found.</div>';
    return;
  }

  const cards = res.feedback.map(f => `
    <div class="cl-item">
      <div class="cl-row" style="margin-bottom:7px">
        <span class="badge ${f.type === 'bug' ? 'badge-red' : 'badge-blue'}">${esc(f.type)}</span>
        ${statusBadge(f.status)}
        <span style="margin-left:auto;font-size:11px;color:var(--fg-muted)">${relTime(f.created_at)}</span>
      </div>
      <div style="font-size:13px;color:var(--fg);line-height:1.45;margin-bottom:6px">${esc(f.message)}</div>
      ${f.user_nickname ? `<div class="cl-meta">by ${esc(f.user_nickname)}</div>` : ''}
      <div class="cl-actions">
        ${f.status === 'open' && can('superadmin','admin','support')
          ? `<button class="btn btn-ghost btn-sm" onclick="archiveFeedback(${f.id})">Archive</button>` : ''}
        ${can('superadmin','admin')
          ? `<button class="btn btn-danger btn-sm" onclick="deleteFeedback(${f.id})">Delete</button>` : ''}
      </div>
    </div>
  `).join('');

  const nextBtn = (offset + 40) < res.total
    ? `<button class="btn btn-ghost btn-sm" onclick="loadFeedback(${offset + 40})">Next →</button>` : '';
  const prevBtn = offset > 0
    ? `<button class="btn btn-ghost btn-sm" onclick="loadFeedback(${offset - 40})">← Prev</button>` : '';

  document.getElementById('fb-results').innerHTML = `
    <div class="table-card" style="padding:0">
      ${cards}
    </div>
    <div class="pagination">${offset + 1}–${Math.min(offset + 40, res.total)} of ${res.total} ${prevBtn} ${nextBtn}</div>
  `;
}

async function archiveFeedback(id) {
  const res = await post('admin_panel_archive_feedback', { id });
  if (res.ok) { toast('Archived', 'success'); loadFeedback(0); }
  else toast(res.error || 'Failed', 'error');
}

async function deleteFeedback(id) {
  if (!confirm('Delete this feedback permanently?')) return;
  const res = await post('admin_panel_delete_feedback', { id });
  if (res.ok) { toast('Deleted', 'success'); loadFeedback(0); }
  else toast(res.error || 'Failed', 'error');
}

Object.assign(window, { loadFeedback, archiveFeedback, deleteFeedback });

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
            ? `<button class="btn btn-ghost btn-sm" style="margin-left:auto" onclick="retryPush(${r.id})">Retry</button>` : ''}
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
            <button class="btn btn-ghost btn-sm" onclick="updateIncident(${inc.id},'investigating')">Investigate</button>
            <button class="btn btn-primary btn-sm" onclick="updateIncident(${inc.id},'resolved')">Resolve</button>
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
    <button class="btn btn-ghost" onclick="modal.close()">Cancel</button>
    <button class="btn btn-primary" onclick="submitIncident()">Create incident</button>
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
          <option value="feedback">feedback</option>
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
          ${entry.target_type ? ` → ${esc(entry.target_type)}${entry.target_id ? ` #${entry.target_id}` : ''}` : ''}
          ${entry.ip_address ? ` · ${esc(entry.ip_address)}` : ''}
        </div>
        ${entry.details ? `<div style="font-size:11px;color:var(--fg-muted);margin-top:3px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap">${esc(JSON.stringify(entry.details).slice(0,80))}</div>` : ''}
      </div>
    `;
  }).join('');

  const prevBtn = offset > 0
    ? `<button class="btn btn-ghost btn-sm" onclick="loadAuditLog(${offset - 50})">← Prev</button>` : '';
  const nextBtn = (offset + 50) < res.total
    ? `<button class="btn btn-ghost btn-sm" onclick="loadAuditLog(${offset + 50})">Next →</button>` : '';

  document.getElementById('audit-results').innerHTML = `
    <div class="table-card" style="padding:0">
      ${cards}
    </div>
    <div class="pagination">${offset + 1}–${Math.min(offset + 50, res.total)} of ${res.total} ${prevBtn} ${nextBtn}</div>
  `;
}

window.loadAuditLog = loadAuditLog;

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
          <button class="btn btn-ghost btn-sm" onclick="editAdminUser(${u.id},'${esc(u.username)}','${esc(u.role)}',${u.is_active})">Edit</button>
          ${u.id !== state.user?.id
            ? `<button class="btn btn-danger btn-sm" onclick="deleteAdminUser(${u.id},'${esc(u.username)}')">Delete</button>` : ''}
        </div>
      </div>
    `).join('');

    return `
      <div class="section-header">
        <div class="section-title">Admin accounts</div>
        <button class="btn btn-primary btn-sm" onclick="showCreateAdminModal()">+ Add admin</button>
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
    <button class="btn btn-ghost" onclick="modal.close()">Cancel</button>
    <button class="btn btn-primary" onclick="createAdminUser()">Create</button>
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
  `, `
    <button class="btn btn-ghost" onclick="modal.close()">Cancel</button>
    <button class="btn btn-primary" onclick="saveAdminUser(${id})">Save</button>
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
  const res = await post('admin_panel_update_admin_user', payload);
  if (res.ok) { modal.close(); toast('Updated', 'success'); navigate('admin-users'); }
  else toast(res.error || 'Failed', 'error');
}

async function deleteAdminUser(id, username) {
  if (!confirm(`Delete admin user "${username}"? This cannot be undone.`)) return;
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
            ? `<button class="btn btn-danger btn-sm" onclick="revokeSession('${esc(s.token_full)}')">Revoke</button>` : ''}
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

async function revokeSession(token) {
  if (!confirm('Revoke this session?')) return;
  const res = await post('admin_panel_revoke_session', { token });
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
          ${u?.totp_enabled
            ? `<span class="badge badge-green">Enabled</span> <button class="btn btn-danger btn-sm" style="margin-left:8px" onclick="disable2fa()">Disable</button>`
            : `<span class="badge badge-gray">Disabled</span> <button class="btn btn-primary btn-sm" style="margin-left:8px" onclick="setup2fa()">Enable 2FA</button>`}
        </span></div>
      </div>
    `;
  },
});

async function setup2fa() {
  const res = await get('admin_panel_setup_totp');
  if (!res.ok) { toast(res.error || 'Failed', 'error'); return; }

  modal.open('Enable Two-Factor Auth', `
    <p style="color:var(--fg-dim);font-size:13px;margin-bottom:16px;">
      Scan this QR code with your authenticator app (Google Authenticator, Authy, 1Password…)
    </p>
    <div style="text-align:center;margin-bottom:16px;">
      <img src="${esc(res.qr_url)}" width="200" height="200" style="border-radius:8px;background:#fff;padding:8px;"/>
    </div>
    <div style="background:var(--bg-card-2);border-radius:8px;padding:10px;font-family:monospace;font-size:13px;text-align:center;letter-spacing:2px;margin-bottom:16px;">
      ${esc(res.secret)}
    </div>
    <p style="color:var(--fg-muted);font-size:12px;margin-bottom:12px;">
      Or enter the secret manually. Then enter the 6-digit code below to confirm.
    </p>
    <div class="form-group">
      <label class="form-label">Confirmation code</label>
      <input class="form-input" id="totp-confirm-code" type="text" inputmode="numeric" maxlength="6" placeholder="000000"/>
    </div>
  `, `
    <button class="btn btn-ghost" onclick="modal.close()">Cancel</button>
    <button class="btn btn-primary" onclick="confirm2fa()">Confirm & enable</button>
  `);
}

async function confirm2fa() {
  const code = document.getElementById('totp-confirm-code').value.trim();
  const res  = await post('admin_panel_confirm_totp', { code });
  if (res.ok) {
    modal.close();
    toast('2FA enabled', 'success');
    if (state.user) state.user.totp_enabled = true;
    navigate('my-account');
  } else {
    toast(res.error || 'Invalid code', 'error');
  }
}

async function disable2fa() {
  const pw = prompt('Enter your password to disable 2FA:');
  if (!pw) return;
  const res = await post('admin_panel_disable_totp', { password: pw });
  if (res.ok) {
    toast('2FA disabled', 'info');
    if (state.user) state.user.totp_enabled = false;
    navigate('my-account');
  } else {
    toast(res.error || 'Failed', 'error');
  }
}

Object.assign(window, { setup2fa, confirm2fa, disable2fa });

// ── Boot ──────────────────────────────────────────────────────────────────────

(async function boot() {
  const sessState = await checkSession().catch(() => false);

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
