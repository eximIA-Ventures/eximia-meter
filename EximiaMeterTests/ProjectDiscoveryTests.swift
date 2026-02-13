import XCTest
@testable import EximiaMeter

final class ProjectDiscoveryTests: XCTestCase {
    func testDecodePath() {
        // Test basic path decoding
        let encoded = "-Users-hugocapitelli-Dev-project"
        let decoded = ProjectDiscoveryService.decodePath(encoded)

        // Should start with /Users
        XCTAssertTrue(decoded.hasPrefix("/Users"))
    }

    func testExtractProjectNameFromPath() {
        let path = "/Users/hugocapitelli/Dev/eximia/ex-mIA-Academy"
        let url = URL(fileURLWithPath: path)
        XCTAssertEqual(url.lastPathComponent, "ex-mIA-Academy")
    }
}
