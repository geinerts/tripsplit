// Login, mandatory 2FA (verify or first enrolment) and logout.
// The server decides every step; this only shows the matching card.
import { get, post } from './core/api.js?v=25';
import { openCurrentRoute } from './core/router.js?v=25';
import { state } from './core/state.js?v=25';
import { toast } from './core/ui.js?v=25';
import { pollIncidents, showApp } from './shell.js?v=25';

const $ = id => document.getElementById(id);

function showError(id, message) {
  const el = $(id);
  el.textContent = message;
  el.hidden = !message;
}

export async function checkSession() {
  const res = await get('admin_panel_session_check');
  if (!res.authenticated) return false;
  if (res.requires_2fa_enrollment) return 'needs_enrollment';
  if (res.requires_2fa)   return 'needs_2fa';
  state.user = res.user;
  return true;
}

export function showAuth(mode = 'login') {
  $('auth-screen').classList.add('visible');
  $('app').hidden = true;
  $('login-card').hidden = mode !== 'login';
  $('totp-card').hidden = mode !== '2fa';
  $('enroll-card').hidden = mode !== 'enroll';
  if (mode === 'enroll') resetEnrollCard();
}

async function enterApp() {
  const sessRes = await get('admin_panel_session_check');
  if (!sessRes.full_auth) { showAuth(sessRes.requires_2fa_enrollment ? 'enroll' : 'login'); return; }
  state.user = sessRes.user;
  showApp();
  openCurrentRoute();
  pollIncidents();
}

// ── Login ─────────────────────────────────────────────────────────────────────

$('login-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = $('login-btn');
  btn.disabled = true;
  btn.textContent = 'Signing in…';
  showError('login-error', '');

  const res = await post('admin_panel_login', {
    username: $('inp-username').value,
    password: $('inp-password').value,
  }).catch(err => ({ ok: false, error: err.message }));

  btn.disabled = false;
  btn.textContent = 'Sign in';

  if (!res.ok) { showError('login-error', res.error || 'Login failed.'); return; }

  $('inp-password').value = '';
  if (res.requires_2fa_enrollment) { showAuth('enroll'); return; }
  if (res.requires_2fa) { showAuth('2fa'); return; }
  await enterApp();
});

// ── 2FA code ──────────────────────────────────────────────────────────────────

$('totp-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = $('totp-btn');
  btn.disabled = true;
  btn.textContent = 'Verifying…';
  showError('totp-error', '');

  const res = await post('admin_panel_verify_2fa', {
    code: $('inp-totp').value,
  }).catch(err => ({ ok: false, error: err.message }));

  btn.disabled = false;
  btn.textContent = 'Verify';

  if (!res.ok) { showError('totp-error', res.error || 'Verification failed.'); return; }

  $('inp-totp').value = '';
  await enterApp();
});

$('back-to-login-btn').addEventListener('click', () => {
  post('admin_panel_logout');
  showAuth('login');
});

// ── Mandatory 2FA enrolment ───────────────────────────────────────────────────

function resetEnrollCard() {
  $('enroll-start-form').hidden = false;
  $('enroll-confirm-form').hidden = true;
  $('enroll-secret').textContent = '';
  $('inp-enroll-password').value = '';
  $('inp-enroll-code').value = '';
  showError('enroll-error', '');
}

$('enroll-start-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = $('enroll-start-btn');
  btn.disabled = true;
  showError('enroll-error', '');
  const res = await post('admin_panel_setup_totp', {
    password: $('inp-enroll-password').value,
  }).catch(err => ({ ok: false, error: err.message }));
  btn.disabled = false;
  $('inp-enroll-password').value = '';
  if (!res.ok) { showError('enroll-error', res.error || 'Could not start setup.'); return; }
  $('enroll-secret').textContent = res.secret;
  $('enroll-start-form').hidden = true;
  $('enroll-confirm-form').hidden = false;
  $('inp-enroll-code').focus();
});

$('enroll-confirm-form').addEventListener('submit', async e => {
  e.preventDefault();
  const btn = $('enroll-confirm-btn');
  btn.disabled = true;
  showError('enroll-error', '');
  const res = await post('admin_panel_confirm_totp', {
    code: $('inp-enroll-code').value.trim(),
  }).catch(err => ({ ok: false, error: err.message }));
  btn.disabled = false;
  if (!res.ok) {
    if (res.code === 'totp_setup_expired') resetEnrollCard();
    showError('enroll-error', res.error || 'Invalid code.');
    return;
  }
  $('enroll-secret').textContent = '';
  toast('2FA enabled', 'success');
  await enterApp();
});

$('enroll-back-btn').addEventListener('click', () => {
  post('admin_panel_logout');
  showAuth('login');
});

// ── Logout ────────────────────────────────────────────────────────────────────

$('logout-btn').addEventListener('click', async () => {
  await post('admin_panel_logout');
  state.user = null;
  $('app').hidden = true;
  showAuth('login');
  toast('Signed out', 'info');
});

// ── Boot ──────────────────────────────────────────────────────────────────────

export async function boot() {
  const sessState = await checkSession().catch(() => false);
  if (sessState === 'needs_enrollment') { showAuth('enroll'); return; }
  if (sessState === 'needs_2fa') { showAuth('2fa'); return; }
  if (!sessState) { showAuth('login'); return; }
  showApp();
  openCurrentRoute();
  pollIncidents();
}
