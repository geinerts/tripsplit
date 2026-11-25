// Admin accounts, admin sessions and the signed-in admin's own 2FA.
import { get, post } from '../core/api.js?v=23';
import { actionAttrs, html } from '../core/html.js?v=23';
import { navigate, registerActions, registerView } from '../core/router.js?v=23';
import { state } from '../core/state.js?v=23';
import { askInModal, modal, relTime, roleBadge, toast } from '../core/ui.js?v=23';

const ROLES = ['readonly', 'support', 'ops', 'admin', 'superadmin'];

// ── Admin users ───────────────────────────────────────────────────────────────

registerView('admin-users', {
  title: 'Admin Users',
  async render() {
    const res = await get('admin_panel_admin_users');
    if (!res.ok) return html`<div class="empty-state">Access denied or error: ${res.error}</div>`;

    const cards = res.users.map(u => html`
      <div class="cl-item">
        <div class="cl-row mb-6">
          <div class="flex-fill">
            <div class="cl-title">${u.username}</div>
            <div class="cl-sub">${u.email}</div>
          </div>
          ${roleBadge(u.role)}
          ${u.is_active ? html`<span class="badge badge-green">active</span>` : html`<span class="badge badge-red">inactive</span>`}
        </div>
        <div class="cl-row">
          <span class="cl-meta">2FA: ${u.totp_enabled ? '✓' : '—'} · Last login: ${relTime(u.last_login_at)} · ${u.active_sessions} session${u.active_sessions !== 1 ? 's' : ''}</span>
        </div>
        <div class="cl-actions">
          <button class="btn btn-ghost btn-sm" ${actionAttrs('editAdminUser', u.id, u.username, u.role, u.is_active)}>Edit</button>
          ${u.id !== state.user?.id
            ? html`<button class="btn btn-danger btn-sm" ${actionAttrs('deleteAdminUser', u.id, u.username)}>Delete</button>` : ''}
        </div>
      </div>
    `);

    return html`
      <div class="section-header">
        <div class="section-title">Admin accounts</div>
        <button class="btn btn-primary btn-sm" ${actionAttrs('showCreateAdminModal')}>+ Add admin</button>
      </div>
      <div class="table-card flush">${cards}</div>
    `;
  },
});

function showCreateAdminModal() {
  modal.open('Create admin user', html`
    <div class="form-group"><label class="form-label" for="new-admin-username">Username</label><input class="form-input" id="new-admin-username" placeholder="johndoe"/></div>
    <div class="form-group"><label class="form-label" for="new-admin-email">Email</label><input class="form-input" id="new-admin-email" type="email" placeholder="john@example.com"/></div>
    <div class="form-group"><label class="form-label" for="new-admin-password">Password (min 12 chars)</label><input class="form-input" id="new-admin-password" type="password"/></div>
    <div class="form-group">
      <label class="form-label" for="new-admin-role">Role</label>
      <select class="form-input" id="new-admin-role">
        ${ROLES.map(r => html`<option value="${r}">${r}</option>`)}
      </select>
    </div>
  `, html`
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
  modal.open(`Edit: ${username}`, html`
    <div class="form-group">
      <label class="form-label" for="edit-admin-role">Role</label>
      <select class="form-input" id="edit-admin-role">
        ${ROLES.map(r => html`<option value="${r}" ${r === role ? html`selected` : ''}>${r}</option>`)}
      </select>
    </div>
    <div class="form-group">
      <label class="form-label" for="edit-admin-active">Status</label>
      <select class="form-input" id="edit-admin-active">
        <option value="1" ${isActive ? html`selected` : ''}>Active</option>
        <option value="0" ${!isActive ? html`selected` : ''}>Inactive</option>
      </select>
    </div>
    <div class="form-group">
      <label class="form-label" for="edit-admin-pw">New password (leave blank to keep)</label>
      <input class="form-input" id="edit-admin-pw" type="password" placeholder="(unchanged)"/>
    </div>
    ${id !== state.user?.id ? html`
    <div class="form-group">
      <label class="form-label"><input type="checkbox" id="edit-admin-reset-2fa"/> Reset 2FA (lost authenticator)</label>
      <p class="hint-small">Signs this admin out. They set up a new authenticator at the next login.</p>
    </div>` : ''}
  `, html`
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

// ── Admin sessions ────────────────────────────────────────────────────────────

registerView('sessions', {
  title: 'Active Sessions',
  async render() {
    const res = await get('admin_panel_active_sessions');
    if (!res.ok) return html`<div class="empty-state">Error: ${res.error}</div>`;
    if (!res.sessions.length) return html`<div class="empty-state">No active sessions found.</div>`;

    const rows = res.sessions.map(s => html`
      <tr class="${s.is_current ? 'current-row' : ''}">
        <td>${s.username || '—'} ${s.is_current ? html`<span class="badge badge-green">current</span>` : ''}</td>
        <td>${s.role ? roleBadge(s.role) : '—'}</td>
        <td>${s.ip_address}</td>
        <td class="ua-cell">${s.user_agent}</td>
        <td>${s.is_2fa_verified ? '✓' : '—'}</td>
        <td>${relTime(s.last_active_at)}</td>
        <td>
          ${!s.is_current
            ? html`<button class="btn btn-danger btn-sm" ${actionAttrs('revokeSession', s.session_id)}>Revoke</button>` : ''}
        </td>
      </tr>
    `);

    return html`
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

// ── My account ────────────────────────────────────────────────────────────────

registerView('my-account', {
  title: 'My Account',
  async render() {
    const u = state.user;
    return html`
      <div class="card narrow">
        <div class="card-title">Profile</div>
        <div class="detail-row"><span class="detail-label">Username</span><span class="detail-value">${u?.username}</span></div>
        <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value">${u?.email}</span></div>
        <div class="detail-row"><span class="detail-label">Role</span><span class="detail-value">${roleBadge(u?.role)}</span></div>
        <div class="detail-row"><span class="detail-label">2FA</span><span class="detail-value">
          <span class="badge badge-green">Enabled</span>
          <button class="btn btn-ghost btn-sm ml-8" ${actionAttrs('replace2fa')}>Replace authenticator</button>
        </span></div>
        <p class="hint">
          2FA is required for admin accounts. Lost your authenticator? Ask a superadmin to reset it,
          or use scripts/admin_totp.php on the server.
        </p>
      </div>
    `;
  },
});

// Replacing needs the password and a code from the current app; the old
// authenticator keeps working until the new one is confirmed.
function replace2fa() {
  modal.open('Replace authenticator', html`
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
  `, html`
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
  modal.open('New authenticator', html`
    <p class="secret-intro">
      Add a new account in your authenticator app and enter this setup key manually.
      Your current authenticator keeps working until you confirm.
    </p>
    <div class="setup-key">${secret}</div>
    <div class="form-group">
      <label class="form-label" for="totp-confirm-code">Code from the new app</label>
      <input class="form-input" id="totp-confirm-code" type="text" inputmode="numeric" maxlength="6" placeholder="000000"/>
    </div>
  `, html`
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

registerActions({
  showCreateAdminModal, createAdminUser, editAdminUser, saveAdminUser, deleteAdminUser,
  revokeSession, replace2fa, confirm2fa,
});
