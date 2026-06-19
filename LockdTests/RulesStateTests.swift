import XCTest
@testable import Lockd

@MainActor
final class RulesStateTests: XCTestCase {
    func testChoosingAppAddsItToSelection() {
        let viewModel = RulesViewModel(screenTimeController: MockScreenTimeController())
        let app = DistractingApp(name: "TikTok", symbolName: "music.note")

        viewModel.chooseApp(app)

        XCTAssertEqual(viewModel.selectedApps, [app])
    }

    func testPredictiveProtectionRequiresProWhenEntitlementIsProRequired() {
        let viewModel = RulesViewModel(screenTimeController: MockScreenTimeController(entitlementState: .proRequired))

        viewModel.enablePredictiveProtection()

        XCTAssertFalse(viewModel.isPredictiveProtectionEnabled)
        XCTAssertEqual(viewModel.entitlementState, .proRequired)
    }
}
