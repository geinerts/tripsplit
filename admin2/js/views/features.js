// Feature flags (docs/api/feature-flags.md) and the receipt AI budget.
import { get, post } from '../core/api.js?v=25';
import { actionAttrs, html } from '../core/html.js?v=25';
import { navigate, registerActions, registerView } from '../core/router.js?v=25';
import { can, state } from '../core/state.js?v=25';
import { askInModal, relTime, toast } from '../core/ui.js?v=25';
import { openUserDetail } from './users.js?v=25';

const FEATURE_MODE_LABELS = { off: 'Off for everyone', allowlist: 'Allowed accounts only', everyone: 'Everyone' };
const FEATURE_MODE_BADGES = { off: 'badge-gray', allowlist: 'badge-amber', everyone: 'badge-green' };

export function userFeaturesHtml(features, u) {
  if (!features.length) return '';
  return features.map(f => {
    const status = f.effective ? html`<span class="badge badge-green">On now</span>`
      : f.granted ? html`<span class="badge badge-amber">Allowed · feature off</span>`
      : html`<span class="badge badge-gray">Not allowed</span>`;
    const button = can('superadmin')
      ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs('setUserFeature', u.id, f.key, !f.granted, u.nickname, f.label)}>${f.granted ? 'Remove access' : 'Allow'}</button>`
      : '';
    return html`<div class="detail-row"><span class="detail-label">${f.label}</span><span class="detail-value">${status} ${button}</span></div>`;
  });
}

async function setUserFeature(userId, key, enabled, name, label) {
  const reason = await askInModal({
    title: `${enabled ? 'Allow' : 'Remove'} ${label} for ${name}?`,
    confirmLabel: enabled ? 'Allow' : 'Remove access', danger: !enabled,
    message: enabled
      ? 'The account gets the feature while the feature is set to "Allowed accounts only" or "Everyone".'
      : 'The account loses the feature unless it is set to "Everyone".',
    input: { label: 'Reason', required: true } });
  if (!reason) return;
  const res = await post('admin_panel_user_feature_set', { user_id: userId, key, enabled, reason });
  if (!res.ok) { toast(res.error || 'Failed', 'error'); return; }
  toast(enabled ? `${label} allowed for ${name}` : `${label} removed for ${name}`, 'success');
  if (state.view === 'features') navigate('features'); else openUserDetail(userId);
}

async function setFeatureMode(key, mode, label) {
  const messages = {
    off: 'Emergency stop: nobody can use it, allowed accounts included. Their access is kept for later.',
    allowlist: 'Only the allowed accounts listed below can use it.',
    everyone: 'Every active account can use it. Limits and budget still apply.',
  };
  const reason = await askInModal({ title: `${label}: ${FEATURE_MODE_LABELS[mode]}?`,
    confirmLabel: mode === 'off' ? 'Turn off for everyone' : 'Change', danger: mode !== 'allowlist',
    message: messages[mode], input: { label: 'Reason', required: true } });
  if (!reason) return;
  const res = await post('admin_panel_feature_set_mode', { key, mode, reason });
  if (!res.ok) { toast(res.error || 'Failed', 'error'); return; }
  toast(`${label}: ${FEATURE_MODE_LABELS[mode]}`, 'success');
  navigate('features');
}

registerView('features', {
  title: 'Features',
  async render() {
    const res = await get('admin_panel_features');
    if (!res.ok) return html`<div class="empty-state">${res.error || 'Failed to load features.'}</div>`;
    const manage = can('superadmin');
    return html`${(res.flags || []).map(f => {
      const grants = (res.grants || []).filter(g => g.key === f.key);
      const modeButtons = manage ? ['off', 'allowlist', 'everyone'].filter(m => m !== f.mode).map(m =>
        html`<button class="btn ${m === 'off' ? 'btn-danger' : 'btn-ghost'} btn-sm" ${actionAttrs('setFeatureMode', f.key, m, f.label)}>${FEATURE_MODE_LABELS[m]}</button>`) : [];
      const rows = grants.length ? grants.map(g => html`
        <div class="cl-item"><div class="cl-row">
          <div class="flex-fill">
            <div class="cl-title">${g.nickname} <span class="muted-inline">#${g.user_id}</span></div>
            <div class="cl-sub">${g.email || '—'} · ${g.account_status} · allowed ${relTime(g.granted_at)}${g.granted_by ? ` by ${g.granted_by}` : ''}</div>
          </div>
          ${manage ? html`<button class="btn btn-ghost btn-sm" ${actionAttrs('setUserFeature', g.user_id, f.key, false, g.nickname, f.label)}>Remove</button>` : ''}
        </div></div>`)
        : html`<div class="empty-state">No accounts allowed yet. Open a user in Users and choose Allow.</div>`;
      return html`
        <div class="card feature-card">
          <div class="cl-row">
            <div class="flex-fill">
              <div class="cl-title">${f.label}</div>
              <div class="cl-sub">${f.description}</div>
            </div>
            <span class="badge ${FEATURE_MODE_BADGES[f.mode] || 'badge-gray'}">${FEATURE_MODE_LABELS[f.mode] || f.mode}</span>
          </div>
          <div class="cl-sub mt-6">${f.updated_at ? `Changed ${relTime(f.updated_at)}${f.updated_by ? ` by ${f.updated_by}` : ''}` : 'Never changed'}</div>
          ${modeButtons.length ? html`<div class="action-row mt-12">${modeButtons}</div>` : ''}
        </div>
        <div class="table-card">
          <div class="table-card-header"><div class="table-card-title">Allowed accounts (${grants.length})</div></div>
          ${rows}
        </div>
        ${f.key === 'receipt_ai' ? receiptAiUsageHtml(res.receipt_ai_usage) : ''}`;
    })}`;
  },
});

function usd(micro) {
  return '$' + ((Number(micro) || 0) / 1e6).toFixed(micro && micro < 10000 ? 4 : 2);
}

function receiptAiUsageHtml(u) {
  if (!u) return html`<div class="card feature-card"><div class="cl-sub">AI usage appears after the receipt-scans migration.</div></div>`;
  const budgetCard = (label, b) => {
    const used = (b.spent_microusd || 0) + (b.reserved_microusd || 0);
    const pct = b.limit_microusd ? Math.round(used / b.limit_microusd * 100) : 0;
    return html`<div class="stat-card ${pct >= 90 ? 'red' : pct >= 60 ? 'amber' : ''}">
      <div class="stat-label">AI budget · ${label}</div>
      <div class="stat-value">${usd(b.spent_microusd)}</div>
      <div class="stat-sub">of ${usd(b.limit_microusd)}${b.reserved_microusd ? ` · ${usd(b.reserved_microusd)} reserved` : ''}</div>
    </div>`;
  };
  const rows = (u.recent || []).length ? u.recent.map(r => html`
    <div class="cl-item"><div class="cl-row">
      <div class="flex-fill">
        <div class="cl-title">#${r.id} · account #${r.user_id}</div>
        <div class="cl-sub">${relTime(r.created_at)} · ${r.cost_microusd === null ? '—' : usd(r.cost_microusd)} · ${r.duration_ms === null ? '—' : (r.duration_ms / 1000).toFixed(1) + ' s'}${r.error_code ? ` · ${r.error_code}` : ''}</div>
      </div>
      <span class="badge ${r.status === 'done' ? 'badge-green' : r.status === 'failed' ? 'badge-red' : 'badge-amber'}">${r.status}</span>
    </div></div>`) : html`<div class="empty-state">No scans yet.</div>`;
  return html`
    <div class="stats-grid">
      ${budgetCard('this hour', u.budget.hour)}
      ${budgetCard('today', u.budget.day)}
      ${budgetCard('this month', u.budget.month)}
      <div class="stat-card ${u.configured ? '' : 'red'}">
        <div class="stat-label">AI scans today</div>
        <div class="stat-value">${u.scans_today}</div>
        <div class="stat-sub">${u.failed_today} failed · ${u.configured ? u.model : 'API key not set'}</div>
      </div>
    </div>
    <div class="table-card">
      <div class="table-card-header"><div class="table-card-title">Recent AI scans (no receipt content)</div></div>
      ${rows}
    </div>`;
}

registerActions({ setFeatureMode, setUserFeature });
