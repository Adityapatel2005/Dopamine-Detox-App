import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const onboarding = read('Lockd/Onboarding/OnboardingView.swift');
const paywall = read('Lockd/Paywall/PaywallView.swift');
const today = read('Lockd/Today/TodayView.swift');
const settings = read('Lockd/Settings/SettingsView.swift');
const preview = read('preview.js');

[
  onboarding,
  paywall,
  today,
  settings,
  preview
].forEach((surface) => {
  assert.match(surface, /Screen Time is the engine/i);
  assert.match(surface, /Lockd is the behavior layer/i);
});

[
  'Personalized lock-ins',
  'Weak-spot protection',
  'Rescue friction',
  'Progress feedback'
].forEach((pillar) => {
  assert.match(paywall, new RegExp(pillar));
  assert.match(preview, new RegExp(pillar));
});

assert.match(onboarding, /Not another app limit/i);
assert.match(today, /Not just app limits/i);
assert.match(settings, /What Lockd adds beyond Screen Time/i);
assert.match(preview, /renderDifferentiators/);

console.log('value proposition smoke test passed');
