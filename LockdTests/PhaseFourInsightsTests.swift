import XCTest
@testable import Lockd

final class PhaseFourInsightsTests: XCTestCase {
    func testFocusScoreRewardsProtectedMinutesAndPenalizesBypasses() {
        let calculator = FocusScoreCalculator()
        let clean = FocusScoreInput(
            protectedMinutes: 300,
            intendedMinutes: 300,
            completedSessions: 5,
            interruptedSessions: 0,
            bypassAttempts: 0
        )
        let noisy = FocusScoreInput(
            protectedMinutes: 180,
            intendedMinutes: 300,
            completedSessions: 3,
            interruptedSessions: 2,
            bypassAttempts: 4
        )

        XCTAssertGreaterThan(calculator.weeklyScore(from: clean), calculator.weeklyScore(from: noisy))
        XCTAssertLessThanOrEqual(calculator.weeklyScore(from: clean), 100)
    }

    func testWeeklySnapshotIsPrivacyPreserving() {
        let snapshot = FocusScoreCalculator().weeklySnapshot(
            from: .preview,
            streakDays: 5,
            topPattern: "Night drift windows are your highest-risk pattern."
        )

        XCTAssertEqual(snapshot.reclaimedHours, 11)
        XCTAssertTrue(snapshot.isPrivacyPreserving)
    }

    func testWeakSpotPredictorRanksRepeatedRiskWindows() {
        let signals = [
            WeakSpotSignal(hour: 21, weekday: 1, appName: "TikTok", outcome: .openedDistractingApp),
            WeakSpotSignal(hour: 21, weekday: 2, appName: "Instagram", outcome: .softFrictionIgnored),
            WeakSpotSignal(hour: 9, weekday: 3, appName: "Safari", outcome: .sessionCompleted)
        ]

        let prediction = WeakSpotPredictor().predictNextWindow(from: signals)

        XCTAssertEqual(prediction.hour, 21)
        XCTAssertEqual(prediction.riskLevel, .medium)
    }

    func testProEntitlementGatesAdvancedFeatures() {
        XCTAssertFalse(LockdProEntitlement.free.unlocksPredictiveProtection)
        XCTAssertFalse(LockdProEntitlement.free.unlocksAdvancedInsights)
        XCTAssertTrue(LockdProEntitlement.pro(expirationDate: nil).unlocksPredictiveProtection)
        XCTAssertTrue(LockdProEntitlement.pro(expirationDate: nil).unlocksAdvancedInsights)
    }

    func testProductCatalogContainsExpectedSubscriptionIds() {
        XCTAssertTrue(LockdProductCatalog.productIdentifiers.contains("com.lockd.pro.monthly"))
        XCTAssertTrue(LockdProductCatalog.productIdentifiers.contains("com.lockd.pro.yearly"))
    }
}
