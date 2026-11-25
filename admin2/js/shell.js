// The signed-in frame: sidebar by role, topbar clock and the open-incident count.
import { get } from './core/api.js?v=24';
import { html, appendHtml } from './core/html.js?v=24';
import { navigate } from './core/router.js?v=24';
import { can, state } from './core/state.js?v=24';

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

export function showApp() {
  document.getElementById('auth-screen').classList.remove('visible');
  document.getElementById('app').hidden = false;
  if (!state.user) return;
  for (const id of ['nav-premium', 'nav-partners', 'nav-security', 'nav-features']) {
    document.getElementById(id).hidden = !can('superadmin', 'admin');
  }
  document.getElementById('nav-system').hidden = !can('superadmin', 'admin', 'ops');
  document.getElementById('sidebar-avatar').textContent = state.user.username.slice(0, 2).toUpperCase();
  document.getElementById('sidebar-username').textContent = state.user.username;
  document.getElementById('sidebar-role').textContent     = state.user.role;
  document.getElementById('admin-users-section').hidden = state.user.role !== 'superadmin';
}

// The topbar pill reflects open incidents; it is not a live health check.
function renderIncidentStatus(count) {
  const pill = document.getElementById('topbar-status');
  if (!pill) return;
  pill.classList.toggle('alert', count > 0);
  pill.querySelector('.topbar-pill-text').textContent =
    count > 0 ? `${count} open incident${count === 1 ? '' : 's'}` : 'No open incidents';
}

document.getElementById('topbar-status').addEventListener('click', () => navigate('incidents'));

export async function pollIncidents() {
  if (!state.user) return;
  const res = await get('admin_panel_incidents', { status: 'open', limit: 1 }).catch(() => null);
  if (!res?.ok) return;
  const count = res.total ?? 0;
  state.openIncidentCount = count;
  const badge = document.querySelector('#nav-incidents .nav-badge');
  const navEl  = document.getElementById('nav-incidents');
  if (count > 0) {
    if (!badge) appendHtml(navEl, html`<span class="nav-badge">${count}</span>`);
    else badge.textContent = count;
  } else if (badge) {
    badge.remove();
  }
  renderIncidentStatus(count);
  setTimeout(pollIncidents, 60_000);
}
