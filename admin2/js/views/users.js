import { get, post } from '../core/api.js?v=23';
import { actionAttrs, html, join, setHtml } from '../core/html.js?v=23';
import { registerActions, registerView } from '../core/router.js?v=23';
import { can } from '../core/state.js?v=23';
import { askInModal, modal, relTime, statusBadge, toast } from '../core/ui.js?v=23';
import { userFeaturesHtml } from './features.js?v=23';
import { premiumDetailHtml } from './premium.js?v=23';

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
    const option = (value, label) => html`<option value="${value}">${label}</option>`;
    return html`
      <div class="toolbar">
        <div class="toolbar-search">
          <input type="search" id="user-search-inp" placeholder="Search by name or email…" aria-label="Search users"/>
        </div>
        <button class="btn btn-ghost btn-sm" id="user-search-btn">Search</button>
        <div class="segmented" role="group" aria-label="Layout">
          <button type="button" class="segmented-btn" data-users-layout="list" aria-pressed="${String(layout === 'list')}">☰ List</button>
          <button type="button" class="segmented-btn" data-users-layout="grid" aria-pressed="${String(layout === 'grid')}">▦ Grid</button>
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
  const actions = [html`<button class="btn btn-ghost btn-sm" ${actionAttrs('openUserDetail', u.id)}>View</button>`];
  if (u.account_status === 'active' && can('superadmin', 'admin', 'support'))
    actions.push(html`<button class="btn btn-amber btn-sm" ${actionAttrs('suspendUser', u.id, u.nickname)}>Suspend</button>`);
  if (u.account_status === 'deactivated' && can('superadmin', 'admin', 'support'))
    actions.push(html`<button class="btn btn-ghost btn-sm" ${actionAttrs('reactivateUser', u.id, u.nickname)}>Reactivate</button>`);
  return actions;
}

function userFacts(u, premiumForEveryone) {
  const trips = `${u.trips_count} trip${u.trips_count === 1 ? '' : 's'}`;
  const premium = u.premium_grant ? html`<span class="badge badge-green">Premium</span>`
    : premiumForEveryone && u.account_status === 'active' ? html`<span class="badge badge-gray">Premium (launch)</span>` : '';
  const active = u.last_active_at ? `Active ${relTime(u.last_active_at)}` : 'No session use';
  return html`<span>${trips}</span><span>·</span><span title="Last session use">${active}</span><span>·</span><span>Joined ${relTime(u.created_at)}</span>${premium}`;
}

function userListItem(u, premiumForEveryone) {
  return html`
    <div class="cl-item">
      <div class="cl-row mb-6">
        <span class="user-avatar" data-hue="${userAvatarHue(u.id)}" aria-hidden="true">${userInitials(u.nickname)}</span>
        <div class="flex-fill">
          <div class="cl-title">${u.nickname}</div>
          <div class="cl-sub">${u.email || '—'}</div>
        </div>
        ${statusBadge(u.account_status)}
      </div>
      <div class="user-signals">${userSignalBadges(u)}</div>
      <div class="user-facts">${userFacts(u, premiumForEveryone)}</div>
      <div class="cl-actions">${userActions(u)}</div>
    </div>`;
}

function userGridCard(u, premiumForEveryone) {
  return html`
    <article class="user-card">
      <div class="user-card-head">
        <span class="user-avatar large" data-hue="${userAvatarHue(u.id)}" aria-hidden="true">${userInitials(u.nickname)}</span>
        ${statusBadge(u.account_status)}
      </div>
      <div class="cl-title">${u.nickname}</div>
      <div class="cl-sub">${u.email || '—'}</div>
      <div class="user-signals">${userSignalBadges(u)}</div>
      <div class="user-facts">${userFacts(u, premiumForEveryone)}</div>
      <div class="cl-actions">${userActions(u)}</div>
    </article>`;
}

export async function userSearch(offset = 0) {
  usersState.offset = offset;
  const results = document.getElementById('user-results');
  if (!results) return;
  setHtml(results, html`<div class="loading-state"><span class="spinner"></span></div>`);

  const res = await get('admin_panel_user_search', userSearchQuery(offset));
  if (!res.ok) { setHtml(results, html`<div class="empty-state">Error: ${res.error}</div>`); return; }
  if (!res.users.length) { setHtml(results, html`<div class="empty-state">No users found.</div>`); return; }

  const everyone = Boolean(res.premium_for_everyone);
  const body = usersLayout() === 'grid'
    ? html`<div class="user-grid">${res.users.map(u => userGridCard(u, everyone))}</div>`
    : html`<div class="table-card flush">${res.users.map(u => userListItem(u, everyone))}</div>`;

  const prevBtn = offset > 0
    ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs('userSearch', offset - 40)}>← Prev</button>` : '';
  const nextBtn = (offset + 40) < res.total
    ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs('userSearch', offset + 40)}>Next →</button>` : '';

  setHtml(results, html`${body}
    <div class="pagination">
      Showing ${offset + 1}–${Math.min(offset + 40, res.total)} of ${res.total}
      ${prevBtn} ${nextBtn}
    </div>`);
}

const SIGN_IN_LABELS = { email: 'Email', apple: 'Apple', google: 'Google' };
const PLATFORM_LABELS = { ios: 'iOS', android: 'Android', web: 'Web' };

// How the account signs in, which apps registered for push, and email verification.
function userSignalBadges(u) {
  const methods = (u.sign_in_methods || []).map(m => html`<span class="badge badge-blue">${SIGN_IN_LABELS[m] || m}</span>`);
  const platforms = (u.platforms || []).map(p => html`<span class="badge badge-purple">${PLATFORM_LABELS[p] || p}</span>`);
  const parts = [...methods, ...platforms];
  if (!methods.length) parts.push(html`<span class="badge badge-gray">No sign-in</span>`);
  if (!platforms.length) parts.push(html`<span class="badge badge-gray">No app push</span>`);
  if (u.email_verified === false && u.email) parts.push(html`<span class="badge badge-amber">Email not verified</span>`);
  return parts;
}

export async function openUserDetail(userId) {
  modal.open('User detail', html`<div class="loading-state"><span class="spinner"></span> Loading…</div>`);
  const res = await get('admin_panel_user_detail', { user_id: userId });
  if (!res.ok) { modal.open('Error', html`<div class="empty-state">${res.error}</div>`); return; }

  const u  = res.user;
  const tripGrants = res.premium?.trip_grants || [];
  const canManageTrips = Boolean(res.premium?.can_manage);
  const trips = (res.trips || []).map(t => {
    const grant = tripGrants.find(g => Number(g.trip_id) === Number(t.id));
    const button = !canManageTrips ? '' : grant
      ? html`<button class="btn btn-danger btn-sm" ${actionAttrs('openPremiumForm', 'trip_grant_revoke', u.id, grant.id)}>Revoke trip Premium</button>`
      : html`<button class="btn btn-ghost btn-sm" ${actionAttrs('openPremiumForm', 'trip_grant_create', u.id, t.id)}>Grant trip Premium</button>`;
    const members = Number(t.members_count) || 0;
    return html`<div class="detail-row"><span><span>${t.name}</span> <span class="muted-inline">· ${members} member${members === 1 ? '' : 's'}</span></span><span class="trip-premium-row">
      <span class="badge badge-gray">${t.status}</span>${grant ? html`<span class="badge">Trip Premium</span>` : ''}${button}</span></div>`;
  });

  const actions = [];
  if (u.account_status === 'active' && can('superadmin','admin','support'))
    actions.push(html`<button class="btn btn-amber btn-sm" data-close-modal ${actionAttrs('suspendUser', u.id, u.nickname)}>Suspend</button>`);
  if (u.account_status === 'deactivated' && can('superadmin','admin','support'))
    actions.push(html`<button class="btn btn-ghost btn-sm" data-close-modal ${actionAttrs('reactivateUser', u.id, u.nickname)}>Reactivate</button>`);
  if (can('superadmin','admin','support'))
    actions.push(html`<button class="btn btn-ghost btn-sm" data-close-modal ${actionAttrs('clearPushTokens', u.id)}>Clear push tokens</button>`);
  if (can('superadmin','admin','support') && (res.sessions || []).length)
    actions.push(html`<button class="btn btn-amber btn-sm" data-close-modal ${actionAttrs('signOutEverywhere', u.id, u.nickname)}>Sign out everywhere</button>`);
  if (can('superadmin','admin'))
    actions.push(html`<button class="btn btn-danger btn-sm" data-close-modal ${actionAttrs('deleteUser', u.id, u.nickname)}>Delete user</button>`);

  modal.open('User: ' + u.nickname, html`
    <div class="detail-row"><span class="detail-label">ID</span><span class="detail-value">${u.id}</span></div>
    <div class="detail-row"><span class="detail-label">Email</span><span class="detail-value">${u.email}</span></div>
    <div class="detail-row"><span class="detail-label">Status</span><span class="detail-value">${statusBadge(u.account_status)}</span></div>
    <div class="detail-row"><span class="detail-label">Joined</span><span class="detail-value">${relTime(u.created_at)}</span></div>
    <div class="detail-row"><span class="detail-label">Unread notifs</span><span class="detail-value">${res.unread_notifs}</span></div>
    <div class="detail-row"><span class="detail-label">Sign-in &amp; apps</span><span class="detail-value user-signals">${userSignalBadges(u)}</span></div>
    <div class="detail-row"><span class="detail-label">Push tokens</span><span class="detail-value">${pushTokenSummary(res.push_tokens || [])}</span></div>
    ${userFeaturesHtml(res.features || [], u)}
    <div class="detail-section-title mt-14">Recent trips</div>
    ${trips.length ? trips : html`<div class="empty-state pad-8">No trips</div>`}
    ${premiumDetailHtml(res.premium, u)}
    <div class="detail-section-title">Signed-in devices (${(res.sessions || []).length})</div>
    ${userSessionsHtml(res.sessions || [])}
    <div class="detail-section-title">Recent activity</div>
    ${userTimelineHtml(res.timeline || [])}
    <div class="action-row">${actions}</div>
  `, html`<button class="btn btn-ghost" ${actionAttrs('closeModal')}>Close</button>`);
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
  if (!sessions.length) return html`<div class="empty-state pad-8">No active sessions</div>`;
  return sessions.map(s => html`
    <div class="detail-row"><span title="${s.user_agent}">${deviceLabel(s.user_agent)}</span>
      <span class="detail-value session-meta">used ${relTime(s.last_used_at || s.created_at)} · since ${relTime(s.created_at)}</span></div>`);
}

function userTimelineHtml(events) {
  if (!events.length) return html`<div class="empty-state pad-8">No recorded activity</div>`;
  return html`<div class="user-timeline">${events.map(e => html`
    <div class="timeline-row">
      <span class="timeline-event">${e.event_type}</span>
      <span class="timeline-meta">${e.trip_name ? `${e.trip_name} · ` : ''}${relTime(e.created_at)}</span>
    </div>`)}</div>`;
}

function pushTokenSummary(tokens) {
  if (!tokens.length) return '0';
  return join(tokens.map(t => html`${PLATFORM_LABELS[String(t.platform).toLowerCase()] || t.platform}${Number(t.is_active) === 1 ? '' : ' (inactive)'} · ${relTime(t.last_seen_at)}`), html`<br>`);
}

// ── Account actions ───────────────────────────────────────────────────────────

async function signOutEverywhere(userId, name) {
  if (!await askInModal({ title: `Sign ${name} out everywhere?`, confirmLabel: 'Sign out', danger: true,
    message: 'Every app session ends now. The account stays active and the user can sign in again.' })) return;
  const res = await post('admin_panel_user_sign_out_everywhere', { user_id: userId });
  if (res.ok) toast(`${res.revoked} session(s) signed out`, 'success');
  else toast(res.error || 'Failed', 'error');
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

registerActions({ userSearch, openUserDetail, suspendUser, reactivateUser, deleteUser, clearPushTokens, signOutEverywhere });
