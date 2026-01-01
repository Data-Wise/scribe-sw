import XCTest
@testable import Scribe

final class ScribeTests: XCTestCase {

    func testNoteWordCount() {
        let note = Note(
            title: "Test",
            content: "Hello world this is a test"
        )
        XCTAssertEqual(note.wordCount, 6)
    }

    func testNotePreview() {
        let note = Note(
            title: "Test",
            content: "First line\nSecond line"
        )
        XCTAssertTrue(note.preview.contains("First line"))
        XCTAssertFalse(note.preview.contains("\n"))
    }

    func testProjectTypes() {
        XCTAssertEqual(ProjectType.generic.displayName, "Generic")
        XCTAssertEqual(ProjectType.research.systemImage, "magnifyingglass")
    }

    func testNoteIsDeleted() {
        var note = Note(title: "Test")
        XCTAssertFalse(note.deletedAt != nil)

        note.deletedAt = Date().unixTimestamp
        XCTAssertTrue(note.deletedAt != nil)
    }
}
