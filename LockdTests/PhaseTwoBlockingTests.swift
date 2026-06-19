import XCTest
@testable import Lockd

final class PhaseTwoBlockingTests: XCTestCase {
    func testSelectionStateCountsAllSelectionTypes() {
        let selectionState = ScreenTimeSelectionState(
            applicationCount: 2,
            categoryCount: 1,
            webDomainCount: 3,
            selectedAppSummary: ["TikTok", "YouTube"]
        )

        XCTAssertEqual(selectionState.totalSelectionCount, 6)
        XCTAssertFalse(selectionState.isEmpty)
    }

    func testEmptySelectionStateIsEmpty() {
        XCTAssertTrue(ScreenTimeSelectionState.empty.isEmpty)
        XCTAssertEqual(ScreenTimeSelectionState.empty.totalSelectionCount, 0)
    }

    func testLockdAppGroupIdentifierIsStable() {
        XCTAssertEqual(LockdAppGroup.identifier, "group.com.lockd.app")
    }
}
