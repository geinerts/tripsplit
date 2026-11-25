// Premium is an expiring, audited grant, independent from paid subscriptions
// (docs/api/trip-premium.md). Changes need verified 2FA and the X-Premium-CSRF token.
import { API, get } from '../core/api.js?v=25';
import { actionAttrs, html, setHtml } from '../core/html.js?v=25';
import { registerActions, registerView } from '../core/router.js?v=25';
import { can, state } from '../core/state.js?v=25';
import { modal, sectionTabs, toast } from '../core/ui.js?v=25';
import { openUserDetail } from './users.js?v=25';

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
    return html`<div>${before?.ends_at ? html`${premiumDate(before.ends_at)} &rarr; ` : 'Until '}${premiumDate(after.ends_at)}</div>`;
  } catch { return ''; }
}

export function premiumDetailHtml(premium, user) {
  if (!premium) return '';
  const access = premium.access || {};
  const title = access.plan === 'premium' ? `Premium until ${premiumDate(access.expires_at)}`
    : access.plan === 'free' ? 'Free' : 'Status unavailable';
  const controls = premium.can_manage && user.account_status === 'active';
  return html`<section class="premium-section"><h3>${title}</h3>
    ${controls ? html`<button class="btn btn-primary btn-sm" ${actionAttrs('openPremiumForm', 'grant_create', user.id)}>Grant Premium</button>` : ''}
    ${(premium.grants || []).map(g => html`<div class="premium-entry">
      <div><strong>${g.partner_name || g.source}</strong> <span class="badge badge-gray">${premiumStatus({...g, account_status: user.account_status})}</span></div>
      <div>${premiumDate(g.starts_at)} - ${premiumDate(g.ends_at)}</div>
      <div>${g.reason}</div>
      ${premium.can_manage && !g.revoked_at ? html`<div class="premium-actions">
        ${controls ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs('openPremiumForm', 'grant_extend', user.id, g.id)}>Extend</button>` : ''}
        <button class="btn btn-danger btn-sm" ${actionAttrs('openPremiumForm', 'grant_revoke', user.id, g.id)}>Revoke</button></div>` : ''}
    </div>`)}
    ${(premium.history || []).length ? html`<details><summary>Premium history (latest 100)</summary>${premium.history.map(h =>
      html`<div class="premium-entry"><strong>${h.action.replace('grant_', '')}</strong> &middot; ${h.admin_username}
      <div>${premiumDate(h.created_at)}</div>${premiumHistoryDates(h)}<div>${h.reason}</div></div>`)}</details>` : ''}
    ${!premium.can_manage && can('superadmin') ? html`<p class="muted">Changes require enabled and verified two-factor authentication.</p>` : ''}
  </section>`;
}

for (const kind of ['premium', 'partners']) {
  registerView(kind, {
    title: 'Premium',
    nav: 'premium',
    async render() {
      if (!can('superadmin', 'admin')) throw new Error('Access denied.');
      return html`${sectionTabs([['premium', 'Grants'], ['partners', 'Partners']], kind)}<div class="toolbar"><input class="form-input" id="premium-search" type="search" placeholder="Search ${kind}" aria-label="Search ${kind}">
        ${kind === 'premium' ? html`<select class="form-input" id="premium-status" aria-label="Status"><option value="active">Active</option><option value="expiring">Expiring in 14 days</option><option value="expired">Expired</option><option value="revoked">Revoked</option><option value="all">All</option></select>` : ''}
        <button class="btn btn-ghost" id="premium-filter">Filter</button>
        ${kind === 'partners' ? html`<button class="btn btn-primary" id="partner-create" hidden>Add partner</button>` : ''}</div>
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
  setHtml(target, html`<div class="loading-state">Loading...</div>`);
  try {
    const result = await get('admin_panel_premium_list', params);
    if (sequence !== premiumListSequence || !target.isConnected) return;
    if (!result.ok) throw new Error(result.error || 'Unable to load Premium.');
    const create = document.getElementById('partner-create');
    if (create) create.hidden = !result.can_manage;
    setHtml(target, html`${params.partner_id ? html`<p>Partner filter active <button class="btn btn-ghost btn-sm" ${actionAttrs('navigate', 'premium')}>Clear</button></p>` : ''}
      ${result.rows.length ? html`<div class="table-wrap"><table><thead><tr>${kind === 'partners' ? html`<th>Partner</th><th>Active grants</th><th></th>` : html`<th>User</th><th>Partner / Source</th><th>Until</th><th>Status</th><th></th>`}</tr></thead><tbody>
      ${result.rows.map(r => kind === 'partners'
        ? html`<tr><td>${r.name}</td><td>${Number(r.active_grants)}</td><td><button class="btn btn-ghost btn-sm" ${actionAttrs('navigate', 'premium', {partnerId:r.id})}>View grants</button></td></tr>`
        : html`<tr><td>${r.nickname}</td><td>${r.partner_name || r.source}</td><td>${premiumDate(r.ends_at)}</td><td>${premiumStatus(r)}</td><td><button class="btn btn-ghost btn-sm" ${actionAttrs('openUserDetail', r.user_id)}>View user</button></td></tr>`)}</tbody></table></div>`
        : html`<div class="empty-state">No matching records</div>`}
      <div class="premium-actions"><button class="btn btn-ghost" ${offset === 0 ? html`disabled` : ''} ${actionAttrs('premiumPage', Math.max(0, offset - 40))}>Previous</button>
      <button class="btn btn-ghost" ${!result.has_more ? html`disabled` : ''} ${actionAttrs('premiumPage', offset + 40)}>Next</button></div>`);
  } catch (error) {
    if (target.isConnected && sequence === premiumListSequence) setHtml(target, html`<div class="empty-state">${error.message}</div>`);
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
  modal.open(title, html`<form id="premium-form" class="premium-form">
    ${isPartner ? html`<label>Partner name<input class="form-input" name="name" required maxlength="120"></label>` : html`<p><strong>${result.user.nickname}</strong> &middot; ${result.user.email}</p>`}
    ${isCreate ? html`<label>Source<select class="form-input" name="source"><option value="testing">Testing</option><option value="partner">Partner</option><option value="compensation">Compensation</option></select></label>
      <label id="premium-partner-label" hidden>Partner<select class="form-input" name="partner_id" disabled><option value="">Select partner</option></select></label>` : ''}
    ${needsDate ? html`<label>Expires (your local time)<input class="form-input" name="ends_at" type="datetime-local" required></label>` : ''}
    ${isTrip ? html`<p>Trip: <strong>${trip.name}</strong>. Trip Premium covers every current member of this trip and has no end date.</p>` : ''}
    ${operation === 'trip_grant_create' ? html`<label>Source<select class="form-input" name="source"><option value="testing">Testing</option><option value="compensation">Compensation</option></select></label>` : ''}
    ${operation === 'grant_revoke' ? html`<p>This revokes only this grant. Other valid grants remain active.</p>` : ''}
    <label>Reason<textarea class="form-input" name="reason" required maxlength="500" rows="3"></textarea></label>
    <p id="premium-form-error" role="alert"></p>
    <div class="premium-actions"><button type="button" class="btn btn-ghost" ${actionAttrs('closeModal')}>Cancel</button><button type="submit" class="btn btn-primary">${title}</button></div>
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

registerActions({ openPremiumForm, premiumPage });
