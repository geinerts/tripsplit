import { html, setHtml } from './html.js?v=24';
import { state } from './state.js?v=24';
import { modal, toast } from './ui.js?v=24';

// ── Views ─────────────────────────────────────────────────────────────────────

const views = {};

// render() returns html`` markup (or a promise of it); init() wires listeners afterwards.
export function registerView(name, { title, render, init }) {
  views[name] = { title, render, init };
}

export function setContent(content) {
  setHtml(document.getElementById('page-content'), content);
}

// ── Sidebar (mobile) ──────────────────────────────────────────────────────────

function openSidebar() {
  document.getElementById('sidebar').classList.add('open');
  document.getElementById('sidebar-overlay').classList.add('open');
}

export function closeSidebar() {
  document.getElementById('sidebar').classList.remove('open');
  document.getElementById('sidebar-overlay').classList.remove('open');
}

document.getElementById('sidebar-toggle').addEventListener('click', () => {
  const isOpen = document.getElementById('sidebar').classList.contains('open');
  isOpen ? closeSidebar() : openSidebar();
});

document.getElementById('sidebar-overlay').addEventListener('click', closeSidebar);

// Close on swipe-left (mobile)
(function() {
  let startX = 0;
  const sidebar = document.getElementById('sidebar');
  sidebar.addEventListener('touchstart', e => { startX = e.touches[0].clientX; }, { passive: true });
  sidebar.addEventListener('touchend', e => {
    if (startX - e.changedTouches[0].clientX > 60) closeSidebar();
  }, { passive: true });
})();

// ── Navigation ────────────────────────────────────────────────────────────────

// Every view has an address: #/name, #/name/id or #/name/id?key=value, so a
// reload, the back button and a copied link all land on the same view.
export function routePath(name, data = {}) {
  const { id, ...rest } = data;
  const query = new URLSearchParams(Object.entries(rest)
    .filter(([, value]) => value !== undefined && value !== null && value !== '')).toString();
  const idPart = id !== undefined && id !== null && id !== '' ? `/${encodeURIComponent(id)}` : '';
  return `#/${name}${idPart}${query ? `?${query}` : ''}`;
}

export function parseRoute(hash) {
  const match = /^#\/([a-z0-9-]+)(?:\/([^/?]+))?(?:\?(.*))?$/i.exec(hash || '');
  if (!match) return null;
  const data = Object.fromEntries(new URLSearchParams(match[3] || ''));
  if (match[2]) data.id = decodeURIComponent(match[2]);
  return { name: match[1], data };
}

// history: 'push' adds a browser history entry, 'replace' rewrites the current
// one, 'none' leaves the address alone (back/forward already changed it).
export function navigate(name, data = {}, { history: mode = 'push' } = {}) {
  const navigationId = ++state.navigationId;
  state.view     = name;
  state.viewData = data;

  const path = routePath(name, data);
  if (mode !== 'none' && location.hash !== path) {
    if (mode === 'replace') history.replaceState(null, '', path);
    else history.pushState(null, '', path);
  }

  closeSidebar();

  document.querySelectorAll('.nav-item').forEach(el => {
    el.classList.toggle('active', el.dataset.view === name);
  });

  const v = views[name];
  if (!v) { setContent(html`<div class="empty-state">Unknown view.</div>`); return; }

  document.getElementById('page-title').textContent = v.title;
  document.getElementById('topbar-actions').replaceChildren();
  setContent(html`<div class="loading-state"><span class="spinner"></span> Loading…</div>`);

  return Promise.resolve()
    .then(() => v.render(data))
    .then(content => {
      if (navigationId !== state.navigationId) return;
      setContent(content);
      if (v.init) v.init(data);
    })
    .catch(err => {
      if (navigationId !== state.navigationId) return;
      setContent(html`<div class="empty-state">Error: ${err.message}</div>`);
    });
}

// Opens the view in the address bar, or the dashboard when there is none.
export function openCurrentRoute() {
  const route = parseRoute(location.hash);
  if (route && views[route.name]) return navigate(route.name, route.data, { history: 'replace' });
  return navigate('dashboard', {}, { history: 'replace' });
}

// Re-renders the current view without a new history entry.
export function reloadView() {
  return navigate(state.view, state.viewData, { history: 'replace' });
}

window.addEventListener('popstate', () => {
  if (!state.user) return;
  modal.close();
  const route = parseRoute(location.hash);
  if (route && views[route.name]) navigate(route.name, route.data, { history: 'none' });
  else navigate('dashboard', {}, { history: 'replace' });
});

document.querySelectorAll('.nav-item[data-view]').forEach(el => {
  el.addEventListener('click', () => navigate(el.dataset.view));
});

// ── Click actions ─────────────────────────────────────────────────────────────

// Buttons name an action with data-action/data-args (see actionAttrs); only
// registered functions can run, with JSON arguments.
const clickActions = new Map([
  ['navigate', navigate],
  ['closeModal', () => modal.close()],
]);

export function registerActions(actions) {
  for (const [name, fn] of Object.entries(actions)) {
    if (clickActions.has(name)) throw new Error(`Action ${name} is already registered.`);
    clickActions.set(name, fn);
  }
}

document.addEventListener('click', async e => {
  const control = e.target.closest('[data-action]');
  if (!control || control.disabled || !clickActions.has(control.dataset.action)) return;
  try {
    const args = JSON.parse(control.dataset.args || '[]');
    if (!Array.isArray(args)) return;
    if (control.hasAttribute('data-close-modal')) modal.close();
    await clickActions.get(control.dataset.action)(...args);
  } catch {
    toast('Unable to complete the action. Please try again.', 'error');
  }
});
