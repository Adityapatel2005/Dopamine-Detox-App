import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var focusScore = 82
    @Published private(set) var weakSpot = WeakSpotWindow(hour: 21, riskLevel: .high, explanation: "TikTok opens usually spike here.")
    @Published private(set) var activeSession: LockSession?
    @Published private(set) var buttonTitle = "Lock In"
    @Published private(set) var protectionStatusMessage = "Choose apps in Rules, then Lock In to apply iOS Screen Time shields."
    @Published private(set) var rescueStatusMessage = ShieldRescueState.defaults.statusMessage
    @Published private(set) var bypassAttempts = 0
    @Published private(set) var emergencyUnlocks = 0
    @Published private(set) var isApplyingProtection = false

    private let screenTimeController: ScreenTimeControlling
    private let rescueStore: ShieldRescueStore

    init(
        screenTimeController: ScreenTimeControlling = RealScreenTimeController(),
        rescueStore: ShieldRescueStore = ShieldRescueStore()
    ) {
        self.screenTimeController = screenTimeController
        self.rescueStore = rescueStore
        refreshRescueState()
    }

    func startLockIn(durationMinutes: Int = 25) {
        guard !isApplyingProtection else { return }
        isApplyingProtection = true
        rescueStore.resetSessionRescueState()
        refreshRescueState()
        buttonTitle = "Locking..."
        protectionStatusMessage = "Applying ManagedSettings shields to your saved Screen Time selection."

        Task {
            await applyBlock(durationMinutes: durationMinutes)
        }
    }

    func completeMockSession() {
        guard let activeSession else { return }
        self.activeSession = activeSession.complete(at: Date(), honoredMinutes: 25)
        focusScore = 94
        buttonTitle = "+12 Focus Score"
        protectionStatusMessage = "Session completed. Screen Time shields are being cleared."
        refreshRescueState()

        Task {
            try? await screenTimeController.clearActiveBlock()
        }
    }

    func refreshRescueState() {
        let state = rescueStore.loadState()
        rescueStatusMessage = state.statusMessage
        bypassAttempts = state.bypassAttempts
        emergencyUnlocks = state.emergencyUnlocks
    }

    private func applyBlock(durationMinutes: Int) async {
        do {
            try await screenTimeController.applyBlock(to: [], durationMinutes: durationMinutes)
            activeSession = LockSession.start(durationMinutes: durationMinutes)
            buttonTitle = "Protected"
            protectionStatusMessage = "ManagedSettings shields are active. DeviceActivityMonitor will clear them when this lock-in ends."
        } catch {
            activeSession = nil
            buttonTitle = "Try Again"
            protectionStatusMessage = statusMessage(for: error)
        }

        isApplyingProtection = false
    }

    private func statusMessage(for error: Error) -> String {
        guard let screenTimeError = error as? ScreenTimeControllerError else {
            return "Lockd could not start this lock-in. Check Screen Time permissions and try again."
        }

        switch screenTimeError {
        case .permissionMissing:
            return "Screen Time permission is required. Open Settings and approve Family Controls for Lockd."
        case .noSelection:
            return "No Screen Time selection is saved. Choose apps in Rules before starting a lock-in."
        case .scheduleFailed:
            return "The block was selected, but iOS could not schedule DeviceActivity monitoring."
        case .unavailable:
            return "Real blocking requires an iPhone build with Family Controls, ManagedSettings, and DeviceActivity."
        }
    }
}
