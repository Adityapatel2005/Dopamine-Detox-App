import Foundation

protocol ScreenTimeControlling {
    var entitlementState: EntitlementState { get }
    func requestAuthorization() async -> EntitlementState
    func applyBlock(to apps: [DistractingApp], durationMinutes: Int) async throws
    func clearActiveBlock() async throws
}

enum ScreenTimeControllerError: Error, Equatable {
    case unavailable
    case permissionMissing
}
