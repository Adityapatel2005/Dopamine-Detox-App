import Foundation
import Combine

@MainActor
final class TodayViewModel: ObservableObject {
    @Published private(set) var focusScore = 82
    @Published private(set) var weakSpot = WeakSpotWindow(hour: 21, riskLevel: .high, explanation: "TikTok opens usually spike here.")
    @Published private(set) var activeSession: LockSession?
    @Published private(set) var buttonTitle = "Lock In"

    func startLockIn() {
        activeSession = LockSession.start(durationMinutes: 25)
        buttonTitle = "Protected"
    }

    func completeMockSession() {
        guard let activeSession else { return }
        self.activeSession = activeSession.complete(at: Date(), honoredMinutes: 25)
        focusScore = 94
        buttonTitle = "+12 Focus Score"
    }
}
