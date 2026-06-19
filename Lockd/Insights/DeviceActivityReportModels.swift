import Foundation

struct LockdWeeklyActivitySummary: Equatable {
    let protectedMinutes: Int
    let distractingPickups: Int
    let mostGuardedCategory: String
    let privacyPreserving: Bool

    static let empty = LockdWeeklyActivitySummary(
        protectedMinutes: 0,
        distractingPickups: 0,
        mostGuardedCategory: "Learning",
        privacyPreserving: true
    )

    static let preview = LockdWeeklyActivitySummary(
        protectedMinutes: 660,
        distractingPickups: 14,
        mostGuardedCategory: "Social",
        privacyPreserving: true
    )

    var sourceDescription: String {
        "DeviceActivityReport privacyPreserving weekly summary"
    }
}
