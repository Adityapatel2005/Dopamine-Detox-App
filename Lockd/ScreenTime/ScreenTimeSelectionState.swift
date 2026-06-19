import Foundation

#if canImport(FamilyControls)
import FamilyControls
#endif

struct ScreenTimeSelectionState: Codable, Equatable {
    var applicationCount: Int
    var categoryCount: Int
    var webDomainCount: Int
    var selectedAppSummary: [String]

    init(
        applicationCount: Int,
        categoryCount: Int,
        webDomainCount: Int,
        selectedAppSummary: [String]
    ) {
        self.applicationCount = applicationCount
        self.categoryCount = categoryCount
        self.webDomainCount = webDomainCount
        self.selectedAppSummary = selectedAppSummary
    }

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

    #if canImport(FamilyControls)
    init(selection: FamilyActivitySelection, selectedAppSummary: [String] = []) {
        self.applicationCount = selection.applicationTokens.count
        self.categoryCount = selection.categoryTokens.count
        self.webDomainCount = selection.webDomainTokens.count
        self.selectedAppSummary = selectedAppSummary
    }
    #endif
}
