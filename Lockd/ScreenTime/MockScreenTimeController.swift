import Foundation

struct MockScreenTimeController: ScreenTimeControlling {
    let entitlementState: EntitlementState

    init(entitlementState: EntitlementState = .unavailableInBuild) {
        self.entitlementState = entitlementState
    }

    func requestAuthorization() async -> EntitlementState {
        entitlementState
    }

    func applyBlock(to apps: [DistractingApp], durationMinutes: Int) async throws {
        if entitlementState == .permissionMissing {
            throw ScreenTimeControllerError.permissionMissing
        }
        if entitlementState == .unavailableInBuild {
            throw ScreenTimeControllerError.unavailable
        }
    }

    func clearActiveBlock() async throws {}
}
