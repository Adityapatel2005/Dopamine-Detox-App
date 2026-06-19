import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    let weeklyScore = 86
    let reclaimedHours = 11
    let streakDays = 5
    let topPattern = "Night drift windows are your highest-risk pattern."
}
