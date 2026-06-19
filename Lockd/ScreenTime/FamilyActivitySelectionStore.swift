import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

final class FamilyActivitySelectionStore {
    private enum Keys {
        static let selection = "lockd.phase2.familyActivitySelection"
        static let selectionState = "lockd.phase2.selectionState"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults? = UserDefaults(suiteName: LockdAppGroup.identifier)) {
        self.userDefaults = userDefaults ?? .standard
    }

    func saveSelectionState(_ selectionState: ScreenTimeSelectionState) throws {
        let data = try encoder.encode(selectionState)
        userDefaults.set(data, forKey: Keys.selectionState)
    }

    func loadSelectionState() -> ScreenTimeSelectionState {
        guard let data = userDefaults.data(forKey: Keys.selectionState),
              let selectionState = try? decoder.decode(ScreenTimeSelectionState.self, from: data) else {
            return .empty
        }
        return selectionState
    }

    #if canImport(FamilyControls)
    func saveSelection(_ selection: FamilyActivitySelection, summary: [String] = []) throws {
        let data = try encoder.encode(selection)
        userDefaults.set(data, forKey: Keys.selection)
        let selectionState = ScreenTimeSelectionState(selection: selection, selectedAppSummary: summary)
        try saveSelectionState(selectionState)
    }

    func loadSelection() -> FamilyActivitySelection {
        guard let data = userDefaults.data(forKey: Keys.selection),
              let selection = try? decoder.decode(FamilyActivitySelection.self, from: data) else {
            return FamilyActivitySelection()
        }
        return selection
    }
    #endif
}
