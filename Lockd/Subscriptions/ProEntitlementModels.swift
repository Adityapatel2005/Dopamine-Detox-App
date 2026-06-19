import Foundation

enum LockdProEntitlement: Equatable {
    case free
    case pro(expirationDate: Date?)

    var unlocksPredictiveProtection: Bool {
        self == .free ? false : true
    }

    var unlocksAdvancedInsights: Bool {
        self == .free ? false : true
    }

    var displayName: String {
        switch self {
        case .free:
            return "Free"
        case .pro:
            return "Lockd Pro"
        }
    }
}

struct LockdSubscriptionPlan: Identifiable, Equatable {
    let id: String
    let title: String
    let displayPrice: String
    let subtitle: String
    let isBestValue: Bool
}

enum StoreKitPurchaseState: Equatable {
    case idle
    case loading
    case purchased
    case pending
    case cancelled
    case failed(String)
    case unavailable
}
