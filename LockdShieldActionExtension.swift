import Foundation

#if canImport(FamilyControls) && canImport(ManagedSettings)
import FamilyControls
import ManagedSettings

final class LockdShieldActionExtension: ShieldActionDelegate {
    private let rescueStore = ShieldRescueStore()
    private let managedSettingsStore = ManagedSettingsStore()

    override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        handle(action: action, completionHandler: completionHandler)
    }

    private func handle(
        action: ShieldAction,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            rescueStore.recordBypassAttempt(action: .primaryPressed)
            completionHandler(.close)
        case .secondaryButtonPressed:
            respondToSecondaryAction(completionHandler: completionHandler)
        @unknown default:
            rescueStore.recordBypassAttempt(action: .primaryPressed)
            completionHandler(.close)
        }
    }

    private func respondToSecondaryAction(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        let state = rescueStore.loadState()

        switch state.mode {
        case .soft:
            rescueStore.recordEmergencyUnlock()
            clearActiveShield()
            completionHandler(.close)
        case .hard:
            rescueStore.recordBypassAttempt(action: .secondaryPressed)
            completionHandler(.defer)
        }
    }

    private func clearActiveShield() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        managedSettingsStore.shield.webDomains = nil
    }
}
#endif
