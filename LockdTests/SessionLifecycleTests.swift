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
