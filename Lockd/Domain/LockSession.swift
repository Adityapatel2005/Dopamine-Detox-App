import Foundation

enum LockSessionState: Equatable {
    case active
    case completed
    case interrupted
    case rescueSuggested
}

struct LockSession: Identifiable, Equatable {
    let id: UUID
    let startDate: Date
    let endDate: Date?
    let durationMinutes: Int
    let intendedMinutes: Int
    let honoredMinutes: Int
    let bypassAttempts: Int
    let state: LockSessionState

    static func start(durationMinutes: Int, startDate: Date = Date()) -> LockSession {
        LockSession(
            id: UUID(),
            startDate: startDate,
            endDate: nil,
            durationMinutes: durationMinutes,
            intendedMinutes: durationMinutes,
            honoredMinutes: 0,
            bypassAttempts: 0,
            state: .active
        )
    }

    func complete(at endDate: Date, honoredMinutes: Int) -> LockSession {
        LockSession(
            id: id,
            startDate: startDate,
            endDate: endDate,
            durationMinutes: durationMinutes,
            intendedMinutes: intendedMinutes,
            honoredMinutes: min(max(honoredMinutes, 0), intendedMinutes),
            bypassAttempts: bypassAttempts,
            state: .completed
        )
    }

    func recordBypassAttempt() -> LockSession {
        LockSession(
            id: id,
            startDate: startDate,
            endDate: endDate,
            durationMinutes: durationMinutes,
            intendedMinutes: intendedMinutes,
            honoredMinutes: honoredMinutes,
            bypassAttempts: bypassAttempts + 1,
            state: .rescueSuggested
        )
    }
}
