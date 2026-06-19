import Foundation

final class ShieldRescueStore {
    private enum Keys {
        static let state = "lockd.phase3.shieldRescueState"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults? = UserDefaults(suiteName: LockdAppGroup.identifier)) {
        self.userDefaults = userDefaults ?? .standard
    }

    func loadState() -> ShieldRescueState {
        guard let data = userDefaults.data(forKey: Keys.state),
              let state = try? decoder.decode(ShieldRescueState.self, from: data) else {
            return .defaults
        }

        return state
    }

    func saveState(_ state: ShieldRescueState) {
        guard let data = try? encoder.encode(state) else { return }
        userDefaults.set(data, forKey: Keys.state)
    }

    func saveShieldMode(_ mode: ShieldMode) {
        var state = loadState()
        state.mode = mode
        state.lastUpdatedAt = Date()
        saveState(state)
    }

    func recordBypassAttempt(action: ShieldRescueAction = .primaryPressed) {
        let next = loadState().recording(action)
        saveState(next)
    }

    func recordEmergencyUnlock() {
        let next = loadState().recording(.emergencyUnlock)
        saveState(next)
    }

    func resetSessionRescueState() {
        let mode = loadState().mode
        saveState(ShieldRescueState(
            mode: mode,
            bypassAttempts: 0,
            emergencyUnlocks: 0,
            lastAction: nil,
            lastUpdatedAt: Date()
        ))
    }
}
