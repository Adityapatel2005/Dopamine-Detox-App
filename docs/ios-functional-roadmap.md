# Lockd iOS Functional Roadmap

This roadmap preserves the build phases required to turn Lockd from a mock preview into a working iPhone app. The current Windows environment can implement and smoke-test shared logic, models, settings, and preview behavior, but real app blocking must be verified later on macOS with Xcode and a real iPhone.

## Phase 1: Native iOS Foundation

Goal: prepare the app for real device functionality without claiming live blocking yet.

- Model Screen Time and notification permission states.
- Store local app settings, selected app summaries, notification preferences, and lock defaults.
- Add Settings controls for iPhone setup, default lock duration, hard block mode, predictive protection, and notification categories.
- Add a local notification scheduling abstraction with a mock implementation for tests.
- Add a Screen Time authorization bridge that uses Family Controls when available.
- Keep app data local-first and compatible with future App Group sharing.

## Phase 2: Real Blocking

Goal: make lock-ins actually block selected apps, app categories, and web domains on a real iPhone.

Status: native scaffold implemented. Final validation still requires macOS, Xcode signing, Apple's Family Controls entitlement, and a real iPhone.

- Add Family Controls entitlement and App Groups in Apple Developer and Xcode signing.
- Replace sample app rows with Apple's FamilyActivityPicker flow.
- Persist FamilyActivitySelection tokens in shared App Group storage.
- Use ManagedSettingsStore to shield selected applications, categories, and web domains during lock-ins.
- Add DeviceActivityMonitor extension so schedules clear shields when the protected window ends.
- Handle permission denied, revoked authorization, no selected apps, device reboot, and expired sessions.

## Phase 3: Shield UX and Rescue

Goal: make the blocked-app experience feel like Lockd instead of a generic system wall.

Status: native scaffold implemented. Final validation still requires macOS, Xcode signing, Apple's Family Controls entitlement, and a real iPhone opening a shielded app.

- Add ShieldConfiguration extension for branded blocked-app screens.
- Add ShieldAction extension for button handling.
- Support soft friction, hard block, rescue mode, emergency unlock, and bypass attempt tracking.
- Route shield actions into local session history where Apple extension boundaries allow it.
- Keep copy humane and avoid shame-based language.

## Phase 4: Insights and Subscriptions

Goal: turn protected sessions into useful progress and paid Pro capabilities.

Status: native scaffold implemented. Final validation still requires macOS, Xcode signing, StoreKit products in App Store Connect, and a real iPhone for DeviceActivityReport output.

- Add DeviceActivityReport extension for privacy-preserving usage reports.
- Compute Focus Score from completed sessions, protected minutes, bypass attempts, and weak-spot windows.
- Add local weak-spot prediction based on historical sessions and usage signals.
- Add StoreKit 2 products, entitlement state, purchase, restore, renewal, and cancellation surfaces.
- Gate Pro features such as predictive protection, advanced schedules, deep insights, challenge packs, and premium recap cards.

## Real-Device Readiness Checklist

- Paid Apple Developer Program account.
- Real iPhone enrolled for development and TestFlight testing.
- Xcode project generated from `project.yml` on macOS.
- Family Controls capability and provisioning profile configured.
- App Groups capability configured before extensions share data.
- Notification permission reviewed with a respectful, user-controlled prompt.
- App Review notes prepared for Screen Time API usage.
