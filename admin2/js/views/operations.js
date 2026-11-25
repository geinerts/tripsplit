// System health, push queue and incidents.
import { get, post } from '../core/api.js?v=25';
import { actionAttrs, html, setHtml } from '../core/html.js?v=25';
import { navigate, registerActions, registerView } from '../core/router.js?v=25';
import { can } from '../core/state.js?v=25';
import { formatBytes, modal, relTime, sectionTabs, sevBadge, statusBadge, timeAgo, toast } from '../core/ui.js?v=25';
import { pollIncidents } from '../shell.js?v=25';

// ── System health (api/lib/helpers/helper_ops_status.php) ─────────────────────

const JOB_STATE_LABELS = { ok: 'OK', stale: 'Late', failed: 'Failed', unknown: 'No data yet' };
const JOB_STATE_BADGES = { ok: 'badge-green', failed: 'badge-red', stale: 'badge-amber' };

function jobDetails(details) {
  return Object.entries(details || {})
    .filter(([key, value]) => typeof value === 'number' && !['limit', 'interval_minutes', 'min_age_minutes'].includes(key))
    .map(([key, value]) => key.endsWith('_bytes') ? `${key.replace(/_bytes$/, '')} ${formatBytes(value)}` : `${key.replace(/_/g, ' ')} ${value}`)
    .join(' · ');
}

const OPS_TABS = [['system', 'Health'], ['push-queue', 'Push queue']];

registerView('system', {
  title: 'Operations',
  async render() {
    const res = await get('admin_panel_system_health');
    if (!res.ok) return html`<div class="empty-state">${res.error || 'Failed to load system health.'}</div>`;
    const sys = res.system || {};
    const push = res.push || {};
    const jobs = res.jobs || [];
    const problems = jobs.filter(j => j.state === 'failed' || j.state === 'stale').length;
    const used = sys.disk_total_bytes && sys.disk_free_bytes !== null ? sys.disk_total_bytes - sys.disk_free_bytes : null;
    const usedPct = used !== null ? Math.round((used / sys.disk_total_bytes) * 100) : null;
    const oldestAge = push.oldest_pending_at ? relTime(push.oldest_pending_at) : '—';
    const limits = res.limits || {};
    const missingLimits = Object.keys(limits).filter(k => !limits[k]);

    const jobRows = jobs.map(j => {
      const details = jobDetails(j.details);
      return html`
      <div class="cl-item">
        <div class="cl-row">
          <div class="flex-fill">
            <div class="cl-title">${j.label}</div>
            <div class="cl-sub">${j.schedule}${j.last_run ? ` · last run ${relTime(j.last_run)}` : ''}</div>
          </div>
          <span class="badge ${JOB_STATE_BADGES[j.state] || 'badge-gray'}">${JOB_STATE_LABELS[j.state] || j.state}</span>
        </div>
        ${details ? html`<div class="user-facts">${details}</div>` : ''}
      </div>`;
    });

    return html`
      ${sectionTabs(OPS_TABS, 'system')}
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
          <div class="stat-sub">MySQL ${sys.mysql_version || '—'}</div>
        </div>
        <div class="stat-card ${missingLimits.length ? 'red' : 'green'}">
          <div class="stat-label">Security limits</div>
          <div class="stat-value">${missingLimits.length ? 'Not working' : 'Working'}</div>
          <div class="stat-sub">${missingLimits.length ? `Missing: ${missingLimits.join(', ')}` : 'Limit tables in place'}</div>
        </div>
        <div class="stat-card ${push.failed_24h ? 'amber' : ''}">
          <div class="stat-label">Push queue</div>
          <div class="stat-value">${push.pending ?? 0} pending</div>
          <div class="stat-sub">${push.failed_24h ?? 0} failed in 24 h · oldest ${oldestAge}</div>
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
        <div class="detail-row"><span class="detail-label">Deployed commit</span><span class="detail-value">${sys.commit || '—'}</span></div>
        <div class="detail-row"><span class="detail-label">PHP</span><span class="detail-value">${sys.php_version || '—'}</span></div>
        <div class="detail-row"><span class="detail-label">Last push sent</span><span class="detail-value">${relTime(push.last_sent_at)}</span></div>
      </div>
    `;
  },
});

// ── Push queue ────────────────────────────────────────────────────────────────

registerView('push-queue', {
  title: 'Operations',
  nav: 'system',
  async render() {
    const res = await get('admin_panel_push_queue', { limit: 50 });
    if (!res.ok) return html`<div class="empty-state">Failed: ${res.error}</div>`;

    const healthCards = Object.entries(res.health || {}).map(([status, data]) => html`
      <div class="stat-card ${status === 'failed' || status === 'dead' ? 'red' : status === 'pending' ? 'amber' : ''}">
        <div class="stat-label">${status}</div>
        <div class="stat-value">${data.count}</div>
        <div class="stat-sub">latest ${relTime(data.latest)}</div>
      </div>
    `);

    const cards = res.rows.map(r => html`
      <div class="cl-item">
        <div class="cl-row mb-6">
          <span class="queue-type">${r.type ?? '—'}</span>
          ${statusBadge(r.status)}
          <span class="queue-id">#${r.id}</span>
        </div>
        <div class="queue-title">${r.title ?? '—'}</div>
        ${r.last_error ? html`<div class="queue-error">${r.last_error}</div>` : ''}
        <div class="cl-row">
          <span class="cl-meta">${r.attempts} attempt${r.attempts !== 1 ? 's' : ''} · ${relTime(r.created_at)}</span>
          ${r.status !== 'sent' && can('superadmin','admin','ops')
            ? html`<button class="btn btn-ghost btn-sm ml-auto" ${actionAttrs('retryPush', r.id)}>Retry</button>` : ''}
        </div>
      </div>
    `);

    return html`
      ${sectionTabs(OPS_TABS, 'push-queue')}
      <div class="stats-grid compact">
        ${healthCards.length ? healthCards : html`<div class="empty-state">No queue data</div>`}
      </div>
      <div class="table-card flush">
        ${cards.length ? cards : html`<div class="empty-state pad-32">Queue is empty</div>`}
      </div>
    `;
  },
});

async function retryPush(queueId) {
  const res = await post('admin_panel_push_retry', { queue_id: queueId });
  if (res.ok) { toast('Queued for retry', 'success'); navigate('push-queue'); }
  else toast(res.error || 'Failed', 'error');
}

// ── Incidents ─────────────────────────────────────────────────────────────────

registerView('incidents', {
  title: 'Incidents',
  async render() {
    return html`
      <div class="section-header">
        <div class="section-title">Active incidents</div>
        ${can('superadmin','admin','ops')
          ? html`<button class="btn btn-primary btn-sm" id="new-inc-btn">+ New incident</button>` : ''}
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
  const list = document.getElementById('incidents-list');
  if (!list) return;
  if (!res.ok) { setHtml(list, html`<div class="empty-state">Error</div>`); return; }
  if (!res.incidents.length) {
    setHtml(list, html`<div class="empty-state">No incidents. All clear! ✓</div>`);
    return;
  }

  const cards = res.incidents.map(inc => html`
    <div class="data-row">
      <div class="data-row-top">
        <span class="inc-dot ${inc.severity}"></span>
        <span class="data-row-title">${inc.title}</span>
        ${sevBadge(inc.severity)}
        ${statusBadge(inc.status)}
      </div>
      <div class="inc-body">
        ${inc.body.slice(0,100)}${inc.body.length>100?'…':''}
      </div>
      <div class="data-row-meta split">
        <span>${inc.admin_username} · ${timeAgo(inc.created_at)}</span>
        ${inc.status !== 'resolved' && can('superadmin','admin','ops') ? html`
          <div class="btn-row">
            <button class="btn btn-ghost btn-sm" ${actionAttrs('updateIncident', inc.id, 'investigating')}>Investigate</button>
            <button class="btn btn-primary btn-sm" ${actionAttrs('updateIncident', inc.id, 'resolved')}>Resolve</button>
          </div>` : ''}
      </div>
    </div>
  `);

  setHtml(list, html`<div class="table-card flush">${cards}</div>`);
}

function showNewIncidentModal() {
  modal.open('New incident', html`
    <div class="form-group">
      <label class="form-label" for="inc-title">Title</label>
      <input class="form-input" id="inc-title" placeholder="Brief description"/>
    </div>
    <div class="form-group">
      <label class="form-label" for="inc-body">Details</label>
      <textarea class="form-input resize-v" id="inc-body" rows="4" placeholder="What's happening, impact, steps taken…"></textarea>
    </div>
    <div class="form-group">
      <label class="form-label" for="inc-severity">Severity</label>
      <select class="form-input" id="inc-severity">
        <option value="low">Low</option>
        <option value="medium" selected>Medium</option>
        <option value="high">High</option>
        <option value="critical">Critical</option>
      </select>
    </div>
  `, html`
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

registerActions({ retryPush, submitIncident, updateIncident });
