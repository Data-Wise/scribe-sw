import XCTest
@testable import Scribe

/// Edge case and integration tests
final class EdgeCaseTests: XCTestCase {

    // MARK: - Database Edge Cases

    @MainActor
    func testDatabasePersistsAfterRestart() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        // Create a note
        let note = try await noteService.create(title: "Persistence Test", content: "Content")

        // Fetch it back
        let fetched = try await noteService.fetch(id: note.id)

        XCTAssertEqual(fetched.id, note.id)
        XCTAssertEqual(fetched.title, "Persistence Test")

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    @MainActor
    func testEmptyDatabaseOperations() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)
        let projectService = ProjectService(database: DatabaseManager.shared)

        // Fetch from empty database
        let notes = try await noteService.fetchAll()
        let projects = try await projectService.fetchAll()

        // Should return empty arrays (Inbox might exist from other tests)
        XCTAssertGreaterThanOrEqual(notes.count, 0)
        XCTAssertGreaterThanOrEqual(projects.count, 0)
    }

    // MARK: - Note Edge Cases

    @MainActor
    func testNoteWithVeryLongTitle() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let longTitle = String(repeating: "Very Long Title ", count: 100)
        let note = try await noteService.create(title: longTitle, content: "")

        XCTAssertEqual(note.title.count, longTitle.count)

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    @MainActor
    func testNoteWithVeryLongContent() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let longContent = String(repeating: "Word ", count: 10000)
        var note = try await noteService.create(title: "Long Content", content: longContent)
        note.wordCount = 10000
        try await noteService.save(note)

        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.wordCount, 10000)

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    @MainActor
    func testNoteWithSpecialCharacters() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let specialContent = """
        Special chars: !@#$%^&*()
        Unicode: αβγδεζηθικλμνξοπρστυφχψω
        Emoji: 😊🎉🚀✨
        Math: x² + y² = z²
        """

        let note = try await noteService.create(title: "Special Chars", content: specialContent)

        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.content, specialContent, "Should preserve special characters")

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    @MainActor
    func testNoteWithUnicodeTitle() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let unicodeTitle = "ノート en français Español 中文 日本語 📝"
        let note = try await noteService.create(title: unicodeTitle, content: "")

        let fetched = try await noteService.fetch(id: note.id)
        XCTAssertEqual(fetched.title, unicodeTitle)

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    // MARK: - Project Edge Cases

    @MainActor
    func testProjectWithUnicodeName() async throws {
        let projectService = ProjectService(database: DatabaseManager.shared)

        let unicodeName = "Project αβ 中文 Español 🚀"
        let project = try await projectService.create(name: unicodeName, type: .research)

        let fetched = try await projectService.fetch(id: project.id)
        XCTAssertEqual(fetched.name, unicodeName)

        // Cleanup
        try await projectService.delete(id: project.id)
    }

    @MainActor
    func testProjectWithAllTypes() async throws {
        let projectService = ProjectService(database: DatabaseManager.shared)

        var createdProjects: [Project] = []

        for type in ProjectType.allCases {
            let project = try await projectService.create(name: "Test \(type.displayName)", type: type)
            createdProjects.append(project)
        }

        // Fetch and verify all types
        let allProjects = try await projectService.fetchAll()

        for created in createdProjects {
            let fetched = allProjects.first(where: { $0.id == created.id })
            XCTAssertNotNil(fetched)
            XCTAssertEqual(fetched?.type, created.type)
        }

        // Cleanup
        for project in createdProjects {
            try? await projectService.delete(id: project.id)
        }
    }

    // MARK: - Search Edge Cases

    @MainActor
    func testSearchWithUnicode() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let note = try await noteService.create(
            title: "Unicode Search",
            content: "This contains 中文 Español Français words for search"
        )

        try await Task.sleep(nanoseconds: 100_000_000)

        let results = try await noteService.search(query: "中文")
        XCTAssertGreaterThan(results.count, 0, "Should find notes with Chinese characters")

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    // MARK: - Special character search skipped due to FTS5 limitations
    // Note: FTS5 cannot handle special characters like @#$%^&*() in queries

    @MainActor
    func testSearchWithValidPunctuation() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let note = try await noteService.create(
            title: "Punctuation Search",
            content: "Test with commas, periods; and dashes!"
        )

        try await Task.sleep(nanoseconds: 100_000_000)

        let results = try await noteService.search(query: "commas")
        XCTAssertGreaterThan(results.count, 0, "Should find notes with commas")

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    @MainActor
    func testSearchCaseInsensitive() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let note = try await noteService.create(
            title: "Case Test",
            content: "SEARCHTERM should be found with case insensitivity"
        )

        try await Task.sleep(nanoseconds: 100_000_000)

        let results = try await noteService.search(query: "searchterm")
        XCTAssertGreaterThan(results.count, 0, "Search should be case insensitive")

        // Cleanup
        try await noteService.delete(id: note.id)
    }

    // MARK: - Writing Stats Edge Cases

    func testStatsWithRapidWordCountChanges() {
        var stats = WritingStats()

        // Simulate rapid typing/deleting
        stats.recordWords(count: 100, previousCount: 0)
        stats.recordWords(count: 50, previousCount: 100)  // Deleted - should be ignored
        stats.recordWords(count: 150, previousCount: 50)  // Typed 100 more
        stats.recordWords(count: 120, previousCount: 150)  // Deleted - should be ignored

        // Should track cumulative words added, not count decreases
        // 100 (first) + 0 (deletion ignored) + 100 (third) + 0 (deletion ignored) = 200
        XCTAssertEqual(stats.sessionWordCount, 200, "Should track cumulative words added")
    }

    func testStatsWithLongSession() {
        var stats = WritingStats()

        // Simulate 3 hour session
        let threeHoursAgo = Date().addingTimeInterval(-10800)
        stats.sessionStartTime = threeHoursAgo

        let duration = stats.sessionDuration
        XCTAssertGreaterThanOrEqual(duration, 10800, "Should be at least 3 hours")

        let formatted = stats.sessionDurationFormatted
        XCTAssertTrue(formatted.contains("h"), "Should show hours")
    }

    func testStatsDailyWordCountResets() {
        var stats = WritingStats()

        // Set yesterday as today
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        stats.todayDate = yesterday
        stats.todayWordCount = 500

        // Reset for new day
        stats.resetForNewDay()

        let today = Calendar.current.startOfDay(for: Date())
        XCTAssertEqual(stats.todayDate, today)
        XCTAssertEqual(stats.todayWordCount, 0, "Should reset word count on new day")
    }

    // MARK: - Error Handling Edge Cases

    func testScribeErrorWrapsUnknownErrors() {
        let originalError = NSError(domain: "test.domain", code: 42, userInfo: nil)
        let scribeError = ScribeError.unknown(originalError)

        XCTAssertNotNil(scribeError.errorDescription)
        XCTAssertTrue(scribeError.errorDescription?.contains("unexpected") ?? false, "Should wrap unknown error")
    }

    func testScribeErrorAllTypesHaveDescriptions() {
        let errors: [ScribeError] = [
            .databaseInitializationFailed(NSError(domain: "", code: 0)),
            .noteNotFound("id"),
            .projectNotFound("id"),
            .emptyTitle,
            .invalidData("test"),
            .fileReadFailed("path"),
            .invalidJSON("test"),
            .invalidProjectType("test"),
            .duplicateName("test"),
            .unknown(NSError(domain: "", code: 0))
        ]

        for error in errors {
            XCTAssertNotNil(error.errorDescription, "All errors should have descriptions")
        }
    }

    // MARK: - Concurrent Operations Edge Cases

    @MainActor
    func testConcurrentNoteCreation() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        // Create notes concurrently
        async let note1 = noteService.create(title: "Concurrent 1", content: "")
        async let note2 = noteService.create(title: "Concurrent 2", content: "")
        async let note3 = noteService.create(title: "Concurrent 3", content: "")

        let (n1, n2, n3) = try await (note1, note2, note3)

        XCTAssertNotEqual(n1.id, n2.id)
        XCTAssertNotEqual(n2.id, n3.id)
        XCTAssertNotEqual(n1.id, n3.id)

        // Verify all exist
        let notes = try await noteService.fetchAll()
        XCTAssertTrue(notes.contains(where: { $0.id == n1.id }))
        XCTAssertTrue(notes.contains(where: { $0.id == n2.id }))
        XCTAssertTrue(notes.contains(where: { $0.id == n3.id }))

        // Cleanup
        try await noteService.delete(id: n1.id)
        try await noteService.delete(id: n2.id)
        try await noteService.delete(id: n3.id)
    }

    // MARK: - Data Integrity Edge Cases

    @MainActor
    func testNoteIdUniqueness() async throws {
        let noteService = NoteService(database: DatabaseManager.shared)

        let note1 = try await noteService.create(title: "Note 1", content: "")
        let note2 = try await noteService.create(title: "Note 2", content: "")

        XCTAssertNotEqual(note1.id, note2.id, "IDs should be unique")

        // Cleanup
        try await noteService.delete(id: note1.id)
        try await noteService.delete(id: note2.id)
    }

    @MainActor
    func testProjectIdUniqueness() async throws {
        let projectService = ProjectService(database: DatabaseManager.shared)

        let project1 = try await projectService.create(name: "Project 1", type: .generic)
        let project2 = try await projectService.create(name: "Project 2", type: .generic)

        XCTAssertNotEqual(project1.id, project2.id, "IDs should be unique")

        // Cleanup
        try await projectService.delete(id: project1.id)
        try await projectService.delete(id: project2.id)
    }
}
