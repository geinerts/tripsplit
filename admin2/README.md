# Admin panel (admin2)

Static front end for `https://ops.splyto.eu`, served from `/var/www/splyto/admin2`.
It talks only to `/api/api.php?action=admin_panel_*` with the HttpOnly admin
session cookie. Login, mandatory 2FA, roles and CSRF are enforced by the server
(`docs/security/admin-mfa.md`, `docs/security/admin-api-boundary.md`); the UI
only hides controls a role cannot use.

## Layout

| Path | Contents |
| --- | --- |
| `index.html` | Shell: login, 2FA and enrolment cards, sidebar, modal. CSP meta tag. |
| `app.js` | Entry module: loads the views, then `boot()`. |
| `js/core/html.js` | `html` template tag, `setHtml`, `actionAttrs`. The only place that writes `innerHTML`. |
| `js/core/api.js` | `get`/`post` for admin actions. |
| `js/core/state.js` | Signed-in admin and current view; `can(...roles)`. |
| `js/core/ui.js` | Toast, modal, `askInModal`, badges, time and byte formatting. |
| `js/core/router.js` | `registerView`, `navigate`, click actions (`registerActions`). Every view has an address (`#/users`, `#/users/12?tab=trips`), so reload, back and copied links keep the place. |
| `js/shell.js` | Sidebar by role, topbar clock, open-incident count. |
| `js/auth.js` | Login, 2FA, enrolment, logout and boot. |
| `js/views/*.js` | One file per area: dashboard, users, features, premium, operations (system, push, incidents), logs (security, audit, app events), admin (admin users, sessions, my account). |
| `app.css` | All styles. The last section holds the classes that replaced inline styles. |

Server side: `api/lib/actions/admin_panel_actions.php` loads the actions from
`api/lib/actions/admin_panel/` (auth, overview, users, operations, admin_users).
Action names and responses are the API contract; see `docs/api/`.

## Rules

- **Markup only through `html```.** Every interpolated value is escaped unless
  it is itself `html``` output. `setHtml` refuses plain strings, so a forgotten
  escape fails loudly instead of becoming XSS. Do not add `innerHTML` elsewhere.
- **No inline scripts, handlers or styles.** The CSP is `script-src 'self'` and
  `style-src 'self'`. Buttons use `actionAttrs('name', ...args)` with a function
  registered through `registerActions`. Dynamic sizes and colours use
  `data-bar-height` / `data-hue` (applied with CSSOM in `html.js`) or a class.
- **One version for every file.** Cloudflare caches static files, so `app.js`,
  `app.css` and every module import carry `?v=N`. When any JS file changes, bump
  the number everywhere (`index.html`, `app.js`, all `import` lines) at once;
  `tests/modules.test.cjs` fails on a mismatch, which would otherwise load a
  module twice with separate state.

## Tests

```bash
NODE_PATH=$(npm root -g) node --test admin2/tests/*.test.cjs
```

Browser tests need Playwright (CI pins 1.59.1). `tests/admin-page.cjs` serves the
folder and exposes the modules to a test page as `window.admin`; the panel itself
has no globals.
