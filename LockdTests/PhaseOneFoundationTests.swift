import XCTest
@testable import Lockd

final class PhaseOneFoundationTests: XCTestCase {
    func testDefaultSettingsPrepareNativeFoundation() {
        let settings = LockdAppSettings.defaults

        XCTAssertEqual(settings.defaultLockDurationMinutes, 25)
        XCTAssertFalse(settings.hardBlockEnabled)
        XCTAssertFalse(settings.predictiveProtectionEnabled)
        XCTAssertTrue(settings.selectedAppSummary.isEmpty)
        XCTAssertEqual(settings.permissionSnapshot.screenTime, .unknown)
    }

    func testNotificationDefaultsIncludeFocusLifecycle() {
        let settings = NotificationSettings.defaults

        XCTAssertTrue(settings.preference(for: .weakSpotWarning).isEnabled)
        XCTAssertTrue(settings.preference(for: .lockEndingSoon).isEnabled)
        XCTAssertTrue(settings.preference(for: .weeklyRecap).isEnabled)
        XCTAssertFalse(settings.preference(for: .dailyPlan).isEnabled)
    }

    @MainActor
    func testViewModelPersistsDefaultDuration() {
        let store = InMemoryAppSettingsStore()
        let viewModel = PhaseOneSettingsViewModel(store: store)

        viewModel.setDefaultLockDuration(45)

        XCTAssertEqual(store.load().defaultLockDurationMinutes, 45)
    }

    @MainActor
    func testViewModelUpdatesNotificationAuthorization() async {
        let store = InMemoryAppSettingsStore()
        let scheduler = MockNotificationScheduler(authorizationResult: .approved)
        let viewModel = PhaseOneSettingsViewModel(store: store, notificationScheduler: scheduler)

        await viewModel.requestNotificationAuthorization()

        XCTAssertEqual(store.load().permissionSnapshot.notifications, .approved)
        XCTAssertEqual(store.load().notificationSettings.authorizationStatus, .approved)
    }
}
