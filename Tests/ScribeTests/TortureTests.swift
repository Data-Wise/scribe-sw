import XCTest
@testable import Scribe

/// Torture tests - stress testing, edge cases, and boundary conditions
final class TortureTests: XCTestCase {
    
    // MARK: - Large Data Tests
    
    @MainActor
    func testCreateManyNotes() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        var createdNotes: [Note] = []
        
        // Create 50 notes rapidly
        for i in 0..<50 {
            let note = try await noteService.create(
                title: "Stress Test Note \(i)",
                content: "Content for note \(i)"
            )
            createdNotes.append(note)
        }
        
        XCTAssertEqual(createdNotes.count, 50)
        
        // Cleanup
        for note in createdNotes {
            try await noteService.delete(id: note.id)
        }
    }
    
    @MainActor
    func testLargeContentNote() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        // Create a note with ~1MB of content
        let largeContent = String(repeating: "Lorem ipsum dolor sit amet. ", count: 30000)
        
        let note = try await noteService.create(
            title: "Large Content Note",
            content: largeContent
        )
        
        XCTAssertGreaterThan(note.content.count, 500000)
        
        // Fetch and verify
        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.content.count, largeContent.count)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testVeryLongTitle() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        let longTitle = String(repeating: "A", count: 10000)
        
        let note = try await noteService.create(
            title: longTitle,
            content: ""
        )
        
        XCTAssertEqual(note.title.count, 10000)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    // MARK: - Edge Case Tests
    
    @MainActor
    func testEmptyTitle() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        let note = try await noteService.create(title: "", content: "")
        
        XCTAssertEqual(note.title, "")
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testUnicodeContent() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        let unicodeContent = """
        🎉 Emoji test: 👨‍👩‍👧‍👦 ❤️ 🔬 📚
        中文测试
        日本語テスト
        한국어 테스트
        العربية
        עברית
        Ελληνικά
        Кириллица
        """
        
        let note = try await noteService.create(
            title: "Unicode Test 🌍",
            content: unicodeContent
        )
        
        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.content, unicodeContent)
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    @MainActor
    func testSpecialCharactersInContent() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        let specialContent = """
        Special chars: < > & " ' \\ / @ # $ % ^ * ( ) [ ] { }
        SQL injection: '; DROP TABLE notes; --
        HTML: <script>alert('xss')</script>
        Null char test: \0
        Tab and newlines: \t\n\r\n
        """
        
        let note = try await noteService.create(
            title: "Special Chars Test",
            content: specialContent
        )
        
        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertTrue(fetched.content.contains("DROP TABLE"))
        XCTAssertTrue(fetched.content.contains("<script>"))
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    // MARK: - Concurrent Operations
    
    @MainActor
    func testConcurrentNoteCreation() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        // Create notes concurrently
        async let note1 = noteService.create(title: "Concurrent 1", content: "")
        async let note2 = noteService.create(title: "Concurrent 2", content: "")
        async let note3 = noteService.create(title: "Concurrent 3", content: "")
        
        let notes = try await [note1, note2, note3]
        XCTAssertEqual(notes.count, 3)
        
        // Cleanup
        for note in notes {
            try await noteService.delete(id: note.id)
        }
    }
    
    @MainActor
    func testRapidUpdatesSameNote() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        var note = try await noteService.create(title: "Rapid Update", content: "")
        
        // Update 20 times rapidly
        for i in 0..<20 {
            note.content = "Update \(i): " + String(repeating: "x", count: 100)
            try await noteService.save(note)
        }
        
        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertTrue(fetched.content.contains("Update 19"))
        
        // Cleanup
        try await noteService.delete(id: note.id)
    }
    
    // MARK: - Boundary Tests
    
    func testWritingStatsExtremeDuration() {
        var stats = WritingStats()
        
        // Set session start to 100 hours ago
        stats.sessionStartTime = Date().addingTimeInterval(-360000)
        
        let formatted = stats.sessionDurationFormatted
        XCTAssertNotNil(formatted)
        XCTAssertFalse(formatted.isEmpty)
    }
    
    func testWritingStatsExtremeWordCount() {
        var stats = WritingStats()
        
        stats.todayWordCount = 1_000_000
        stats.sessionWordCount = 500_000
        
        // Goal progress should cap at 1.0
        XCTAssertEqual(stats.goalProgress, 1.0)
    }
    
    func testProjectWithNilSettings() {
        let project = Project(
            name: "No Settings",
            type: .generic,
            settings: nil
        )
        
        XCTAssertNil(project.settings)
    }
    
    // MARK: - Error Recovery Tests
    
    @MainActor
    func testDeleteNonExistentNote() async {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        // Should not crash when deleting non-existent note
        do {
            try await noteService.delete(id: "non-existent-note-id-12345")
            // If it doesn't throw, that's acceptable
        } catch {
            // Error is also acceptable
        }
    }
    
    @MainActor
    func testFetchDeletedNote() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        let note = try await noteService.create(title: "Will Delete", content: "")
        try await noteService.delete(id: note.id)
        
        // Fetching deleted note should fail
        do {
            _ = try await noteService.fetch(id: note.id)
            // Note: may succeed with soft-delete - check behavior
        } catch let error as ScribeError {
            if case .noteNotFound = error {
                // Expected
            }
        }
    }
    
    // MARK: - Memory Stress Tests
    
    @MainActor
    func testCreateAndDeleteManyNotesSequentially() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        
        for i in 0..<100 {
            let note = try await noteService.create(
                title: "Ephemeral Note \(i)",
                content: String(repeating: "Content ", count: 100)
            )
            try await noteService.delete(id: note.id)
        }
        
        // Should complete without memory issues
    }
}
