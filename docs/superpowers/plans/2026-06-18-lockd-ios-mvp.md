# Lockd iOS MVP Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the first native SwiftUI Lockd MVP vertical slice with mocked Screen Time adapters, testable domain logic, and polished Today, Rules, Insights, onboarding, paywall, and share-card surfaces.

**Architecture:** Use a native SwiftUI app generated from an XcodeGen `project.yml`. Keep pure behavior in small domain and prediction files with XCTest coverage, put Screen Time behavior behind protocols, and let SwiftUI views consume lightweight view models seeded with mock data.

**Tech Stack:** SwiftUI, XCTest, FamilyControls/DeviceActivity/ManagedSettings adapters behind protocols, XcodeGen for project generation, iOS 17.0 deployment target.

## Global Constraints

- First build target is native SwiftUI, not React Native, PWA, or web wrapper.
- Use mock Screen Time adapters until Apple Family Controls entitlement and device integration are ready.
- Keep Screen Time capabilities behind protocols so tests and preview builds can use mocks.
- Local-first prediction logic only; no network call or LLM nudge for v1.
- Three primary tabs: Today, Rules, Insights.
- Settings is secondary and reachable from a header, not a fourth primary tab.
- Marketing tone is competitive; in-app tone is balanced and humane.
- Focus Score is private by default and sharing is opt-in.
- All core controls need 44pt or larger touch targets and VoiceOver labels.
- Support reduced motion with fades or instant state changes instead of repeated decorative animation.
- On this Windows workspace, `swift`, `xcodebuild`, and iOS Simulator are unavailable. Build and UI verification steps must be run on macOS with Xcode after files are created.
- Git commits are required by the normal workflow, but this repo's `.git` ACL currently blocks Codex from creating `.git/index.lock`. Commit steps are included and should run after `.git` write permission is repaired.

---

## File Structure

- Create `.gitignore` for Xcode, SwiftPM, and local build artifacts.
- Create `project.yml` as the XcodeGen source of truth for the iOS app and XCTest target.
- Create `Lockd/Info.plist` for app bundle settings.
- Create `Lockd/App/LockdApp.swift` for the app entry point.
- Create `Lockd/App/AppRootView.swift` for onboarding-to-tab flow.
- Create `Lockd/DesignSystem/LockdTheme.swift` for colors, typography helpers, spacing, haptics, and reduced-motion helpers.
- Create `Lockd/DesignSystem/LockdButton.swift` for animated primary/secondary buttons.
- Create `Lockd/Domain/FocusScore.swift` for the score formula and edge cases.
- Create `Lockd/Domain/LockSession.swift` for session lifecycle models.
- Create `Lockd/Domain/RulesModels.swift` for selected apps, goals, friction, schedules, and entitlements.
- Create `Lockd/Domain/WeakSpot.swift` for prediction inputs and outputs.
- Create `Lockd/Prediction/WeakSpotPredictor.swift` for local statistical prediction.
- Create `Lockd/ScreenTime/ScreenTimeControlling.swift` for app-blocking protocol boundaries.
- Create `Lockd/ScreenTime/MockScreenTimeController.swift` for previews and tests.
- Create `Lockd/Today/TodayViewModel.swift` and `Lockd/Today/TodayView.swift` for command-center behavior and UI.
- Create `Lockd/Settings/SettingsView.swift` for secondary settings access from the Today header.
- Create `Lockd/Rules/RulesViewModel.swift` and `Lockd/Rules/RulesView.swift` for setup and rule controls.
- Create `Lockd/Insights/InsightsViewModel.swift` and `Lockd/Insights/InsightsView.swift` for score, streaks, patterns, challenge, and recap data.
- Create `Lockd/Onboarding/OnboardingView.swift` for the value-first onboarding flow.
- Create `Lockd/Paywall/PaywallView.swift` for Predictive Protection monetization.
- Create `Lockd/Share/ShareCardView.swift` for screenshot-ready recap cards.
- Create `LockdTests/FocusScoreTests.swift`, `LockdTests/WeakSpotPredictorTests.swift`, `LockdTests/SessionLifecycleTests.swift`, and `LockdTests/RulesStateTests.swift`.
- Create `docs/qa/lockd-visual-qa.md` for manual visual and accessibility checks.

---

### Task 1: Native Project Scaffold

**Files:**
- Create: `.gitignore`
- Create: `project.yml`
- Create: `Lockd/Info.plist`
- Create: `Lockd/App/LockdApp.swift`
- Create: `Lockd/App/AppRootView.swift`

**Interfaces:**
- Consumes: approved spec in `docs/superpowers/specs/2026-06-18-lockd-ios-design.md`
- Produces: `LockdApp`, `AppRootView`, and an XcodeGen project definition used by all later tasks.

- [ ] **Step 1: Write the scaffold files**

Create `.gitignore`:

```gitignore
.DS_Store
DerivedData/
build/
.build/
*.xcuserstate
xcuserdata/
*.xcodeproj/project.xcworkspace/xcuserdata/
*.xcodeproj/xcuserdata/
*.xcworkspace/xcuserdata/
```

Create `project.yml`:

```yaml
name: Lockd
options:
  bundleIdPrefix: com.lockd
  deploymentTarget:
    iOS: "17.0"
settings:
  base:
    SWIFT_VERSION: "5.10"
    MARKETING_VERSION: "0.1.0"
    CURRENT_PROJECT_VERSION: "1"
targets:
  Lockd:
    type: application
    platform: iOS
    sources:
      - path: Lockd
    info:
      path: Lockd/Info.plist
    settings:
      base:
        PRODUCT_BUNDLE_IDENTIFIER: com.lockd.app
        INFOPLIST_FILE: Lockd/Info.plist
  LockdTests:
    type: bundle.unit-test
    platform: iOS
    sources:
      - path: LockdTests
    dependencies:
      - target: Lockd
```

Create `Lockd/Info.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>$(EXECUTABLE_NAME)</string>
  <key>CFBundleIdentifier</key>
  <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
  <key>CFBundleDisplayName</key>
  <string>Lockd</string>
  <key>CFBundleName</key>
  <string>$(PRODUCT_NAME)</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$(MARKETING_VERSION)</string>
  <key>CFBundleVersion</key>
  <string>$(CURRENT_PROJECT_VERSION)</string>
  <key>UILaunchScreen</key>
  <dict/>
  <key>UIApplicationSupportsIndirectInputEvents</key>
  <true/>
</dict>
</plist>
```

Create `Lockd/App/LockdApp.swift`:

```swift
import SwiftUI

@main
struct LockdApp: App {
    var body: some Scene {
        WindowGroup {
            AppRootView()
        }
    }
}
```

Create `Lockd/App/AppRootView.swift`:

```swift
import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
```

- [ ] **Step 2: Generate the Xcode project on macOS**

Run:

```bash
xcodegen generate
```

Expected: `Lockd.xcodeproj` is created without warnings about missing targets.

- [ ] **Step 3: Commit**

```bash
git add .gitignore project.yml Lockd/Info.plist Lockd/App/LockdApp.swift Lockd/App/AppRootView.swift
git commit -m "chore: scaffold native Lockd iOS project"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 2: Core Domain And Focus Score

**Files:**
- Create: `Lockd/Domain/FocusScore.swift`
- Create: `Lockd/Domain/LockSession.swift`
- Create: `Lockd/Domain/RulesModels.swift`
- Test: `LockdTests/FocusScoreTests.swift`
- Test: `LockdTests/SessionLifecycleTests.swift`

**Interfaces:**
- Consumes: no app UI.
- Produces: `FocusScoreInput`, `FocusScoreCalculator.calculate(_:)`, `LockSession`, `LockSession.complete(at:honoredMinutes:)`, `GoalPreset`, `FrictionLevel`, and `EntitlementState`.

- [ ] **Step 1: Write failing Focus Score tests**

Create `LockdTests/FocusScoreTests.swift`:

```swift
import XCTest
@testable import Lockd

final class FocusScoreTests: XCTestCase {
    func testZeroSessionScoreIsZero() {
        let input = FocusScoreInput(
            intendedMinutes: 0,
            honoredMinutes: 0,
            goalAppMinutesTarget: 0,
            goalAppMinutesActual: 0,
            sessionsStarted: 0,
            sessionsCompleted: 0
        )

        XCTAssertEqual(FocusScoreCalculator.calculate(input), 0)
    }

    func testPerfectDayScoresOneHundred() {
        let input = FocusScoreInput(
            intendedMinutes: 60,
            honoredMinutes: 60,
            goalAppMinutesTarget: 30,
            goalAppMinutesActual: 0,
            sessionsStarted: 2,
            sessionsCompleted: 2
        )

        XCTAssertEqual(FocusScoreCalculator.calculate(input), 100)
    }

    func testPartialAdherenceUsesWeightedFormula() {
        let input = FocusScoreInput(
            intendedMinutes: 100,
            honoredMinutes: 50,
            goalAppMinutesTarget: 60,
            goalAppMinutesActual: 45,
            sessionsStarted: 4,
            sessionsCompleted: 3
        )

        XCTAssertEqual(FocusScoreCalculator.calculate(input), 48)
    }

    func testOverHonoredMinutesClampToOneHundred() {
        let input = FocusScoreInput(
            intendedMinutes: 30,
            honoredMinutes: 45,
            goalAppMinutesTarget: 20,
            goalAppMinutesActual: 0,
            sessionsStarted: 1,
            sessionsCompleted: 1
        )

        XCTAssertEqual(FocusScoreCalculator.calculate(input), 100)
    }
}
```

- [ ] **Step 2: Write failing session lifecycle tests**

Create `LockdTests/SessionLifecycleTests.swift`:

```swift
import XCTest
@testable import Lockd

final class SessionLifecycleTests: XCTestCase {
    func testActiveSessionCompletesWithHonoredMinutes() {
        let start = Date(timeIntervalSince1970: 1_800)
        let end = Date(timeIntervalSince1970: 3_600)
        let session = LockSession.start(durationMinutes: 30, startDate: start)

        let completed = session.complete(at: end, honoredMinutes: 28)

        XCTAssertEqual(completed.state, .completed)
        XCTAssertEqual(completed.intendedMinutes, 30)
        XCTAssertEqual(completed.honoredMinutes, 28)
    }

    func testBypassAttemptMovesToRescueSuggested() {
        let session = LockSession.start(durationMinutes: 15, startDate: Date(timeIntervalSince1970: 2_000))

        let updated = session.recordBypassAttempt()

        XCTAssertEqual(updated.state, .rescueSuggested)
        XCTAssertEqual(updated.bypassAttempts, 1)
    }
}
```

- [ ] **Step 3: Run tests to verify failure on macOS**

Run:

```bash
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: FAIL because `FocusScoreInput`, `FocusScoreCalculator`, and `LockSession` are not defined.

- [ ] **Step 4: Implement domain code**

Create `Lockd/Domain/FocusScore.swift`:

```swift
import Foundation

struct FocusScoreInput: Equatable {
    let intendedMinutes: Int
    let honoredMinutes: Int
    let goalAppMinutesTarget: Int
    let goalAppMinutesActual: Int
    let sessionsStarted: Int
    let sessionsCompleted: Int
}

enum FocusScoreCalculator {
    static func calculate(_ input: FocusScoreInput) -> Int {
        guard input.intendedMinutes > 0 || input.sessionsStarted > 0 || input.goalAppMinutesTarget > 0 else {
            return 0
        }

        let adherence = ratio(numerator: input.honoredMinutes, denominator: input.intendedMinutes)
        let goalRate = goalRatio(target: input.goalAppMinutesTarget, actual: input.goalAppMinutesActual)
        let sessionRate = ratio(numerator: input.sessionsCompleted, denominator: input.sessionsStarted)
        let rawScore = 100 * ((0.5 * adherence) + (0.3 * goalRate) + (0.2 * sessionRate))

        return min(max(Int(rawScore.rounded()), 0), 100)
    }

    private static func ratio(numerator: Int, denominator: Int) -> Double {
        guard denominator > 0 else { return 0 }
        return min(max(Double(numerator) / Double(denominator), 0), 1)
    }

    private static func goalRatio(target: Int, actual: Int) -> Double {
        guard target > 0 else { return 0 }
        let underGoalMinutes = max(target - actual, 0)
        return min(Double(underGoalMinutes) / Double(target), 1)
    }
}
```

Create `Lockd/Domain/LockSession.swift`:

```swift
import Foundation

enum LockSessionState: Equatable {
    case active
    case completed
    case interrupted
    case rescueSuggested
}

struct LockSession: Identifiable, Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    let durationMinutes: Int
    let intendedMinutes: Int
    let honoredMinutes: Int
    let bypassAttempts: Int
    let state: LockSessionState

    static func start(durationMinutes: Int, startDate: Date = Date()) -> LockSession {
        LockSession(
            id: UUID(),
            startDate: startDate,
            endDate: nil,
            durationMinutes: durationMinutes,
            intendedMinutes: durationMinutes,
            honoredMinutes: 0,
            bypassAttempts: 0,
            state: .active
        )
    }

    func complete(at endDate: Date, honoredMinutes: Int) -> LockSession {
        LockSession(
            id: id,
            startDate: startDate,
            endDate: endDate,
            durationMinutes: durationMinutes,
            intendedMinutes: intendedMinutes,
            honoredMinutes: min(max(honoredMinutes, 0), intendedMinutes),
            bypassAttempts: bypassAttempts,
            state: .completed
        )
    }

    func recordBypassAttempt() -> LockSession {
        LockSession(
            id: id,
            startDate: startDate,
            endDate: endDate,
            durationMinutes: durationMinutes,
            intendedMinutes: intendedMinutes,
            honoredMinutes: honoredMinutes,
            bypassAttempts: bypassAttempts + 1,
            state: .rescueSuggested
        )
    }
}
```

Create `Lockd/Domain/RulesModels.swift`:

```swift
import Foundation

enum GoalPreset: String, CaseIterable, Identifiable {
    case cutBrainRot = "Cut brain rot"
    case study = "Study without folding"
    case sleep = "Sleep without scrolling"
    case monkMode = "Monk Mode challenge"
    case custom = "Custom"

    var id: String { rawValue }
}

enum FrictionLevel: String, CaseIterable, Identifiable {
    case soft = "Soft friction"
    case hard = "Hard block"

    var id: String { rawValue }
}

enum EntitlementState: Equatable {
    case unavailableInBuild
    case permissionMissing
    case available
    case proRequired
}

struct DistractingApp: Identifiable, Equatable {
    let id: UUID
    let name: String
    let symbolName: String

    init(id: UUID = UUID(), name: String, symbolName: String) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
    }
}
```

- [ ] **Step 5: Run tests to verify pass**

Run:

```bash
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS for `FocusScoreTests` and `SessionLifecycleTests`.

- [ ] **Step 6: Commit**

```bash
git add Lockd/Domain LockdTests/FocusScoreTests.swift LockdTests/SessionLifecycleTests.swift
git commit -m "feat: add Lockd domain scoring and sessions"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 3: Local Weak Spot Prediction

**Files:**
- Create: `Lockd/Domain/WeakSpot.swift`
- Create: `Lockd/Prediction/WeakSpotPredictor.swift`
- Test: `LockdTests/WeakSpotPredictorTests.swift`

**Interfaces:**
- Consumes: domain layer from Task 2.
- Produces: `WeakSpotSignal`, `WeakSpotWindow`, `RiskLevel`, and `WeakSpotPredictor.predict(signals:now:)`.

- [ ] **Step 1: Write failing predictor tests**

Create `LockdTests/WeakSpotPredictorTests.swift`:

```swift
import XCTest
@testable import Lockd

final class WeakSpotPredictorTests: XCTestCase {
    func testPredictsHighRiskForRepeatedSameHourSignals() {
        let signals = [
            WeakSpotSignal(hour: 21, weekday: 4, appName: "TikTok", outcome: .openedDistractingApp),
            WeakSpotSignal(hour: 21, weekday: 4, appName: "TikTok", outcome: .openedDistractingApp),
            WeakSpotSignal(hour: 21, weekday: 4, appName: "Instagram", outcome: .softFrictionIgnored)
        ]

        let prediction = WeakSpotPredictor().predict(signals: signals, now: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(prediction.hour, 21)
        XCTAssertEqual(prediction.riskLevel, .high)
        XCTAssertTrue(prediction.explanation.contains("TikTok"))
    }

    func testNoSignalsReturnsLearningState() {
        let prediction = WeakSpotPredictor().predict(signals: [], now: Date(timeIntervalSince1970: 0))

        XCTAssertEqual(prediction.riskLevel, .learning)
        XCTAssertEqual(prediction.explanation, "Lockd will learn your pattern after 2 days.")
    }
}
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: FAIL because weak-spot prediction types are not defined.

- [ ] **Step 3: Implement prediction code**

Create `Lockd/Domain/WeakSpot.swift`:

```swift
import Foundation

enum RiskLevel: String, Equatable {
    case learning
    case low
    case medium
    case high
}

enum WeakSpotOutcome: Equatable {
    case openedDistractingApp
    case softFrictionIgnored
    case sessionInterrupted
    case sessionCompleted
}

struct WeakSpotSignal: Equatable {
    let hour: Int
    let weekday: Int
    let appName: String
    let outcome: WeakSpotOutcome
}

struct WeakSpotWindow: Equatable {
    let hour: Int
    let riskLevel: RiskLevel
    let explanation: String
}
```

Create `Lockd/Prediction/WeakSpotPredictor.swift`:

```swift
import Foundation

struct WeakSpotPredictor {
    func predict(signals: [WeakSpotSignal], now: Date = Date()) -> WeakSpotWindow {
        guard !signals.isEmpty else {
            return WeakSpotWindow(
                hour: Calendar.current.component(.hour, from: now),
                riskLevel: .learning,
                explanation: "Lockd will learn your pattern after 2 days."
            )
        }

        let grouped = Dictionary(grouping: signals) { $0.hour }
        let strongest = grouped.max { left, right in
            riskScore(left.value) < riskScore(right.value)
        }

        guard let hour = strongest?.key, let hourSignals = strongest?.value else {
            return WeakSpotWindow(hour: Calendar.current.component(.hour, from: now), riskLevel: .low, explanation: "No strong drift window found yet.")
        }

        let score = riskScore(hourSignals)
        let riskLevel: RiskLevel
        if score >= 5 {
            riskLevel = .high
        } else if score >= 3 {
            riskLevel = .medium
        } else {
            riskLevel = .low
        }

        let topApp = Dictionary(grouping: hourSignals) { $0.appName }
            .max { $0.value.count < $1.value.count }?
            .key ?? "distracting apps"

        return WeakSpotWindow(
            hour: hour,
            riskLevel: riskLevel,
            explanation: "\(topApp) opens usually spike here."
        )
    }

    private func riskScore(_ signals: [WeakSpotSignal]) -> Int {
        signals.reduce(0) { total, signal in
            switch signal.outcome {
            case .openedDistractingApp:
                return total + 2
            case .softFrictionIgnored:
                return total + 2
            case .sessionInterrupted:
                return total + 1
            case .sessionCompleted:
                return total - 1
            }
        }
    }
}
```

- [ ] **Step 4: Run tests to verify pass**

Run:

```bash
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS for predictor tests.

- [ ] **Step 5: Commit**

```bash
git add Lockd/Domain/WeakSpot.swift Lockd/Prediction/WeakSpotPredictor.swift LockdTests/WeakSpotPredictorTests.swift
git commit -m "feat: add local weak spot prediction"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 4: Screen Time Adapter Boundary And Rules State

**Files:**
- Create: `Lockd/ScreenTime/ScreenTimeControlling.swift`
- Create: `Lockd/ScreenTime/MockScreenTimeController.swift`
- Create: `Lockd/Rules/RulesViewModel.swift`
- Test: `LockdTests/RulesStateTests.swift`

**Interfaces:**
- Consumes: `DistractingApp`, `GoalPreset`, `FrictionLevel`, `EntitlementState`.
- Produces: `ScreenTimeControlling`, `MockScreenTimeController`, `RulesViewModel.chooseApp(_:)`, `RulesViewModel.setGoal(_:)`, and `RulesViewModel.enablePredictiveProtection()`.

- [ ] **Step 1: Write failing rules state tests**

Create `LockdTests/RulesStateTests.swift`:

```swift
import XCTest
@testable import Lockd

@MainActor
final class RulesStateTests: XCTestCase {
    func testChoosingAppAddsItToSelection() {
        let viewModel = RulesViewModel(screenTimeController: MockScreenTimeController())
        let app = DistractingApp(name: "TikTok", symbolName: "music.note")

        viewModel.chooseApp(app)

        XCTAssertEqual(viewModel.selectedApps, [app])
    }

    func testPredictiveProtectionRequiresProWhenEntitlementIsProRequired() {
        let viewModel = RulesViewModel(screenTimeController: MockScreenTimeController(entitlementState: .proRequired))

        viewModel.enablePredictiveProtection()

        XCTAssertFalse(viewModel.isPredictiveProtectionEnabled)
        XCTAssertEqual(viewModel.entitlementState, .proRequired)
    }
}
```

- [ ] **Step 2: Run tests to verify failure**

Run:

```bash
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: FAIL because `RulesViewModel` and Screen Time adapters are not defined.

- [ ] **Step 3: Implement adapter and rules state**

Create `Lockd/ScreenTime/ScreenTimeControlling.swift`:

```swift
import Foundation

protocol ScreenTimeControlling {
    var entitlementState: EntitlementState { get }
    func requestAuthorization() async -> EntitlementState
    func applyBlock(to apps: [DistractingApp], durationMinutes: Int) async throws
    func clearActiveBlock() async throws
}

enum ScreenTimeControllerError: Error, Equatable {
    case unavailable
    case permissionMissing
}
```

Create `Lockd/ScreenTime/MockScreenTimeController.swift`:

```swift
import Foundation

struct MockScreenTimeController: ScreenTimeControlling {
    let entitlementState: EntitlementState

    init(entitlementState: EntitlementState = .unavailableInBuild) {
        self.entitlementState = entitlementState
    }

    func requestAuthorization() async -> EntitlementState {
        entitlementState
    }

    func applyBlock(to apps: [DistractingApp], durationMinutes: Int) async throws {
        if entitlementState == .permissionMissing {
            throw ScreenTimeControllerError.permissionMissing
        }
        if entitlementState == .unavailableInBuild {
            throw ScreenTimeControllerError.unavailable
        }
    }

    func clearActiveBlock() async throws {}
}
```

Create `Lockd/Rules/RulesViewModel.swift`:

```swift
import Foundation
import Combine

@MainActor
final class RulesViewModel: ObservableObject {
    @Published private(set) var selectedApps: [DistractingApp] = []
    @Published private(set) var goal: GoalPreset = .cutBrainRot
    @Published private(set) var frictionLevel: FrictionLevel = .soft
    @Published private(set) var isPredictiveProtectionEnabled = false
    @Published private(set) var entitlementState: EntitlementState

    private let screenTimeController: ScreenTimeControlling

    init(screenTimeController: ScreenTimeControlling) {
        self.screenTimeController = screenTimeController
        self.entitlementState = screenTimeController.entitlementState
    }

    func chooseApp(_ app: DistractingApp) {
        guard !selectedApps.contains(app) else { return }
        selectedApps.append(app)
    }

    func setGoal(_ goal: GoalPreset) {
        self.goal = goal
    }

    func setFrictionLevel(_ frictionLevel: FrictionLevel) {
        self.frictionLevel = frictionLevel
    }

    func enablePredictiveProtection() {
        guard entitlementState == .available else {
            isPredictiveProtectionEnabled = false
            return
        }
        isPredictiveProtectionEnabled = true
    }
}
```

- [ ] **Step 4: Run tests to verify pass**

Run:

```bash
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS for rules tests.

- [ ] **Step 5: Commit**

```bash
git add Lockd/ScreenTime Lockd/Rules/RulesViewModel.swift LockdTests/RulesStateTests.swift
git commit -m "feat: add Screen Time adapter boundary"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 5: Design System And Animated Buttons

**Files:**
- Create: `Lockd/DesignSystem/LockdTheme.swift`
- Create: `Lockd/DesignSystem/LockdButton.swift`

**Interfaces:**
- Consumes: no domain types.
- Produces: `LockdTheme`, `LockdButton`, and `LockdButtonStyle`.

- [ ] **Step 1: Implement theme primitives**

Create `Lockd/DesignSystem/LockdTheme.swift`:

```swift
import SwiftUI

enum LockdTheme {
    static let background = Color(red: 0.035, green: 0.039, blue: 0.047)
    static let surface = Color(red: 0.075, green: 0.082, blue: 0.096)
    static let elevatedSurface = Color(red: 0.105, green: 0.113, blue: 0.133)
    static let protectedGreen = Color(red: 0.42, green: 1.0, blue: 0.48)
    static let riskOrange = Color(red: 1.0, green: 0.42, blue: 0.18)
    static let insightBlue = Color(red: 0.27, green: 0.58, blue: 1.0)
    static let primaryText = Color.white
    static let secondaryText = Color.white.opacity(0.68)

    static let cornerRadius: CGFloat = 18
    static let compactRadius: CGFloat = 12
    static let minimumTouchTarget: CGFloat = 44
}
```

- [ ] **Step 2: Implement animated button component**

Create `Lockd/DesignSystem/LockdButton.swift`:

```swift
import SwiftUI
#if os(iOS)
import UIKit
#endif

enum LockdButtonStyle {
    case primary
    case secondary
    case warning
}

struct LockdButton: View {
    let title: String
    let systemImage: String
    let style: LockdButtonStyle
    let isLoading: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var isPressed = false

    init(
        _ title: String,
        systemImage: String,
        style: LockdButtonStyle = .primary,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.systemImage = systemImage
        self.style = style
        self.isLoading = isLoading
        self.action = action
    }

    var body: some View {
        Button {
            triggerHaptic()
            action()
        } label: {
            HStack(spacing: 10) {
                if isLoading {
                    ProgressView()
                        .tint(foreground)
                } else {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .font(.headline)
                    .lineLimit(1)
                    .minimumScaleFactor(0.82)
            }
            .foregroundStyle(foreground)
            .frame(maxWidth: .infinity, minHeight: LockdTheme.minimumTouchTarget)
            .padding(.vertical, 6)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: LockdTheme.compactRadius, style: .continuous))
            .scaleEffect(isPressed && !reduceMotion ? 0.97 : 1)
        }
        .buttonStyle(.plain)
        .disabled(isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(reduceMotion ? nil : .spring(response: 0.16, dampingFraction: 0.72), value: isPressed)
        .accessibilityLabel(title)
    }

    private func triggerHaptic() {
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        #endif
    }

    private var foreground: Color {
        switch style {
        case .primary:
            return .black
        case .secondary, .warning:
            return .white
        }
    }

    private var background: Color {
        switch style {
        case .primary:
            return LockdTheme.protectedGreen
        case .secondary:
            return LockdTheme.elevatedSurface
        case .warning:
            return LockdTheme.riskOrange
        }
    }
}
```

- [ ] **Step 3: Commit**

```bash
git add Lockd/DesignSystem
git commit -m "feat: add Lockd design system buttons"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 6: Today, Rules, And Insights Vertical Slice

**Files:**
- Create: `Lockd/Today/TodayViewModel.swift`
- Create: `Lockd/Today/TodayView.swift`
- Create: `Lockd/Settings/SettingsView.swift`
- Create: `Lockd/Rules/RulesView.swift`
- Create: `Lockd/Insights/InsightsViewModel.swift`
- Create: `Lockd/Insights/InsightsView.swift`
- Modify: `Lockd/App/AppRootView.swift`

**Interfaces:**
- Consumes: `FocusScoreCalculator`, `WeakSpotPredictor`, `LockSession`, `RulesViewModel`, and `LockdButton`.
- Produces: `MainTabView`, `TodayView`, `RulesView`, and `InsightsView`.

- [ ] **Step 1: Implement Today view model**

Create `Lockd/Today/TodayViewModel.swift`:

```swift
import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var focusScore = 82
    @Published private(set) var weakSpot = WeakSpotWindow(hour: 21, riskLevel: .high, explanation: "TikTok opens usually spike here.")
    @Published private(set) var activeSession: LockSession?
    @Published private(set) var buttonTitle = "Lock In"

    func startLockIn() {
        activeSession = LockSession.start(durationMinutes: 25)
        buttonTitle = "Protected"
    }

    func completeMockSession() {
        guard let activeSession else { return }
        self.activeSession = activeSession.complete(at: Date(), honoredMinutes: 25)
        focusScore = 94
        buttonTitle = "+12 Focus Score"
    }
}
```

- [ ] **Step 2: Implement Today UI**

Create `Lockd/Today/TodayView.swift`:

```swift
import SwiftUI

struct TodayView: View {
    @StateObject private var viewModel = TodayViewModel()
    @State private var isShowingSettings = false

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 22) {
                        header
                        scoreCard
                        weakSpotCard
                        sessionCard
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Today")
            .toolbar {
                Button {
                    isShowingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                        .foregroundStyle(LockdTheme.secondaryText)
                }
                .accessibilityLabel("Settings")
            }
            .sheet(isPresented: $isShowingSettings) {
                SettingsView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Protect the next block.")
                .font(.largeTitle.bold())
                .foregroundStyle(LockdTheme.primaryText)
            Text("Your next weak spot is predictable.")
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
    }

    private var scoreCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Focus Score")
                .font(.headline)
                .foregroundStyle(LockdTheme.secondaryText)
            Text("\(viewModel.focusScore)")
                .font(.system(size: 72, weight: .black, design: .rounded))
                .foregroundStyle(LockdTheme.protectedGreen)
                .accessibilityLabel("Focus Score \(viewModel.focusScore)")
            LockdButton(viewModel.buttonTitle, systemImage: "lock.fill") {
                viewModel.startLockIn()
            }
        }
        .padding(18)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }

    private var weakSpotCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("9:10 PM - high risk", systemImage: "exclamationmark.triangle.fill")
                .font(.headline)
                .foregroundStyle(LockdTheme.riskOrange)
            Text("Why: \(viewModel.weakSpot.explanation)")
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }

    private var sessionCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(viewModel.activeSession == nil ? "No session active" : "Protected mode active")
                .font(.headline)
                .foregroundStyle(LockdTheme.primaryText)
            Text(viewModel.activeSession == nil ? "Start with a 25-minute lock-in." : "Your selected apps are guarded by the mock Screen Time adapter.")
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.elevatedSurface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
```

- [ ] **Step 3: Implement Settings UI**

Create `Lockd/Settings/SettingsView.swift`:

```swift
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("Protection") {
                        Label("Screen Time access is mocked in this build", systemImage: "shield.lefthalf.filled")
                        Label("Family Controls entitlement comes before release", systemImage: "checkmark.seal")
                    }

                    Section("Privacy") {
                        Label("Focus Score stays private by default", systemImage: "lock.fill")
                        Label("Recap cards share only when you choose", systemImage: "square.and.arrow.up")
                    }

                    Section("Subscription") {
                        Label("Manage Pro after App Store setup", systemImage: "creditcard")
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .toolbar {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}
```

- [ ] **Step 4: Implement Rules UI**

Create `Lockd/Rules/RulesView.swift`:

```swift
import SwiftUI

struct RulesView: View {
    @StateObject private var viewModel = RulesViewModel(screenTimeController: MockScreenTimeController(entitlementState: .proRequired))
    private let sampleApps = [
        DistractingApp(name: "TikTok", symbolName: "music.note"),
        DistractingApp(name: "Instagram", symbolName: "camera"),
        DistractingApp(name: "YouTube", symbolName: "play.rectangle"),
        DistractingApp(name: "Reddit", symbolName: "bubble.left.and.bubble.right"),
        DistractingApp(name: "Safari", symbolName: "safari")
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                List {
                    Section("Distracting apps") {
                        ForEach(sampleApps) { app in
                            Button {
                                viewModel.chooseApp(app)
                            } label: {
                                Label(app.name, systemImage: app.symbolName)
                            }
                            .foregroundStyle(LockdTheme.primaryText)
                        }
                    }

                    Section("Goal") {
                        Picker("Goal", selection: Binding(get: { viewModel.goal }, set: { viewModel.setGoal($0) })) {
                            ForEach(GoalPreset.allCases) { goal in
                                Text(goal.rawValue).tag(goal)
                            }
                        }
                    }

                    Section("Protection") {
                        Picker("Friction", selection: Binding(get: { viewModel.frictionLevel }, set: { viewModel.setFrictionLevel($0) })) {
                            ForEach(FrictionLevel.allCases) { level in
                                Text(level.rawValue).tag(level)
                            }
                        }
                        Button("Enable Predictive Protection") {
                            viewModel.enablePredictiveProtection()
                        }
                        Text("Predictive Protection requires Pro in this mock build.")
                            .foregroundStyle(LockdTheme.secondaryText)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Rules")
        }
    }
}
```

- [ ] **Step 5: Implement Insights view model and UI**

Create `Lockd/Insights/InsightsViewModel.swift`:

```swift
import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    let weeklyScore = 86
    let reclaimedHours = 11
    let streakDays = 5
    let topPattern = "Night drift windows are your highest-risk pattern."
}
```

Create `Lockd/Insights/InsightsView.swift`:

```swift
import SwiftUI

struct InsightsView: View {
    @StateObject private var viewModel = InsightsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                LockdTheme.background.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("Weekly control")
                            .font(.largeTitle.bold())
                            .foregroundStyle(LockdTheme.primaryText)

                        metric(title: "Weekly Focus Score", value: "\(viewModel.weeklyScore)", color: LockdTheme.protectedGreen)
                        metric(title: "Time reclaimed", value: "\(viewModel.reclaimedHours)h", color: LockdTheme.insightBlue)
                        metric(title: "Protected streak", value: "\(viewModel.streakDays)d", color: LockdTheme.riskOrange)

                        ShareCardView(score: viewModel.weeklyScore, reclaimedHours: viewModel.reclaimedHours, streakDays: viewModel.streakDays)
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Insights")
        }
    }

    private func metric(title: String, value: String, color: Color) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(LockdTheme.secondaryText)
            Spacer()
            Text(value)
                .font(.title.bold())
                .foregroundStyle(color)
        }
        .padding(18)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
```

- [ ] **Step 6: Wire tab shell**

Replace `Lockd/App/AppRootView.swift` with:

```swift
import SwiftUI

struct AppRootView: View {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    var body: some View {
        TabView {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "lock.shield")
                }

            RulesView()
                .tabItem {
                    Label("Rules", systemImage: "slider.horizontal.3")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
        .tint(LockdTheme.protectedGreen)
    }
}
```

- [ ] **Step 7: Build on macOS**

Run:

```bash
xcodebuild build -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS with a runnable simulator app showing Today, Rules, and Insights tabs.

- [ ] **Step 8: Commit**

```bash
git add Lockd/App/AppRootView.swift Lockd/Today Lockd/Settings Lockd/Rules/RulesView.swift Lockd/Insights
git commit -m "feat: build Lockd tabbed vertical slice"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 7: Onboarding, Paywall, And Share Card

**Files:**
- Create: `Lockd/Onboarding/OnboardingView.swift`
- Create: `Lockd/Paywall/PaywallView.swift`
- Create: `Lockd/Share/ShareCardView.swift`

**Interfaces:**
- Consumes: `LockdButton`, `LockdTheme`, and `ShareCardView`.
- Produces: value-first onboarding, Predictive Protection paywall surface, and opt-in recap card.

- [ ] **Step 1: Implement onboarding flow**

Create `Lockd/Onboarding/OnboardingView.swift`:

```swift
import SwiftUI

struct OnboardingView: View {
    let onComplete: () -> Void
    @State private var step = 0

    private let titles = [
        "Your weak spots are predictable.",
        "Pick three apps to guard.",
        "Choose the lock-in goal.",
        "Try a 10-minute quick lock."
    ]

    private let subtitles = [
        "Lockd helps you stop before the scroll starts.",
        "Start small. TikTok, Instagram, YouTube, Reddit, Safari, or your own selections later.",
        "Cut brain rot, study without folding, sleep without scrolling, or start Monk Mode.",
        "Feel protected now. Permissions and Pro come after the first win."
    ]

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 26) {
                Spacer()
                Text(titles[step])
                    .font(.system(size: 42, weight: .black, design: .rounded))
                    .foregroundStyle(LockdTheme.primaryText)
                    .minimumScaleFactor(0.78)
                Text(subtitles[step])
                    .font(.title3)
                    .foregroundStyle(LockdTheme.secondaryText)
                Spacer()
                LockdButton(step == titles.count - 1 ? "Start Lockd" : "Continue", systemImage: "arrow.right") {
                    if step == titles.count - 1 {
                        onComplete()
                    } else {
                        step += 1
                    }
                }
            }
            .padding(24)
        }
    }
}
```

- [ ] **Step 2: Implement paywall surface**

Create `Lockd/Paywall/PaywallView.swift`:

```swift
import SwiftUI

struct PaywallView: View {
    let onClose: () -> Void

    var body: some View {
        ZStack {
            LockdTheme.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 18) {
                Text("Unlock Predictive Protection")
                    .font(.largeTitle.bold())
                    .foregroundStyle(LockdTheme.primaryText)
                Text("Automatic weak-spot detection, unlimited lock-ins, advanced schedules, weekly insight cards, premium recap cards, and challenge packs.")
                    .foregroundStyle(LockdTheme.secondaryText)
                pricing(title: "$39.99 / year", subtitle: "7-day free trial. Best for Monk Mode.")
                pricing(title: "$5.99 / month", subtitle: "Flexible monthly protection.")
                LockdButton("Start 7-day trial", systemImage: "lock.open.fill") {}
                Button("Maybe later", action: onClose)
                    .foregroundStyle(LockdTheme.secondaryText)
                    .frame(maxWidth: .infinity, minHeight: LockdTheme.minimumTouchTarget)
            }
            .padding(24)
        }
    }

    private func pricing(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
                .foregroundStyle(LockdTheme.primaryText)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(LockdTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
```

- [ ] **Step 3: Implement share card**

Create `Lockd/Share/ShareCardView.swift`:

```swift
import SwiftUI

struct ShareCardView: View {
    let score: Int
    let reclaimedHours: Int
    let streakDays: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("LOCKD RECAP")
                .font(.caption.bold())
                .foregroundStyle(LockdTheme.secondaryText)
            Text("\(score)")
                .font(.system(size: 64, weight: .black, design: .rounded))
                .foregroundStyle(LockdTheme.protectedGreen)
                .accessibilityLabel("Share recap Focus Score \(score)")
            Text("\(reclaimedHours) hours reclaimed")
                .font(.title3.bold())
                .foregroundStyle(LockdTheme.primaryText)
            Text("\(streakDays)-day protected streak")
                .foregroundStyle(LockdTheme.secondaryText)
            Text("Private by default. Shared only when you choose.")
                .font(.caption)
                .foregroundStyle(LockdTheme.secondaryText)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [LockdTheme.elevatedSurface, LockdTheme.surface],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: LockdTheme.cornerRadius, style: .continuous))
    }
}
```

- [ ] **Step 4: Build on macOS**

Run:

```bash
xcodebuild build -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: PASS with onboarding and share card compiling.

- [ ] **Step 5: Commit**

```bash
git add Lockd/Onboarding Lockd/Paywall Lockd/Share
git commit -m "feat: add onboarding paywall and recap surfaces"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

### Task 8: QA Checklist And Final Verification

**Files:**
- Create: `docs/qa/lockd-visual-qa.md`

**Interfaces:**
- Consumes: complete app source from Tasks 1-7.
- Produces: manual QA checklist for simulator and accessibility verification.

- [ ] **Step 1: Create visual QA checklist**

Create `docs/qa/lockd-visual-qa.md`:

```markdown
# Lockd Visual QA

Run these checks on macOS with Xcode after generating `Lockd.xcodeproj`.

## Build

- Generate project: `xcodegen generate`
- Run tests: `xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'`
- Run app: open `Lockd.xcodeproj`, select an iPhone simulator, and press Run.

## Viewports

- iPhone SE sized simulator: no clipped buttons, tab labels, or score text.
- Standard iPhone simulator: Today, Rules, Insights fit with comfortable spacing.
- Large iPhone simulator: cards do not stretch into awkward low-density layouts.

## Accessibility

- VoiceOver reads Focus Score, Settings, Lock In, Rules choices, and share recap clearly.
- Dynamic Type Large keeps buttons at or above 44pt and prevents text overlap.
- Reduce Motion disables springy press scale and avoids repeated animation loops.
- Risk states are not color-only: icons and text labels are present.

## Product States

- Fresh install opens onboarding.
- Onboarding completion opens Today.
- Today Lock In button enters protected state.
- Rules can select app rows without duplicate entries.
- Predictive Protection shows Pro-required state in mock mode.
- Insights shows weekly score, reclaimed time, streak, and private-by-default recap copy.

## Visual Standard

- Dark graphite base, green protected accent, orange risk accent, blue insight accent.
- No generic purple AI gradient treatment.
- No nested cards inside cards.
- No hero-scale type inside compact controls.
- Buttons do not wrap or resize on press.
```

- [ ] **Step 2: Run static file checks on this Windows workspace**

Run:

```powershell
$badPatterns = @('TO' + 'DO', 'TB' + 'D', 'fill' + ' in', 'implement' + ' later') -join '|'
rg -n $badPatterns Lockd docs/superpowers/specs docs/qa project.yml .gitignore
rg -n "React Native|PWA|web wrapper" docs Lockd project.yml
```

Expected: first command returns no matches; second command only returns the spec or plan language explaining those are not the target.

- [ ] **Step 3: Run full macOS verification**

Run:

```bash
xcodegen generate
xcodebuild test -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
xcodebuild build -project Lockd.xcodeproj -scheme Lockd -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: all commands pass on macOS with Xcode and an available iPhone simulator.

- [ ] **Step 4: Commit**

```bash
git add docs/qa/lockd-visual-qa.md
git commit -m "docs: add Lockd visual QA checklist"
```

Expected: commit succeeds after `.git` ACL write permission is repaired.

---

## Self-Review

### Spec Coverage

- Native SwiftUI target: Task 1.
- Mock Screen Time adapters: Task 4.
- Focus Score formula and zero cases: Task 2.
- Local weak-spot prediction: Task 3.
- Today, Rules, Insights primary tabs: Task 6.
- Value-first onboarding: Task 7.
- Predictive Protection paywall: Task 7.
- Shareable recap card and private-by-default copy: Task 7.
- Motion/button feedback and reduced-motion support: Task 5.
- Visual QA targets: Task 8.
- Family Controls entitlement risk: Global Constraints and Task 4 adapter boundary.

### Known Execution Constraint

This Windows workspace cannot run `swift`, `xcodegen`, `xcodebuild`, or iOS Simulator. Implementers can still create the source files here. Build, unit test, simulator, VoiceOver, Dynamic Type, and reduced-motion checks require macOS with Xcode.
