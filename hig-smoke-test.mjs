import { readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const previewHtml = read('preview.html');
const previewCss = read('preview.css');
const appRoot = read('Lockd/App/AppRootView.swift');
const theme = read('Lockd/DesignSystem/LockdTheme.swift');
const button = read('Lockd/DesignSystem/LockdButton.swift');
const today = read('Lockd/Today/TodayView.swift');
const onboarding = read('Lockd/Onboarding/OnboardingView.swift');
const shareCard = read('Lockd/Share/ShareCardView.swift');
const rules = read('Lockd/Rules/RulesView.swift');
const settings = read('Lockd/Settings/SettingsView.swift');
const paywall = read('Lockd/Paywall/PaywallView.swift');
const previewJs = read('preview.js');

assert.doesNotMatch(previewHtml, /status-bar|status-icons|5G|100%|9:41/);
assert.match(previewCss, /\.app-root\s*\{[\s\S]*height:\s*100%/);
assert.doesNotMatch(previewCss, /calc\(100% - 44px\)|inset:\s*44px/);

assert.doesNotMatch(appRoot, /preferredColorScheme\(\.dark\)/);

assert.match(theme, /Color\(\.systemBackground\)/);
assert.match(theme, /Color\(\.secondarySystemGroupedBackground\)/);
assert.match(theme, /Color\(\.label\)/);
assert.match(theme, /Color\(\.secondaryLabel\)/);

assert.match(button, /accessibilityHint/);
assert.match(button, /UINotificationFeedbackGenerator/);

assert.match(today, /@ScaledMetric/);
assert.doesNotMatch(today, /font\(\.system\(size:\s*72/);
assert.match(today, /accessibilityValue/);
assert.match(today, /accessibilityHint/);

assert.match(onboarding, /@ScaledMetric/);
assert.doesNotMatch(onboarding, /font\(\.system\(size:\s*42/);
assert.match(onboarding, /accessibilityValue/);

assert.match(shareCard, /@ScaledMetric/);
assert.doesNotMatch(shareCard, /font\(\.system\(size:\s*64/);

assert.match(rules, /isShowingPaywall/);
assert.match(rules, /PaywallView/);
assert.match(rules, /Why Lockd needs Screen Time/);

assert.doesNotMatch(settings, /mocked in this build/);
assert.match(settings, /openAppSettings/);
assert.match(settings, /UIApplication\.openSettingsURLString/);
assert.match(settings, /Why Lockd needs Screen Time/);

assert.doesNotMatch(paywall, /onTapGesture/);
assert.match(paywall, /Button\s*\{/);
assert.match(paywall, /accessibilityHint/);
assert.match(paywall, /Restore Purchases/);

assert.doesNotMatch(previewJs, /9:41|5G|100%/);
assert.match(previewJs, /phase4InsightStatus/);

console.log('hig smoke test passed');
