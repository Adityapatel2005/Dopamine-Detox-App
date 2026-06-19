import XCTest
@testable import Lockd

final class ComplianceResourceTests: XCTestCase {
    func testComplianceResourcesCoverRequiredLaunchLinks() {
        let titles = ComplianceResource.allCases.map(\.title)

        XCTAssertTrue(titles.contains("Privacy Policy"))
        XCTAssertTrue(titles.contains("Terms of Service"))
        XCTAssertTrue(titles.contains("Privacy Rights"))
        XCTAssertTrue(titles.contains("Delete Local Data"))
        XCTAssertTrue(titles.contains("Accessibility"))
        XCTAssertTrue(titles.contains("Subscription Terms"))
        XCTAssertTrue(titles.contains("Medical Disclaimer"))
    }

    func testMedicalDisclaimerStatesAppIsNotMedicalAdvice() {
        XCTAssertTrue(ComplianceResource.medicalDisclaimer.subtitle.localizedCaseInsensitiveContains("not medical advice"))
    }

    func testDeleteLocalDataExplainsOnDeviceStorage() {
        XCTAssertTrue(ComplianceResource.deleteLocalData.subtitle.localizedCaseInsensitiveContains("on-device"))
    }
}
