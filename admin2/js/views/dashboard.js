import { get } from '../core/api.js?v=25';
import { actionAttrs, html } from '../core/html.js?v=25';
import { registerView } from '../core/router.js?v=25';
import { can } from '../core/state.js?v=25';
import { formatBytes, sevBadge, statusBadge, timeAgo } from '../core/ui.js?v=25';
import { describeAudit, describeEvent } from './logs.js?v=25';

// Monthly totals of feature use (docs/api/feature-usage-counters.md), not people.
export function renderFeatureUsage(usage) {
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
    ? html`<div class="empty-state" role="status">Usage totals are unavailable. Check the feature usage migration.</div>`
    : !months.length
      ? html`<div class="empty-state" role="status">No feature use counted yet.</div>`
      : html`<div class="table-wrap feature-usage-table"><table>
          <thead><tr><th scope="col">Feature</th>${months.map(month => html`<th scope="col">${month.month}</th>`)}</tr></thead>
          <tbody>${labels.map(([feature, label]) => html`<tr><th scope="row">${label}</th>${months.map(month => html`<td>${count(month, feature)}</td>`)}</tr>`)}</tbody>
        </table></div>
        <p class="deletion-note">Monthly totals of uses, not people. They include our own testing. Don't share numbers below 5 outside this panel.</p>`;
  return html`<section class="table-card feature-usage" aria-labelledby="feature-usage-title">
    <div class="table-card-header">
      <div class="table-card-title" id="feature-usage-title">Feature usage</div>
      <span class="deletion-period">Last ${months.length || 0} months</span>
    </div>
    ${body}
  </section>`;
}

// Anonymous selections from deletion requests, not completed deletions.
export function renderDeletionFeedback(feedback) {
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
    const circle = html`<circle cx="60" cy="60" r="46" pathLength="100" fill="none"
      stroke="${row.color}" stroke-width="16" stroke-dasharray="${portion} ${100 - portion}"
      stroke-dashoffset="${-offset}" transform="rotate(-90 60 60)"/>`;
    offset += portion;
    return circle;
  }) : '';
  return html`<section class="table-card deletion-feedback" aria-labelledby="deletion-feedback-title">
    <div class="table-card-header">
      <div class="table-card-title" id="deletion-feedback-title">Account deletion reasons</div>
      <span class="deletion-period">All time</span>
    </div>
    ${!available ? html`<div class="empty-state" role="status">Reason statistics are unavailable. Check the feedback migration and try refreshing.</div>` : html`
      <div class="deletion-feedback-body">
        <div class="deletion-donut" aria-hidden="true">
          <svg viewBox="0 0 120 120"><circle cx="60" cy="60" r="46" fill="none" stroke="var(--border)" stroke-width="16"/>${segments}</svg>
          <div class="deletion-donut-total"><strong>${total.toLocaleString('en')}</strong><span>selections</span></div>
        </div>
        <ul class="deletion-legend">
          ${rows.map(row => html`<li><svg width="10" height="10" aria-hidden="true"><circle cx="5" cy="5" r="5" fill="${row.color}"/></svg>
            <span>${row.label}</span><strong>${row.count.toLocaleString('en')}</strong>
            <span class="deletion-percent">${total ? (row.count / total * 100).toFixed(1) : '0.0'}%</span></li>`)}
        </ul>
      </div>
      ${!total ? html`<p class="deletion-empty" role="status">No reasons collected yet.</p>` : ''}
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
  const headline = total ? html`${sum}<span class="growth-unit">in 30 days</span>`
    : html`${today}<span class="growth-unit">today · peak ${max}</span>`;
  const cols = days.map((d, i) => {
    const v = values[i];
    const h = max ? Math.max(v ? 4 : 0, Math.round((v / max) * 100)) : 0;
    return html`<div class="growth-col" data-tip="${growthDay(d.date)} · ${v} ${title.toLowerCase()}">
      <div class="growth-bar" data-bar-height="${h}"></div></div>`;
  });
  const rows = days.map((d, i) => html`<tr><td>${d.date}</td><td>${values[i]}</td></tr>`);
  return html`
    <div class="growth-chart">
      <div class="growth-title">${title}</div>
      <div class="growth-value">${headline}</div>
      <div class="growth-plot" role="img" aria-label="${title} per day for the last 30 days, maximum ${max}">
        <span class="growth-max">${max}</span>${cols}
      </div>
      <div class="growth-axis"><span>${growthDay(days[0].date)}</span><span>${growthDay(days[days.length - 1].date)}</span></div>
      <details class="growth-table"><summary>Table</summary>
        <table><thead><tr><th>Date</th><th>${title}</th></tr></thead><tbody>${rows}</tbody></table>
      </details>
    </div>`;
}

function renderGrowth(days) {
  if (!Array.isArray(days) || !days.length) return '';
  return html`
    <div class="table-card growth-card">
      <div class="table-card-header"><div class="table-card-title">📈 Last 30 days</div></div>
      <div class="growth-grid">${GROWTH_SERIES.map(series => renderGrowthChart(days, series))}</div>
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

// ── Today: what needs attention now ───────────────────────────────────────────

const optional = promise => promise.catch(() => null);

// Each item: [tone, text, view to open]. Only checks the admin's role can see.
function attentionItems(stats, health, features) {
  const items = [];
  const incidents = stats.open_incidents ?? 0;
  if (incidents) items.push(['red', `${incidents} open incident${incidents === 1 ? '' : 's'}`, 'incidents']);

  if (health?.ok) {
    for (const job of health.jobs || []) {
      if (job.state === 'failed') items.push(['red', `${job.label} failed`, 'system']);
      else if (job.state === 'stale') items.push(['amber', `${job.label} is late`, 'system']);
    }
    const missing = Object.keys(health.limits || {}).filter(key => !health.limits[key]);
    if (missing.length) items.push(['red', `Security limits not working: ${missing.join(', ')}`, 'system']);
    const sys = health.system || {};
    if (sys.disk_total_bytes && sys.disk_free_bytes !== null && sys.disk_free_bytes !== undefined) {
      const usedPct = Math.round((sys.disk_total_bytes - sys.disk_free_bytes) / sys.disk_total_bytes * 100);
      if (usedPct >= 85) items.push(['amber', `Disk ${usedPct}% full (${formatBytes(sys.disk_free_bytes)} free)`, 'system']);
    }
  }

  const pq = stats.push_queue || {};
  const failed = pq.failed ?? 0;
  const dead = pq.dead ?? 0;
  if (failed || dead) items.push(['amber', `Push notifications: ${failed} failed, ${dead} dead`, can('superadmin', 'admin', 'ops') ? 'push-queue' : null]);

  const budget = features?.ok ? features.receipt_ai_usage?.budget : null;
  for (const [period, label] of [['hour', 'this hour'], ['day', 'today'], ['month', 'this month']]) {
    const b = budget?.[period];
    if (!b?.limit_microusd) continue;
    const pct = Math.round(((b.spent_microusd || 0) + (b.reserved_microusd || 0)) / b.limit_microusd * 100);
    if (pct >= 80) items.push([pct >= 95 ? 'red' : 'amber', `AI receipt budget ${pct}% used ${label}`, 'features']);
  }
  return items;
}

function checkedList(health, features) {
  return ['incidents', 'push', health?.ok ? 'scheduled jobs, disk, security limits' : null, features?.ok ? 'AI budget' : null]
    .filter(Boolean).join(', ');
}

function attentionCard(items, checked) {
  if (!items.length) {
    return html`<section class="attention ok" aria-label="Status">
      <span class="attention-dot bg-green"></span><strong>Everything is working.</strong>
      <span class="text-muted">Checked: ${checked}.</span></section>`;
  }
  return html`<section class="attention" aria-labelledby="attention-title">
    <h2 id="attention-title">Needs attention (${items.length})</h2>
    <ul>${items.map(([tone, text, view]) => html`<li>
      <span class="attention-dot bg-${tone}"></span><span class="flex-fill">${text}</span>
      ${view ? html`<button type="button" class="btn btn-ghost btn-sm" ${actionAttrs('navigate', view)}>Open</button>` : ''}
    </li>`)}</ul>
    <p class="text-muted small">Also checked: ${checked}.</p>
  </section>`;
}

function feedItem({ who, text, code, time }) {
  return html`
    <div class="activity-item">
      <div class="flex-fill">
        <div class="activity-text"><strong>${who}</strong> ${text}</div>
        <div class="activity-time"><span class="event-code">${code}</span> · ${timeAgo(time)}</div>
      </div>
    </div>`;
}

registerView('dashboard', {
  title: 'Today',
  async render() {
    const ops = can('superadmin', 'admin', 'ops');
    const [dashRes, auditRes, eventsRes, health, features] = await Promise.all([
      get('admin_panel_dashboard'),
      ops ? optional(get('admin_panel_audit_log', { limit: 8, offset: 0 })) : null,
      ops ? optional(get('admin_panel_app_events', { limit: 8, offset: 0 })) : null,
      ops ? optional(get('admin_panel_system_health')) : null,
      can('superadmin', 'admin') ? optional(get('admin_panel_features')) : null,
    ]);
    if (!dashRes.ok) return html`<div class="empty-state">Failed to load stats.</div>`;
    const s = dashRes.stats || {};

    const incidents = (s.recent_incidents || []).map(inc => html`
      <div class="data-row clickable" ${actionAttrs('navigate', 'incidents')}>
        <div class="data-row-top">
          <span class="inc-dot ${inc.severity}"></span>
          <span class="data-row-title">${inc.title}</span>
          ${sevBadge(inc.severity)}
          ${statusBadge(inc.status)}
        </div>
        <div class="data-row-meta"><span>${inc.admin_username}</span><span>·</span>${timeAgo(inc.created_at)}</div>
      </div>`);

    const events = (eventsRes?.ok ? eventsRes.events || [] : []).map(e => feedItem({
      who: e.username || 'Deleted user', text: describeEvent(e), code: e.event_type, time: e.created_at }));
    const audit = (auditRes?.ok ? auditRes.log || [] : []).map(e => feedItem({
      who: e.admin_username, text: describeAudit(e), code: e.action, time: e.created_at }));

    return html`
      ${attentionCard(attentionItems(s, health, features), checkedList(health, features))}
      <div class="dashboard-grid">
        <div>
          <div class="table-card">
            <div class="table-card-header">
              <div class="table-card-title">🚨 Open incidents</div>
              <span class="table-card-link" ${actionAttrs('navigate', 'incidents')}>All incidents →</span>
            </div>
            ${incidents.length ? incidents : html`<div class="empty-state pad-24">No open incidents</div>`}
          </div>
          ${ops ? html`<div class="activity-card">
            <div class="activity-header split"><span>⚡ App activity</span>
              <span class="table-card-link" ${actionAttrs('navigate', 'app-events')}>All →</span></div>
            ${events.length ? events : html`<div class="activity-empty">No recent activity</div>`}
          </div>` : ''}
        </div>
        <div>
          ${ops ? html`<div class="activity-card">
            <div class="activity-header split"><span>📋 Admin actions</span>
              <span class="table-card-link" ${actionAttrs('navigate', 'audit-log')}>All →</span></div>
            ${audit.length ? audit : html`<div class="activity-empty">No recent admin actions</div>`}
          </div>` : ''}
        </div>
      </div>`;
  },
});

// ── Growth: how the app is used ───────────────────────────────────────────────

registerView('growth', {
  title: 'Growth',
  async render() {
    const res = await get('admin_panel_dashboard');
    if (!res.ok) return html`<div class="empty-state">Failed to load stats.</div>`;
    const s = res.stats || {};
    return html`
      <div class="stats-grid">
        <div class="stat-card green">
          <div class="stat-label">Total users</div>
          <div class="stat-value">${s.total_users ?? 0}</div>
          <div class="stat-sub">+${s.new_users_7d ?? 0} this week</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Active users</div>
          <div class="stat-value">${s.active_users ?? 0}</div>
          <div class="stat-sub">${s.total_users ? Math.round((s.active_users / s.total_users) * 100) : 0}% of total</div>
        </div>
        <div class="stat-card blue">
          <div class="stat-label">Total trips</div>
          <div class="stat-value">${s.total_trips ?? 0}</div>
        </div>
        <div class="stat-card">
          <div class="stat-label">Expenses</div>
          <div class="stat-value">${s.total_expenses ?? 0}</div>
        </div>
      </div>
      ${renderGrowth(s.growth)}
      <div class="dashboard-grid">
        <div>${renderDeletionFeedback(s.account_deletion_feedback)}</div>
        <div>${renderFeatureUsage(s.feature_usage)}</div>
      </div>`;
  },
});
