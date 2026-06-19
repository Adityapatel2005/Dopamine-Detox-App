import Foundation
import Combine

@MainActor
final class PhaseOneSettingsViewModel: ObservableObject {
    @Published private(set) var settings: LockdAppSettings
    @Published private(set) var saveErrorMessage: String?

    private let store: AppSettingsStoring
    private let notificationScheduler: NotificationScheduling
    private let screenTimeAuthorizationController: NativeScreenTimeAuthorizationController

    init(
        store: AppSettingsStoring = UserDefaultsAppSettingsStore(),
        notificationScheduler: NotificationScheduling = MockNotificationScheduler(),
        screenTimeAuthorizationController: NativeScreenTimeAuthorizationController = NativeScreenTimeAuthorizationController()
    ) {
        self.store = store
        self.notificationScheduler = notificationScheduler
        self.screenTimeAuthorizationController = screenTimeAuthorizationController
        self.settings = store.load()
        refreshPermissionSnapshot()
    }

    func refreshPermissionSnapshot() {
        settings.permissionSnapshot.screenTime = screenTimeAuthorizationController.currentStatus
        settings.permissionSnapshot.notifications = notificationScheduler.authorizationStatus
        settings.permissionSnapshot.lastCheckedAt = Date()
        persist()
    }

    func requestScreenTimeAuthorization() async {
        let status = await screenTimeAuthorizationController.requestAuthorization()
        settings.permissionSnapshot.screenTime = status
        settings.permissionSnapshot.lastCheckedAt = Date()
        persist()
    }

    func requestNotificationAuthorization() async {
        let status = await notificationScheduler.requestAuthorization()
        settings.permissionSnapshot.notifications = status
        settings.notificationSettings.authorizationStatus = status
        settings.permissionSnapshot.lastCheckedAt = Date()
        persist()
    }

    func setDefaultLockDuration(_ minutes: Int) {
        settings.setDefaultLockDuration(minutes)
        persist()
    }

    func setHardBlockEnabled(_ isEnabled: Bool) {
        settings.hardBlockEnabled = isEnabled
        persist()
    }

    func setPredictiveProtectionEnabled(_ isEnabled: Bool) {
        settings.predictiveProtectionEnabled = isEnabled
        persist()
    }

    func isNotificationEnabled(_ kind: LockdNotificationKind) -> Bool {
        settings.notificationSettings.preference(for: kind).isEnabled
    }

    func toggleNotification(_ kind: LockdNotificationKind, isEnabled: Bool) {
        settings.notificationSettings.setEnabled(isEnabled, for: kind)
        persist()
    }

    func resetLocalSettings() {
        do {
            try store.reset()
            settings = store.load()
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "Could not reset local settings."
        }
    }

    private func persist() {
        do {
            try store.save(settings)
            saveErrorMessage = nil
        } catch {
            saveErrorMessage = "Could not save settings."
        }
    }
}
