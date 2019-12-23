@testable import MetobsKit
import XCTest

final class ConstantsTests: XCTestCase {
    func testEndpoint() {
        XCTAssertEqual(MetobsKit.endpoint.absoluteString, "https://opendata-download-metobs.smhi.se")
    }

    func testDirectoryPath() {
        XCTAssertEqual(MetobsKit.directoryPath.absoluteString, "https://opendata-download-metobs.smhi.se/api.json")
    }

    func testPreferredType() {
        XCTAssertEqual(MetobsKit.preferredType, "application/json")
    }

    static var allTests = [
        ("testEndpoint", testEndpoint),
        ("testDirectoryPath", testDirectoryPath),
        ("testPreferredType", testPreferredType),
    ]
}
