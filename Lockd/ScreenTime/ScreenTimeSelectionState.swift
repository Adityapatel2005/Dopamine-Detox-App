import Foundation

struct ScreenTimeSelectionState: Codable, Equatable {
    var applicationCount: Int
    var categoryCount: Int
    var webDomainCount: Int
    var selectedAppSummary: [String]

    static let empty = ScreenTimeSelectionState(
        applicationCount: 0,
        categoryCount: 0,
        webDomainCount: 0,
        selectedAppSummary: []
    )

    var isEmpty: Bool {
        applicationCount == 0 && categoryCount == 0 && webDomainCount == 0
    }

    var totalSelectionCount: Int {
        applicationCount + categoryCount + webDomainCount
    }
}
