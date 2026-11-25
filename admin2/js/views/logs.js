// Security overview, admin audit log and app events.
import { get } from '../core/api.js?v=25';
import { actionAttrs, html, setHtml } from '../core/html.js?v=25';
import { registerActions, registerView } from '../core/router.js?v=25';
import { can } from '../core/state.js?v=25';
import { auditTone, dayLabel, eventTone, sectionTabs, timeAgo } from '../core/ui.js?v=25';

// ── Plain-language descriptions ───────────────────────────────────────────────

const EVENT_TEXT = {
  'user.registered': 'signed up', 'user.login': 'signed in',
  'trip.created': 'created a trip', 'trip.updated': 'edited a trip', 'trip.deleted': 'deleted a trip',
  'trip.finished': 'finished a trip', 'trip.settled': 'settled a trip',
  'trip.all_members_ready': 'made the last member ready: everyone is ready to settle',
  'trip.member_ready': 'is ready to settle', 'trip.member_not_ready': 'is no longer ready to settle',
  'trip.member_joined': 'joined a trip', 'trip.member_left': 'left a trip', 'trip.member_removed': 'removed a trip member',
  'trip.member_role_updated': 'changed a member\'s role', 'trip.members_invited': 'invited people to a trip',
  'trip.invitation_declined': 'declined a trip invitation', 'trip.invitation_revoked': 'withdrew a trip invitation',
  'trip.guest_added': 'added a member without an account', 'trip.guest_renamed': 'renamed a member without an account',
  'expense.created': 'added an expense', 'expense.updated': 'edited an expense', 'expense.deleted': 'deleted an expense',
  'expense.comment_added': 'commented on an expense',
  'settlement.marked_sent': 'marked a settlement as paid', 'settlement.confirmed': 'confirmed receiving a payment',
  'settlement.not_received': 'reported a payment as not received', 'settlement.reminder_sent': 'sent a payment reminder',
  'settlement.sent_cancelled': 'took back a "paid" mark',
  'payment.requested': 'requested a payment', 'payment.marked_sent': 'marked a payment as sent',
  'quick_split.created': 'created a quick split', 'friend.accepted': 'accepted a friend request',
};

const AUDIT_TEXT = {
  'user.suspend': 'suspended', 'user.reactivate': 'reactivated', 'user.delete': 'deleted',
  'user.push_tokens.clear': 'cleared push tokens of', 'user.sessions.revoke_all': 'signed out everywhere:',
  'push.retry': 'retried', 'incident.create': 'opened', 'incident.update': 'updated',
  'admin_user.create': 'created admin', 'admin_user.update': 'changed admin', 'admin_user.delete': 'deleted admin',
  'admin.session.revoke': 'revoked an admin session', 'admin.auth.logout': 'signed out',
  'admin.auth.login_success': 'entered the correct password', 'admin.auth.2fa_success': 'signed in with 2FA',
  'admin.auth.login_failed': 'failed to sign in (wrong password)', 'admin.auth.2fa_failed': 'entered a wrong 2FA code',
  'admin.totp.enable': 'set up 2FA', 'admin.totp.replace': 'replaced their authenticator',
  'admin.totp.replace_started': 'started replacing their authenticator',
  'feature.mode_set': 'changed a feature\'s availability', 'feature.user_grant': 'allowed a feature for',
  'feature.user_revoke': 'removed a feature from',
};

const TARGET_LABELS = { user: 'user', admin_user: '', incident: 'incident', push_queue: 'push', session: 'session', trip: 'trip', expense: 'expense' };

function target(type, id) {
  if (!type && !id) return '';
  const label = TARGET_LABELS[type] ?? String(type || '').replace(/_/g, ' ');
  return [label, id ? `#${id}` : ''].filter(Boolean).join(' ');
}

// "added an expense · trip #3"; unknown codes fall back to a readable form.
export function describeEvent(e, { withTarget = true } = {}) {
  const text = EVENT_TEXT[e.event_type] || String(e.event_type).replace(/[._]/g, ' ');
  const what = withTarget ? target(e.entity_type, e.entity_id) : '';
  return what ? `${text} · ${what}` : text;
}

export function describeAudit(e, { withTarget = true } = {}) {
  const text = AUDIT_TEXT[e.action] || String(e.action).replace(/[._]/g, ' ');
  const what = withTarget ? target(e.target_type, e.target_id) : '';
  return what ? `${text} ${what}` : text;
}

const LOG_TABS = () => [['app-events', 'App activity'], ['audit-log', 'Admin actions'], ['security', 'Sign-ins & security', can('superadmin', 'admin')]];

// Entries are newest first; a header row starts each local day.
function byDay(entries, row) {
  let last = null;
  return entries.map(entry => {
    const day = dayLabel(entry.created_at);
    const header = day !== last ? html`<div class="day-header">${day}</div>` : '';
    last = day;
    return html`${header}${row(entry)}`;
  });
}

// ── Security ──────────────────────────────────────────────────────────────────

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
  title: 'Logs',
  nav: 'app-events',
  async render() {
    const res = await get('admin_panel_security_overview');
    if (!res.ok) return html`<div class="empty-state">${res.error || 'Failed to load.'}</div>`;
    const c = res.counts_7d || {};
    const events = (res.events || []).map(e => {
      const [label, cls] = SECURITY_ACTION_LABELS[e.action] || [e.action, 'badge-gray'];
      return html`<div class="cl-item"><div class="cl-row">
        <span class="badge ${cls}">${label}</span>
        <div class="flex-fill ml-10"><div class="cl-sub m-0">${e.admin_username} · ${e.ip_address || '—'}</div></div>
        <span class="timeline-meta">${timeAgo(e.created_at)}</span></div></div>`;
    });
    const limits = (res.rate_limits_24h || []).map(r => html`
      <tr><td class="mono-cell">${r.scope}</td>
      <td>${r.peak}</td><td>${r.requests}</td><td>${r.windows}</td></tr>`);
    return html`
      ${sectionTabs(LOG_TABS(), 'security')}
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
        ${events.length ? events : html`<div class="empty-state pad-24">No sign-in or security events in the last 7 days</div>`}
      </div>
      <div class="table-card">
        <div class="table-card-header"><div class="table-card-title">🚦 Rate limits (24 h)</div></div>
        ${limits.length ? html`<div class="table-wrap flat"><table>
          <thead><tr><th>Scope</th><th>Peak in one window</th><th>Requests</th><th>Windows</th></tr></thead>
          <tbody>${limits}</tbody></table></div>` : html`<div class="empty-state pad-24">No rate-limited requests in the last 24 hours</div>`}
        <div class="cl-sub note-pad">A high peak for one scope means one IP or account sent many requests in a short window. Subjects are stored only as hashes.</div>
      </div>`;
  },
});

// ── Shared list page with Prev/Next ───────────────────────────────────────────

function pagedList(cards, offset, total, action) {
  const prevBtn = offset > 0
    ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs(action, offset - 50)}>← Prev</button>` : '';
  const nextBtn = (offset + 50) < total
    ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs(action, offset + 50)}>Next →</button>` : '';
  return html`
    <div class="table-card flush">${cards}</div>
    <div class="pagination">${offset + 1}–${Math.min(offset + 50, total)} of ${total} ${prevBtn} ${nextBtn}</div>
  `;
}

const loading = html`<div class="loading-state"><span class="spinner"></span></div>`;

// ── Audit log ─────────────────────────────────────────────────────────────────

registerView('audit-log', {
  title: 'Logs',
  nav: 'app-events',
  async render() {
    return html`
      ${sectionTabs(LOG_TABS(), 'audit-log')}
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="audit-action-filter" placeholder="Filter by action (e.g. user.suspend)…" aria-label="Filter by action"/>
        </div>
        <select class="form-input w-auto" id="audit-target-filter" aria-label="Target">
          <option value="">All targets</option>
          <option value="user">user</option>
          <option value="admin_user">admin_user</option>
          <option value="incident">incident</option>
          <option value="push_queue">push_queue</option>
          <option value="session">session</option>
        </select>
        <button class="btn btn-ghost btn-sm" id="audit-search-btn">Filter</button>
      </div>
      <div id="audit-results">${loading}</div>
    `;
  },
  init() {
    loadAuditLog(0);
    document.getElementById('audit-search-btn').addEventListener('click', () => loadAuditLog(0));
  },
});

async function loadAuditLog(offset = 0) {
  const results = document.getElementById('audit-results');
  if (!results) return;
  const action = document.getElementById('audit-action-filter').value.trim();
  const target = document.getElementById('audit-target-filter').value;
  setHtml(results, loading);

  const res = await get('admin_panel_audit_log', { action_filter: action, target, limit: 50, offset });
  if (!res.ok) { setHtml(results, html`<div class="empty-state">Error: ${res.error}</div>`); return; }
  if (!res.log.length) { setHtml(results, html`<div class="empty-state">No audit entries found.</div>`); return; }

  const cards = byDay(res.log, entry => html`
      <div class="cl-item">
        <div class="cl-row mb-5">
          <span class="log-line"><strong>${entry.admin_username}</strong> ${describeAudit(entry, { withTarget: false })}</span>
          <span class="log-time">${timeAgo(entry.created_at)}</span>
        </div>
        <div class="cl-meta">
          <span class="event-code text-${auditTone(entry.action)}">${entry.action}</span>
          ${entry.target_type ? ` · ${entry.target_type}${entry.target_id ? ` #${entry.target_id}` : ''}` : ''}
          ${entry.ip_address ? ` · ${entry.ip_address}` : ''}
        </div>
        ${entry.details ? html`<div class="log-details">${JSON.stringify(entry.details).slice(0,120)}</div>` : ''}
      </div>
    `);
  setHtml(results, pagedList(cards, offset, res.total, 'loadAuditLog'));
}

// ── App events ────────────────────────────────────────────────────────────────

registerView('app-events', {
  title: 'Logs',
  async render() {
    return html`
      ${sectionTabs(LOG_TABS(), 'app-events')}
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="app-event-filter" placeholder="Filter by event type (e.g. trip.created)…" aria-label="Filter by event type"/>
        </div>
        <button class="btn btn-ghost btn-sm" id="app-events-search-btn">Filter</button>
      </div>
      <div id="app-events-results">${loading}</div>
    `;
  },
  init() {
    loadAppEvents(0);
    document.getElementById('app-events-search-btn').addEventListener('click', () => loadAppEvents(0));
  },
});

async function loadAppEvents(offset = 0) {
  const results = document.getElementById('app-events-results');
  if (!results) return;
  const typeFilter = document.getElementById('app-event-filter').value.trim();
  setHtml(results, loading);

  const res = await get('admin_panel_app_events', { event_type: typeFilter, limit: 50, offset });
  if (!res.ok) { setHtml(results, html`<div class="empty-state">Error: ${res.error}</div>`); return; }
  if (!res.events.length) { setHtml(results, html`<div class="empty-state">No events found.</div>`); return; }

  const cards = byDay(res.events, entry => html`
    <div class="cl-item">
      <div class="cl-row mb-5">
        <span class="log-line"><strong>${entry.username || 'Deleted user'}</strong> ${describeEvent(entry, { withTarget: false })}</span>
        <span class="log-time">${timeAgo(entry.created_at)}</span>
      </div>
      <div class="cl-meta">
        <span class="event-code text-${eventTone(entry.event_type)}">${entry.event_type}</span>
        ${entry.entity_type ? ` · ${entry.entity_type}${entry.entity_id ? ` #${entry.entity_id}` : ''}` : ''}
      </div>
    </div>
  `);
  setHtml(results, pagedList(cards, offset, res.total, 'loadAppEvents'));
}

registerActions({ loadAuditLog, loadAppEvents });
