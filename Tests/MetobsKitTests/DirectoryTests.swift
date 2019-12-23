@testable import MetobsKit
import XCTest

final class DirectoryTests: XCTestCase {
    func testCodable() {
        let value: Directory = .mock

        do {
            // Attempt to encode
            let encoded = try value.encoded()

            // Attempt to decode
            let decoded: Directory = try encoded.decoded()

            // Make sure no data was lost in the process
            XCTAssertEqual(value.title, decoded.title)
            XCTAssertEqual(value.summary, decoded.summary)
            XCTAssertEqual(value.link.count, decoded.link.count)
            XCTAssertEqual(value.version.count, decoded.version.count)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }

    static var allTests = [
        ("testCodable", testCodable),
    ]
}
