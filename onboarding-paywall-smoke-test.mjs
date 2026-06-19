import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const appRoot = read('Lockd/App/AppRootView.swift');
const onboarding = read('Lockd/Onboarding/OnboardingView.swift');
const paywall = read('Lockd/Paywall/PaywallView.swift');
const preview = read('preview.js');
const previewCss = read('preview.css');

assert.match(onboarding, /OnboardingQuestion/);
assert.match(onboarding, /OnboardingAnswerOption/);
assert.match(onboarding, /OnboardingAppTargetGroup/);
assert.match(onboarding, /onboardingAnswers/);
assert.match(onboarding, /What are you trying to get back\?/);
assert.match(onboarding, /What usually starts the spiral\?/);
assert.match(onboarding, /When are you easiest to break\?/);
assert.match(onboarding, /What do you lose the most time to\?/);
assert.match(onboarding, /How aggressive should Lockd be\?/);
assert.match(onboarding, /What should your first protected block be\?/);
assert.match(onboarding, /allowsMultipleSelection/);
assert.match(onboarding, /safeAreaInset\(edge:\s*\.bottom\)/);
assert.match(onboarding, /DisclosureGroup/);
assert.match(onboarding, /expandedAppTargetGroupIDs/);
assert.match(onboarding, /selectedAppTargetCount/);
assert.match(onboarding, /lineLimit\(nil\)/);
assert.match(onboarding, /fixedSize\(horizontal:\s*false,\s*vertical:\s*true\)/);
assert.match(onboarding, /contentShape\(Rectangle\(\)\)/);
assert.match(onboarding, /On iPhone you can choose any apps, categories, and websites with Screen Time\./);
[
  'TikTok',
  'YouTube Shorts',
  'Instagram Reels',
  'Snapchat Spotlight',
  'Discord',
  'WhatsApp',
  'Netflix',
  'Tinder',
  'Amazon',
  'Roblox',
  'Adult websites'
].forEach((appName) => assert.match(onboarding, new RegExp(appName)));
assert.match(onboarding, /Your Lockd setup is ready/);
assert.match(onboarding, /personalizedPlanRows/);
assert.match(onboarding, /accessibilityValue/);

assert.match(appRoot, /hasUnlockedPro/);
assert.match(appRoot, /PaywallView\([\s\S]*allowsDismissal:\s*false/);
assert.match(appRoot, /hasCompletedOnboarding/);
assert.match(appRoot, /MainTabView\(\)/);

assert.match(paywall, /allowsDismissal/);
assert.match(paywall, /onPurchased/);
assert.match(paywall, /Start 7-day trial/);
assert.match(paywall, /7 days free, then/);
assert.doesNotMatch(paywall, /Maybe later/);

assert.match(preview, /onboardingAnswers/);
assert.match(preview, /onboardingQuestions/);
assert.match(preview, /appTargetGroups/);
assert.match(preview, /select-onboarding-answer/);
assert.match(preview, /select-onboarding-app-target/);
assert.match(preview, /app-choice-group/);
assert.match(preview, /onboarding-scroll/);
assert.match(preview, /onboarding-footer/);
assert.match(preview, /details class="app-choice-group"/);
assert.match(preview, /summary class="app-choice-heading"/);
assert.match(preview, /renderRequiredPaywall/);
assert.match(preview, /Start 7-day trial/);
assert.match(preview, /7 days free, then/);
assert.doesNotMatch(preview, /Maybe later/);

assert.match(previewCss, /\.onboarding\s*\{[\s\S]*grid-template-rows:\s*auto 1fr auto/);
assert.match(previewCss, /\.onboarding\s*\{[\s\S]*overflow:\s*hidden/);
assert.match(previewCss, /\.onboarding-scroll\s*\{[\s\S]*overflow:\s*auto/);
assert.match(previewCss, /\.onboarding-footer\s*\{[\s\S]*padding-top:\s*12px/);
assert.match(previewCss, /\.onboarding h1\s*\{[\s\S]*font-size:\s*2\.1rem/);
assert.match(previewCss, /\.choice\s*\{[\s\S]*min-height:\s*56px/);

console.log('onboarding paywall smoke test passed');
