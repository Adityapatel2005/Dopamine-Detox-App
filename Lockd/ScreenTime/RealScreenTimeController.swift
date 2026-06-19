import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

#if canImport(ManagedSettings)
import ManagedSettings
#endif

struct RealScreenTimeController: ScreenTimeControlling {
    private let authorizationController: NativeScreenTimeAuthorizationController
    private let selectionStore: FamilyActivitySelectionStore
    private let scheduleController: DeviceActivityScheduleController

    init(
        authorizationController: NativeScreenTimeAuthorizationController = NativeScreenTimeAuthorizationController(),
        selectionStore: FamilyActivitySelectionStore = FamilyActivitySelectionStore(),
        scheduleController: DeviceActivityScheduleController = DeviceActivityScheduleController()
    ) {
        self.authorizationController = authorizationController
        self.selectionStore = selectionStore
        self.scheduleController = scheduleController
    }

    var entitlementState: EntitlementState {
        authorizationController.currentStatus == .approved ? .available : .permissionMissing
    }

    func requestAuthorization() async -> EntitlementState {
        let status = await authorizationController.requestAuthorization()
        return status == .approved ? .available : .permissionMissing
    }

    func applyBlock(to apps: [DistractingApp], durationMinutes: Int) async throws {
        guard entitlementState == .available else {
            throw ScreenTimeControllerError.permissionMissing
        }

        #if canImport(FamilyControls) && canImport(ManagedSettings)
        let selection = selectionStore.loadSelection()
        let selectionState = ScreenTimeSelectionState(selection: selection)
        guard !selectionState.isEmpty else {
            throw ScreenTimeControllerError.noSelection
        }

        applyShield(for: selection)

        do {
            let request = LockdDeviceActivityScheduleRequest(durationMinutes: durationMinutes)
            try scheduleController.startMonitoring(request)
        } catch {
            throw ScreenTimeControllerError.scheduleFailed
        }
        #else
        throw ScreenTimeControllerError.unavailable
        #endif
    }

    func clearActiveBlock() async throws {
        #if canImport(ManagedSettings)
        ManagedSettingsStore().shield.applications = nil
        ManagedSettingsStore().shield.applicationCategories = nil
        ManagedSettingsStore().shield.webDomains = nil
        scheduleController.stopMonitoring()
        #else
        throw ScreenTimeControllerError.unavailable
        #endif
    }

    #if canImport(FamilyControls) && canImport(ManagedSettings)
    private func applyShield(for selection: FamilyActivitySelection) {
        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
    }
    #endif
}
