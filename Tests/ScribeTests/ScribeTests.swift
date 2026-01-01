import XCTest
@testable import Scribe

final class ScribeTests: XCTestCase {

    func testPageWordCount() {
        let page = Page(
            title: "Test",
            content: "Hello world this is a test"
        )
        XCTAssertEqual(page.wordCount, 6)
    }

    func testPagePreview() {
        let page = Page(
            title: "Test",
            content: "First line\nSecond line"
        )
        XCTAssertTrue(page.preview.contains("First line"))
        XCTAssertFalse(page.preview.contains("\n"))
    }

    func testVaultTypes() {
        XCTAssertEqual(VaultType.inbox.displayName, "Inbox")
        XCTAssertEqual(VaultType.research.icon, "magnifyingglass")
    }

    func testPageIsDeleted() {
        var page = Page(title: "Test")
        XCTAssertFalse(page.isDeleted)

        page.deletedAt = Date()
        XCTAssertTrue(page.isDeleted)
    }
}
