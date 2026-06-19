import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const settingsSwift = read('Lockd/Settings/SettingsView.swift');
const previewJs = read('preview.js');

for (const section of [
  'Section("iPhone Setup")',
  'Section("Protection Defaults")',
  'Section("Notification Preferences")',
  'Section("Account & Legal")'
]) {
  assert.match(settingsSwift, new RegExp(section.replace(/[()"]/g, '\\$&')));
}

assert.doesNotMatch(settingsSwift, /Section\("Protection"\)/);
assert.doesNotMatch(settingsSwift, /Section\("Lock Defaults"\)/);
assert.doesNotMatch(settingsSwift, /Section\("Notifications"\)/);
assert.doesNotMatch(settingsSwift, /Section\("Policies & Compliance"\)/);
assert.match(settingsSwift, /settingsSummaryRow/);
assert.match(settingsSwift, /Reset Local Settings/);

for (const heading of [
  'iPhone Setup',
  'Protection Defaults',
  'Notification Preferences',
  'Account & Legal'
]) {
  assert.match(previewJs, new RegExp(heading));
}

assert.doesNotMatch(previewJs, /sheet-section-title">Notifications/);
assert.match(previewJs, /Open iPhone Settings/);
assert.match(previewJs, /Policies & Compliance/);

console.log('settings organization smoke test passed');
