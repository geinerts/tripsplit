// Trusted markup for the panel. Every value interpolated into html`` is escaped
// unless it is itself html`` output, so a forgotten escape cannot inject markup.
// The page's CSP blocks inline scripts and inline style attributes; dynamic
// values that need styling go through data attributes applied with CSSOM below.

const ESCAPES = { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' };

export function esc(value) {
  return String(value ?? '').replace(/[&<>"']/g, char => ESCAPES[char]);
}

class TrustedHtml {
  #markup;
  constructor(markup) { this.#markup = markup; }
  toString() { return this.#markup; }
}

function part(value) {
  if (value instanceof TrustedHtml) return value.toString();
  if (Array.isArray(value)) return value.map(part).join('');
  return esc(value);
}

export function html(strings, ...values) {
  let markup = strings[0];
  values.forEach((value, i) => { markup += part(value) + strings[i + 1]; });
  return new TrustedHtml(markup);
}

export function join(items, separator) {
  return new TrustedHtml(items.map(part).join(part(separator)));
}

export function isHtml(value) {
  return value instanceof TrustedHtml;
}

// Arguments stay JSON data, never JavaScript in an HTML event attribute.
export function actionAttrs(action, ...args) {
  return html`data-action="${action}" data-args="${JSON.stringify(args)}"`;
}

function applyDynamicStyles(root) {
  for (const el of root.querySelectorAll('[data-bar-height]')) {
    el.style.height = `${Math.min(100, Math.max(0, Number(el.dataset.barHeight) || 0))}%`;
  }
  for (const el of root.querySelectorAll('[data-hue]')) {
    el.style.setProperty('--hue', String(Number(el.dataset.hue) || 0));
  }
}

function trusted(content) {
  if (!(content instanceof TrustedHtml)) throw new TypeError('Only html`` markup may be rendered.');
  return content.toString();
}

export function setHtml(el, content) {
  el.innerHTML = trusted(content);
  applyDynamicStyles(el);
}

export function appendHtml(el, content) {
  el.insertAdjacentHTML('beforeend', trusted(content));
  applyDynamicStyles(el);
}
