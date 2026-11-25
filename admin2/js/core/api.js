// Same-origin admin API. The session is an HttpOnly cookie; the server checks
// Origin on every POST (docs/security/admin-api-boundary.md).

export const API = '/api/api.php';

async function api(action, params = {}, method = 'GET') {
  const url = `${API}?action=${action}`;
  const opts = {
    method,
    credentials: 'include',
    headers: { 'Content-Type': 'application/json' },
  };
  if (method === 'POST') {
    opts.body = JSON.stringify(params);
  } else {
    const qs = new URLSearchParams(params).toString();
    return fetch(qs ? `${url}&${qs}` : url, { ...opts, body: undefined }).then(r => r.json());
  }
  return fetch(url, opts).then(r => r.json());
}

export const get  = (action, params = {}) => api(action, params, 'GET');
export const post = (action, params = {}) => api(action, params, 'POST');
