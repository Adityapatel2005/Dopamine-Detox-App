import Foundation

struct FocusScoreInput: Equatable {
    let intendedMinutes: Int
    let honoredMinutes: Int
    let goalAppMinutesTarget: Int
    let goalAppMinutesActual: Int
    let sessionsStarted: Int
    let sessionsCompleted: Int
}

enum FocusScoreCalculator {
    static func calculate(_ input: FocusScoreInput) -> Int {
        guard input.intendedMinutes > 0 || input.sessionsStarted > 0 || input.goalAppMinutesTarget > 0 else {
            return 0
        }

        let adherence = ratio(numerator: input.honoredMinutes, denominator: input.intendedMinutes)
        let goalRate = goalRatio(target: input.goalAppMinutesTarget, actual: input.goalAppMinutesActual)
        let sessionRate = ratio(numerator: input.sessionsCompleted, denominator: input.sessionsStarted)
        let rawScore = 100 * ((0.5 * adherence) + (0.3 * goalRate) + (0.2 * sessionRate))

        return min(max(Int(rawScore.rounded()), 0), 100)
    }

    private static func ratio(numerator: Int, denominator: Int) -> Double {
        guard denominator > 0 else { return 0 }
        return min(max(Double(numerator) / Double(denominator), 0), 1)
    }

    private static func goalRatio(target: Int, actual: Int) -> Double {
        guard target > 0 else { return 0 }
        let underGoalMinutes = max(target - actual, 0)
        return min(Double(underGoalMinutes) / Double(target), 1)
    }
}
