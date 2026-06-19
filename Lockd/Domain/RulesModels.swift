import Foundation

enum GoalPreset: String, CaseIterable, Identifiable {
    case cutBrainRot = "Cut brain rot"
    case study = "Study without folding"
    case sleep = "Sleep without scrolling"
    case monkMode = "Monk Mode challenge"
    case custom = "Custom"

    var id: String { rawValue }
}

enum FrictionLevel: String, CaseIterable, Identifiable {
    case soft = "Soft friction"
    case hard = "Hard block"

    var id: String { rawValue }
}

enum EntitlementState: Equatable {
    case unavailableInBuild
    case permissionMissing
    case available
    case proRequired
}

struct DistractingApp: Identifiable, Equatable {
    let id: UUID
    let name: String
    let symbolName: String

    init(id: UUID = UUID(), name: String, symbolName: String) {
        self.id = id
        self.name = name
        self.symbolName = symbolName
    }
}
