import XCTest
@testable import Scribe

/// Unit tests for NoteService
final class NoteServiceTests: XCTestCase {
    
    var noteService: NoteService!
    
    @MainActor
    override func setUp() async throws {
        noteService = NoteService(database: DatabaseManager.shared)
    }
    
    // MARK: - Create Tests
    
    @MainActor
    func testCreateNote() async throws {
        let note = try await noteService.create(
            title: "Test Note",
            content: "Test content"
        )
        
        XCTAssertEqual(note.title, "Test Note")
        XCTAssertEqual(note.content, "Test content")
        XCTAssertFalse(note.id.isEmpty)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testCreateNoteWithDefaultTitle() async throws {
        let note = try await noteService.create(title: "", content: "")
        
        // Title should be empty as passed, not defaulted in create
        XCTAssertEqual(note.title, "")
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testCreateNoteWithProject() async throws {
        let projectService = ProjectService(database: DatabaseManager.shared)
        let project = try await projectService.create(name: "Test Project", type: .research)
        
        let note = try await noteService.create(
            title: "Project Note",
            content: "Content",
            projectId: project.id
        )
        
        XCTAssertEqual(note.projectId, project.id)
        
        // Cleanup
        try await noteService.delete(id: note.id)
        try await projectService.delete(id: project.id)
    }
    
    // MARK: - Fetch Tests
    
    @MainActor
    func testFetchNote() async throws {
        let created = try await noteService.create(title: "Fetch Test", content: "Content")
        
        let fetched = try await noteService.fetch(id: created.id)
        
        XCTAssertEqual(fetched.id, created.id)
        XCTAssertEqual(fetched.title, "Fetch Test")
        
        // Cleanup
        try await noteService.delete(id: created.id)
    }
    
    @MainActor
    func testFetchNonExistentNote() async {
        do {
            _ = try await noteService.fetch(id: "non-existent-id")
            XCTFail("Should throw noteNotFound error")
        } catch let error as ScribeError {
            if case .noteNotFound = error {
                // Expected
            } else {
                XCTFail("Expected noteNotFound error, got \(error)")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    @MainActor
    func testFetchAllNotes() async throws {
        let note1 = try await noteService.create(title: "Note 1", content: "")
        let note2 = try await noteService.create(title: "Note 2", content: "")
        
        let notes = try await noteService.fetchAll()
        
        XCTAssertGreaterThanOrEqual(notes.count, 2)
        
        // Cleanup
        try await noteService.delete(id: note1.id)
        try await noteService.delete(id: note2.id)
    }
    
    @MainActor
    func testFetchNotesWithLimit() async throws {
        let note1 = try await noteService.create(title: "Limit 1", content: "")
        let note2 = try await noteService.create(title: "Limit 2", content: "")
        let note3 = try await noteService.create(title: "Limit 3", content: "")
        
        let notes = try await noteService.fetchAll(limit: 2)
        
        XCTAssertEqual(notes.count, 2)
        
        // Cleanup
        try await noteService.delete(id: note1.id)
        try await noteService.delete(id: note2.id)
        try await noteService.delete(id: note3.id)
    }
    
    // MARK: - Update Tests
    
    @MainActor
    func testSaveNote() async throws {
        var note = try await noteService.create(title: "Original", content: "")
        note.title = "Updated"
        note.content = "New content"
        
        try await noteService.save(note)
        
        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.title, "Updated")
        XCTAssertEqual(fetched.content, "New content")
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testWordCountUpdatedOnSave() async throws {
        var note = try await noteService.create(title: "Word Count Test", content: "")
        note.content = "one two three four five"
        
        try await noteService.save(note)
        
        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.wordCount, 5)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    // MARK: - Search Tests
    
    @MainActor
    func testSearchNotes() async throws {
        let note = try await noteService.create(
            title: "Searchable Note",
            content: "This contains unique7391 keyword"
        )
        
        // Small delay for FTS indexing
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let results = try await noteService.search(query: "unique7391")
        
        XCTAssertGreaterThanOrEqual(results.count, 1)
        XCTAssertTrue(results.contains { $0.id == note.id })
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testSearchEmptyQuery() async throws {
        let results = try await noteService.search(query: "")
        XCTAssertTrue(results.isEmpty)
    }
    
    @MainActor
    func testSearchWhitespaceQuery() async throws {
        let results = try await noteService.search(query: "   ")
        XCTAssertTrue(results.isEmpty)
    }
    
    // MARK: - Daily Note Tests
    
    @MainActor
    func testCreateDailyNote() async throws {
        let dailyNote = try await noteService.createDailyNote()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let expectedTitle = formatter.string(from: Date())
        
        XCTAssertEqual(dailyNote.title, expectedTitle)
        XCTAssertTrue(dailyNote.content.contains("## Notes"))
        
        // Cleanup
        try await noteService.delete(id: dailyNote.id)
    }
    
    @MainActor
    func testCreateDailyNoteIdempotent() async throws {
        let first = try await noteService.createDailyNote()
        let second = try await noteService.createDailyNote()
        
        XCTAssertEqual(first.id, second.id, "Should return existing daily note")
        
        // Cleanup
        try await noteService.delete(id: first.id)
    }
}
