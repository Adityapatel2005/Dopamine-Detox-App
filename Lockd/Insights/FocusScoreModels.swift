import Foundation

struct FocusScoreInput: Equatable {
    let protectedMinutes: Int
    let intendedMinutes: Int
    let completedSessions: Int
    let interruptedSessions: Int
    let bypassAttempts: Int

    static let preview = FocusScoreInput(
        protectedMinutes: 660,
        intendedMinutes: 720,
        completedSessions: 9,
        interruptedSessions: 1,
        bypassAttempts: 2
    )
}

struct WeeklyInsightSnapshot: Equatable {
    let weeklyScore: Int
    let reclaimedHours: Int
    let streakDays: Int
    let protectedMinutes: Int
    let bypassAttempts: Int
    let topPattern: String
    let isPrivacyPreserving: Bool
}

struct FocusScoreCalculator {
    func weeklyScore(from input: FocusScoreInput) -> Int {
        guard input.intendedMinutes > 0 else { return 50 }

        let completionRatio = Double(input.protectedMinutes) / Double(input.intendedMinutes)
        let completionScore = completionRatio * 72
        let sessionBonus = min(Double(input.completedSessions) * 2.2, 18)
        let interruptionPenalty = Double(input.interruptedSessions * 7)
        let bypassPenalty = Double(input.bypassAttempts * 3)

        return clamp(Int((completionScore + sessionBonus - interruptionPenalty - bypassPenalty).rounded()))
    }

    func weeklySnapshot(
        from input: FocusScoreInput,
        streakDays: Int,
        topPattern: String
    ) -> WeeklyInsightSnapshot {
        WeeklyInsightSnapshot(
            weeklyScore: weeklyScore(from: input),
            reclaimedHours: max(0, input.protectedMinutes / 60),
            streakDays: streakDays,
            protectedMinutes: input.protectedMinutes,
            bypassAttempts: input.bypassAttempts,
            topPattern: topPattern,
            isPrivacyPreserving: true
        )
    }

    private func clamp(_ value: Int) -> Int {
        min(100, max(0, value))
    }
}
