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
