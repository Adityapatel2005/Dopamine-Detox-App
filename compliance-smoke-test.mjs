import { existsSync, readFileSync } from 'node:fs';
import assert from 'node:assert/strict';

const read = (file) => readFileSync(new URL(file, import.meta.url), 'utf8');

const requiredFiles = [
  'docs/privacy-policy.md',
  'docs/terms-of-service.md',
  'docs/privacy-rights-request.md',
  'docs/disclaimer.md',
  'docs/app-store-privacy-label.md',
  'docs/app-review-checklist.md',
  'docs/children-and-health-claims.md',
  'docs/privacy-data-map.md',
  'docs/gdpr-california-rights.md',
  'docs/subscription-compliance.md',
  'docs/accessibility-checklist.md',
  'docs/soc2-readiness.md',
  'docs/security-controls.md',
  'docs/vendor-risk-register.md',
  'docs/incident-response.md',
  'docs/data-retention.md',
  'docs/release-checklist.md',
  'Lockd/PrivacyInfo.xcprivacy',
  'Lockd/Settings/ComplianceResource.swift',
  'LockdTests/ComplianceResourceTests.swift'
];

for (const file of requiredFiles) {
  assert.ok(existsSync(new URL(file, import.meta.url)), `${file} should exist`);
}

const privacy = read('docs/privacy-policy.md');
assert.match(privacy, /local-first/i);
assert.match(privacy, /not intended for children under 13/i);
assert.match(privacy, /California/i);
assert.match(privacy, /GDPR/i);

const terms = read('docs/terms-of-service.md');
assert.match(terms, /Apple In-App Purchase/i);
assert.match(terms, /not medical advice/i);

const dataMap = read('docs/privacy-data-map.md');
assert.match(dataMap, /Screen Time app selections/i);
assert.match(dataMap, /On device/i);
assert.match(dataMap, /No third-party analytics/i);

const soc2 = read('docs/soc2-readiness.md');
assert.match(soc2, /Security/i);
assert.match(soc2, /Availability/i);
assert.match(soc2, /external CPA/i);

const privacyManifest = read('Lockd/PrivacyInfo.xcprivacy');
assert.match(privacyManifest, /NSPrivacyTracking/);
assert.match(privacyManifest, /<false\/>/);
assert.match(privacyManifest, /NSPrivacyCollectedDataTypes/);

const project = read('project.yml');
assert.match(project, /PrivacyInfo\.xcprivacy/);

const settings = read('Lockd/Settings/SettingsView.swift');
assert.match(settings, /ComplianceResource/);
assert.match(settings, /ComplianceSection/);
assert.match(settings, /Section\("Account & Legal"\)/);
assert.match(settings, /Policies & Compliance/);
assert.match(settings, /NavigationLink/);
assert.match(settings, /ComplianceCenterView/);

const settingsRoot = settings.split('private struct ComplianceCenterView')[0];
assert.doesNotMatch(settingsRoot, /Section\("Privacy & Legal"\)/);
assert.doesNotMatch(settingsRoot, /Section\("Access & Safety"\)/);
assert.doesNotMatch(settingsRoot, /Section\("Subscription"\)/);

const resource = read('Lockd/Settings/ComplianceResource.swift');
assert.match(resource, /privacyPolicy/);
assert.match(resource, /termsOfService/);
assert.match(resource, /medicalDisclaimer/);
assert.match(resource, /Delete Local Data/);
assert.match(resource, /Privacy Rights/);
assert.match(resource, /Privacy & Legal/);
assert.match(resource, /Data Rights/);
assert.match(resource, /Access & Safety/);
assert.match(resource, /Subscription/);

const preview = read('preview.js');
assert.match(preview, /Privacy Policy/);
assert.match(preview, /Terms of Service/);
assert.match(preview, /Delete Local Data/);
assert.match(preview, /policySections/);
assert.match(preview, /openPolicyCenter/);
assert.match(preview, /Policies & Compliance/);

console.log('compliance smoke test passed');
