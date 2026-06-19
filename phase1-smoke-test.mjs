import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const requiredFiles = [
  'docs/ios-functional-roadmap.md',
  'Lockd/Domain/PermissionModels.swift',
  'Lockd/Domain/NotificationModels.swift',
  'Lockd/Domain/LockdAppSettings.swift',
  'Lockd/Settings/AppSettingsStore.swift',
  'Lockd/Settings/PhaseOneSettingsViewModel.swift',
  'Lockd/ScreenTime/NativeScreenTimeAuthorizationController.swift',
  'Lockd/ScreenTime/ScreenTimeSelectionState.swift',
  'LockdTests/PhaseOneFoundationTests.swift'
];

for (const file of requiredFiles) {
  assert.ok(existsSync(new URL(file, import.meta.url)), `${file} should exist`);
}

const roadmap = read('docs/ios-functional-roadmap.md');
assert.match(roadmap, /Phase 1: Native iOS Foundation/i);
assert.match(roadmap, /Phase 2: Real Blocking/i);
assert.match(roadmap, /Phase 3: Shield UX and Rescue/i);
assert.match(roadmap, /Phase 4: Insights and Subscriptions/i);
assert.match(roadmap, /real iPhone/i);

const permissions = read('Lockd/Domain/PermissionModels.swift');
assert.match(permissions, /LockdPermissionStatus/);
assert.match(permissions, /screenTime/);
assert.match(permissions, /notifications/);
assert.match(permissions, /canStartRealLock/);

const notifications = read('Lockd/Domain/NotificationModels.swift');
assert.match(notifications, /LockdNotificationKind/);
assert.match(notifications, /weakSpotWarning/);
assert.match(notifications, /lockEndingSoon/);
assert.match(notifications, /weeklyRecap/);
assert.match(notifications, /NotificationScheduling/);

const settings = read('Lockd/Domain/LockdAppSettings.swift');
assert.match(settings, /defaultLockDurationMinutes/);
assert.match(settings, /hardBlockEnabled/);
assert.match(settings, /predictiveProtectionEnabled/);
assert.match(settings, /selectedAppSummary/);

const store = read('Lockd/Settings/AppSettingsStore.swift');
assert.match(store, /UserDefaultsAppSettingsStore/);
assert.match(store, /InMemoryAppSettingsStore/);
assert.match(store, /JSONEncoder/);

const viewModel = read('Lockd/Settings/PhaseOneSettingsViewModel.swift');
assert.match(viewModel, /requestNotificationAuthorization/);
assert.match(viewModel, /setDefaultLockDuration/);
assert.match(viewModel, /toggleNotification/);

const nativeScreenTime = read('Lockd/ScreenTime/NativeScreenTimeAuthorizationController.swift');
assert.match(nativeScreenTime, /FamilyControls/);
assert.match(nativeScreenTime, /AuthorizationCenter/);
assert.match(nativeScreenTime, /individual/);

const settingsView = read('Lockd/Settings/SettingsView.swift');
assert.match(settingsView, /PhaseOneSettingsViewModel/);
assert.match(settingsView, /iPhone Setup/);
assert.match(settingsView, /Lock Defaults/);
assert.match(settingsView, /Notifications/);
assert.match(settingsView, /Default duration/);

const preview = read('preview.js');
assert.match(preview, /notificationPreferences/);
assert.match(preview, /defaultLockDurationMinutes/);
assert.match(preview, /iPhone Setup/);
assert.match(preview, /Lock defaults/);
assert.match(preview, /Weak spot warning/);

console.log('phase 1 smoke test passed');
