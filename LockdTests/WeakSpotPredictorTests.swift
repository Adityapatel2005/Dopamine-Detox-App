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
