import Foundation

enum ShieldMode: String, Codable, Equatable {
    case soft
    case hard
}

enum ShieldRescueAction: String, Codable, Equatable {
    case primaryPressed
    case secondaryPressed
    case emergencyUnlock
}

struct ShieldCopy: Equatable {
    let title: String
    let subtitle: String
    let primaryButtonTitle: String
    let secondaryButtonTitle: String

    static func copy(for mode: ShieldMode) -> ShieldCopy {
        switch mode {
        case .soft:
            return ShieldCopy(
                title: "Protected by Lockd",
                subtitle: "This app is guarded for your current lock-in. Take the pause before the scroll starts.",
                primaryButtonTitle: "Back to Lockd",
                secondaryButtonTitle: "Emergency unlock"
            )
        case .hard:
            return ShieldCopy(
                title: "Protected by Lockd",
                subtitle: "Hard block is on. This choice waits until your protected window ends.",
                primaryButtonTitle: "Stay locked",
                secondaryButtonTitle: "Breathe for a moment"
            )
        }
    }
}

struct ShieldRescueState: Codable, Equatable {
    var mode: ShieldMode
    var bypassAttempts: Int
    var emergencyUnlocks: Int
    var lastAction: ShieldRescueAction?
    var lastUpdatedAt: Date?

    static let defaults = ShieldRescueState(
        mode: .soft,
        bypassAttempts: 0,
        emergencyUnlocks: 0,
        lastAction: nil,
        lastUpdatedAt: nil
    )

    var statusMessage: String {
        if emergencyUnlocks > 0 {
            return "\(emergencyUnlocks) emergency unlock\(emergencyUnlocks == 1 ? "" : "s") recorded. Restart a lock-in when you are ready."
        }

        if bypassAttempts > 0 {
            return "\(bypassAttempts) bypass attempt\(bypassAttempts == 1 ? "" : "s") paused by Lockd."
        }

        return "No bypass attempts recorded during this lock-in."
    }

    func recording(_ action: ShieldRescueAction, at date: Date = Date()) -> ShieldRescueState {
        var next = self
        next.lastAction = action
        next.lastUpdatedAt = date

        switch action {
        case .primaryPressed, .secondaryPressed:
            next.bypassAttempts += 1
        case .emergencyUnlock:
            next.emergencyUnlocks += 1
        }

        return next
    }
}
