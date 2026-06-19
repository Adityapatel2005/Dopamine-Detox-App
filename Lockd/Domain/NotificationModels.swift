import Foundation

enum LockdNotificationKind: String, Codable, CaseIterable, Identifiable {
    case weakSpotWarning
    case lockStarted
    case lockEndingSoon
    case lockCompleted
    case rescueNudge
    case dailyPlan
    case weeklyRecap

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weakSpotWarning:
            return "Weak spot warning"
        case .lockStarted:
            return "Lock-in started"
        case .lockEndingSoon:
            return "Lock-in ending soon"
        case .lockCompleted:
            return "Lock-in completed"
        case .rescueNudge:
            return "Rescue nudge"
        case .dailyPlan:
            return "Daily plan"
        case .weeklyRecap:
            return "Weekly recap"
        }
    }

    var defaultBody: String {
        switch self {
        case .weakSpotWarning:
            return "A risky scroll window is coming up. Lock in before it starts."
        case .lockStarted:
            return "Your selected apps are protected for this block."
        case .lockEndingSoon:
            return "You are almost through this lock-in."
        case .lockCompleted:
            return "Session protected. Your Focus Score can update now."
        case .rescueNudge:
            return "Pause for a breath before opening the app."
        case .dailyPlan:
            return "Choose the block you want to protect today."
        case .weeklyRecap:
            return "Your private weekly recap is ready."
        }
    }
}

struct NotificationPreference: Codable, Equatable, Identifiable {
    let kind: LockdNotificationKind
    var isEnabled: Bool
    var leadTimeMinutes: Int

    var id: String { kind.id }

    static func defaultPreference(for kind: LockdNotificationKind) -> NotificationPreference {
        switch kind {
        case .weakSpotWarning:
            return NotificationPreference(kind: kind, isEnabled: true, leadTimeMinutes: 10)
        case .lockStarted:
            return NotificationPreference(kind: kind, isEnabled: true, leadTimeMinutes: 0)
        case .lockEndingSoon:
            return NotificationPreference(kind: kind, isEnabled: true, leadTimeMinutes: 5)
        case .lockCompleted:
            return NotificationPreference(kind: kind, isEnabled: true, leadTimeMinutes: 0)
        case .rescueNudge:
            return NotificationPreference(kind: kind, isEnabled: true, leadTimeMinutes: 0)
        case .dailyPlan:
            return NotificationPreference(kind: kind, isEnabled: false, leadTimeMinutes: 0)
        case .weeklyRecap:
            return NotificationPreference(kind: kind, isEnabled: true, leadTimeMinutes: 0)
        }
    }
}

struct NotificationSettings: Codable, Equatable {
    var authorizationStatus: LockdPermissionStatus
    var quietHoursStartHour: Int
    var quietHoursEndHour: Int
    var preferences: [NotificationPreference]

    static let defaults = NotificationSettings(
        authorizationStatus: .unknown,
        quietHoursStartHour: 22,
        quietHoursEndHour: 7,
        preferences: LockdNotificationKind.allCases.map { NotificationPreference.defaultPreference(for: $0) }
    )

    func preference(for kind: LockdNotificationKind) -> NotificationPreference {
        preferences.first { $0.kind == kind } ?? .defaultPreference(for: kind)
    }

    mutating func setEnabled(_ isEnabled: Bool, for kind: LockdNotificationKind) {
        if let index = preferences.firstIndex(where: { $0.kind == kind }) {
            preferences[index].isEnabled = isEnabled
        } else {
            var preference = NotificationPreference.defaultPreference(for: kind)
            preference.isEnabled = isEnabled
            preferences.append(preference)
        }
    }
}

struct ScheduledLockdNotification: Codable, Equatable, Identifiable {
    let id: String
    let kind: LockdNotificationKind
    let fireDate: Date
    let title: String
    let body: String
}

protocol NotificationScheduling: AnyObject {
    var authorizationStatus: LockdPermissionStatus { get }
    func requestAuthorization() async -> LockdPermissionStatus
    func schedule(_ notifications: [ScheduledLockdNotification]) async throws
    func cancelAllPending() async
}

enum NotificationSchedulingError: Error, Equatable {
    case permissionDenied
    case unavailable
}

final class MockNotificationScheduler: NotificationScheduling {
    private(set) var authorizationStatus: LockdPermissionStatus
    private let authorizationResult: LockdPermissionStatus
    private(set) var scheduledNotifications: [ScheduledLockdNotification] = []

    init(
        authorizationStatus: LockdPermissionStatus = .notDetermined,
        authorizationResult: LockdPermissionStatus = .approved
    ) {
        self.authorizationStatus = authorizationStatus
        self.authorizationResult = authorizationResult
    }

    func requestAuthorization() async -> LockdPermissionStatus {
        authorizationStatus = authorizationResult
        return authorizationResult
    }

    func schedule(_ notifications: [ScheduledLockdNotification]) async throws {
        guard authorizationStatus == .approved else {
            throw NotificationSchedulingError.permissionDenied
        }
        scheduledNotifications = notifications
    }

    func cancelAllPending() async {
        scheduledNotifications.removeAll()
    }
}
