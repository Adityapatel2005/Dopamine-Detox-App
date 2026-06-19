import Foundation
import Combine

@MainActor
final class RulesViewModel: ObservableObject {
    @Published private(set) var selectedApps: [DistractingApp] = []
    @Published private(set) var goal: GoalPreset = .cutBrainRot
    @Published private(set) var frictionLevel: FrictionLevel = .soft
    @Published private(set) var isPredictiveProtectionEnabled = false
    @Published private(set) var entitlementState: EntitlementState

    private let screenTimeController: ScreenTimeControlling

    init(screenTimeController: ScreenTimeControlling) {
        self.screenTimeController = screenTimeController
        self.entitlementState = screenTimeController.entitlementState
    }

    func chooseApp(_ app: DistractingApp) {
        guard !selectedApps.contains(app) else { return }
        selectedApps.append(app)
    }

    func setGoal(_ goal: GoalPreset) {
        self.goal = goal
    }

    func setFrictionLevel(_ frictionLevel: FrictionLevel) {
        self.frictionLevel = frictionLevel
    }

    func enablePredictiveProtection() {
        guard entitlementState == .available else {
            isPredictiveProtectionEnabled = false
            return
        }
        isPredictiveProtectionEnabled = true
    }
}
