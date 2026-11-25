// Shared browser-test helpers: serve the panel's own files and reach its modules.
const fs = require('node:fs');
const path = require('node:path');

const ADMIN_DIR = path.resolve(__dirname, '..');
const TYPES = { '.html': 'text/html', '.js': 'text/javascript', '.css': 'text/css', '.svg': 'image/svg+xml' };

// Answers /admin2/... from the admin2 folder (never tests/ or outside it).
function fulfillAdmin(route, url) {
  if (!url.pathname.startsWith('/admin2/')) return route.abort();
  const relative = url.pathname === '/admin2/' ? 'index.html' : decodeURIComponent(url.pathname.slice('/admin2/'.length));
  const file = path.resolve(ADMIN_DIR, relative);
  const inside = file.startsWith(ADMIN_DIR + path.sep) && !file.startsWith(path.join(ADMIN_DIR, 'tests') + path.sep);
  if (!inside || !fs.existsSync(file) || !fs.statSync(file).isFile()) return route.abort();
  return route.fulfill({ body: fs.readFileSync(file), contentType: TYPES[path.extname(file)] || 'application/octet-stream' });
}

// The panel has no globals; tests import the same module instances the page
// loaded (same ?v=) and use them as window.admin.
async function exposeAdmin(page) {
  await page.evaluate(async () => {
    const entry = document.querySelector('script[type="module"][src*="app.js"]').src;
    const version = new URL(entry).search;
    const modules = ['core/html.js', 'core/state.js', 'core/router.js', 'shell.js', 'views/dashboard.js', 'views/users.js'];
    const loaded = await Promise.all(modules.map(name => import(new URL(`js/${name}${version}`, entry).href)));
    window.admin = Object.assign({}, ...loaded);
  });
}

// app.js and every module under js/.
function adminSources() {
  const walk = dir => fs.readdirSync(dir, { withFileTypes: true }).flatMap(entry =>
    entry.isDirectory() ? walk(path.join(dir, entry.name)) : entry.name.endsWith('.js') ? [path.join(dir, entry.name)] : []);
  return [path.join(ADMIN_DIR, 'app.js'), ...walk(path.join(ADMIN_DIR, 'js'))];
}

module.exports = { ADMIN_DIR, adminSources, exposeAdmin, fulfillAdmin };
