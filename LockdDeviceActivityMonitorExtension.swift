import Foundation

#if canImport(DeviceActivity) && canImport(FamilyControls) && canImport(ManagedSettings)
import DeviceActivity
import FamilyControls
import ManagedSettings

final class LockdDeviceActivityMonitorExtension: DeviceActivityMonitor {
    private let selectionStore = FamilyActivitySelectionStore()
    private let managedSettingsStore = ManagedSettingsStore()

    override func intervalDidStart(for activity: DeviceActivityName) {
        guard activity == .lockdActiveSession else { return }
        applyCurrentShield()
    }

    override func intervalDidEnd(for activity: DeviceActivityName) {
        guard activity == .lockdActiveSession else { return }
        clearCurrentShield()
    }

    private func applyCurrentShield() {
        let selection = selectionStore.loadSelection()
        managedSettingsStore.shield.applications = selection.applicationTokens
        managedSettingsStore.shield.applicationCategories = .specific(selection.categoryTokens)
        managedSettingsStore.shield.webDomains = selection.webDomainTokens
    }

    private func clearCurrentShield() {
        managedSettingsStore.shield.applications = nil
        managedSettingsStore.shield.applicationCategories = nil
        managedSettingsStore.shield.webDomains = nil
    }
}
#endif
