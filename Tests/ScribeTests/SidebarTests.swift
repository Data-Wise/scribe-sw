import XCTest
@testable import Scribe

/// Tests for sidebar components and note selection
final class SidebarTests: XCTestCase {
    
    // MARK: - Note Selection Tests
    
    @MainActor
    func testSelectNoteFromSidebar() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Wait for data load
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Create two notes
        await appState.createNewNote()
        let firstNoteId = appState.selectedNoteId
        
        await appState.createNewNote()
        let secondNoteId = appState.selectedNoteId
        
        XCTAssertNotNil(firstNoteId)
        XCTAssertNotNil(secondNoteId)
        XCTAssertNotEqual(firstNoteId, secondNoteId)
        
        // Select first note
        appState.selectedNoteId = firstNoteId
        XCTAssertEqual(appState.selectedNoteId, firstNoteId)
        
        // Select second note
        appState.selectedNoteId = secondNoteId
        XCTAssertEqual(appState.selectedNoteId, secondNoteId)
        
        // Cleanup
        if let id = firstNoteId { await appState.deleteNote(id) }
        if let id = secondNoteId { await appState.deleteNote(id) }
    }
    
    @MainActor
    func testProjectFiltering() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Wait for data load
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Initial state - no project filter
        XCTAssertNil(appState.selectedProjectId)
        
        // Set project filter
        if let firstProject = appState.projects.first {
            appState.selectedProjectId = firstProject.id
            XCTAssertEqual(appState.selectedProjectId, firstProject.id)
        }
        
        // Clear filter
        appState.selectedProjectId = nil
        XCTAssertNil(appState.selectedProjectId)
    }
    
    @MainActor
    func testSidebarVisibilityToggle() async {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        // Both sidebars initially hidden
        XCTAssertFalse(appState.showSidebar)
        XCTAssertFalse(appState.showRightSidebar)
        
        // Toggle left
        appState.showSidebar = true
        XCTAssertTrue(appState.showSidebar)
        
        // Toggle right
        appState.showRightSidebar = true
        XCTAssertTrue(appState.showRightSidebar)
        
        // Both can be open simultaneously
        XCTAssertTrue(appState.showSidebar && appState.showRightSidebar)
    }
    
    // MARK: - Note Row Tests
    
    func testNotePreviewForEmptyContent() {
        let note = Note(title: "Empty", content: "")
        XCTAssertEqual(note.preview, "")
    }
    
    func testNotePreviewTruncation() {
        let longContent = String(repeating: "word ", count: 100)
        let note = Note(title: "Long", content: longContent)
        XCTAssertLessThanOrEqual(note.preview.count, 200)
    }
    
    // MARK: - Outline Extraction Tests
    
    func testHeadingExtraction() {
        let content = """
        # Heading 1
        Some content
        ## Heading 2
        More content
        ### Heading 3
        """
        
        let headings = extractHeadings(from: content)
        
        XCTAssertEqual(headings.count, 3)
        XCTAssertEqual(headings[0].level, 1)
        XCTAssertEqual(headings[0].text, "Heading 1")
        XCTAssertEqual(headings[1].level, 2)
        XCTAssertEqual(headings[2].level, 3)
    }
    
    func testNoHeadings() {
        let content = "Just some text without any headings"
        let headings = extractHeadings(from: content)
        XCTAssertTrue(headings.isEmpty)
    }
    
    // MARK: - Backlinks Tests
    
    @MainActor
    func testFindBacklinks() async throws {
        let appState = AppState(
            noteService: NoteService(database: DatabaseManager.shared),
            projectService: ProjectService(database: DatabaseManager.shared)
        )
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Create target note
        await appState.createNewNote()
        guard let targetId = appState.selectedNoteId,
              var targetNote = appState.notes.first(where: { $0.id == targetId }) else {
            XCTFail("Could not create target note")
            return
        }
        targetNote.title = "Target Note"
        appState.saveNote(targetNote)
        
        // Create linking note
        await appState.createNewNote()
        guard let linkingId = appState.selectedNoteId,
              var linkingNote = appState.notes.first(where: { $0.id == linkingId }) else {
            XCTFail("Could not create linking note")
            return
        }
        linkingNote.content = "This links to [[Target Note]]"
        appState.saveNote(linkingNote)
        
        try await Task.sleep(nanoseconds: 500_000_000)
        
        // Find backlinks
        let backlinks = appState.notes.filter { note in
            note.id != targetId && note.content.contains("[[Target Note]]")
        }
        
        XCTAssertGreaterThanOrEqual(backlinks.count, 1)
        
        // Cleanup
        await appState.deleteNote(targetId)
        await appState.deleteNote(linkingId)
    }
    
    // MARK: - Helpers
    
    private struct HeadingItem {
        let level: Int
        let text: String
    }
    
    private func extractHeadings(from content: String) -> [HeadingItem] {
        let lines = content.components(separatedBy: "\n")
        var headings: [HeadingItem] = []
        
        for line in lines {
            if line.hasPrefix("# ") {
                headings.append(HeadingItem(level: 1, text: String(line.dropFirst(2))))
            } else if line.hasPrefix("## ") {
                headings.append(HeadingItem(level: 2, text: String(line.dropFirst(3))))
            } else if line.hasPrefix("### ") {
                headings.append(HeadingItem(level: 3, text: String(line.dropFirst(4))))
            }
        }
        
        return headings
    }
}
