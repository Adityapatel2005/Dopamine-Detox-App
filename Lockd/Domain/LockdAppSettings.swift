import Foundation

struct LockdAppSettings: Codable, Equatable {
    var permissionSnapshot: LockdPermissionSnapshot
    var defaultLockDurationMinutes: Int
    var hardBlockEnabled: Bool
    var predictiveProtectionEnabled: Bool
    var notificationSettings: NotificationSettings
    var selectionState: ScreenTimeSelectionState
    var selectedAppSummary: [String]
    var lastSavedAt: Date?

    static let defaults = LockdAppSettings(
        permissionSnapshot: .initial,
        defaultLockDurationMinutes: 25,
        hardBlockEnabled: false,
        predictiveProtectionEnabled: false,
        notificationSettings: .defaults,
        selectionState: .empty,
        selectedAppSummary: [],
        lastSavedAt: nil
    )

    mutating func setDefaultLockDuration(_ minutes: Int) {
        defaultLockDurationMinutes = min(max(minutes, 5), 180)
    }

    mutating func updateSelection(_ selection: ScreenTimeSelectionState) {
        selectionState = selection
        selectedAppSummary = selection.selectedAppSummary
    }
}
