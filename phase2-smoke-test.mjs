import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const requiredFiles = [
  'Lockd.entitlements',
  'LockdDeviceActivityMonitor.entitlements',
  'LockdDeviceActivityMonitor-Info.plist',
  'LockdDeviceActivityMonitorExtension.swift',
  'Lockd/ScreenTime/FamilyActivitySelectionStore.swift',
  'Lockd/ScreenTime/DeviceActivityScheduleController.swift',
  'Lockd/ScreenTime/RealScreenTimeController.swift',
  'LockdTests/PhaseTwoBlockingTests.swift'
];

for (const file of requiredFiles) {
  assert.ok(existsSync(new URL(file, import.meta.url)), `${file} should exist`);
}

const appEntitlements = read('Lockd.entitlements');
assert.match(appEntitlements, /com\.apple\.developer\.family-controls/);
assert.match(appEntitlements, /com\.apple\.security\.application-groups/);
assert.match(appEntitlements, /group\.com\.lockd\.app/);

const monitorEntitlements = read('LockdDeviceActivityMonitor.entitlements');
assert.match(monitorEntitlements, /com\.apple\.developer\.family-controls/);
assert.match(monitorEntitlements, /group\.com\.lockd\.app/);

const monitorInfo = read('LockdDeviceActivityMonitor-Info.plist');
assert.match(monitorInfo, /com\.apple\.deviceactivity\.monitor-extension/);
assert.match(monitorInfo, /LockdDeviceActivityMonitorExtension/);

const project = read('project.yml');
assert.match(project, /LockdDeviceActivityMonitor/);
assert.match(project, /CODE_SIGN_ENTITLEMENTS: Lockd\.entitlements/);
assert.match(project, /CODE_SIGN_ENTITLEMENTS: LockdDeviceActivityMonitor\.entitlements/);
assert.match(project, /PRODUCT_BUNDLE_IDENTIFIER: com\.lockd\.app\.DeviceActivityMonitor/);

const selectionStore = read('Lockd/ScreenTime/FamilyActivitySelectionStore.swift');
assert.match(selectionStore, /FamilyActivitySelection/);
assert.match(selectionStore, /UserDefaults\(suiteName: LockdAppGroup\.identifier\)/);
assert.match(selectionStore, /JSONEncoder/);
assert.match(selectionStore, /selectionState/);

const realController = read('Lockd/ScreenTime/RealScreenTimeController.swift');
assert.match(realController, /ManagedSettingsStore/);
assert.match(realController, /shield\.applications/);
assert.match(realController, /applicationCategories/);
assert.match(realController, /webDomains/);
assert.match(realController, /DeviceActivityScheduleController/);
assert.match(realController, /noSelection/);

const scheduleController = read('Lockd/ScreenTime/DeviceActivityScheduleController.swift');
assert.match(scheduleController, /DeviceActivityCenter/);
assert.match(scheduleController, /DeviceActivitySchedule/);
assert.match(scheduleController, /lockdActiveSession/);

const monitorExtension = read('LockdDeviceActivityMonitorExtension.swift');
assert.match(monitorExtension, /DeviceActivityMonitor/);
assert.match(monitorExtension, /intervalDidStart/);
assert.match(monitorExtension, /intervalDidEnd/);
assert.match(monitorExtension, /ManagedSettingsStore/);
assert.match(monitorExtension, /shield\.applications/);

const rulesView = read('Lockd/Rules/RulesView.swift');
assert.match(rulesView, /FamilyActivityPicker/);
assert.match(rulesView, /familyActivityPicker/);
assert.match(rulesView, /saveFamilyActivitySelection/);

const todayViewModel = read('Lockd/Today/TodayViewModel.swift');
assert.match(todayViewModel, /ScreenTimeControlling/);
assert.match(todayViewModel, /applyBlock/);
assert.match(todayViewModel, /protectionStatusMessage/);

const preview = read('preview.js');
assert.match(preview, /phase2BlockingStatus/);
assert.match(preview, /FamilyActivityPicker/);
assert.match(preview, /ManagedSettings/);
assert.match(preview, /DeviceActivityMonitor/);

console.log('phase 2 smoke test passed');
