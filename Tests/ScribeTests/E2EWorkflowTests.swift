import XCTest
@testable import Scribe

/// End-to-end integration tests for complete user workflows
final class E2EWorkflowTests: XCTestCase {
    
    // MARK: - Complete Note Workflow
    
    @MainActor
    func testCompleteNoteWorkflow() async throws {
        // Setup
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Wait for initial data load
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let initialNoteCount = appState.notes.count
        
        // 1. Create a new note
        await appState.createNewNote()
        XCTAssertEqual(appState.notes.count, initialNoteCount + 1)
        XCTAssertNotNil(appState.selectedNoteId)
        
        // 2. Get the new note
        guard let noteId = appState.selectedNoteId,
              var note = appState.notes.first(where: { $0.id == noteId }) else {
            XCTFail("Could not find created note")
            return
        }
        
        // 3. Update the note
        note.title = "E2E Test Note"
        note.content = "This is an end-to-end test note with some content."
        note.wordCount = 11
        appState.saveNote(note)
        
        // Wait for save
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 4. Verify update persisted in state
        if let updatedNote = appState.notes.first(where: { $0.id == noteId }) {
            XCTAssertEqual(updatedNote.title, "E2E Test Note")
            XCTAssertEqual(updatedNote.wordCount, 11)
        }
        
        // 5. Delete the note
        await appState.deleteNote(noteId)
        XCTAssertEqual(appState.notes.count, initialNoteCount)
        XCTAssertNil(appState.notes.first { $0.id == noteId })
    }
    
    // MARK: - Project Workflow
    
    @MainActor
    func testCompleteProjectWorkflow() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Wait for initial data load
        try await Task.sleep(nanoseconds: 500_000_000)
        
        let initialProjectCount = appState.projects.count
        
        // 1. Create a project
        await appState.createProject(name: "E2E Test Project", type: .research)
        XCTAssertEqual(appState.projects.count, initialProjectCount + 1)
        
        guard let project = appState.projects.first(where: { $0.name == "E2E Test Project" }) else {
            XCTFail("Could not find created project")
            return
        }
        
        XCTAssertEqual(project.type, .research)
        
        // 2. Delete the project
        await appState.deleteProject(project.id)
        XCTAssertEqual(appState.projects.count, initialProjectCount)
    }
    
    // MARK: - Sidebar Toggle Workflow
    
    @MainActor
    func testSidebarToggleWorkflow() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Initial state
        XCTAssertFalse(appState.showSidebar)
        XCTAssertFalse(appState.showRightSidebar)
        
        // Toggle left sidebar
        appState.showSidebar.toggle()
        XCTAssertTrue(appState.showSidebar)
        XCTAssertFalse(appState.showRightSidebar)
        
        // Toggle right sidebar
        appState.showRightSidebar.toggle()
        XCTAssertTrue(appState.showSidebar)
        XCTAssertTrue(appState.showRightSidebar)
        
        // Toggle both off
        appState.showSidebar.toggle()
        appState.showRightSidebar.toggle()
        XCTAssertFalse(appState.showSidebar)
        XCTAssertFalse(appState.showRightSidebar)
    }
    
    // MARK: - Writing Stats Workflow
    
    @MainActor
    func testWritingStatsWorkflow() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Wait for initial data load
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 1. Create a note
        await appState.createNewNote()
        guard let noteId = appState.selectedNoteId,
              var note = appState.notes.first(where: { $0.id == noteId }) else {
            XCTFail("Could not find note")
            return
        }
        
        let initialTodayWords = appState.writingStats.todayWordCount
        
        // 2. Write some content
        note.content = "word1 word2 word3 word4 word5"
        note.wordCount = 5
        appState.saveNote(note)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // 3. Verify writing stats updated
        XCTAssertGreaterThan(appState.writingStats.todayWordCount, initialTodayWords)
        
        // 4. Cleanup
        await appState.deleteNote(noteId)
    }
    
    // MARK: - Error Dialog Workflow
    
    @MainActor
    func testErrorDialogWorkflow() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Initial state
        XCTAssertFalse(appState.showErrorDialog)
        
        // Show error
        appState.showError(title: "Test Error", message: "This is a test error message")
        
        XCTAssertTrue(appState.showErrorDialog)
        XCTAssertEqual(appState.errorTitle, "Test Error")
        XCTAssertEqual(appState.errorMessage, "This is a test error message")
        XCTAssertEqual(appState.errorLevel, .error)
        
        // Show warning
        appState.showErrorDialog = false
        appState.showError(title: "Test Warning", message: "This is a warning", level: .warning)
        
        XCTAssertTrue(appState.showErrorDialog)
        XCTAssertEqual(appState.errorLevel, .warning)
        
        // Dismiss
        appState.showErrorDialog = false
        XCTAssertFalse(appState.showErrorDialog)
    }
    
    // MARK: - Inbox Project Workflow
    
    @MainActor
    func testInboxProjectCreation() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Wait for data load and inbox creation
        try await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Verify Inbox exists
        let inboxProject = appState.projects.first { $0.name == "Inbox" }
        XCTAssertNotNil(inboxProject, "Inbox project should be auto-created")
    }
}
