import Foundation

enum RiskLevel: String, Equatable {
    case learning
    case low
    case medium
    case high
}

enum WeakSpotOutcome: Equatable {
    case openedDistractingApp
    case softFrictionIgnored
    case sessionInterrupted
    case sessionCompleted
}

struct WeakSpotSignal: Equatable {
    let hour: Int
    let weekday: Int
    let appName: String
    let outcome: WeakSpotOutcome
}

struct WeakSpotWindow: Equatable {
    let hour: Int
    let riskLevel: RiskLevel
    let explanation: String
}
