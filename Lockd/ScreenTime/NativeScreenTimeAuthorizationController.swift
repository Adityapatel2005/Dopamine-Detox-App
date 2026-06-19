import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

struct NativeScreenTimeAuthorizationController {
    var currentStatus: LockdPermissionStatus {
        #if canImport(FamilyControls)
        return AuthorizationCenter.shared.authorizationStatus.lockdStatus
        #else
        return .unavailable
        #endif
    }

    func requestAuthorization() async -> LockdPermissionStatus {
        #if canImport(FamilyControls)
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            return AuthorizationCenter.shared.authorizationStatus.lockdStatus
        } catch {
            return .denied
        }
        #else
        return .unavailable
        #endif
    }
}

#if canImport(FamilyControls)
private extension AuthorizationStatus {
    var lockdStatus: LockdPermissionStatus {
        switch self {
        case .notDetermined:
            return .notDetermined
        case .denied:
            return .denied
        case .approved:
            return .approved
        @unknown default:
            return .unknown
        }
    }
}
#endif
