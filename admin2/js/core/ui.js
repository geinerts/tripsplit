import { actionAttrs, html, setHtml } from './html.js?v=25';

// ── Toast ─────────────────────────────────────────────────────────────────────

export function toast(msg, type = 'info', durationMs = 3500) {
  const el = document.createElement('div');
  el.className = `toast ${type}`;
  el.textContent = msg;
  document.getElementById('toast-container').appendChild(el);
  setTimeout(() => el.remove(), durationMs);
}

// ── Modal ─────────────────────────────────────────────────────────────────────

export const modal = {
  open(title, body, footer = html``) {
    const pending = modal.afterClose;
    modal.afterClose = null;
    if (pending) pending();
    document.getElementById('modal-title').textContent = title;
    setHtml(document.getElementById('modal-body'), body);
    setHtml(document.getElementById('modal-footer'), footer);
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

document.getElementById('modal-backdrop').addEventListener('click', e => {
  if (e.target === e.currentTarget) modal.close();
});

// Asks inside the panel's own modal instead of the browser's prompt()/confirm().
// Resolves to the entered text (or true without an input), or null when cancelled.
export function askInModal({ title, message, input = null, confirmLabel = 'Confirm', danger = false }) {
  return new Promise(resolve => {
    modal.close();
    const password = input?.type === 'password';
    const field = input ? html`
      <div class="form-group mt-14">
        <label class="form-label" for="ask-input">${input.label}</label>
        <input class="form-input" id="ask-input" type="${password ? 'password' : 'text'}"
               autocomplete="${password ? 'current-password' : 'off'}" maxlength="500"
               ${input.required ? html`required` : ''}/>
      </div>` : '';
    modal.open(title, html`<form id="ask-form" novalidate><p class="ask-message">${message}</p>${field}
      <p class="ask-error" id="ask-error" hidden>This field is required.</p></form>`, html`
      <button class="btn btn-ghost" type="button" id="ask-cancel">Cancel</button>
      <button class="btn ${danger ? 'btn-danger' : 'btn-primary'}" type="submit" form="ask-form">${confirmLabel}</button>`);
    let settled = false;
    const finish = value => { if (!settled) { settled = true; resolve(value); } };
    modal.afterClose = () => finish(null);
    document.getElementById('ask-cancel').addEventListener('click', () => modal.close());
    const inputEl = document.getElementById('ask-input');
    document.getElementById('ask-form').addEventListener('submit', e => {
      e.preventDefault();
      const value = inputEl ? inputEl.value.trim() : true;
      if (input?.required && !value) { document.getElementById('ask-error').hidden = false; inputEl.focus(); return; }
      finish(inputEl ? (password ? inputEl.value : value) : true);
      modal.afterClose = null;
      modal.close();
    });
    (inputEl || document.querySelector('#modal-footer [type="submit"]')).focus();
  });
}

// ── Formatting ────────────────────────────────────────────────────────────────

export function relTime(raw) {
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

export function formatBytes(bytes) {
  if (bytes === null || bytes === undefined) return '—';
  const units = ['B', 'KB', 'MB', 'GB', 'TB'];
  let value = Number(bytes);
  let unit = 0;
  while (value >= 1024 && unit < units.length - 1) { value /= 1024; unit += 1; }
  return `${value.toFixed(value >= 10 || unit === 0 ? 0 : 1)} ${units[unit]}`;
}

function parseServerTime(raw) {
  const iso = String(raw).replace(' ', 'T');
  return new Date(iso.includes('Z') || iso.includes('+') ? iso : iso + 'Z');
}

// Relative time with the exact local date and time on hover.
export function timeAgo(raw) {
  if (!raw) return html`<span>—</span>`;
  const date = parseServerTime(raw);
  const exact = Number.isNaN(date.getTime()) ? String(raw)
    : date.toLocaleString('lv-LV', { dateStyle: 'medium', timeStyle: 'short' });
  return html`<time datetime="${Number.isNaN(date.getTime()) ? '' : date.toISOString()}" title="${exact}">${relTime(raw)}</time>`;
}

// "Today", "Yesterday" or the date, for grouping log entries by local day.
export function dayLabel(raw) {
  if (!raw) return '—';
  const date = parseServerTime(raw);
  const day = d => new Date(d.getFullYear(), d.getMonth(), d.getDate()).getTime();
  const diff = Math.round((day(new Date()) - day(date)) / 86400000);
  if (diff === 0) return 'Today';
  if (diff === 1) return 'Yesterday';
  return date.toLocaleDateString('lv-LV', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

// Tabs between related views that share one sidebar item, e.g. Logs.
// items: [view, label, allowed = true]; each is a real view with its own address.
export function sectionTabs(items, current) {
  const visible = items.filter(([, , allowed = true]) => allowed);
  if (visible.length < 2) return '';
  return html`<nav class="tabs section-tabs" aria-label="Section">${visible.map(([view, label]) => html`
    <button type="button" class="tab" ${view === current ? html`aria-current="page"` : ''} ${actionAttrs('navigate', view)}>${label}</button>`)}</nav>`;
}

// Colour family for audit actions and app event types; maps to .text-* / .bg-* classes.
export function auditTone(action, fallback = 'green-soft') {
  return action.includes('delete') ? 'red'
    : action.includes('suspend') || action.includes('disable') ? 'amber'
    : fallback;
}

export function eventTone(type) {
  return type.includes('delete') ? 'red'
    : type.startsWith('user.login') || type.startsWith('user.register') ? 'green-soft'
    : type.startsWith('trip.') ? 'blue'
    : type.startsWith('expense.') ? 'amber'
    : type.startsWith('settlement.') ? 'purple'
    : type.startsWith('friend.') ? 'green-soft'
    : 'muted';
}

// ── Badges ────────────────────────────────────────────────────────────────────

export function statusBadge(status) {
  const map = {
    active: 'badge-green', deactivated: 'badge-red', suspended: 'badge-red', deleted: 'badge-gray',
    open: 'badge-red', investigating: 'badge-amber', resolved: 'badge-green',
    pending: 'badge-amber', sent: 'badge-green', failed: 'badge-red', dead: 'badge-gray',
    ok: 'badge-green', stale: 'badge-amber', unknown: 'badge-gray',
  };
  return html`<span class="badge ${map[status] ?? 'badge-gray'}">${status}</span>`;
}

export function roleBadge(role) {
  const map = {
    superadmin: 'badge-purple', admin: 'badge-blue',
    support: 'badge-green', ops: 'badge-amber', readonly: 'badge-gray',
  };
  return html`<span class="badge ${map[role] ?? 'badge-gray'}">${role}</span>`;
}

export function sevBadge(sev) {
  const map = {
    critical: 'badge-red', high: 'badge-amber', medium: 'badge-green', low: 'badge-gray',
  };
  return html`<span class="badge ${map[sev] ?? 'badge-gray'}">${sev}</span>`;
}
