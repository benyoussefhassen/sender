import XCTest
@testable import SenderProMac

@MainActor
final class SenderProMacTests: XCTestCase {

    func testFullEndToEndIntegrationSuite() async {
        setenv("SENDERPRO_HEADLESS_TEST", "1", 1)
        let exitCode = await SenderProMacApp.runRealEndToEndIntegrationSuite()
        XCTAssertEqual(exitCode, 0, "All 11 real functional and integration test suites must pass with 0 failures")
    }
}
