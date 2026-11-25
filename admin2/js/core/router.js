import { html, setHtml } from './html.js?v=23';
import { state } from './state.js?v=23';
import { modal, toast } from './ui.js?v=23';

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

export function navigate(name, data = {}) {
  const navigationId = ++state.navigationId;
  state.view     = name;
  state.viewData = data;

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
