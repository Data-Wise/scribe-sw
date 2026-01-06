import XCTest
@testable import Scribe

/// Integration tests for the Note model and database operations
final class NoteModelTests: XCTestCase {
    
    // MARK: - Model Creation
    
    func testNoteDefaultValues() {
        let note = Note()
        
        XCTAssertFalse(note.id.isEmpty)
        XCTAssertEqual(note.title, "Untitled")
        XCTAssertEqual(note.content, "")
        XCTAssertNil(note.projectId)
        XCTAssertEqual(note.wordCount, 0)
        XCTAssertNil(note.deletedAt)
    }
    
    func testNoteCustomValues() {
        let note = Note(
            title: "Custom Title",
            content: "Custom content",
            projectId: "project-123",
            wordCount: 42
        )
        
        XCTAssertEqual(note.title, "Custom Title")
        XCTAssertEqual(note.content, "Custom content")
        XCTAssertEqual(note.projectId, "project-123")
        XCTAssertEqual(note.wordCount, 42)
    }
    
    // MARK: - Preview Generation
    
    func testNotePreview() {
        let note = Note(content: "This is a long content that should be truncated for the preview. It contains multiple sentences and should only show the first 200 characters.")
        
        let preview = note.preview
        
        XCTAssertLessThanOrEqual(preview.count, 200)
        XCTAssertFalse(preview.contains("\n"))
    }
    
    func testNotePreviewEmpty() {
        let note = Note(content: "")
        XCTAssertEqual(note.preview, "")
    }
    
    func testNotePreviewWithNewlines() {
        let note = Note(content: "Line 1\nLine 2\nLine 3")
        let preview = note.preview
        
        XCTAssertFalse(preview.contains("\n"))
        XCTAssertTrue(preview.contains("Line 1"))
        XCTAssertTrue(preview.contains("Line 2"))
    }
    
    // MARK: - Date Helpers
    
    func testUnixTimestamp() {
        let now = Date()
        let timestamp = now.unixTimestamp
        let restored = Date(unixTimestamp: timestamp)
        
        // Should be within 1 second
        XCTAssertEqual(now.timeIntervalSince1970, restored.timeIntervalSince1970, accuracy: 1.0)
    }
    
    // MARK: - Coding Keys
    
    func testNoteCodingKeysMapping() {
        // Verify snake_case mappings are correct
        XCTAssertEqual(Note.CodingKeys.wordCount.rawValue, "word_count")
        XCTAssertEqual(Note.CodingKeys.projectId.rawValue, "project_id")
        XCTAssertEqual(Note.CodingKeys.createdAt.rawValue, "created_at")
        XCTAssertEqual(Note.CodingKeys.updatedAt.rawValue, "updated_at")
        XCTAssertEqual(Note.CodingKeys.deletedAt.rawValue, "deleted_at")
    }
    
    // MARK: - Hashable / Identifiable
    
    func testNoteHashable() {
        let note1 = Note(id: "same-id", title: "Note 1")
        let note2 = Note(id: "same-id", title: "Note 1")
        let note3 = Note(id: "different-id", title: "Note 3")
        
        // Notes with same ID should be equal (Hashable is based on all properties)
        XCTAssertEqual(note1.id, note2.id)
        XCTAssertNotEqual(note1.id, note3.id)
        
        // Test Set behavior with different IDs
        var noteSet = Set<Note>()
        noteSet.insert(note1)
        noteSet.insert(note3)
        XCTAssertEqual(noteSet.count, 2)
    }
    
    func testNoteIdentifiable() {
        let note = Note(id: "test-id-123")
        XCTAssertEqual(note.id, "test-id-123")
    }
    
    // MARK: - Tags
    
    func testTagsEmpty() {
        let note = Note(title: "No tags here", content: "Just plain text")
        XCTAssertEqual(note.tags, [])
    }
    
    func testTagsSingle() {
        let note = Note(title: "Research note", content: "This is about #research")
        XCTAssertEqual(note.tags, ["research"])
    }
    
    func testTagsMultiple() {
        let note = Note(content: "Topics: #research #statistics #causal-inference")
        XCTAssertEqual(note.tags, ["causal-inference", "research", "statistics"])
    }
    
    func testTagsInTitle() {
        let note = Note(title: "#meeting notes", content: "Discussion points")
        XCTAssertEqual(note.tags, ["meeting"])
    }
    
    func testTagsInBothTitleAndContent() {
        let note = Note(title: "#research paper", content: "About #statistics and #causal-inference")
        XCTAssertEqual(note.tags, ["causal-inference", "research", "statistics"])
    }
    
    func testTagsDuplicate() {
        let note = Note(content: "#research is important. More #research needed.")
        XCTAssertEqual(note.tags, ["research"])
    }
    
    func testTagsCaseInsensitive() {
        let note = Note(content: "#Research #RESEARCH #research")
        XCTAssertEqual(note.tags, ["research"])
    }
    
    func testTagsSpecialChars() {
        let note = Note(content: "#test-tag #another_tag #tag123")
        XCTAssertEqual(note.tags, ["another_tag", "tag123", "test-tag"])
    }
}
