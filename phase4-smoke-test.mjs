import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const requiredFiles = [
  'LockdDeviceActivityReport-Info.plist',
  'LockdDeviceActivityReport.entitlements',
  'LockdDeviceActivityReportExtension.swift',
  'Lockd/Insights/FocusScoreModels.swift',
  'Lockd/Insights/WeakSpotPredictor.swift',
  'Lockd/Insights/DeviceActivityReportModels.swift',
  'Lockd/Subscriptions/LockdProductCatalog.swift',
  'Lockd/Subscriptions/ProEntitlementModels.swift',
  'Lockd/Subscriptions/StoreKitSubscriptionController.swift',
  'LockdTests/PhaseFourInsightsTests.swift'
];

for (const file of requiredFiles) {
  assert.ok(existsSync(new URL(file, import.meta.url)), `${file} should exist`);
}

const project = read('project.yml');
assert.match(project, /LockdDeviceActivityReport/);
assert.match(project, /com\.lockd\.app\.DeviceActivityReport/);
assert.match(project, /CODE_SIGN_ENTITLEMENTS: LockdDeviceActivityReport\.entitlements/);

const reportInfo = read('LockdDeviceActivityReport-Info.plist');
assert.match(reportInfo, /com\.apple\.deviceactivity\.report-extension/);
assert.match(reportInfo, /LockdDeviceActivityReportExtension/);

const reportExtension = read('LockdDeviceActivityReportExtension.swift');
assert.match(reportExtension, /DeviceActivityReportExtension/);
assert.match(reportExtension, /DeviceActivityReportScene/);
assert.match(reportExtension, /DeviceActivityResults/);
assert.match(reportExtension, /lockdWeeklySummary/);

const focusModels = read('Lockd/Insights/FocusScoreModels.swift');
assert.match(focusModels, /struct FocusScoreInput/);
assert.match(focusModels, /struct FocusScoreCalculator/);
assert.match(focusModels, /protectedMinutes/);
assert.match(focusModels, /bypassAttempts/);
assert.match(focusModels, /weeklyScore/);

const weakSpotPredictor = read('Lockd/Insights/WeakSpotPredictor.swift');
assert.match(weakSpotPredictor, /struct WeakSpotPredictor/);
assert.match(weakSpotPredictor, /WeakSpotSignal/);
assert.match(weakSpotPredictor, /predictNextWindow/);

const reportModels = read('Lockd/Insights/DeviceActivityReportModels.swift');
assert.match(reportModels, /struct LockdWeeklyActivitySummary/);
assert.match(reportModels, /DeviceActivityReport/);
assert.match(reportModels, /privacyPreserving/);

const catalog = read('Lockd/Subscriptions/LockdProductCatalog.swift');
assert.match(catalog, /com\.lockd\.pro\.monthly/);
assert.match(catalog, /com\.lockd\.pro\.yearly/);
assert.match(catalog, /productIdentifiers/);

const entitlements = read('Lockd/Subscriptions/ProEntitlementModels.swift');
assert.match(entitlements, /enum LockdProEntitlement/);
assert.match(entitlements, /case free/);
assert.match(entitlements, /case pro/);
assert.match(entitlements, /unlocksPredictiveProtection/);
assert.match(entitlements, /unlocksAdvancedInsights/);

const storeKit = read('Lockd/Subscriptions/StoreKitSubscriptionController.swift');
assert.match(storeKit, /StoreKit/);
assert.match(storeKit, /Product\.products/);
assert.match(storeKit, /Transaction\.currentEntitlements/);
assert.match(storeKit, /AppStore\.sync/);
assert.match(storeKit, /purchase/);

const insightsVM = read('Lockd/Insights/InsightsViewModel.swift');
assert.match(insightsVM, /FocusScoreCalculator/);
assert.match(insightsVM, /WeakSpotPredictor/);
assert.match(insightsVM, /LockdProEntitlement/);
assert.match(insightsVM, /isAdvancedInsightsLocked/);

const paywall = read('Lockd/Paywall/PaywallView.swift');
assert.match(paywall, /StoreKitSubscriptionController/);
assert.match(paywall, /restorePurchases/);
assert.match(paywall, /LockdProductCatalog/);

const preview = read('preview.js');
assert.match(preview, /phase4InsightStatus/);
assert.match(preview, /StoreKit 2/);
assert.match(preview, /DeviceActivityReport/);
assert.match(preview, /currentEntitlements/);
assert.match(preview, /proEntitlement/);

const roadmap = read('docs/ios-functional-roadmap.md');
assert.match(roadmap, /Phase 4: Insights and Subscriptions/);
assert.match(roadmap, /Status: native scaffold implemented/);

console.log('phase 4 smoke test passed');
