import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const html = read('preview.html');
const css = read('preview.css');
const js = read('preview.js');

assert.match(html, /<main class="phone-shell"/);
assert.match(html, /id="app"/);
assert.match(html, /Lockd/);

assert.match(css, /--protected:/);
assert.match(css, /@media \(prefers-reduced-motion: reduce\)/);
assert.match(css, /\.phone-shell/);

assert.match(js, /const state =/);
assert.match(js, /renderOnboarding/);
assert.match(js, /renderToday/);
assert.match(js, /renderRules/);
assert.match(js, /renderInsights/);
assert.match(js, /startLockIn/);
assert.match(js, /selectedResource/);
assert.match(js, /openComplianceResource/);
assert.match(js, /openPolicyCenter/);
assert.match(js, /policySections/);
assert.match(js, /data-resource/);
assert.match(js, /policyCenter/);
assert.match(js, /Policies & Compliance/);
assert.match(js, /Data Rights/);

console.log('preview smoke test passed');
