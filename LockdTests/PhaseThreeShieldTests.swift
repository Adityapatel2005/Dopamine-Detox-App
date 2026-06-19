import XCTest
@testable import Lockd

final class PhaseThreeShieldTests: XCTestCase {
    func testSoftShieldCopyIncludesEmergencyUnlock() {
        let copy = ShieldCopy.copy(for: .soft)

        XCTAssertEqual(copy.title, "Protected by Lockd")
        XCTAssertEqual(copy.secondaryButtonTitle, "Emergency unlock")
        XCTAssertTrue(copy.subtitle.contains("pause"))
    }

    func testHardShieldCopyRemovesUnlockLanguage() {
        let copy = ShieldCopy.copy(for: .hard)

        XCTAssertEqual(copy.primaryButtonTitle, "Stay locked")
        XCTAssertFalse(copy.secondaryButtonTitle.contains("unlock"))
    }

    func testRescueStateRecordsBypassAndEmergencyUnlockSeparately() {
        let attempted = ShieldRescueState.defaults.recording(.primaryPressed)
        let unlocked = attempted.recording(.emergencyUnlock)

        XCTAssertEqual(unlocked.bypassAttempts, 1)
        XCTAssertEqual(unlocked.emergencyUnlocks, 1)
        XCTAssertEqual(unlocked.lastAction, .emergencyUnlock)
        XCTAssertTrue(unlocked.statusMessage.contains("emergency unlock"))
    }

    func testRescueStorePersistsShieldMode() {
        let defaults = UserDefaults(suiteName: "lockd.phase3.tests.\(UUID().uuidString)")!
        let store = ShieldRescueStore(userDefaults: defaults)

        store.saveShieldMode(.hard)

        XCTAssertEqual(store.loadState().mode, .hard)
    }

    func testRescueStoreResetsCountsButKeepsMode() {
        let defaults = UserDefaults(suiteName: "lockd.phase3.tests.\(UUID().uuidString)")!
        let store = ShieldRescueStore(userDefaults: defaults)

        store.saveShieldMode(.hard)
        store.recordBypassAttempt()
        store.recordEmergencyUnlock()
        store.resetSessionRescueState()

        let state = store.loadState()
        XCTAssertEqual(state.mode, .hard)
        XCTAssertEqual(state.bypassAttempts, 0)
        XCTAssertEqual(state.emergencyUnlocks, 0)
    }
}
