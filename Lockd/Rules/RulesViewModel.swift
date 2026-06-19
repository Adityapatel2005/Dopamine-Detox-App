import Foundation
import Combine

#if canImport(FamilyControls)
import FamilyControls
#endif

@MainActor
final class RulesViewModel: ObservableObject {
    @Published private(set) var selectedApps: [DistractingApp] = []
    @Published private(set) var goal: GoalPreset = .cutBrainRot
    @Published private(set) var frictionLevel: FrictionLevel = .soft
    @Published private(set) var isPredictiveProtectionEnabled = false
    @Published private(set) var entitlementState: EntitlementState
    @Published private(set) var selectionState: ScreenTimeSelectionState
    @Published private(set) var selectionMessage: String

    private let screenTimeController: ScreenTimeControlling
    private let selectionStore: FamilyActivitySelectionStore

    init(
        screenTimeController: ScreenTimeControlling,
        selectionStore: FamilyActivitySelectionStore = FamilyActivitySelectionStore()
    ) {
        self.screenTimeController = screenTimeController
        self.selectionStore = selectionStore
        self.entitlementState = screenTimeController.entitlementState
        self.selectionState = selectionStore.loadSelectionState()
        self.selectionMessage = RulesViewModel.message(for: selectionStore.loadSelectionState())
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

    #if canImport(FamilyControls)
    func loadFamilyActivitySelection() -> FamilyActivitySelection {
        selectionStore.loadSelection()
    }

    func saveFamilyActivitySelection(_ selection: FamilyActivitySelection) {
        do {
            try selectionStore.saveSelection(selection)
            selectionState = ScreenTimeSelectionState(selection: selection)
            selectionMessage = RulesViewModel.message(for: selectionState)
        } catch {
            selectionMessage = "The Screen Time selection could not be saved. Try again before locking in."
        }
    }
    #endif

    private static func message(for selectionState: ScreenTimeSelectionState) -> String {
        guard !selectionState.isEmpty else {
            return "Choose apps, categories, or websites before starting a real lock-in."
        }

        let appText = "\(selectionState.applicationCount) app\(selectionState.applicationCount == 1 ? "" : "s")"
        let categoryText = "\(selectionState.categoryCount) categor\(selectionState.categoryCount == 1 ? "y" : "ies")"
        let webText = "\(selectionState.webDomainCount) web domain\(selectionState.webDomainCount == 1 ? "" : "s")"
        return "Saved \(appText), \(categoryText), and \(webText) for Screen Time shielding."
    }
}
