import XCTest
@testable import Scribe

/// Integration tests for DatabaseManager
final class DatabaseManagerTests: XCTestCase {
    
    // MARK: - Initialization
    
    func testDatabaseManagerSingleton() async {
        let db1 = DatabaseManager.shared
        let db2 = DatabaseManager.shared
        
        // Should be same instance
        XCTAssertTrue(db1 === db2)
    }
    
    // MARK: - Note Operations
    
    func testSaveAndFetchNote() async throws {
        let db = DatabaseManager.shared
        
        let note = Note(title: "DB Test", content: "Testing database")
        try await db.saveNote(note)
        
        let fetched = try await db.fetchNote(id: note.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.title, "DB Test")
        
        // Cleanup
        try await db.deleteNote(id: note.id)
    }
    
    func testUpdateNote() async throws {
        let db = DatabaseManager.shared
        
        var note = Note(title: "Original", content: "")
        try await db.saveNote(note)
        
        note.title = "Updated"
        try await db.saveNote(note)
        
        let fetched = try await db.fetchNote(id: note.id)
        XCTAssertEqual(fetched?.title, "Updated")
        
        // Cleanup
        try await db.deleteNote(id: note.id)
    }
    
    func testDeleteNote() async throws {
        let db = DatabaseManager.shared
        
        let note = Note(title: "To Delete", content: "")
        try await db.saveNote(note)
        
        try await db.deleteNote(id: note.id)
        
        // Soft delete - note still exists but marked
        let fetched = try await db.fetchNote(id: note.id)
        XCTAssertNotNil(fetched?.deletedAt)
    }
    
    func testFetchAllNotes() async throws {
        let db = DatabaseManager.shared
        
        let note1 = Note(title: "All 1", content: "")
        let note2 = Note(title: "All 2", content: "")
        
        try await db.saveNote(note1)
        try await db.saveNote(note2)
        
        let notes = try await db.fetchNotes()
        XCTAssertGreaterThanOrEqual(notes.count, 2)
        
        // Cleanup
        try await db.deleteNote(id: note1.id)
        try await db.deleteNote(id: note2.id)
    }
    
    func testFetchNotesWithLimit() async throws {
        let db = DatabaseManager.shared
        
        let note1 = Note(title: "Limit 1", content: "")
        let note2 = Note(title: "Limit 2", content: "")
        let note3 = Note(title: "Limit 3", content: "")
        
        try await db.saveNote(note1)
        try await db.saveNote(note2)
        try await db.saveNote(note3)
        
        let notes = try await db.fetchNotes(limit: 2)
        XCTAssertEqual(notes.count, 2)
        
        // Cleanup
        try await db.deleteNote(id: note1.id)
        try await db.deleteNote(id: note2.id)
        try await db.deleteNote(id: note3.id)
    }
    
    // MARK: - Project Operations
    
    func testSaveAndFetchProject() async throws {
        let db = DatabaseManager.shared
        
        let project = Project(name: "DB Project Test", type: .research)
        try await db.saveProject(project)
        
        let fetched = try await db.fetchProject(id: project.id)
        XCTAssertNotNil(fetched)
        XCTAssertEqual(fetched?.name, "DB Project Test")
        XCTAssertEqual(fetched?.type, .research)
        
        // Cleanup
        try await db.deleteProject(id: project.id)
    }
    
    func testProjectNoteAssociation() async throws {
        let db = DatabaseManager.shared
        
        let project = Project(name: "Parent Project", type: .generic)
        try await db.saveProject(project)
        
        let note = Note(title: "Child Note", projectId: project.id)
        try await db.saveNote(note)
        
        let notes = try await db.fetchNotes(projectId: project.id)
        XCTAssertEqual(notes.count, 1)
        XCTAssertEqual(notes.first?.id, note.id)
        
        // Cleanup
        try await db.deleteNote(id: note.id)
        try await db.deleteProject(id: project.id)
    }
    
    // MARK: - Search Tests
    
    func testFullTextSearch() async throws {
        let db = DatabaseManager.shared
        
        let note = Note(
            title: "FTS Test",
            content: "This contains xyzzy123abc unique keyword"
        )
        try await db.saveNote(note)
        
        // Wait for FTS trigger
        try await Task.sleep(nanoseconds: 100_000_000)
        
        let results = try await db.searchNotes(query: "xyzzy123abc")
        XCTAssertGreaterThanOrEqual(results.count, 1)
        
        // Cleanup
        try await db.deleteNote(id: note.id)
    }
    
    // MARK: - Statistics
    
    func testNoteCount() async throws {
        let db = DatabaseManager.shared
        
        let initialCount = try await db.noteCount()
        
        let note = Note(title: "Count Test", content: "")
        try await db.saveNote(note)
        
        let newCount = try await db.noteCount()
        XCTAssertEqual(newCount, initialCount + 1)
        
        // Cleanup
        try await db.deleteNote(id: note.id)
    }
    
    func testTotalWordCount() async throws {
        let db = DatabaseManager.shared
        
        let initialCount = try await db.totalWordCount()
        
        let note = Note(title: "Words", content: "", wordCount: 100)
        try await db.saveNote(note)
        
        let newCount = try await db.totalWordCount()
        XCTAssertEqual(newCount, initialCount + 100)
        
        // Cleanup
        try await db.deleteNote(id: note.id)
    }
}
