import { get, post } from '../core/api.js?v=25';
import { actionAttrs, html, join, setHtml } from '../core/html.js?v=25';
import { navigate, registerActions, registerView, reloadView, routePath } from '../core/router.js?v=25';
import { can, state } from '../core/state.js?v=25';
import { askInModal, relTime, statusBadge, toast } from '../core/ui.js?v=25';
import { userFeaturesHtml } from './features.js?v=25';
import { premiumDetailHtml } from './premium.js?v=25';

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
  render(data) {
    return data.id ? renderUserPage(data) : renderUserList(data);
  },
  init(data) {
    if (data.id) initUserPage();
    else initUserList();
  },
});

async function renderUserList(data) {
  const layout = usersLayout();
  const option = (value, label) => html`<option value="${value}">${label}</option>`;
  return html`
    <div class="toolbar">
      <div class="toolbar-search">
        <input type="search" id="user-search-inp" placeholder="Search by name or email…" aria-label="Search users" value="${data.q || ''}"/>
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
}

function initUserList() {
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
}

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

  const query = userSearchQuery(offset);
  // Keep the search text in the address so reload and back return to the same results.
  if (state.view === 'users' && !state.viewData.id) {
    state.viewData = query.q ? { q: query.q } : {};
    history.replaceState(null, '', routePath('users', state.viewData));
  }
  const res = await get('admin_panel_user_search', query);
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

// Opens the user's own page (#/users/<id>); on that page already, reloads it in place.
export function openUserDetail(userId) {
  if (state.view === 'users' && String(state.viewData.id) === String(userId)) return reloadView();
  return navigate('users', { id: userId });
}

const USER_TABS = [
  ['overview', 'Overview'], ['trips', 'Trips'], ['premium', 'Premium'], ['devices', 'Devices'], ['activity', 'Activity'],
];

async function renderUserPage(data) {
  const back = html`<button type="button" class="back-link" ${actionAttrs('navigate', 'users')}>← All users</button>`;
  const res = await get('admin_panel_user_detail', { user_id: Number(data.id) });
  if (!res.ok) return html`${back}<div class="empty-state">${res.error || 'User not found.'}</div>`;

  const u  = res.user;
  const sessions = res.sessions || [];
  const timeline = res.timeline || [];
  const tripRows = userTripsHtml(res, u);
  const tab = USER_TABS.some(([key]) => key === data.tab) ? data.tab : 'overview';
  const support = can('superadmin', 'admin', 'support');

  // Reversible support actions sit in the header; account-level ones in the danger zone.
  const quick = [];
  if (support) quick.push(html`<button class="btn btn-ghost btn-sm" ${actionAttrs('clearPushTokens', u.id)}>Clear push tokens</button>`);
  if (support && sessions.length) quick.push(html`<button class="btn btn-ghost btn-sm" ${actionAttrs('signOutEverywhere', u.id, u.nickname)}>Sign out everywhere</button>`);

  const danger = [];
  if (u.account_status === 'active' && support)
    danger.push(html`<div class="danger-row"><div><strong>Suspend account</strong><p>Signs the user out; they cannot use the app until reactivated.</p></div>
      <button class="btn btn-amber btn-sm" ${actionAttrs('suspendUser', u.id, u.nickname)}>Suspend</button></div>`);
  if (u.account_status === 'deactivated' && support)
    danger.push(html`<div class="danger-row"><div><strong>Reactivate account</strong><p>The user can sign in again.</p></div>
      <button class="btn btn-ghost btn-sm" ${actionAttrs('reactivateUser', u.id, u.nickname)}>Reactivate</button></div>`);
  if (can('superadmin', 'admin') && u.account_status !== 'deleted')
    danger.push(html`<div class="danger-row"><div><strong>Delete account</strong><p>Cannot be undone. Shared trip history stays as "Deleted User".</p></div>
      <button class="btn btn-danger btn-sm" ${actionAttrs('deleteUser', u.id, u.nickname)}>Delete user</button></div>`);

  const counts = { trips: (res.trips || []).length, devices: sessions.length, activity: timeline.length };
  const panels = {
    overview: html`
      <div class="card">
        <div class="detail-row"><span class="detail-label">Joined</span><span class="detail-value">${relTime(u.created_at)}</span></div>
        <div class="detail-row"><span class="detail-label">Unread notifs</span><span class="detail-value">${res.unread_notifs}</span></div>
        <div class="detail-row"><span class="detail-label">Sign-in &amp; apps</span><span class="detail-value user-signals">${userSignalBadges(u)}</span></div>
        <div class="detail-row"><span class="detail-label">Push tokens</span><span class="detail-value">${pushTokenSummary(res.push_tokens || [])}</span></div>
        ${userFeaturesHtml(res.features || [], u)}
      </div>
      ${danger.length ? html`<section class="danger-zone" aria-labelledby="danger-title">
        <h3 id="danger-title">Danger zone</h3>${danger}</section>` : ''}`,
    trips: html`<div class="card">${tripRows.length ? tripRows : html`<div class="empty-state pad-8">No trips</div>`}</div>`,
    premium: html`<div class="card">${premiumDetailHtml(res.premium, u) || html`<div class="empty-state pad-8">Premium status unavailable.</div>`}</div>`,
    devices: html`<div class="card">${userSessionsHtml(sessions)}</div>`,
    activity: html`<div class="card">${userTimelineHtml(timeline)}</div>`,
  };

  return html`
    ${back}
    <header class="user-page-head">
      <span class="user-avatar large" data-hue="${userAvatarHue(u.id)}" aria-hidden="true">${userInitials(u.nickname)}</span>
      <div class="flex-fill">
        <h2 class="user-page-name">${u.nickname}</h2>
        <div class="cl-sub">${u.email || '—'} · #${u.id}</div>
      </div>
      ${statusBadge(u.account_status)}
      ${quick.length ? html`<div class="user-page-actions">${quick}</div>` : ''}
    </header>
    <div class="tabs" role="tablist" aria-label="User sections">
      ${USER_TABS.map(([key, label]) => html`<button type="button" class="tab" role="tab" id="user-tab-${key}"
        aria-controls="user-panel-${key}" aria-selected="${String(key === tab)}" tabindex="${key === tab ? '0' : '-1'}"
        data-user-tab="${key}">${label}${counts[key] !== undefined ? html` <span class="tab-count">${counts[key]}</span>` : ''}</button>`)}
    </div>
    ${USER_TABS.map(([key]) => html`<section class="tab-panel" role="tabpanel" id="user-panel-${key}"
      aria-labelledby="user-tab-${key}" ${key === tab ? '' : html`hidden`}>${panels[key]}</section>`)}
  `;
}

// Tabs switch in place; the tab is kept in the address without a new history entry.
function initUserPage() {
  const tabs = [...document.querySelectorAll('[data-user-tab]')];
  const select = tab => {
    for (const el of tabs) {
      const on = el === tab;
      el.setAttribute('aria-selected', String(on));
      el.tabIndex = on ? 0 : -1;
      document.getElementById(el.getAttribute('aria-controls')).hidden = !on;
    }
    const key = tab.dataset.userTab;
    state.viewData = { ...state.viewData, tab: key === 'overview' ? undefined : key };
    history.replaceState(null, '', routePath('users', state.viewData));
  };
  for (const tab of tabs) {
    tab.addEventListener('click', () => select(tab));
    tab.addEventListener('keydown', e => {
      const step = e.key === 'ArrowRight' ? 1 : e.key === 'ArrowLeft' ? -1 : 0;
      if (!step) return;
      const next = tabs[(tabs.indexOf(tab) + step + tabs.length) % tabs.length];
      next.focus();
      select(next);
    });
  }
}

function userTripsHtml(res, u) {
  const tripGrants = res.premium?.trip_grants || [];
  const canManageTrips = Boolean(res.premium?.can_manage);
  return (res.trips || []).map(t => {
    const grant = tripGrants.find(g => Number(g.trip_id) === Number(t.id));
    const button = !canManageTrips ? '' : grant
      ? html`<button class="btn btn-danger btn-sm" ${actionAttrs('openPremiumForm', 'trip_grant_revoke', u.id, grant.id)}>Revoke trip Premium</button>`
      : html`<button class="btn btn-ghost btn-sm" ${actionAttrs('openPremiumForm', 'trip_grant_create', u.id, t.id)}>Grant trip Premium</button>`;
    const members = Number(t.members_count) || 0;
    return html`<div class="detail-row"><span><span>${t.name}</span> <span class="muted-inline">· ${members} member${members === 1 ? '' : 's'}</span></span><span class="trip-premium-row">
      <span class="badge badge-gray">${t.status}</span>${grant ? html`<span class="badge">Trip Premium</span>` : ''}${button}</span></div>`;
  });
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

function refreshAfterAction() {
  if (state.view === 'users' && state.viewData.id) reloadView();
  else userSearch(usersState.offset);
}

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
  if (res.ok) { toast(`${name} suspended`, 'success'); refreshAfterAction(); }
  else toast(res.error || 'Failed', 'error');
}

async function reactivateUser(userId, name) {
  const res = await post('admin_panel_user_reactivate', { user_id: userId, reason: 'admin action' });
  if (res.ok) { toast(`${name} reactivated`, 'success'); refreshAfterAction(); }
  else toast(res.error || 'Failed', 'error');
}

async function deleteUser(userId, name) {
  const reason = await askInModal({ title: `Delete ${name}?`, confirmLabel: 'Delete user', danger: true,
    message: 'This cannot be undone. Personal data, sign-in links, friends, sessions and push tokens are erased; shared trip history stays as "Deleted User".',
    input: { label: 'Reason', required: true } });
  if (!reason) return;
  const res = await post('admin_panel_user_delete', { user_id: userId, reason });
  if (res.ok) { toast(`${name} deleted`, 'success'); refreshAfterAction(); }
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
