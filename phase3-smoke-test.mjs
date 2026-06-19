import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const requiredFiles = [
  'LockdShieldConfiguration-Info.plist',
  'LockdShieldAction-Info.plist',
  'LockdShieldConfiguration.entitlements',
  'LockdShieldAction.entitlements',
  'LockdShieldConfigurationExtension.swift',
  'LockdShieldActionExtension.swift',
  'Lockd/ScreenTime/ShieldRescueModels.swift',
  'Lockd/ScreenTime/ShieldRescueStore.swift',
  'LockdTests/PhaseThreeShieldTests.swift'
];

for (const file of requiredFiles) {
  assert.ok(existsSync(new URL(file, import.meta.url)), `${file} should exist`);
}

const project = read('project.yml');
assert.match(project, /LockdShieldConfiguration/);
assert.match(project, /LockdShieldAction/);
assert.match(project, /com\.lockd\.app\.ShieldConfiguration/);
assert.match(project, /com\.lockd\.app\.ShieldAction/);
assert.match(project, /CODE_SIGN_ENTITLEMENTS: LockdShieldConfiguration\.entitlements/);
assert.match(project, /CODE_SIGN_ENTITLEMENTS: LockdShieldAction\.entitlements/);

const configurationInfo = read('LockdShieldConfiguration-Info.plist');
assert.match(configurationInfo, /com\.apple\.ManagedSettingsUI\.shield-configuration-service/);
assert.match(configurationInfo, /LockdShieldConfigurationExtension/);

const actionInfo = read('LockdShieldAction-Info.plist');
assert.match(actionInfo, /com\.apple\.ManagedSettings\.shield-action-service/);
assert.match(actionInfo, /LockdShieldActionExtension/);

const configurationExtension = read('LockdShieldConfigurationExtension.swift');
assert.match(configurationExtension, /ShieldConfigurationDataSource/);
assert.match(configurationExtension, /ShieldConfiguration/);
assert.match(configurationExtension, /Protected by Lockd/);
assert.match(configurationExtension, /Emergency unlock/);
assert.match(configurationExtension, /backgroundBlurStyle/);

const actionExtension = read('LockdShieldActionExtension.swift');
assert.match(actionExtension, /ShieldActionDelegate/);
assert.match(actionExtension, /ShieldActionResponse/);
assert.match(actionExtension, /recordBypassAttempt/);
assert.match(actionExtension, /recordEmergencyUnlock/);
assert.match(actionExtension, /clearActiveShield/);

const models = read('Lockd/ScreenTime/ShieldRescueModels.swift');
assert.match(models, /enum ShieldMode/);
assert.match(models, /case soft/);
assert.match(models, /case hard/);
assert.match(models, /struct ShieldRescueState/);
assert.match(models, /bypassAttempts/);
assert.match(models, /emergencyUnlocks/);

const store = read('Lockd/ScreenTime/ShieldRescueStore.swift');
assert.match(store, /UserDefaults\(suiteName: LockdAppGroup\.identifier\)/);
assert.match(store, /recordBypassAttempt/);
assert.match(store, /recordEmergencyUnlock/);
assert.match(store, /saveShieldMode/);

const todayViewModel = read('Lockd/Today/TodayViewModel.swift');
assert.match(todayViewModel, /ShieldRescueStore/);
assert.match(todayViewModel, /rescueStatusMessage/);
assert.match(todayViewModel, /refreshRescueState/);

const rulesViewModel = read('Lockd/Rules/RulesViewModel.swift');
assert.match(rulesViewModel, /saveShieldMode/);
assert.match(rulesViewModel, /ShieldMode/);

const preview = read('preview.js');
assert.match(preview, /phase3ShieldStatus/);
assert.match(preview, /ShieldConfiguration/);
assert.match(preview, /ShieldActionDelegate/);
assert.match(preview, /Emergency unlock/);
assert.match(preview, /bypassAttempts/);

const roadmap = read('docs/ios-functional-roadmap.md');
assert.match(roadmap, /Phase 3: Shield UX and Rescue/);
assert.match(roadmap, /Status: native scaffold implemented/);

console.log('phase 3 smoke test passed');
