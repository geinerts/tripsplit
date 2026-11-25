// Run: node --test admin2/tests/modules.test.cjs
// Cloudflare caches static files, so every module URL carries the same ?v= as
// app.js in index.html. A module imported under two versions would load twice
// with separate state, so the versions must match exactly.
const { test } = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const { ADMIN_DIR, adminSources } = require('./admin-page.cjs');

const index = fs.readFileSync(path.join(ADMIN_DIR, 'index.html'), 'utf8');

test('index loads app.js as the only script, as a module, with a version', () => {
  const scripts = [...index.matchAll(/<script\b[^>]*>/g)].map(m => m[0]);
  assert.equal(scripts.length, 1);
  assert.match(scripts[0], /^<script type="module" src="app\.js\?v=\d+">$/);
});

test('every module import uses the index version and every module is imported', () => {
  const version = index.match(/src="app\.js\?v=(\d+)"/)[1];
  const imported = new Set();
  for (const file of adminSources()) {
    const source = fs.readFileSync(file, 'utf8');
    const specifiers = [...source.matchAll(/^\s*import\s[^'"]*['"]([^'"]+)['"]/gm), ...source.matchAll(/^\s*import\s+['"]([^'"]+)['"]/gm)]
      .map(m => m[1]);
    for (const specifier of specifiers) {
      assert.match(specifier, /^\.\.?\//, `${file}: ${specifier} must be relative`);
      assert.ok(specifier.endsWith(`.js?v=${version}`), `${path.relative(ADMIN_DIR, file)} imports ${specifier}, expected ?v=${version}`);
      imported.add(path.resolve(path.dirname(file), specifier.replace(/\?.*$/, '')));
    }
    assert.doesNotMatch(source, /\bimport\s*\(/, `${file}: no dynamic imports`);
  }
  for (const file of adminSources().slice(1)) assert.ok(imported.has(file), `${path.relative(ADMIN_DIR, file)} is never imported`);
});

test('CSP allows no inline scripts or styles', () => {
  const csp = index.match(/http-equiv="Content-Security-Policy"\s+content="([^"]+)"/)[1];
  assert.match(csp, /script-src 'self'(;|$)/);
  assert.match(csp, /style-src 'self'(;|$)/);
  assert.doesNotMatch(csp, /unsafe-inline|unsafe-eval/);
  assert.doesNotMatch(index, /\sstyle="|<style\b|\son\w+=/);
});
