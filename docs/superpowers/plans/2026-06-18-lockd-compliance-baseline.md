# Lockd Compliance Baseline Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a compliance-ready baseline for Lockd covering legal notices, privacy/data rights, App Store privacy review, SOC 2 readiness, accessibility, subscription disclosure, and in-app Settings access.

**Architecture:** Keep v1 local-first and no-tracking. Put legal/compliance artifacts under `docs/`, put iOS privacy disclosure in `Lockd/PrivacyInfo.xcprivacy`, expose compliance resources through a small Swift model consumed by Settings, and mirror the same resources in the Windows web preview.

**Tech Stack:** Markdown documentation, Apple privacy manifest plist, SwiftUI Settings rows, XCTest-style resource tests, Node smoke tests for repository verification.

## Global Constraints

- Lockd should not target children under 13.
- Lockd should not be submitted in Apple's Kids Category.
- Lockd should not claim to diagnose, treat, cure, or prevent addiction, ADHD, anxiety, depression, or any medical condition.
- Lockd v1 stays local-first with no third-party analytics, advertising SDKs, or cross-app tracking.
- Screen Time selections, focus sessions, weak-spot prediction inputs, and Focus Score stay on device unless a later backend design explicitly changes this.
- Focus Score is private by default and sharing is opt-in.
- Any public Privacy Policy, Terms, and support URLs must be reviewed before App Store submission.
- SOC 2 cannot be self-certified; this implementation provides readiness controls and evidence structure only.
- Accessibility targets include WCAG 2.2 AA principles, VoiceOver labels, Dynamic Type, reduced motion, and 44pt touch targets.

---

### Task 1: Compliance Smoke Test

**Files:**
- Create: `compliance-smoke-test.mjs`

**Interfaces:**
- Consumes: repository files.
- Produces: a Node verification command that checks required compliance artifacts and app hooks.

- [ ] Write `compliance-smoke-test.mjs` to assert the required docs, `Lockd/PrivacyInfo.xcprivacy`, `Lockd/Compliance/ComplianceResource.swift`, Settings resource usage, and preview legal copy exist.
- [ ] Run `node compliance-smoke-test.mjs`; expected initial result is failure before files are added.

### Task 2: Legal And Compliance Docs

**Files:**
- Create: `docs/legal/privacy-policy.md`
- Create: `docs/legal/terms-of-service.md`
- Create: `docs/legal/privacy-rights-request.md`
- Create: `docs/legal/disclaimer.md`
- Create: `docs/compliance/app-store-privacy-label.md`
- Create: `docs/compliance/app-review-checklist.md`
- Create: `docs/compliance/children-and-health-claims.md`
- Create: `docs/compliance/privacy-data-map.md`
- Create: `docs/compliance/gdpr-california-rights.md`
- Create: `docs/compliance/subscription-compliance.md`
- Create: `docs/compliance/accessibility-checklist.md`
- Create: `docs/compliance/soc2-readiness.md`
- Create: `docs/compliance/security-controls.md`
- Create: `docs/compliance/vendor-risk-register.md`
- Create: `docs/compliance/incident-response.md`
- Create: `docs/compliance/data-retention.md`
- Create: `docs/compliance/release-checklist.md`

**Interfaces:**
- Produces: launch-readiness documentation and operational workflows.

- [ ] Add docs with concrete Lockd v1 assumptions: local-first, no tracking, no children under 13, no health/medical claims, no third-party SDKs, Apple IAP subscriptions only.

### Task 3: Apple Privacy Manifest

**Files:**
- Create: `Lockd/PrivacyInfo.xcprivacy`
- Modify: `project.yml`

**Interfaces:**
- Produces: Apple privacy manifest declaring no tracking and no collected data for the current v1 scaffold.

- [ ] Add `PrivacyInfo.xcprivacy` with `NSPrivacyTracking` false, empty tracking domains, empty collected data types, and empty accessed API types.
- [ ] Wire it into `project.yml` target resources.

### Task 4: Native Settings Compliance Resources

**Files:**
- Create: `Lockd/Compliance/ComplianceResource.swift`
- Modify: `Lockd/Settings/SettingsView.swift`
- Create: `LockdTests/ComplianceResourceTests.swift`

**Interfaces:**
- Produces: structured Settings resources for Privacy Policy, Terms, Privacy Rights, Accessibility, Delete Data, Subscription Terms, and Medical Disclaimer.

- [ ] Write resource tests first.
- [ ] Add resource model.
- [ ] Update Settings to show compliance sections and local-first copy.

### Task 5: Web Preview Compliance Hooks

**Files:**
- Modify: `preview.js`
- Modify: `preview.css`

**Interfaces:**
- Produces: browser preview Settings sheet with Privacy Policy, Terms, Data Rights, Accessibility, Delete Data, Subscription Terms, and Medical Disclaimer rows.

- [ ] Add a compliance resources array and render rows in the settings sheet.
- [ ] Keep rows readable, tappable, and consistent with the existing mobile preview vocabulary.

### Task 6: Verification And Publish

**Files:**
- Modify: repository as needed.

**Interfaces:**
- Produces: verified local files and a pushed GitHub commit.

- [ ] Run `node compliance-smoke-test.mjs`.
- [ ] Run `node preview-smoke-test.mjs`.
- [ ] Run red-flag scans for placeholder language.
- [ ] Parse plist files as XML.
- [ ] Push changes to `Adityapatel2005/Dopamine-Detox-App`.

## Self-Review

This plan covers the requested privacy policy, terms, SOC 2 readiness, GDPR, California privacy, accessibility, App Store privacy, subscription disclosure, child-safety stance, health-claim guardrails, and app UI access. It intentionally does not claim legal compliance or SOC 2 certification because those require attorney review and external audit.
