import Foundation

enum LockdPermissionStatus: String, Codable, Equatable, CaseIterable, Identifiable {
    case unknown
    case notDetermined
    case approved
    case denied
    case unavailable

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .notDetermined:
            return "Not requested"
        case .approved:
            return "Allowed"
        case .denied:
            return "Denied"
        case .unavailable:
            return "Unavailable"
        }
    }

    var isApproved: Bool {
        self == .approved
    }
}

struct LockdPermissionSnapshot: Codable, Equatable {
    var screenTime: LockdPermissionStatus
    var notifications: LockdPermissionStatus
    var lastCheckedAt: Date?

    static let initial = LockdPermissionSnapshot(
        screenTime: .unknown,
        notifications: .unknown,
        lastCheckedAt: nil
    )

    var canStartRealLock: Bool {
        screenTime.isApproved
    }
}
