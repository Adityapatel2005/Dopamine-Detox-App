import Foundation
import Combine

@MainActor
final class InsightsViewModel: ObservableObject {
    @Published private(set) var snapshot: WeeklyInsightSnapshot
    @Published private(set) var nextWeakSpot: WeakSpotWindow
    @Published private(set) var entitlement: LockdProEntitlement

    private let calculator: FocusScoreCalculator
    private let weakSpotPredictor: WeakSpotPredictor

    init(
        calculator: FocusScoreCalculator = FocusScoreCalculator(),
        weakSpotPredictor: WeakSpotPredictor = WeakSpotPredictor(),
        entitlement: LockdProEntitlement = .free
    ) {
        self.calculator = calculator
        self.weakSpotPredictor = weakSpotPredictor
        self.entitlement = entitlement

        let signals = Self.previewSignals
        let predictedWindow = weakSpotPredictor.predictNextWindow(from: signals)
        self.nextWeakSpot = predictedWindow
        self.snapshot = calculator.weeklySnapshot(
            from: .preview,
            streakDays: 5,
            topPattern: predictedWindow.explanation
        )
    }

    var weeklyScore: Int { snapshot.weeklyScore }
    var reclaimedHours: Int { snapshot.reclaimedHours }
    var streakDays: Int { snapshot.streakDays }
    var topPattern: String { snapshot.topPattern }
    var isAdvancedInsightsLocked: Bool { !entitlement.unlocksAdvancedInsights }

    func applyEntitlement(_ entitlement: LockdProEntitlement) {
        self.entitlement = entitlement
    }

    private static let previewSignals = [
        WeakSpotSignal(hour: 21, weekday: 2, appName: "TikTok", outcome: .openedDistractingApp),
        WeakSpotSignal(hour: 21, weekday: 3, appName: "Instagram", outcome: .softFrictionIgnored),
        WeakSpotSignal(hour: 22, weekday: 4, appName: "YouTube", outcome: .sessionInterrupted),
        WeakSpotSignal(hour: 21, weekday: 5, appName: "TikTok", outcome: .openedDistractingApp),
        WeakSpotSignal(hour: 9, weekday: 6, appName: "Safari", outcome: .sessionCompleted)
    ]
}
